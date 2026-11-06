import 'package:flutter/material.dart';

import '../dashboard/widgets/dashboard_background.dart';

class PlantRecommendationScreen extends StatefulWidget {
  const PlantRecommendationScreen({super.key});

  @override
  State<PlantRecommendationScreen> createState() =>
      _PlantRecommendationScreenState();
}

class _PlantRecommendationScreenState extends State<PlantRecommendationScreen> {
  String _light = 'Full sun';
  String _space = 'Balcony';
  bool _showResults = false;

  static const _recommendations = <_RecommendationData>[
    _RecommendationData(
      'Rose',
      'Rosa',
      'Flowering plant for sunny spaces',
      Icons.local_florist_rounded,
      Color(0xFFE91E63),
    ),
    _RecommendationData(
      'Hibiscus',
      'Hibiscus rosa-sinensis',
      'Tropical flowering plant for warm gardens',
      Icons.spa_rounded,
      Color(0xFFEF6C79),
    ),
    _RecommendationData(
      'Marigold',
      'Tagetes',
      'Hardy seasonal flower for bright locations',
      Icons.eco_rounded,
      Color(0xFFF4B400),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Plant Recommendation'),
        backgroundColor: colors.surface.withValues(alpha: 0.9),
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  'Find plants that fit your space',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your growing conditions to find suitable plants.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _ChoiceField(
                  label: 'Available light',
                  value: _light,
                  options: const ['Full sun', 'Partial shade', 'Low light'],
                  onChanged: (value) => setState(() => _light = value),
                ),
                const SizedBox(height: 16),
                _ChoiceField(
                  label: 'Growing space',
                  value: _space,
                  options: const ['Balcony', 'Indoor', 'Garden bed', 'Terrace'],
                  onChanged: (value) => setState(() => _space = value),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => setState(() => _showResults = true),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Recommend Plants'),
                ),
                if (_showResults) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Recommended for $_light and your $_space space',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  ..._recommendations.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.color.withValues(alpha: 0.15),
                          child: Icon(item.icon, color: item.color),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.scientificName}\n${item.description}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _RecommendationData {
  const _RecommendationData(
    this.name,
    this.scientificName,
    this.description,
    this.icon,
    this.color,
  );

  final String name;
  final String scientificName;
  final String description;
  final IconData icon;
  final Color color;
}
