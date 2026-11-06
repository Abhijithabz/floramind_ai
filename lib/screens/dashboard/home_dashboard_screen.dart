import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../crop_library/crop_library_screen.dart';
import '../flower_library/flower_library_screen.dart';
import '../../l10n/app_strings.dart';
import 'placeholders/ai_plant_assistant_placeholder_screen.dart';
import 'placeholders/disease_detection_placeholder_screen.dart';
import 'placeholders/fertilizer_recommendation_placeholder_screen.dart';
import 'placeholders/nearby_nurseries_placeholder_screen.dart';
import 'placeholders/notifications_tab_placeholder_screen.dart';
import 'placeholders/help_support_placeholder_screen.dart';
import 'placeholders/garden_store_placeholder_screen.dart';
import 'placeholders/plant_detection_placeholder_screen.dart';
import 'placeholders/plant_recommendation_placeholder_screen.dart';
import 'placeholders/profile_placeholder_screen.dart';
import 'placeholders/profile_tab_placeholder_screen.dart';
import 'placeholders/settings_placeholder_screen.dart';
import 'widgets/dashboard_background.dart';
import 'widgets/dashboard_banner_card.dart';
import 'widgets/dashboard_feature_card.dart';
import 'widgets/dashboard_search_bar.dart';
import 'widgets/dashboard_weather_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;
  late final List<_DashboardFeatureItem> _featureItems;

  @override
  void initState() {
    super.initState();

    _featureItems = [
      _DashboardFeatureItem(
        title: 'Plant Detection',
        description: 'Identify plants quickly using smart visual analysis.',
        icon: Icons.photo_camera_rounded,
        builder: (_) => const PlantDetectionPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Disease Detection',
        description: 'Spot leaf issues and possible plant diseases early.',
        icon: Icons.bug_report_rounded,
        builder: (_) => const DiseaseDetectionPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Crops',
        description:
            'Explore growing conditions, soil, companions, and crop rotation.',
        icon: Icons.agriculture_rounded,
        builder: (_) => const CropLibraryScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Flowering Plants',
        description: 'Learn how to grow common garden and ornamental flowers.',
        icon: Icons.local_florist_rounded,
        builder: (_) => const FlowerLibraryScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Plant Recommendation',
        description: 'Discover plants that match your space and climate.',
        icon: Icons.spa_rounded,
        builder: (_) => const PlantRecommendationPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Fertilizer Recommendation',
        description: 'Choose balanced nutrients for healthier growth.',
        icon: Icons.science_rounded,
        builder: (_) => const FertilizerRecommendationPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'AI Plant Assistant',
        description: 'Ask care questions and get instant gardening help.',
        icon: Icons.smart_toy_rounded,
        builder: (_) => const AIPlantAssistantPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Nearby Nurseries',
        description: 'Find trusted garden stores and nurseries nearby.',
        icon: Icons.store_rounded,
        builder: (_) => const NearbyNurseriesPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Garden Store',
        description: 'Buy and sell plants, gardening products and supplies.',
        icon: Icons.shopping_bag_rounded,
        builder: (_) => const GardenStorePlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Profile',
        description: 'View and manage your garden account settings.',
        icon: Icons.person_outline_rounded,
        builder: (_) => const ProfilePlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Settings',
        description: 'Customize your app, language, and garden preferences.',
        icon: Icons.settings_rounded,
        builder: (_) => const SettingsPlaceholderScreen(),
      ),
      _DashboardFeatureItem(
        title: 'Help & Support',
        description: 'Find answers, contact support, and share feedback.',
        icon: Icons.help_center_rounded,
        builder: (_) => const HelpSupportPlaceholderScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openFeature(WidgetBuilder builder) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }

  void _onTabSelected(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    if (_selectedIndex == 0) {
      return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 92,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              strings.goodMorning,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              strings.guestUser,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: _DashboardAvatar(),
          ),
        ],
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
      surfaceTintColor: Colors.transparent,
      title: Text(
        _tabLabel(_selectedIndex, strings),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: const [
        Padding(padding: EdgeInsets.only(right: 18), child: _DashboardAvatar()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pageForIndex(_selectedIndex),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        elevation: 12,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: strings.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: strings.notifications,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: strings.profile,
          ),
        ],
      ),
    );
  }

  Widget _pageForIndex(int index) {
    if (index == 0) {
      return _HomeDashboardContent(
        key: const PageStorageKey<String>('home_dashboard_content'),
        featureItems: _featureItems,
        onFeatureTap: _openFeature,
      );
    }

    if (index == 1) {
      return const NotificationsTabPlaceholderScreen();
    }

    return const ProfileTabPlaceholderScreen();
  }

  String _tabLabel(int index, AppStrings strings) {
    switch (index) {
      case 0:
        return strings.home;
      case 1:
        return strings.notifications;
      default:
        return strings.profile;
    }
  }
}

class _HomeDashboardContent extends StatefulWidget {
  const _HomeDashboardContent({
    super.key,
    required this.featureItems,
    required this.onFeatureTap,
  });

  final List<_DashboardFeatureItem> featureItems;
  final ValueChanged<WidgetBuilder> onFeatureTap;

  @override
  State<_HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<_HomeDashboardContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bannerFade;
  late final Animation<Offset> _bannerSlide;
  late final Animation<double> _searchFade;
  late final Animation<Offset> _searchSlide;
  late final Animation<double> _sectionFade;
  late final List<_CardReveal> _cardReveals;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _bannerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.02, 0.24, curve: Curves.easeOut),
    );
    _bannerSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.02, 0.28, curve: Curves.easeOutCubic),
          ),
        );
    _searchFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.32, curve: Curves.easeOut),
    );
    _searchSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.10, 0.34, curve: Curves.easeOutCubic),
          ),
        );
    _sectionFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.40, curve: Curves.easeOut),
    );

    _cardReveals = List.generate(widget.featureItems.length, (index) {
      final start = 0.24 + (index * 0.05);
      final end = math.min(start + 0.28, 1.0);
      return _CardReveal(
        fade: CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
        slide: Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              ),
            ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        const Positioned.fill(child: DashboardBackground()),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width >= 1200
                ? 40.0
                : width >= 900
                ? 28.0
                : 18.0;
            final contentMaxWidth = width >= 1200 ? 1180.0 : width;
            final columns = width >= 1120
                ? 3
                : width >= 760
                ? 2
                : 1;
            final gap = 14.0;
            final cardWidth = columns == 1
                ? contentMaxWidth - (horizontalPadding * 2)
                : ((contentMaxWidth -
                              (horizontalPadding * 2) -
                              ((columns - 1) * gap)) /
                          columns)
                      .clamp(220.0, 340.0)
                      .toDouble();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                28,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeTransition(
                        opacity: _bannerFade,
                        child: SlideTransition(
                          position: _bannerSlide,
                          child: const DashboardBannerCard(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const DashboardWeatherCard(),
                      const SizedBox(height: 18),
                      FadeTransition(
                        opacity: _searchFade,
                        child: SlideTransition(
                          position: _searchSlide,
                          child: const DashboardSearchBar(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _sectionFade,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.exploreFeatures,
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    strings.featuresSubtitle,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: List.generate(widget.featureItems.length, (
                          index,
                        ) {
                          final item = widget.featureItems[index];
                          return SizedBox(
                            width: cardWidth,
                            child: FadeTransition(
                              opacity: _cardReveals[index].fade,
                              child: SlideTransition(
                                position: _cardReveals[index].slide,
                                child: DashboardFeatureCard(
                                  icon: item.icon,
                                  title: item.title,
                                  description: item.description,
                                  onTap: () =>
                                      widget.onFeatureTap(item.builder),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DashboardFeatureItem {
  const _DashboardFeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

class _CardReveal {
  const _CardReveal({required this.fade, required this.slide});

  final Animation<double> fade;
  final Animation<Offset> slide;
}

class _TabItem {
  const _TabItem({required this.label});

  final String label;
}

class _DashboardAvatar extends StatelessWidget {
  const _DashboardAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(1.3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            const Color(0xFF8BC34A),
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF6FBF4),
        ),
        child: Icon(
          Icons.person_rounded,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
