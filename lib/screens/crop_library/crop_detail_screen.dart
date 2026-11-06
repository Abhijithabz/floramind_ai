import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/crop_profile.dart';
import '../dashboard/widgets/dashboard_background.dart';

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({super.key, required this.crop});

  final CropProfile crop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(crop.accentColor);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(crop.name),
        actions: [
          IconButton(
            tooltip: 'Copy guide',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _shareText()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Crop guide copied')),
              );
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.90),
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
                      Container(
                        height: 210,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: color.withValues(alpha: 0.14),
                        ),
                        child: Center(child: _cropIcon(crop.icon, size: 92)),
                      ),
                      const SizedBox(height: 18),
                      Text(crop.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(crop.scientificName, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      Text(crop.description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                      const SizedBox(height: 22),
                      _GuideSection(title: 'Growing conditions', children: [_GuideGrid(items: {'Temperature': crop.temperature, 'Exposure': crop.exposure, 'Rainfall': crop.rainfall, 'Relative humidity': crop.humidity, 'Watering': crop.watering})]),
                      _GuideSection(title: 'Soil parameters', children: [_GuideGrid(items: {'Soil': crop.soil, 'pH': crop.ph})]),
                      _GuideSection(title: 'Cultivation', children: [_GuideItem(title: 'Spacing', value: crop.spacing), _GuideList(title: 'Good companions', values: crop.companions), _GuideList(title: 'Rotation ideas', values: crop.rotation)]),
                      _GuideSection(title: 'Nutrient guidance', children: [_GuideList(title: 'General recommendations', values: crop.nutrients)]),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(18)),
                        child: const Text('These are general crop guidelines. Adjust them for your variety, local climate, soil test, and advice from an agricultural professional.'),
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

  String _shareText() => '${crop.name}\n${crop.description}\nTemperature: ${crop.temperature}\nSoil: ${crop.soil}\npH: ${crop.ph}\nSpacing: ${crop.spacing}';
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...children,
        ]),
      );
}

class _GuideGrid extends StatelessWidget {
  const _GuideGrid({required this.items});
  final Map<String, String> items;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78), borderRadius: BorderRadius.circular(20)),
        child: Wrap(
          children: items.entries.map((entry) => SizedBox(width: MediaQuery.sizeOf(context).width < 600 ? MediaQuery.sizeOf(context).width - 36 : 350, child: _GuideItem(title: entry.key, value: entry.value))).toList(),
        ),
      );
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 5),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      );
}

class _GuideList extends StatelessWidget {
  const _GuideList({required this.title, required this.values});
  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ...values.map((value) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•  '), Expanded(child: Text(value))]))),
        ]),
      );
}

Widget _cropIcon(String type, {double size = 58}) {
  final icon = switch (type) {
    'apple' => '🍎',
    'banana' => '🍌',
    'tomato' => '🍅',
    'barley' || 'wheat' => '🌾',
    'rice' => '🌱',
    _ => '🌿',
  };
  return Text(icon, style: TextStyle(fontSize: size));
}
