import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/plant_prediction.dart';
import 'plant_detection_api_service.dart';

abstract class PlantDetectionService {
  const PlantDetectionService();

  Future<PlantPrediction> detectPlant(
    Uint8List imageBytes, {
    String fileName = 'plant-image.jpg',
  });
}

class ApiBackedPlantDetectionService extends PlantDetectionService {
  ApiBackedPlantDetectionService({PlantDetectionApiService? apiService})
      : _apiService = apiService ?? PlantDetectionApiService();

  final PlantDetectionApiService _apiService;
  final PlantDetectionService _localService = const MockPlantDetectionService();

  @override
  Future<PlantPrediction> detectPlant(
    Uint8List imageBytes, {
    String fileName = 'plant-image.jpg',
  }) async {
    PlantPrediction? localPrediction;
    String? localError;

    // Use the existing on-device flower model first. Online services are only
    // needed when the local result is missing or below its confidence bar.
    try {
      localPrediction = await _localService.detectPlant(
        imageBytes,
        fileName: fileName,
      );
      if (localPrediction!.prediction != null &&
          !localPrediction!.isLowConfidence) {
        return localPrediction!;
      }
    } on PlantDetectionServiceException catch (error) {
      localError = error.message;
      debugPrint('Local flower model failed: $localError');
    }

    try {
      final result = await _apiService.identifyPlant(
        imageBytes: imageBytes,
        fileName: fileName,
        organ: 'auto',
      );
      final onlinePlant = result.plant;
      final onlinePlantIsUsable = onlinePlant != null &&
          onlinePlant.commonName.trim().toLowerCase() != 'unknown plant' &&
          onlinePlant.confidence > 0;
      if (onlinePlantIsUsable) {
        final plant = onlinePlant!;
        return PlantPrediction(
          success: result.success,
          message: result.message ?? 'Plant identification result ready.',
          prediction: PlantPredictionMatch(
            commonName: plant.commonName,
            scientificName: plant.scientificName,
            family: plant.family,
            genus: plant.genus,
            confidence: plant.confidence,
          ),
          alternatives: result.alternatives
              .map(
                (item) => PlantPredictionAlternative(
                  commonName: item.commonName,
                  scientificName: item.scientificName,
                  confidence: item.confidence,
                ),
              )
              .toList(growable: false),
          modelMessage: 'PlantNet and Gemini identification service.',
        );
      }
      localError = result.message ?? 'Online services returned no result.';
    } on PlantDetectionApiException catch (error) {
      localError = error.message;
      debugPrint('Plant identification backend failed: $localError');
    }

    final localResult = localPrediction;
    if (localResult?.prediction != null) {
      return PlantPrediction(
        success: true,
        message: 'Online identification was unavailable. Showing the local model result with low confidence.',
        prediction: localResult!.prediction,
        alternatives: localResult.alternatives,
        modelMessage: 'Local FloraMind TFLite flower model.',
        modelLoadError: localResult.modelLoadError,
        usesFallbackModel: true,
      );
    }

    return PlantPrediction(
      success: false,
      message: '${localError ?? 'Plant identification failed.'} The local flower model could not provide a confident result.',
      prediction: null,
      alternatives: const [],
      modelMessage: 'Local and online plant identification unavailable.',
      modelLoadError: localResult?.modelLoadError,
      usesFallbackModel: true,
    );
  }
}

class MockPlantDetectionService extends PlantDetectionService {
  const MockPlantDetectionService();

  static const String _modelAssetPath =
      'assets/models/floramind_flower_model.tflite';
  static const String _labelsAssetPath = 'assets/models/labels (1).txt';
  static const double _lowConfidenceThreshold = 0.68;
  static const double _minimumConfidenceGap = 0.08;
  static const int _inputSize = 224;
  static const int _inputChannels = 3;
  static const int _outputClasses = 102;

  static Future<_LoadedPlantModel>? _loadFuture;
  static _LoadedPlantModel? _cachedModel;

  @override
  Future<PlantPrediction> detectPlant(
    Uint8List imageBytes, {
    String fileName = 'plant-image.jpg',
  }) async {
    if (imageBytes.isEmpty) {
      throw PlantDetectionServiceException(
        'The selected image is empty. Please choose another plant photo.',
      );
    }

    final model = await _ensureModelLoaded();
    final input = await _prepareInput(imageBytes);
    final probabilities = _runInference(model.interpreter, input);
    final ranked = _rankPredictions(probabilities, model.labels);

    if (ranked.isEmpty) {
      throw PlantDetectionServiceException(
        'The model did not return any predictions. Please try again.',
      );
    }

    final best = ranked.first;
    final isConfident = _isConfidentMatch(ranked);
    final prediction = PlantPredictionMatch(
      commonName: best.commonName,
      scientificName: best.scientificName,
      family: 'Unknown',
      genus: 'Unknown',
      confidence: best.confidence,
    );
    final alternatives = ranked.skip(1)
        .take(3)
        .map(
          (item) => PlantPredictionAlternative(
            commonName: item.commonName,
            scientificName: item.scientificName,
            confidence: item.confidence,
          ),
        )
        .toList(growable: false);

    return PlantPrediction(
      success: true,
      message: isConfident
          ? 'Prediction ready from the FloraMind AI model.'
          : 'Low confidence. Try a clearer image for a better match.',
      prediction: prediction,
      alternatives: alternatives,
      modelMessage:
          'Loaded TFLite model with ${model.labels.length} plant classes.',
      modelLoadError: null,
      usesFallbackModel: false,
    );
  }

  Future<_LoadedPlantModel> _ensureModelLoaded() async {
    final cached = _cachedModel;
    if (cached != null) {
      return cached;
    }

    final future = _loadFuture ??= _loadModel();
    final model = await future;
    _cachedModel = model;
    return model;
  }

  Future<_LoadedPlantModel> _loadModel() async {
    try {
      final modelBytes = await rootBundle.load(_modelAssetPath);
      final labelsText = await rootBundle.loadString(_labelsAssetPath);
      final labels = _parseLabels(labelsText);

      if (labels.isEmpty) {
        throw PlantDetectionServiceException(
          'The class names file is empty: $_labelsAssetPath',
        );
      }

      if (labels.length != _outputClasses) {
        throw PlantDetectionServiceException(
          'Expected $_outputClasses class names, found ${labels.length}.',
        );
      }

      final options = InterpreterOptions()..threads = 2;
      final interpreter = Interpreter.fromBuffer(
        modelBytes.buffer.asUint8List(),
        options: options,
      );
      interpreter.allocateTensors();

      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;

      if (inputShape.length != 4 ||
          inputShape[1] != _inputSize ||
          inputShape[2] != _inputSize ||
          inputShape[3] != _inputChannels) {
        interpreter.close();
        throw PlantDetectionServiceException(
          'Unexpected model input shape: ${inputShape.join("x")}.',
        );
      }

      if (outputShape.isEmpty || outputShape.last != _outputClasses) {
        interpreter.close();
        throw PlantDetectionServiceException(
          'Unexpected model output shape: ${outputShape.join("x")}.',
        );
      }

      return _LoadedPlantModel(
        interpreter: interpreter,
        labels: labels,
      );
    } on PlantDetectionServiceException {
      rethrow;
    } catch (error) {
      throw PlantDetectionServiceException(
        'Unable to load the plant detection model: $error',
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
      throw PlantDetectionServiceException(
        'Unable to read pixels from the selected image.',
      );
    }

    final pixels = byteData.buffer.asUint8List();
    var pixelOffset = 0;

    final imageTensor = List<List<List<double>>>.generate(
      _inputSize,
      (_) {
        return List<List<double>>.generate(
          _inputSize,
          (_) {
            final red = pixels[pixelOffset].toDouble();
            final green = pixels[pixelOffset + 1].toDouble();
            final blue = pixels[pixelOffset + 2].toDouble();
            pixelOffset += 4;
            return <double>[
              _normalizeChannel(red),
              _normalizeChannel(green),
              _normalizeChannel(blue),
            ];
          },
          growable: false,
        );
      },
      growable: false,
    );

    return <List<List<List<double>>>>[imageTensor];
  }

  double _normalizeChannel(double value) {
    // The exported MobileNetV2 model already contains its [-1, 1]
    // Rescaling layer, so pass decoded RGB pixels in their original range.
    return value;
  }

  List<double> _runInference(
    Interpreter interpreter,
    List<List<List<List<double>>>> input,
  ) {
    final output = List.generate(
      1,
      (_) => List<double>.filled(_outputClasses, 0.0, growable: false),
      growable: false,
    );

    interpreter.run(input, output);
    return _normalizeOutput(output.first);
  }

  List<double> _normalizeOutput(List<double> output) {
    final sum = output.fold<double>(0, (total, value) => total + value);
    final alreadyProbabilities = output.every((value) => value >= 0 && value <= 1) &&
        (sum - 1).abs() < 0.02;
    if (alreadyProbabilities) {
      return output;
    }

    final maxValue = output.reduce((left, right) => left > right ? left : right);
    final exponentials = output
        .map((value) => math.exp(value - maxValue))
        .toList(growable: false);
    final exponentialSum = exponentials.fold<double>(
      0,
      (total, value) => total + value,
    );
    return exponentials
        .map((value) => value / exponentialSum)
        .toList(growable: false);
  }

  List<_RankedPrediction> _rankPredictions(
    List<double> probabilities,
    List<_PlantLabel> labels,
  ) {
    final ranked = <_RankedPrediction>[];
    final count = probabilities.length < labels.length
        ? probabilities.length
        : labels.length;

    for (var index = 0; index < count; index++) {
      final label = labels[index];
      ranked.add(
        _RankedPrediction(
          commonName: label.commonName,
          scientificName: label.scientificName,
          confidence: probabilities[index].clamp(0.0, 1.0).toDouble(),
        ),
      );
    }

    ranked.sort((left, right) => right.confidence.compareTo(left.confidence));
    return ranked;
  }

  bool _isConfidentMatch(List<_RankedPrediction> ranked) {
    final best = ranked.first;
    if (best.confidence < _lowConfidenceThreshold) {
      return false;
    }

    if (ranked.length == 1) {
      return true;
    }

    final runnerUp = ranked[1];
    return (best.confidence - runnerUp.confidence) >= _minimumConfidenceGap;
  }

  List<_PlantLabel> _parseLabels(String rawLabels) {
    return rawLabels
        .split(RegExp(r'\r?\n'))
        .map(_parseLabel)
        .where((label) => label.commonName.isNotEmpty)
        .toList(growable: false);
  }

  _PlantLabel _parseLabel(String label) {
    final trimmed = label.trim();
    final match = RegExp(r'^(.*?)\s*\((.*?)\)\s*$').firstMatch(trimmed);

    if (match != null) {
      final commonName = match.group(1)?.trim() ?? trimmed;
      final scientificName = match.group(2)?.trim() ?? trimmed;
      return _PlantLabel(
        commonName: commonName.isNotEmpty ? commonName : trimmed,
        scientificName:
            scientificName.isNotEmpty ? scientificName : commonName,
      );
    }

    return _PlantLabel(
      commonName: trimmed,
      scientificName: trimmed,
    );
  }
}

class _LoadedPlantModel {
  const _LoadedPlantModel({
    required this.interpreter,
    required this.labels,
  });

  final Interpreter interpreter;
  final List<_PlantLabel> labels;
}

class _PlantLabel {
  const _PlantLabel({
    required this.commonName,
    required this.scientificName,
  });

  final String commonName;
  final String scientificName;
}

class _RankedPrediction {
  const _RankedPrediction({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  final String commonName;
  final String scientificName;
  final double confidence;
}

class PlantDetectionServiceException implements Exception {
  PlantDetectionServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
