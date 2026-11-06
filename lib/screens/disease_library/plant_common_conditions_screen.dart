import 'package:flutter/material.dart';

import '../../models/plant_disease.dart';
import '../../services/disease_library_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/disease_content_section.dart';
import 'widgets/disease_image_banner.dart';
import 'widgets/disease_severity_badge.dart';

class PlantCommonConditionsScreen extends StatefulWidget {
  const PlantCommonConditionsScreen({
    super.key,
    required this.plantName,
    required this.scientificName,
    required this.plantId,
  });

  final String plantName;
  final String scientificName;
  final String plantId;

  @override
  State<PlantCommonConditionsScreen> createState() =>
      _PlantCommonConditionsScreenState();
}

class _PlantCommonConditionsScreenState extends State<PlantCommonConditionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late Future<DiseaseLibraryMatchData> _matchesFuture;

  final DiseaseLibraryService _service = const FirestoreDiseaseLibraryService();

  @override
  void initState() {
    super.initState();
    _loadMatches();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
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
    super.dispose();
  }

  void _loadMatches() {
    _matchesFuture = _service.loadMatchesForPlant(
      plantName: widget.plantName,
      scientificName: widget.scientificName,
      plantId: widget.plantId,
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
                'Loading common diseases & pests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Checking Firestore for matching records.',
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
                'Unable to load matching records.',
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
                    _loadMatches();
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

  Widget _buildEmptyState(BuildContext context, DiseaseLibraryMatchData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            'No matching diseases or pests found',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Firestore does not currently have library records for ${data.displayPlantName}.',
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

  Widget _buildIntroCard(BuildContext context, DiseaseLibraryMatchData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Common Diseases & Pests',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.displayPlantName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matched from the Firestore disease and pest library using the detected plant name and plant ID.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.eco_rounded,
                label: '${data.diseases.length} matches',
              ),
              _InfoChip(
                icon: Icons.tag_rounded,
                label: data.displayPlantId.isEmpty
                    ? 'Plant ID not resolved'
                    : data.displayPlantId,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    DiseaseLibraryMatchData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: data.diseases
          .map(
            (disease) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ConditionCard(disease: disease),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Common Diseases & Pests'),
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
            child: FutureBuilder<DiseaseLibraryMatchData>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(context);
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorState(
                    context,
                    snapshot.error ?? 'Unknown Firestore error',
                  );
                }

                final data = snapshot.data!;
                if (data.isEmpty) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildIntroCard(context, data),
                            const SizedBox(height: 18),
                            _buildEmptyState(context, data),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final width = MediaQuery.sizeOf(context).width;
                final contentWidth = width >= 1200
                    ? 1120.0
                    : width >= 920
                        ? 900.0
                        : width - 32;

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
                              _buildIntroCard(context, data),
                              const SizedBox(height: 18),
                              _buildResults(context, data),
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

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.disease,
  });

  final PlantDisease disease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiseaseImageBanner(
            disease: disease,
            height: 200,
            heroTag: 'common-disease-${disease.id}',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      disease.isPest ? 'Pest' : 'Disease',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DiseaseSeverityBadge(severity: disease.severity),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            disease.overview,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          DiseaseContentSection(
            title: 'Symptoms',
            subtitle: 'What to look for on the plant.',
            items: disease.symptoms,
          ),
          const SizedBox(height: 12),
          DiseaseContentSection(
            title: 'Causes',
            subtitle: 'Typical triggers and spread conditions.',
            items: disease.causes,
          ),
          const SizedBox(height: 12),
          DiseaseContentSection(
            title: 'Remedies / Treatment',
            subtitle: 'Practical steps to reduce the issue now.',
            items: disease.remedies,
          ),
          const SizedBox(height: 12),
          DiseaseContentSection(
            title: 'Prevention',
            subtitle: 'Ways to reduce the chance of it returning.',
            items: disease.prevention,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
