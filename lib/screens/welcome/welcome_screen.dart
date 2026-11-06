import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../authentication/login_screen.dart';
import 'widgets/welcome_background.dart';
import 'widgets/welcome_cta_button.dart';
import 'widgets/welcome_feature_card.dart';
import 'widgets/welcome_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.center_focus_strong_rounded,
      title: 'Plant Identification',
      description: 'Instantly recognize plants with AI vision.',
    ),
    _FeatureData(
      icon: Icons.bug_report_rounded,
      title: 'Disease Detection',
      description: 'Spot leaf issues early with smart analysis.',
    ),
    _FeatureData(
      icon: Icons.smart_toy_rounded,
      title: 'AI Plant Assistant',
      description: 'Ask for care tips anytime like a gardening expert.',
    ),
    _FeatureData(
      icon: Icons.spa_rounded,
      title: 'Plant Recommendation',
      description: 'Discover plants that fit your space and climate.',
    ),
    _FeatureData(
      icon: Icons.science_rounded,
      title: 'Fertilizer Recommendation',
      description: 'Choose the right nutrients for stronger growth.',
    ),
    _FeatureData(
      icon: Icons.store_rounded,
      title: 'Nearby Nurseries',
      description: 'Find trusted garden shops and plant suppliers nearby.',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: WelcomeBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final isCompact = width < 600;
                final contentWidth = width >= 1100
                    ? 1040.0
                    : width >= 800
                    ? 760.0
                    : width >= 600
                    ? 640.0
                    : width - 32;
                final horizontalPadding = isCompact ? 16.0 : 24.0;
                final cardWidth = width >= 1024
                    ? 230.0
                    : width >= 720
                    ? ((contentWidth - 24) / 2).clamp(220.0, 260.0).toDouble()
                    : contentWidth;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: math.max(16.0, height * 0.03),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const WelcomeLogo(),
                            const SizedBox(height: 22),
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary,
                                    const Color(0xFF8BC34A),
                                    const Color(0xFF2E7D32),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'FloraMind AI',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                  color: Colors.white,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your Smart Gardening Assistant',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.96,
                                ),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(_features.length, (
                                index,
                              ) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: WelcomeFeatureCard(
                                    icon: _features[index].icon,
                                    title: _features[index].title,
                                    description: _features[index].description,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 26),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: WelcomeCtaButton(
                                label: 'Get Started',
                                icon: Icons.eco_rounded,
                                onPressed: _openLogin,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
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

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
