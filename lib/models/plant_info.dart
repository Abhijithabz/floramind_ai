class PlantInfo {
  const PlantInfo({
    required this.plantName,
    required this.scientificName,
    required this.description,
    required this.watering,
    required this.sunlight,
    required this.soil,
    required this.temperature,
    required this.humidity,
    required this.careTips,
    required this.commonProblems,
  });

  final String plantName;
  final String scientificName;
  final String description;
  final String watering;
  final String sunlight;
  final String soil;
  final String temperature;
  final String humidity;
  final List<String> careTips;
  final List<String> commonProblems;

  factory PlantInfo.fromMap(Map<String, dynamic> map) {
    return PlantInfo(
      plantName: (map['plantName'] as String?)?.trim().isNotEmpty == true
          ? map['plantName'] as String
          : 'Unknown',
      scientificName: (map['scientificName'] as String?)?.trim().isNotEmpty ==
              true
          ? map['scientificName'] as String
          : 'Unknown',
      description: (map['description'] as String?)?.trim().isNotEmpty == true
          ? map['description'] as String
          : '',
      watering: (map['watering'] as String?)?.trim().isNotEmpty == true
          ? map['watering'] as String
          : '',
      sunlight: (map['sunlight'] as String?)?.trim().isNotEmpty == true
          ? map['sunlight'] as String
          : '',
      soil: (map['soil'] as String?)?.trim().isNotEmpty == true
          ? map['soil'] as String
          : '',
      temperature: (map['temperature'] as String?)?.trim().isNotEmpty == true
          ? map['temperature'] as String
          : '',
      humidity: (map['humidity'] as String?)?.trim().isNotEmpty == true
          ? map['humidity'] as String
          : '',
      careTips: _stringList(map['careTips']),
      commonProblems: _stringList(map['commonProblems']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'plantName': plantName,
      'scientificName': scientificName,
      'description': description,
      'watering': watering,
      'sunlight': sunlight,
      'soil': soil,
      'temperature': temperature,
      'humidity': humidity,
      'careTips': careTips,
      'commonProblems': commonProblems,
    };
  }

  static String documentIdFor(String value) {
    final normalized = value.trim().toLowerCase();
    final documentId = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return documentId.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const <String>[];
  }
}
