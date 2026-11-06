class DiseasePrediction {
  const DiseasePrediction({
    required this.success,
    required this.message,
    required this.diseaseName,
    required this.confidence,
    this.isLoading = false,
    this.errorMessage,
    this.modelLoadError,
    this.usesFallbackModel = false,
    this.symptoms = const <String>[],
    this.causes = const <String>[],
    this.treatment = const <String>[],
    this.prevention = const <String>[],
    this.pesticideGuidance = const <String>[],
  });

  const DiseasePrediction.loading({
    this.message = 'Loading disease prediction...',
  })  : success = false,
        diseaseName = null,
        confidence = 0,
        isLoading = true,
        errorMessage = null,
        modelLoadError = null,
        usesFallbackModel = true,
        symptoms = const <String>[],
        causes = const <String>[],
        treatment = const <String>[],
        prevention = const <String>[],
        pesticideGuidance = const <String>[];

  final bool success;
  final String message;
  final String? diseaseName;
  final double confidence;
  final bool isLoading;
  final String? errorMessage;
  final String? modelLoadError;
  final bool usesFallbackModel;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;
  final List<String> pesticideGuidance;

  bool get hasError => errorMessage?.trim().isNotEmpty == true;

  bool get isUnknown =>
      diseaseName == null ||
      diseaseName!.trim().isEmpty ||
      confidence < 0.60;

  bool get isLowConfidence => confidence < 0.60;

  int get confidencePercent => (confidence * 100).round();
}
