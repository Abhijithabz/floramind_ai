import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/nearby_nursery.dart';
import '../../services/nearby_nurseries/nearby_nursery_location_service.dart';
import '../../services/nearby_nurseries/nearby_nurseries_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/nursery_card.dart';
import 'widgets/nursery_filter_chip.dart';
import 'widgets/recommended_nursery_card.dart';

class NearbyNurseriesScreen extends StatefulWidget {
  const NearbyNurseriesScreen({super.key});

  @override
  State<NearbyNurseriesScreen> createState() => _NearbyNurseriesScreenState();
}

class _NearbyNurseriesScreenState extends State<NearbyNurseriesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final NearbyNurseryLocationService _locationService =
      const NearbyNurseryLocationService();
  final NearbyNurseriesService _nurseryService =
      NearbyNurseryServiceFactory.create();

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  List<NearbyNursery> _nurseries = <NearbyNursery>[];
  NearbyLocationSnapshot _locationSnapshot = const NearbyLocationSnapshot(
    state: NearbyLocationState.loading,
    message: 'Checking your location...',
  );
  String _selectedCategory = 'All';
  String _generalErrorMessage = '';
  bool _isLoading = true;

  static const List<String> _categories = <String>[
    'All',
    'Plants',
    'Fertilizers',
    'Seeds',
    'Pots',
    'Garden Tools',
  ];

  @override
  void initState() {
    super.initState();
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generalErrorMessage = '';
      _locationSnapshot = const NearbyLocationSnapshot(
        state: NearbyLocationState.loading,
        message: 'Checking your location...',
      );
    });

    final locationSnapshot = await _locationService.resolveCurrentLocation();

    try {
      final hasRealLocation = locationSnapshot.location != null;
      final nurseries = hasRealLocation
          ? await _nurseryService.fetchNurseries(
              currentLocation: locationSnapshot.location,
            )
          : const <NearbyNursery>[];

      final liveResultsEmpty = nurseries.isEmpty;

      if (!mounted) {
        return;
      }

      setState(() {
        _locationSnapshot = locationSnapshot;
        _nurseries = nurseries;
        _generalErrorMessage = !hasRealLocation
            ? 'Your location is required to show real nearby nurseries.'
            : liveResultsEmpty
            ? 'No verified nursery listings were returned near your location. Use Maps to find real businesses nearby.'
            : '';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _locationSnapshot = locationSnapshot;
        // Do not show fixed demo coordinates as nearby real businesses.
        _nurseries = const <NearbyNursery>[];
        _generalErrorMessage =
            'Live nursery search is unavailable. Use Maps to find real nurseries near your current location.';
        _isLoading = false;
      });
    }
  }

  List<NearbyNursery> get _filteredNurseries {
    final query = _searchController.text;
    final filtered = _nurseries
        .where((nursery) {
          return nursery.matchesCategory(_selectedCategory) &&
              nursery.matchesQuery(query);
        })
        .toList(growable: true);

    filtered.sort(_compareByDistanceThenRating);
    return filtered;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _callNursery(NearbyNursery nursery) async {
    final phoneUri = Uri(
      scheme: 'tel',
      path: nursery.contactNumber.replaceAll(' ', ''),
    );

    final launched = await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _showMessage('Unable to open the phone app right now.');
    }
  }

  Future<void> _openDirections(NearbyNursery nursery) async {
    // Use coordinates for both ends so Maps cannot resolve a similarly named
    // nursery in another city.
    final destination = '${nursery.latitude},${nursery.longitude}';
    final origin = _locationSnapshot.location;
    final mapsUri = Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      if (origin != null) 'origin': '${origin.latitude},${origin.longitude}',
      'destination': destination,
      'travelmode': 'driving',
      'dir_action': 'navigate',
    });

    final launched = await launchUrl(
      mapsUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _showMessage('Unable to open directions right now.');
    }
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _openRealNurseriesSearch() async {
    final location = _locationSnapshot.location;
    if (location == null) {
      _showMessage('Refresh your location before searching nearby nurseries.');
      return;
    }

    final query = Uri.encodeComponent(
      'plant nurseries near ${location.latitude},${location.longitude}',
    );
    final mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    final launched = await launchUrl(
      mapsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _showMessage('Unable to open Google Maps right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Nearby Nurseries'),
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
            child: _isLoading
                ? _LoadingStateCard(message: _locationSnapshot.message)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final contentWidth = width >= 1240
                          ? 1160.0
                          : width >= 920
                          ? 900.0
                          : width - 32;
                      final columns = width >= 1120
                          ? 2
                          : width >= 720
                          ? 2
                          : 1;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: contentWidth),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Discover nearby nurseries for plants, fertilizers, seeds, pots, and gardening supplies.',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            height: 1.5,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    _LocationSummaryCard(
                                      snapshot: _locationSnapshot,
                                      onRetry: _bootstrap,
                                      onOpenAppSettings: _openAppSettings,
                                      onOpenLocationSettings:
                                          _openLocationSettings,
                                    ),
                                    if (_generalErrorMessage.isNotEmpty) ...[
                                      const SizedBox(height: 14),
                                      _ErrorStateCard(
                                        message: _generalErrorMessage,
                                        onRetry: _bootstrap,
                                        onOpenMaps: _openRealNurseriesSearch,
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    _SearchField(
                                      controller: _searchController,
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      onClear: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: _categories
                                            .map(
                                              (category) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: NurseryFilterChip(
                                                  label: category,
                                                  selected:
                                                      _selectedCategory ==
                                                      category,
                                                  onSelected: () {
                                                    setState(() {
                                                      _selectedCategory =
                                                          category;
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList(growable: false),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _SectionHeader(
                                      title: 'Nurseries Nearby',
                                      subtitle:
                                          'Nearest nurseries appear first, with distance acting as the main sort order.',
                                    ),
                                    const SizedBox(height: 16),
                                    LayoutBuilder(
                                      builder: (context, nurseryConstraints) {
                                        final gap = 14.0;
                                        final cardWidth = columns == 1
                                            ? nurseryConstraints.maxWidth
                                            : ((nurseryConstraints.maxWidth -
                                                          gap) /
                                                      2)
                                                  .clamp(260.0, 440.0)
                                                  .toDouble();

                                        final nurseries = _filteredNurseries;
                                        final recommendedNursery =
                                            nurseries.isEmpty
                                            ? null
                                            : nurseries.first;

                                        return Wrap(
                                          spacing: gap,
                                          runSpacing: gap,
                                          children: nurseries.isEmpty
                                              ? [
                                                  SizedBox(
                                                    width: nurseryConstraints
                                                        .maxWidth,
                                                    child: _NoResultsStateCard(
                                                      onClearFilters: () {
                                                        setState(() {
                                                          _selectedCategory =
                                                              'All';
                                                          _searchController
                                                              .clear();
                                                        });
                                                      },
                                                      onOpenMaps:
                                                          _openRealNurseriesSearch,
                                                    ),
                                                  ),
                                                ]
                                              : [
                                                  ...nurseries
                                                      .map(
                                                        (nursery) => SizedBox(
                                                          width: cardWidth,
                                                          child: NurseryCard(
                                                            nurseryName:
                                                                nursery.name,
                                                            address:
                                                                nursery.address,
                                                            distance: nursery
                                                                .distanceLabel,
                                                            rating:
                                                                nursery.rating,
                                                            openingHours: nursery
                                                                .openingHours,
                                                            openingStatus: nursery
                                                                .openingStatusLabel,
                                                            isOpenNow: nursery
                                                                .isOpenNow,
                                                            contactNumber: nursery
                                                                .contactNumber,
                                                            availableServices:
                                                                nursery
                                                                    .services,
                                                            homeDelivery: true,
                                                            description: nursery
                                                                .description,
                                                            accentColor: nursery
                                                                .accentColor,
                                                            onViewDetails: () =>
                                                                _openDirections(
                                                                  nursery,
                                                                ),
                                                            onCallNursery: () =>
                                                                _callNursery(
                                                                  nursery,
                                                                ),
                                                            onGetDirections: () =>
                                                                _openDirections(
                                                                  nursery,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(growable: false),
                                                  if (recommendedNursery !=
                                                      null) ...[
                                                    SizedBox(
                                                      width: nurseryConstraints
                                                          .maxWidth,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          const _SectionHeader(
                                                            title:
                                                                'Recommended Nursery',
                                                            subtitle:
                                                                'The nearest verified nursery found near your current location.',
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          RecommendedNurseryCard(
                                                            nurseryName:
                                                                recommendedNursery
                                                                    .name,
                                                            address:
                                                                recommendedNursery
                                                                    .address,
                                                            distance:
                                                                recommendedNursery
                                                                    .distanceLabel,
                                                            rating:
                                                                recommendedNursery
                                                                    .rating,
                                                            openingHours:
                                                                recommendedNursery
                                                                    .openingHours,
                                                            openingStatus:
                                                                recommendedNursery
                                                                    .openingStatusLabel,
                                                            isOpenNow:
                                                                recommendedNursery
                                                                    .isOpenNow,
                                                            contactNumber:
                                                                recommendedNursery
                                                                    .contactNumber,
                                                            availableServices:
                                                                recommendedNursery
                                                                    .services,
                                                            homeDelivery: true,
                                                            description:
                                                                recommendedNursery
                                                                    .description,
                                                            accentColor:
                                                                recommendedNursery
                                                                    .accentColor,
                                                            onViewDetails: () =>
                                                                _openDirections(
                                                                  recommendedNursery,
                                                                ),
                                                            onCallNursery: () =>
                                                                _callNursery(
                                                                  recommendedNursery,
                                                                ),
                                                            onGetDirections: () =>
                                                                _openDirections(
                                                                  recommendedNursery,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
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

int _compareByDistanceThenRating(NearbyNursery left, NearbyNursery right) {
  final distanceComparison = left.sortDistanceKm.compareTo(
    right.sortDistanceKm,
  );
  if (distanceComparison != 0) {
    return distanceComparison;
  }

  final ratingComparison = right.rating.compareTo(left.rating);
  if (ratingComparison != 0) {
    return ratingComparison;
  }

  return left.name.compareTo(right.name);
}

class _LocationSummaryCard extends StatelessWidget {
  const _LocationSummaryCard({
    required this.snapshot,
    required this.onRetry,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final NearbyLocationSnapshot snapshot;
  final VoidCallback onRetry;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isReady = snapshot.state == NearbyLocationState.ready;
    final isPermissionIssue =
        snapshot.state == NearbyLocationState.permissionDenied ||
        snapshot.state == NearbyLocationState.permissionDeniedForever ||
        snapshot.state == NearbyLocationState.serviceDisabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.86),
            colorScheme.primaryContainer.withValues(alpha: 0.26),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isReady
                      ? Icons.my_location_rounded
                      : Icons.location_off_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReady ? 'Current location' : 'Location access',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isReady) ...[
            const SizedBox(height: 14),
            Text(
              'Enable location to search real nurseries near your current location.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh Location'),
              ),
              if (isPermissionIssue)
                OutlinedButton.icon(
                  onPressed:
                      snapshot.state == NearbyLocationState.serviceDisabled
                      ? onOpenLocationSettings
                      : onOpenAppSettings,
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Open Settings'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingStateCard extends StatelessWidget {
  const _LoadingStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.86),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 14),
              Text(
                'Loading nearby nurseries...',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
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
}

class _ErrorStateCard extends StatelessWidget {
  const _ErrorStateCard({
    required this.message,
    required this.onRetry,
    required this.onOpenMaps,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.84),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 44, color: colorScheme.error),
          const SizedBox(height: 10),
          Text(
            'Nearby nurseries unavailable',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onOpenMaps,
            icon: const Icon(Icons.map_rounded),
            label: const Text('Find Real Nurseries in Maps'),
          ),
        ],
      ),
    );
  }
}

class _NoResultsStateCard extends StatelessWidget {
  const _NoResultsStateCard({
    required this.onClearFilters,
    required this.onOpenMaps,
  });

  final VoidCallback onClearFilters;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.84),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_florist_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No nurseries found',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term or clear the current filter.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Clear Filters'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onOpenMaps,
            icon: const Icon(Icons.map_rounded),
            label: const Text('Search Real Nurseries in Maps'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.26),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F4C2B).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.90),
              colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search nurseries...',
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
