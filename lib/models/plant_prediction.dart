import 'plant_identification_result.dart';

class PlantPrediction {
  const PlantPrediction({
    required this.success,
    required this.message,
    required this.prediction,
    required this.alternatives,
    this.modelMessage,
    this.modelLoadError,
    this.usesFallbackModel = false,
  });

  final bool success;
  final String message;
  final PlantPredictionMatch? prediction;
  final List<PlantPredictionAlternative> alternatives;
  final String? modelMessage;
  final String? modelLoadError;
  final bool usesFallbackModel;

  bool get hasPrediction => prediction != null;

  bool get isUnknown => prediction == null || prediction!.isLowConfidence;

  bool get isLowConfidence => prediction != null && prediction!.isLowConfidence;

  bool get hasModelLoadError => modelLoadError?.trim().isNotEmpty == true;

  double get confidence => prediction?.confidence ?? 0;

  int get confidencePercent => (confidence * 100).round();

  PlantIdentificationResult toIdentificationResult() {
    return PlantIdentificationResult(
      success: success,
      message: message,
      plant: prediction?.toIdentificationPlant(),
      alternatives: alternatives
          .map((item) => item.toIdentificationAlternative())
          .toList(),
    );
  }
}

class PlantPredictionMatch {
  const PlantPredictionMatch({
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.genus,
    required this.confidence,
  });

  final String commonName;
  final String scientificName;
  final String family;
  final String genus;
  final double confidence;

  bool get isLowConfidence => confidence < 0.68;

  int get confidencePercent => (confidence * 100).round();

  PlantIdentificationPlant toIdentificationPlant() {
    return PlantIdentificationPlant(
      commonName: commonName,
      scientificName: scientificName,
      family: family,
      genus: genus,
      confidence: confidence,
    );
  }
}

class PlantPredictionAlternative {
  const PlantPredictionAlternative({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  final String commonName;
  final String scientificName;
  final double confidence;

  int get confidencePercent => (confidence * 100).round();

  PlantIdentificationAlternative toIdentificationAlternative() {
    return PlantIdentificationAlternative(
      commonName: commonName,
      scientificName: scientificName,
      confidence: confidence,
    );
  }
}
