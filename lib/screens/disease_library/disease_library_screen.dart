import 'package:flutter/material.dart';

import '../../models/plant_disease.dart';
import '../../services/disease_library_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/store_search_bar.dart';
import 'disease_detail_screen.dart';
import 'widgets/disease_library_card.dart';
import 'widgets/library_selection_chip.dart';

class DiseaseLibraryScreen extends StatefulWidget {
  const DiseaseLibraryScreen({super.key});

  @override
  State<DiseaseLibraryScreen> createState() => _DiseaseLibraryScreenState();
}

class _DiseaseLibraryScreenState extends State<DiseaseLibraryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late Future<DiseaseLibraryData> _libraryFuture;

  final TextEditingController _searchController = TextEditingController();
  final DiseaseLibraryService _service = const FirestoreDiseaseLibraryService();

  String _selectedPlantId = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadLibrary();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadLibrary() {
    _libraryFuture = _service.loadLibrary();
  }

  List<PlantDisease> _filteredDiseases(
    DiseaseLibraryData library,
    String query,
  ) {
    return library.diseases.where((disease) {
      final matchesPlant = disease.matchesPlant(_selectedPlantId);
      final matchesType = _selectedType == 'all' ||
          (_selectedType == 'diseases' && !disease.isPest) ||
          (_selectedType == 'pests' && disease.isPest);
      return matchesPlant && matchesType && disease.matchesQuery(query);
    }).toList(growable: false);
  }

  int _countForPlant(DiseaseLibraryData library, String plantId) {
    return library.diseases.where((disease) => disease.matchesPlant(plantId)).length;
  }

  int _countForType(DiseaseLibraryData library, String type) {
    return library.diseases.where((disease) {
      if (type == 'diseases') {
        return !disease.isPest;
      }
      if (type == 'pests') {
        return disease.isPest;
      }
      return true;
    }).length;
  }

  void _openDetail(PlantDisease disease) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DiseaseDetailScreen(disease: disease),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, DiseaseLibraryData library) {
    final textTheme = Theme.of(context).textTheme;
    final highSeverityCount = library.diseases
        .where((item) => item.severity.index >= 2)
        .length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1.1,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF5EAF61),
            Color(0xFF9AD26A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20502B).withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            right: -2,
            child: Icon(
              Icons.bug_report_rounded,
              size: 92,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Plant Disease & Pest Library',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Recognize common plant problems before they spread',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse reference cards for diseases and pests. Each entry includes symptoms, causes, treatment, and prevention.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroStatChip(
                    icon: Icons.eco_rounded,
                    label: '${library.plants.length} plants',
                  ),
                  _HeroStatChip(
                    icon: Icons.local_florist_rounded,
                    label: '${library.diseases.length} conditions',
                  ),
                  _HeroStatChip(
                    icon: Icons.priority_high_rounded,
                    label: '$highSeverityCount high severity',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    DiseaseLibraryData library,
  ) {
    final plants = library.plants;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final plantFilters = <_FilterData>[
      _FilterData(
        id: 'all',
        label: 'All Plants',
        icon: Icons.grid_view_rounded,
        count: library.diseases.length,
      ),
      ...plants.map(
        (plant) => _FilterData(
          id: plant.id,
          label: plant.commonName,
          icon: Icons.eco_rounded,
          count: _countForPlant(library, plant.id),
        ),
      ),
    ];

    final typeFilters = <_FilterData>[
      _FilterData(
        id: 'all',
        label: 'All',
        icon: Icons.grid_view_rounded,
        count: library.diseases.length,
      ),
      _FilterData(
        id: 'diseases',
        label: 'Diseases',
        icon: Icons.science_rounded,
        count: _countForType(library, 'diseases'),
      ),
      _FilterData(
        id: 'pests',
        label: 'Pests',
        icon: Icons.bug_report_rounded,
        count: _countForType(library, 'pests'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search and filter',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Start with a plant, then narrow the library by disease or pest type.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        StoreSearchBar(
          controller: _searchController,
          hintText: 'Search diseases, pests, symptoms, or treatments...',
          onChanged: (_) => setState(() {}),
          onClear: () {
            setState(() {
              _searchController.clear();
            });
          },
        ),
        const SizedBox(height: 14),
        Text(
          'Select a plant',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: plantFilters
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: LibrarySelectionChip(
                      label: filter.label,
                      icon: filter.icon,
                      count: filter.count,
                      selected: _selectedPlantId == filter.id,
                      onTap: () {
                        setState(() {
                          _selectedPlantId = filter.id;
                        });
                      },
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Condition type',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: typeFilters
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: LibrarySelectionChip(
                      label: filter.label,
                      icon: filter.icon,
                      count: filter.count,
                      selected: _selectedType == filter.id,
                      onTap: () {
                        setState(() {
                          _selectedType = filter.id;
                        });
                      },
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No conditions match your filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different plant, clear the search, or switch back to All.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPlantId = 'all';
                _selectedType = 'all';
                _searchController.clear();
              });
            },
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.86),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading disease library',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Fetching plants, diseases, and pests from Firestore.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.86),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 46,
                color: colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load the disease library right now.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _loadLibrary();
                  });
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No library records found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add documents to the plants, diseases, and pests collections in Firestore to populate this screen.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Disease & Pest Library'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: FutureBuilder<DiseaseLibraryData>(
              future: _libraryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(context);
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorState(context, snapshot.error ?? 'Unknown error');
                }

                final library = snapshot.data!;
                if (library.isEmpty) {
                  return SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeroCard(context, library),
                              const SizedBox(height: 18),
                              _buildFilterSection(context, library),
                              const SizedBox(height: 22),
                              _buildLibraryEmptyState(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final query = _searchController.text;
                final filteredDiseases = _filteredDiseases(library, query);
                final width = MediaQuery.sizeOf(context).width;
                final contentWidth = width >= 1200
                    ? 1120.0
                    : width >= 920
                        ? 900.0
                        : width - 32;
                final columns = width >= 1120
                    ? 2
                    : width >= 760
                        ? 2
                        : 1;
                final gap = 14.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeroCard(context, library),
                              const SizedBox(height: 18),
                              _buildFilterSection(context, library),
                              const SizedBox(height: 22),
                              if (filteredDiseases.isEmpty)
                                _buildEmptyState(context)
                              else
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final cardWidth = columns == 1
                                        ? constraints.maxWidth
                                        : ((constraints.maxWidth - gap) / 2)
                                            .clamp(240.0, 480.0)
                                            .toDouble();

                                    return Wrap(
                                      spacing: gap,
                                      runSpacing: gap,
                                      children: filteredDiseases
                                          .map(
                                            (disease) => SizedBox(
                                              width: cardWidth,
                                              child: DiseaseLibraryCard(
                                                disease: disease,
                                                onTap: () => _openDetail(disease),
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                    );
                                  },
                                ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterData {
  const _FilterData({
    required this.id,
    required this.label,
    required this.icon,
    required this.count,
  });

  final String id;
  final String label;
  final IconData icon;
  final int count;
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
