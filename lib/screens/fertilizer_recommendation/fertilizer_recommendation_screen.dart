import 'package:flutter/material.dart';

import '../dashboard/widgets/dashboard_background.dart';
import '../../services/fertilizer_recommendation_api_service.dart';

class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() =>
      _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState
    extends State<FertilizerRecommendationScreen> {
  final _npkController = TextEditingController();
  String _plant = 'Tomato';
  String _stage = 'Vegetative growth';
  String _condition = 'Healthy';
  String _soil = 'Loamy and well-drained';
  bool _showResult = false;
  bool _isLoading = false;
  FertilizerRecommendation? _apiRecommendation;

  @override
  void dispose() {
    _npkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Fertilizer Recommendation'),
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
                  'Choose inputs for a practical recommendation',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommendations use the information you provide.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _field('Plant or crop', _plant, const [
                  'Tomato',
                  'Rose',
                  'Hibiscus',
                  'Chilli',
                  'General garden plant',
                ], (value) => setState(() => _plant = value)),
                _field('Growth stage', _stage, const [
                  'Seedling',
                  'Vegetative growth',
                  'Flowering or fruiting',
                ], (value) => setState(() => _stage = value)),
                _field(
                  'Plant condition',
                  _condition,
                  const [
                    'Healthy',
                    'Pale leaves',
                    'Slow growth',
                    'Flowering poorly',
                  ],
                  (value) => setState(() => _condition = value),
                ),
                _field('Soil condition', _soil, const [
                  'Loamy and well-drained',
                  'Sandy and dry',
                  'Heavy clay',
                  'Unknown',
                ], (value) => setState(() => _soil = value)),
                TextField(
                  controller: _npkController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Optional soil N-P-K values',
                    hintText: 'Example: 10-5-8',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _getRecommendation,
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Get Recommendation'),
                ),
                if (_showResult) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suggested approach for $_plant',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (_isLoading)
                            const LinearProgressIndicator()
                          else ...[
                            Text(
                              _apiRecommendation?.summary ?? _recommendation,
                            ),
                            if (_apiRecommendation != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Suggested N-P-K: ${_apiRecommendation!.npk}',
                              ),
                              const SizedBox(height: 8),
                              Text(_apiRecommendation!.application),
                              for (final caution
                                  in _apiRecommendation!.cautions)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('• $caution'),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Source: ${_apiRecommendation!.source}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                          const SizedBox(height: 16),
                          const Text(
                            'Use a product labelled for this plant and follow its label. A soil test is the safest way to choose an exact dose.',
                          ),
                        ],
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

  Future<void> _getRecommendation() async {
    setState(() {
      _showResult = true;
      _isLoading = true;
      _apiRecommendation = null;
    });

    try {
      _apiRecommendation = await FertilizerRecommendationApiService().recommend(
        plant: _plant,
        stage: _stage,
        condition: _condition,
        soil: _soil,
        npk: _npkController.text.trim(),
      );
    } catch (_) {
      // Keep the local recommendation available when the remote provider is unavailable.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _recommendation {
    if (_condition == 'Pale leaves' || _condition == 'Slow growth') {
      return 'Start with compost or a mild balanced fertilizer. Improve drainage and apply only after checking the soil and plant label.';
    }
    if (_stage == 'Flowering or fruiting' || _condition == 'Flowering poorly') {
      return 'Use compost plus a flowering or fruiting fertilizer with relatively more phosphorus and potassium than nitrogen.';
    }
    return 'Use mature compost and a balanced fertilizer suitable for the crop. Avoid heavy feeding while the plant is young.';
  }

  Widget _field(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }
}
