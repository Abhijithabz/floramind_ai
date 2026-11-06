class PlantIdentificationResult {
  PlantIdentificationResult({
    required this.success,
    required this.alternatives,
    this.message,
    this.plant,
  });

  final bool success;
  final String? message;
  final PlantIdentificationPlant? plant;
  final List<PlantIdentificationAlternative> alternatives;

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) {
    final plantJson = json['plant'];
    final alternativesJson = json['alternatives'];

    return PlantIdentificationResult(
      success: json['success'] == true,
      message: json['message'] as String?,
      plant: plantJson is Map<String, dynamic>
          ? PlantIdentificationPlant.fromJson(plantJson)
          : null,
      alternatives: alternativesJson is List
          ? alternativesJson
              .whereType<Map<String, dynamic>>()
              .map(PlantIdentificationAlternative.fromJson)
              .toList()
          : const <PlantIdentificationAlternative>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'plant': plant?.toJson(),
      'alternatives': alternatives.map((item) => item.toJson()).toList(),
    };
  }
}

class PlantIdentificationPlant {
  PlantIdentificationPlant({
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

  factory PlantIdentificationPlant.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationPlant(
      commonName: (json['common_name'] as String?)?.trim().isNotEmpty == true
          ? json['common_name'] as String
          : 'Unknown',
      scientificName: (json['scientific_name'] as String?)?.trim().isNotEmpty ==
              true
          ? json['scientific_name'] as String
          : 'Unknown',
      family: (json['family'] as String?)?.trim().isNotEmpty == true
          ? json['family'] as String
          : 'Unknown',
      genus: (json['genus'] as String?)?.trim().isNotEmpty == true
          ? json['genus'] as String
          : 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'common_name': commonName,
      'scientific_name': scientificName,
      'family': family,
      'genus': genus,
      'confidence': confidence,
    };
  }

  int get confidencePercent => (confidence * 100).round();
}

class PlantIdentificationAlternative {
  PlantIdentificationAlternative({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  final String commonName;
  final String scientificName;
  final double confidence;

  factory PlantIdentificationAlternative.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationAlternative(
      commonName: (json['common_name'] as String?)?.trim().isNotEmpty == true
          ? json['common_name'] as String
          : 'Unknown',
      scientificName: (json['scientific_name'] as String?)?.trim().isNotEmpty ==
              true
          ? json['scientific_name'] as String
          : 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'common_name': commonName,
      'scientific_name': scientificName,
      'confidence': confidence,
    };
  }

  int get confidencePercent => (confidence * 100).round();
}
