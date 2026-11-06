class PlantProfile {
  const PlantProfile({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.category,
    this.aliases = const <String>[],
    this.description = '',
  });

  final String id;
  final String commonName;
  final String scientificName;
  final String category;
  final List<String> aliases;
  final String description;

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return commonName.toLowerCase().contains(normalizedQuery) ||
        scientificName.toLowerCase().contains(normalizedQuery) ||
        category.toLowerCase().contains(normalizedQuery) ||
        description.toLowerCase().contains(normalizedQuery) ||
        aliases.any((alias) => alias.toLowerCase().contains(normalizedQuery));
  }
}
