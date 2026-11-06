import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/plant_disease_library_sample_data.dart';
import '../models/disease_prediction.dart';
import '../models/plant_disease.dart';

abstract class DiseaseDetectionService {
  const DiseaseDetectionService();

  Future<DiseasePrediction> detectDisease(
    Uint8List imageBytes, {
    String fileName = 'leaf-image.jpg',
  });
}

class TfliteDiseaseDetectionService extends DiseaseDetectionService {
  const TfliteDiseaseDetectionService();

  static const String _modelAssetPath =
      'assets/models/floramind_disease_model.tflite';
  static const String _labelsAssetPath = 'assets/models/disease_labels.txt';
  static const double _lowConfidenceThreshold = 0.60;
  static const int _inputSize = 224;
  static const int _outputClasses = 38;

  static Future<_LoadedDiseaseModel>? _modelLoadFuture;
  static _LoadedDiseaseModel? _cachedModel;

  @override
  Future<DiseasePrediction> detectDisease(
    Uint8List imageBytes, {
    String fileName = 'leaf-image.jpg',
  }) async {
    if (imageBytes.isEmpty) {
      throw DiseaseDetectionServiceException(
        'The selected leaf image is empty. Please choose another photo.',
      );
    }

    final model = await _ensureModelLoaded();
    final input = await _prepareInput(imageBytes);
    final probabilities = _runInference(model.interpreter, input);
    final bestIndex = _argMax(probabilities);
    final confidence = probabilities[bestIndex];
    final isLowConfidence = confidence < _lowConfidenceThreshold;
    final rawDiseaseName = model.labels[bestIndex];
    final diseaseName = isLowConfidence
        ? 'Unknown disease'
        : _displayDiseaseName(rawDiseaseName);
    final details = _findLibraryDisease(rawDiseaseName);

    return DiseasePrediction(
      success: true,
      message: isLowConfidence
          ? 'Low confidence. Try a clear, close-up leaf image.'
          : 'Prediction ready from the FloraMind disease model.',
      diseaseName: diseaseName,
      confidence: confidence,
      symptoms: details?.symptoms ?? const <String>[],
      causes: details?.causes ?? const <String>[],
      treatment: details?.remedies ?? const <String>[],
      prevention: details?.prevention ?? const <String>[],
      pesticideGuidance: isLowConfidence
          ? const <String>[]
          : _pesticideGuidance(rawDiseaseName),
    );
  }

  List<String> _pesticideGuidance(String rawDiseaseName) {
    final name = rawDiseaseName.toLowerCase();
    if (name.contains('healthy')) {
      return const <String>[];
    }

    if (name.contains('spider mite')) {
      return const <String>[
        'Use a locally registered miticide or horticultural oil labelled for this crop.',
        'Thoroughly cover leaf undersides and follow the product label for timing and repeat applications.',
        'Do not mix products unless the label permits it; wear the required protective equipment.',
      ];
    }

    if (name.contains('bacterial') || name.contains('greening')) {
      return const <String>[
        'Pesticides do not cure bacterial diseases. Remove affected material and use only a locally approved copper product when the label specifically allows it.',
        'For citrus greening, contact a local agriculture extension service because infected trees need specialist management.',
        'Follow the product label, harvest interval, and protective-equipment instructions.',
      ];
    }

    if (name.contains('virus') || name.contains('mosaic')) {
      return const <String>[
        'There is no pesticide that cures a plant virus. Remove severely infected plants and control insect vectors only with locally approved products.',
        'Disinfect tools and avoid propagating from infected plants.',
      ];
    }

    return const <String>[
      'Use a locally registered fungicide labelled for this crop and confirmed disease.',
      'Start with the least-toxic option listed on the label and follow the exact dose, timing, and harvest interval.',
      'Wear protective equipment and never spray near people, pets, water, or pollinators.',
    ];
  }

  PlantDisease? _findLibraryDisease(String name) {
    final normalizedName = _displayDiseaseName(name);
    for (final disease in sampleLibraryDiseases) {
      if (disease.name.toLowerCase() == normalizedName.toLowerCase() ||
          normalizedName.toLowerCase().contains(disease.name.toLowerCase())) {
        return disease;
      }
    }
    return null;
  }

  String _displayDiseaseName(String label) {
    final separatorIndex = label.indexOf('___');
    final disease = separatorIndex >= 0
        ? label.substring(separatorIndex + 3)
        : label;
    if (disease.toLowerCase() == 'healthy') {
      return 'Healthy Leaf';
    }
    return disease
        .replaceAll('_', ' ')
        .replaceAll('  ', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Future<_LoadedDiseaseModel> _ensureModelLoaded() async {
    final cached = _cachedModel;
    if (cached != null) {
      return cached;
    }

    final future = _modelLoadFuture ??= _loadModel();
    final model = await future;
    _cachedModel = model;
    return model;
  }

  Future<_LoadedDiseaseModel> _loadModel() async {
    try {
      final labelsText = await rootBundle.loadString(_labelsAssetPath);
      final labels = labelsText
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList(growable: false);
      if (labels.length != _outputClasses) {
        throw DiseaseDetectionServiceException(
          'Expected $_outputClasses disease labels, found ${labels.length}.',
        );
      }

      final modelBytes = await rootBundle.load(_modelAssetPath);
      final interpreter = Interpreter.fromBuffer(
        modelBytes.buffer.asUint8List(),
        options: InterpreterOptions()..threads = 2,
      );
      interpreter.allocateTensors();
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;
      if (inputShape.length != 4 ||
          inputShape[1] != _inputSize ||
          inputShape[2] != _inputSize ||
          inputShape[3] != 3 ||
          outputShape.isEmpty ||
          outputShape.last != _outputClasses) {
        interpreter.close();
        throw DiseaseDetectionServiceException(
          'The disease model has an unsupported tensor shape.',
        );
      }

      return _LoadedDiseaseModel(interpreter: interpreter, labels: labels);
    } on DiseaseDetectionServiceException {
      rethrow;
    } catch (error) {
      throw DiseaseDetectionServiceException(
        'Unable to load the disease detection model: $error',
      );
    }
  }

  Future<List<List<List<List<double>>>>> _prepareInput(
    Uint8List imageBytes,
  ) async {
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: _inputSize,
      targetHeight: _inputSize,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    codec.dispose();

    if (byteData == null) {
      throw DiseaseDetectionServiceException(
        'Unable to read pixels from the selected image.',
      );
    }

    final pixels = byteData.buffer.asUint8List();
    var offset = 0;
    final tensor = List.generate(
      _inputSize,
      (_) => List.generate(
        _inputSize,
        (_) {
          final values = <double>[
            // The TFLite model contains its own 0..255 to -1..1 rescaling.
            pixels[offset].toDouble(),
            pixels[offset + 1].toDouble(),
            pixels[offset + 2].toDouble(),
          ];
          offset += 4;
          return values;
        },
        growable: false,
      ),
      growable: false,
    );
    return <List<List<List<double>>>>[tensor];
  }

  List<double> _runInference(
    Interpreter interpreter,
    List<List<List<List<double>>>> input,
  ) {
    final output = <List<double>>[
      List<double>.filled(_outputClasses, 0.0, growable: false),
    ];
    interpreter.run(input, output);

    return _normalizeOutput(output.first);
  }

  List<double> _normalizeOutput(List<double> values) {
    final sum = values.fold<double>(0, (total, value) => total + value);
    final alreadyProbabilities = values.every((value) => value >= 0 && value <= 1) &&
        (sum - 1).abs() < 0.02;
    if (alreadyProbabilities) {
      return values;
    }

    final maxValue = values.reduce(
      (left, right) => left > right ? left : right,
    );
    final exponentials = values
        .map((value) => math.exp(value - maxValue))
        .toList(growable: false);
    final exponentialSum =
        exponentials.fold<double>(0, (total, value) => total + value);
    return exponentials
        .map((value) => value / exponentialSum)
        .toList(growable: false);
  }

  int _argMax(List<double> values) {
    var index = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[index]) {
        index = i;
      }
    }
    return index;
  }
}

class DiseaseDetectionServiceException implements Exception {
  DiseaseDetectionServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _LoadedDiseaseModel {
  const _LoadedDiseaseModel({required this.interpreter, required this.labels});

  final Interpreter interpreter;
  final List<String> labels;
}
