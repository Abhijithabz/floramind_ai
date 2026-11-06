import 'package:flutter/material.dart';

import '../../data/crop_library_data.dart';
import '../../models/crop_profile.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../cultivation_tips/cultivation_tips_screen.dart';
import 'crop_detail_screen.dart';

class CropLibraryScreen extends StatefulWidget {
  const CropLibraryScreen({super.key});

  @override
  State<CropLibraryScreen> createState() => _CropLibraryScreenState();
}

class _CropLibraryScreenState extends State<CropLibraryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crops = cropLibrary.where((crop) => crop.matchesQuery(_query)).toList();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Crops'),
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
                      Text(
                        'Crop growing guides',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Learn about optimal growing conditions, soil parameters, crop companions and rotation for successful cultivation.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CultivationTipsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.checklist_rounded),
                          label: const Text('Cultivation Tips'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Search crops',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: theme.colorScheme.surface.withValues(alpha: 0.82),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (crops.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No crops match your search.'),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 650 ? 3 : 2;
                            final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
                            return Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: crops
                                  .map(
                                    (crop) => SizedBox(
                                      width: width,
                                      child: _CropCard(
                                        crop: crop,
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => CropDetailScreen(crop: crop),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
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
}

class _CropCard extends StatelessWidget {
  const _CropCard({required this.crop, required this.onTap});

  final CropProfile crop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 130,
              color: Color(crop.accentColor).withValues(alpha: 0.12),
              child: Center(child: _cropIcon(crop.icon)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crop.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(crop.category, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _cropIcon(String type) {
  final icon = switch (type) {
    'apple' => '🍎',
    'banana' => '🍌',
    'tomato' => '🍅',
    'barley' || 'wheat' => '🌾',
    'rice' => '🌱',
    _ => '🌿',
  };
  return Text(icon, style: const TextStyle(fontSize: 58));
}
