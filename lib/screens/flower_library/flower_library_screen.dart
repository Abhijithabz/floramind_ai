import 'package:flutter/material.dart';

import '../../data/crop_library_data.dart';
import '../../models/crop_profile.dart';
import '../crop_library/crop_detail_screen.dart';
import '../cultivation_tips/cultivation_tips_screen.dart';
import '../dashboard/widgets/dashboard_background.dart';

class FlowerLibraryScreen extends StatefulWidget {
  const FlowerLibraryScreen({super.key});

  @override
  State<FlowerLibraryScreen> createState() => _FlowerLibraryScreenState();
}

class _FlowerLibraryScreenState extends State<FlowerLibraryScreen> {
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
    final flowers = floweringPlantLibrary
        .where((flower) => flower.matchesQuery(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Flowering Plants'),
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
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
                        'Flowering plant guides',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore flowers for gardens, balconies, pots, and landscapes with simple care and growing guidance.',
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
                          hintText: 'Search flowering plants',
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
                          fillColor:
                              theme.colorScheme.surface.withValues(alpha: 0.82),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (flowers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No flowering plants match your search.'),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 650 ? 3 : 2;
                            final width = (constraints.maxWidth -
                                    ((columns - 1) * 14)) /
                                columns;
                            return Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: flowers
                                  .map(
                                    (flower) => SizedBox(
                                      width: width,
                                      child: _FlowerCard(
                                        flower: flower,
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => CropDetailScreen(
                                              crop: flower,
                                            ),
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

class _FlowerCard extends StatelessWidget {
  const _FlowerCard({required this.flower, required this.onTap});

  final CropProfile flower;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 130,
              color: Color(flower.accentColor).withValues(alpha: 0.14),
              child: Center(
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 64,
                  color: Color(flower.accentColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flower.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    flower.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
