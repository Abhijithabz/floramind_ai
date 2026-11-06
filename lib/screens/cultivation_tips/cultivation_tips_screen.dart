import 'package:flutter/material.dart';

import '../../data/crop_library_data.dart';
import '../../models/crop_profile.dart';
import '../../services/cultivation_tips_api_service.dart';
import '../dashboard/widgets/dashboard_background.dart';

class CultivationTipsScreen extends StatefulWidget {
  const CultivationTipsScreen({super.key, this.initialCrop});

  final CropProfile? initialCrop;

  @override
  State<CultivationTipsScreen> createState() => _CultivationTipsScreenState();
}

class _CultivationTipsScreenState extends State<CultivationTipsScreen> {
  late final List<CropProfile> _plants;
  late CropProfile _selectedPlant;
  bool _byTask = true;
  bool _isGenerating = false;
  List<String>? _aiTips;

  @override
  void initState() {
    super.initState();
    _plants = [...cropLibrary, ...floweringPlantLibrary];
    _selectedPlant =
        widget.initialCrop ??
        _plants.firstWhere(
          (plant) => plant.id == 'tomato',
          orElse: () => _plants.first,
        );
  }

  List<_Tip> _taskTips(CropProfile plant) {
    return [
      _Tip(
        'Plant selection',
        'Choose a healthy variety suited to ${plant.temperature} and ${plant.exposure.toLowerCase()}. Use clean, disease-free seed or seedlings.',
      ),
      _Tip(
        'Site selection',
        'Select a site with ${plant.exposure.toLowerCase()} and soil that matches ${plant.soil}. Keep the area well drained.',
      ),
      _Tip(
        'Planting',
        'Prepare soil around pH ${plant.ph}. Follow the recommended spacing: ${plant.spacing}.',
      ),
      _Tip(
        'Irrigation',
        'Use ${plant.watering.toLowerCase()} watering. Water at the root and avoid wet foliage when possible.',
      ),
      _Tip(
        'Monitoring',
        'Check leaves, stems, and new growth at least twice a week. Remove damaged material and act early if pests or disease appear.',
      ),
      _Tip(
        'Fertilization organic',
        plant.nutrients.isEmpty
            ? 'Add mature compost and mulch around the root zone.'
            : '${plant.nutrients.first}. Add mature compost and keep fertilizer away from the stem.',
      ),
      _Tip(
        'Fertilization chemical',
        plant.nutrients.length > 1
            ? plant.nutrients.skip(1).join('. ')
            : 'Use a soil-test-based fertilizer and follow the product label dose.',
      ),
      _Tip(
        'Weeding and mulching',
        'Keep the root zone free of weeds. Add a light organic mulch layer without touching the stem.',
      ),
    ];
  }

  List<_Tip> _stageTips(CropProfile plant) {
    return [
      _Tip(
        'Before planting',
        'Choose a suitable variety, prepare ${plant.soil}, and target pH ${plant.ph}. Plan spacing of ${plant.spacing}.',
      ),
      _Tip(
        'Seedling stage',
        'Give young plants steady ${plant.watering.toLowerCase()} watering, good light, and protection from weeds and strong wind.',
      ),
      _Tip(
        'Vegetative stage',
        'Check new leaves weekly, maintain moisture at the roots, and guide or support the plant when needed.',
      ),
      _Tip(
        'Flowering and fruiting',
        'Keep watering consistent. Avoid sudden fertilizer changes and monitor closely for pests and disease.',
      ),
      _Tip(
        'Harvest and aftercare',
        'Harvest at the crop’s recommended maturity. Remove diseased residue and record what worked for the next season.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tips = _byTask
        ? _taskTips(_selectedPlant)
        : _stageTips(_selectedPlant);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Cultivation Tips'),
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Practical growing suggestions',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select a crop or flowering plant to see guidance for each growing task and stage.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<CropProfile>(
                        value: _selectedPlant,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select crop or plant',
                          prefixIcon: Icon(
                            Icons.local_florist_rounded,
                            color: Color(_selectedPlant.accentColor),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface.withValues(
                            alpha: 0.88,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _plants
                            .map(
                              (plant) => DropdownMenuItem<CropProfile>(
                                value: plant,
                                child: Text(
                                  '${plant.name} • ${plant.category}',
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (plant) {
                          if (plant != null) {
                            setState(() {
                              _selectedPlant = plant;
                              _aiTips = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('By Task'),
                            icon: Icon(Icons.checklist_rounded),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('By Stage'),
                            icon: Icon(Icons.timeline_rounded),
                          ),
                        ],
                        selected: {_byTask},
                        onSelectionChanged: (selection) {
                          setState(() => _byTask = selection.first);
                        },
                      ),
                      const SizedBox(height: 18),
                      _PlantSummary(plant: _selectedPlant),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isGenerating ? null : _generateAiTips,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                          _isGenerating
                              ? 'Generating tips...'
                              : 'Get AI cultivation tips',
                        ),
                      ),
                      if (_aiTips != null) ...[
                        const SizedBox(height: 12),
                        _AiTipsCard(
                          plantName: _selectedPlant.name,
                          tips: _aiTips!,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ...tips.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TipCard(tip: tip),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'These are general growing suggestions. Adjust practices to your variety, local climate, soil test, and agricultural guidance.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAiTips() async {
    setState(() {
      _isGenerating = true;
      _aiTips = null;
    });
    try {
      final tips = await const CultivationTipsApiService().generateTips(
        _selectedPlant,
      );
      if (mounted) {
        setState(() => _aiTips = tips);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI tips are unavailable. Showing local guidance.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _Tip {
  const _Tip(this.title, this.body);

  final String title;
  final String body;
}

class _PlantSummary extends StatelessWidget {
  const _PlantSummary({required this.plant});

  final CropProfile plant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Color(plant.accentColor).withValues(alpha: 0.14),
        border: Border.all(
          color: Color(plant.accentColor).withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, size: 34, color: Color(plant.accentColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${plant.name}: ${plant.description}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final _Tip tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface.withValues(alpha: 0.84),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
        ),
        title: Text(
          tip.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            tip.body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ),
    );
  }
}

class _AiTipsCard extends StatelessWidget {
  const _AiTipsCard({required this.plantName, required this.tips});

  final String plantName;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI guidance for $plantName',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('• $tip'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'General guidance only. Follow local agricultural advice and product labels.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
