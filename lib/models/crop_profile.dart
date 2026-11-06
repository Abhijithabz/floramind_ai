class CropProfile {
  const CropProfile({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.description,
    required this.temperature,
    required this.exposure,
    required this.rainfall,
    required this.humidity,
    required this.watering,
    required this.soil,
    required this.ph,
    required this.spacing,
    required this.companions,
    required this.rotation,
    required this.nutrients,
  });

  final String id;
  final String name;
  final String scientificName;
  final String category;
  final String icon;
  final int accentColor;
  final String description;
  final String temperature;
  final String exposure;
  final String rainfall;
  final String humidity;
  final String watering;
  final String soil;
  final String ph;
  final String spacing;
  final List<String> companions;
  final List<String> rotation;
  final List<String> nutrients;

  bool matchesQuery(String query) {
    final value = query.trim().toLowerCase();
    return value.isEmpty ||
        name.toLowerCase().contains(value) ||
        category.toLowerCase().contains(value) ||
        scientificName.toLowerCase().contains(value);
  }
}
