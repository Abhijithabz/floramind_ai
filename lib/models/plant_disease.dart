import 'disease_severity.dart';

class PlantDisease {
  const PlantDisease({
    required this.id,
    required this.name,
    required this.type,
    required this.severity,
    required this.affectedPlantIds,
    required this.affectedPlantNames,
    required this.symptoms,
    required this.causes,
    required this.remedies,
    required this.prevention,
    this.overview = '',
    this.imageLabel = '',
    this.imageUrl = '',
    this.tags = const <String>[],
  });

  final String id;
  final String name;
  final String type;
  final DiseaseSeverity severity;
  final List<String> affectedPlantIds;
  final List<String> affectedPlantNames;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> remedies;
  final List<String> prevention;
  final String overview;
  final String imageLabel;
  final String imageUrl;
  final List<String> tags;

  bool get isPest => type.toLowerCase().contains('pest');

  String get typeLabel => isPest ? 'Pest' : 'Disease';

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final haystack = <String>[
      name,
      type,
      overview,
      imageLabel,
      ...affectedPlantNames,
      ...symptoms,
      ...causes,
      ...remedies,
      ...prevention,
      ...tags,
    ].join(' ').toLowerCase();

    return haystack.contains(normalizedQuery);
  }

  bool matchesPlant(String plantId) {
    return plantId == 'all' || affectedPlantIds.contains(plantId);
  }
}
