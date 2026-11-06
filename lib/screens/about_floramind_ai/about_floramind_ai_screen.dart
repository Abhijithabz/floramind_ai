import 'package:flutter/material.dart';

import '../../widgets/app_logo_placeholder.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/about_glass_card.dart';
import 'widgets/developer_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/footer_widget.dart';
import 'widgets/information_card.dart';
import 'widgets/technology_chip.dart';

class AboutFloraMindAiScreen extends StatefulWidget {
  const AboutFloraMindAiScreen({super.key});

  @override
  State<AboutFloraMindAiScreen> createState() => _AboutFloraMindAiScreenState();
}

class _AboutFloraMindAiScreenState extends State<AboutFloraMindAiScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const String _appName = 'FloraMind AI';
  static const String _version = '1.0.0';
  static const String _tagline = 'Your Intelligent AI Gardening Companion';

  static const List<_FeatureData> _objectives = [
    _FeatureData(
      title: 'Plant Identification',
      description: 'Recognize plants from photos with smart visual analysis.',
      icon: Icons.photo_camera_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _FeatureData(
      title: 'Disease Detection',
      description: 'Detect early symptoms and leaf issues before they spread.',
      icon: Icons.bug_report_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _FeatureData(
      title: 'Plant Recommendation',
      description: 'Suggest suitable plants based on your environment.',
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _FeatureData(
      title: 'Fertilizer Recommendation',
      description: 'Recommend nutrients for healthy and balanced growth.',
      icon: Icons.science_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _FeatureData(
      title: 'AI Gardening Assistant',
      description: 'Get quick gardening tips through a chat-style assistant.',
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF7CB342),
    ),
    _FeatureData(
      title: 'Nearby Nurseries',
      description: 'Locate useful nurseries and plant stores nearby.',
      icon: Icons.store_rounded,
      accentColor: Color(0xFF2B8A5A),
    ),
  ];

  static const List<_ModuleData> _aiModules = [
    _ModuleData(
      title: 'Plant Detection AI',
      description: 'Analyzes plant images and prepares identification results.',
      icon: Icons.photo_camera_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _ModuleData(
      title: 'Disease Detection AI',
      description: 'Reviews leaf patterns to flag possible disease symptoms.',
      icon: Icons.bug_report_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _ModuleData(
      title: 'Plant Recommendation AI',
      description: 'Matches plant choices with garden preferences and space.',
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _ModuleData(
      title: 'Fertilizer Recommendation AI',
      description: 'Suggests fertilizer guidance using garden context data.',
      icon: Icons.science_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _ModuleData(
      title: 'AI Chat Assistant',
      description:
          'Offers conversational support for daily gardening questions.',
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
  ];

  static const List<_TechData> _technologyStack = [
    _TechData(
      label: 'Flutter',
      icon: Icons.flutter_dash_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _TechData(
      label: 'Dart',
      icon: Icons.code_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _TechData(
      label: 'Python',
      icon: Icons.data_object_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _TechData(
      label: 'Flask',
      icon: Icons.cloud_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _TechData(
      label: 'TensorFlow',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
    _TechData(
      label: 'MySQL',
      icon: Icons.storage_rounded,
      accentColor: Color(0xFF7CB342),
    ),
    _TechData(
      label: 'Material 3',
      icon: Icons.palette_rounded,
      accentColor: Color(0xFF2B8A5A),
    ),
    _TechData(
      label: 'REST API',
      icon: Icons.api_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _TechData(
      label: 'Git & GitHub',
      icon: Icons.merge_type_rounded,
      accentColor: Color(0xFFF4A261),
    ),
  ];

  static const List<_FeatureData> _futureEnhancements = [
    _FeatureData(
      title: 'Weather Integration',
      description: 'Use weather data to improve irrigation and care advice.',
      icon: Icons.wb_cloudy_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _FeatureData(
      title: 'Voice Assistant',
      description: 'Add hands-free gardening guidance through voice input.',
      icon: Icons.mic_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _FeatureData(
      title: 'Cloud Backup',
      description: 'Save garden records safely across devices later.',
      icon: Icons.cloud_done_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _FeatureData(
      title: 'Smart Scheduling',
      description: 'Plan watering and reminders around real garden needs.',
      icon: Icons.schedule_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _FeatureData(
      title: 'Predictive AI Analytics',
      description: 'Forecast plant health trends using data-driven models.',
      icon: Icons.analytics_rounded,
      accentColor: Color(0xFF5EAF61),
    ),
  ];

  static const List<_DeveloperData> _developerInfo = [
    _DeveloperData(
      label: 'Developer Name',
      value: 'Your Name',
      icon: Icons.person_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _DeveloperData(
      label: 'College',
      value: 'Your College Name',
      icon: Icons.school_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _DeveloperData(
      label: 'Course',
      value: 'Your Course Name',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _DeveloperData(
      label: 'Project',
      value: 'FloraMind AI',
      icon: Icons.eco_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _DeveloperData(
      label: 'Guide',
      value: 'Your Guide Name',
      icon: Icons.psychology_alt_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
    _DeveloperData(
      label: 'Email',
      value: 'your.email@example.com',
      icon: Icons.email_rounded,
      accentColor: Color(0xFF5EAF61),
    ),
  ];

  static const List<_AcknowledgementData> _acknowledgements = [
    _AcknowledgementData(
      title: 'Open Source Community',
      description:
          'For the tools, packages, and shared knowledge that made this project possible.',
      icon: Icons.volunteer_activism_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _AcknowledgementData(
      title: 'Flutter Team',
      description:
          'For building a fast, expressive framework that powers this UI experience.',
      icon: Icons.flutter_dash_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _AcknowledgementData(
      title: 'TensorFlow Team',
      description:
          'For the AI ecosystem that helps power intelligent garden features.',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _AcknowledgementData(
      title: 'College Faculty',
      description:
          'For guidance, encouragement, and review throughout the project.',
      icon: Icons.groups_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLegalMessage(String title) {
    _showSnackBar('$title will be connected later');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('About FloraMind AI'),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final contentWidth = width >= 1240
                    ? 1160.0
                    : width >= 920
                    ? 900.0
                    : width - 32;

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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HeroSection(
                                appName: _appName,
                                version: _version,
                                tagline: _tagline,
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Project Overview',
                                subtitle:
                                    'A concise summary of the idea behind FloraMind AI.',
                              ),
                              const SizedBox(height: 16),
                              const InformationCard(
                                title: 'Project Overview',
                                description:
                                    'FloraMind AI is an AI-powered gardening application that helps users identify plants, detect diseases, discover suitable plants and fertilizers, and care for their gardens.',
                                icon: Icons.eco_rounded,
                                accentColor: Color(0xFF2E7D32),
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Our Objectives',
                                subtitle:
                                    'Key gardening capabilities designed to make plant care smarter.',
                              ),
                              const SizedBox(height: 16),
                              _FeatureGrid(items: _objectives),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'AI Modules',
                                subtitle:
                                    'AI-powered components planned for the next integration phase.',
                              ),
                              const SizedBox(height: 16),
                              _ModuleGrid(items: _aiModules),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Technology Stack',
                                subtitle:
                                    'Modern tools and frameworks used to build FloraMind AI.',
                              ),
                              const SizedBox(height: 16),
                              _TechGrid(items: _technologyStack),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Future Enhancements',
                                subtitle:
                                    'Ideas planned for future releases of the application.',
                              ),
                              const SizedBox(height: 16),
                              _FeatureGrid(items: _futureEnhancements),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Developer Information',
                                subtitle:
                                    'Placeholder details for the project author and academic information.',
                              ),
                              const SizedBox(height: 16),
                              _DeveloperGrid(items: _developerInfo),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Acknowledgements',
                                subtitle:
                                    'A note of appreciation to the people and communities behind the tools we use.',
                              ),
                              const SizedBox(height: 16),
                              _AcknowledgementGrid(items: _acknowledgements),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Legal Information',
                                subtitle:
                                    'These buttons currently show SnackBars and will be linked later.',
                              ),
                              const SizedBox(height: 16),
                              _LegalActions(
                                onPrivacyPolicy: () =>
                                    _showLegalMessage('Privacy Policy'),
                                onTerms: () =>
                                    _showLegalMessage('Terms & Conditions'),
                                onLicenses: () =>
                                    _showLegalMessage('Open Source Licenses'),
                              ),
                              const SizedBox(height: 20),
                              const FooterWidget(),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.appName,
    required this.version,
    required this.tagline,
  });

  final String appName;
  final String version;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AboutGlassCard(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;

          final logo = Container(
            width: 144,
            height: 144,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.22),
                  const Color(0xFFB7E4C7).withValues(alpha: 0.18),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F4C2B).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const AppLogoPlaceholder(size: 120),
          );

          final textColumn = Column(
            crossAxisAlignment: wide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Text(
                  'AI Smart Garden Application',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                appName,
                textAlign: wide ? TextAlign.left : TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Version $version',
                textAlign: wide ? TextAlign.left : TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tagline,
                textAlign: wide ? TextAlign.left : TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _MiniTag(
                    label: 'AI Powered',
                    icon: Icons.auto_awesome_rounded,
                  ),
                  _MiniTag(label: 'Material 3', icon: Icons.palette_rounded),
                ],
              ),
            ],
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                logo,
                const SizedBox(width: 22),
                Expanded(child: textColumn),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: logo),
              const SizedBox(height: 18),
              textColumn,
            ],
          );
        },
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items});

  final List<_FeatureData> items;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveWrap(
      items: items,
      childBuilder: (item) => FeatureCard(
        title: item.title,
        description: item.description,
        icon: item.icon,
        accentColor: item.accentColor,
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.items});

  final List<_ModuleData> items;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveWrap(
      items: items,
      childBuilder: (item) => InformationCard(
        title: item.title,
        description: item.description,
        icon: item.icon,
        accentColor: item.accentColor,
        badgeLabel: 'Integration Coming Soon',
      ),
    );
  }
}

class _TechGrid extends StatelessWidget {
  const _TechGrid({required this.items});

  final List<_TechData> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => TechnologyChip(
              label: item.label,
              icon: item.icon,
              accentColor: item.accentColor,
            ),
          )
          .toList(),
    );
  }
}

class _DeveloperGrid extends StatelessWidget {
  const _DeveloperGrid({required this.items});

  final List<_DeveloperData> items;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveWrap(
      items: items,
      childBuilder: (item) => DeveloperCard(
        label: item.label,
        value: item.value,
        icon: item.icon,
        accentColor: item.accentColor,
      ),
    );
  }
}

class _AcknowledgementGrid extends StatelessWidget {
  const _AcknowledgementGrid({required this.items});

  final List<_AcknowledgementData> items;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveWrap(
      items: items,
      childBuilder: (item) => InformationCard(
        title: item.title,
        description: item.description,
        icon: item.icon,
        accentColor: item.accentColor,
      ),
    );
  }
}

class _ResponsiveWrap<T> extends StatelessWidget {
  const _ResponsiveWrap({required this.items, required this.childBuilder});

  final List<T> items;
  final Widget Function(T item) childBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1180
            ? 3
            : width >= 760
            ? 2
            : 1;
        final gap = 14.0;
        final cardWidth = columns == 1
            ? width
            : ((width - ((columns - 1) * gap)) / columns)
                  .clamp(220.0, 420.0)
                  .toDouble();

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(width: cardWidth, child: childBuilder(item)),
              )
              .toList(),
        );
      },
    );
  }
}

class _LegalActions extends StatelessWidget {
  const _LegalActions({
    required this.onPrivacyPolicy,
    required this.onTerms,
    required this.onLicenses,
  });

  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTerms;
  final VoidCallback onLicenses;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 620
            ? 2
            : 1;
        final gap = 12.0;
        final buttonWidth = columns == 1
            ? width
            : ((width - ((columns - 1) * gap)) / columns)
                  .clamp(210.0, 360.0)
                  .toDouble();

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: buttonWidth,
              child: FilledButton.icon(
                onPressed: onPrivacyPolicy,
                icon: const Icon(Icons.privacy_tip_rounded),
                label: const Text('Privacy Policy'),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: OutlinedButton.icon(
                onPressed: onTerms,
                icon: const Icon(Icons.description_rounded),
                label: const Text('Terms & Conditions'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: FilledButton.tonalIcon(
                onPressed: onLicenses,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open Source Licenses'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.primary.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}

class _ModuleData {
  const _ModuleData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}

class _TechData {
  const _TechData({
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
}

class _DeveloperData {
  const _DeveloperData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
}

class _AcknowledgementData {
  const _AcknowledgementData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}
