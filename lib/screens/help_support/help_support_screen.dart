import 'package:flutter/material.dart';

import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/help_contact_card.dart';
import 'widgets/help_emergency_tip_card.dart';
import 'widgets/help_faq_card.dart';
import 'widgets/help_feedback_card.dart';
import 'widgets/help_guide_card.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 5;

  static const List<_FaqData> _faqs = [
    _FaqData(
      question: 'How do I identify a plant?',
      answer:
          'Use the Plant Detection module and scan a clear image of the plant to view the predicted plant type and key details.',
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _FaqData(
      question: 'How does disease detection work?',
      answer:
          'The Disease Detection module analyzes leaf appearance in the frontend today and will later connect to AI-powered disease prediction.',
      icon: Icons.bug_report_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _FaqData(
      question: 'How are fertilizer recommendations generated?',
      answer:
          'Fertilizer recommendations use the plant, growth stage, condition, soil, and optional NPK details you provide.',
      icon: Icons.science_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
  ];

  static const List<_ContactData> _contacts = [
    _ContactData(
      title: 'Email Support',
      value: 'support@floramind.ai',
      subtitle: 'Get help by sending us a message.',
      icon: Icons.email_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _ContactData(
      title: 'Phone Support',
      value: '+91 XXXXX XXXXX',
      subtitle: 'Speak with the support team directly.',
      icon: Icons.call_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _ContactData(
      title: 'Working Hours',
      value: 'Monday - Saturday\n9:00 AM - 6:00 PM',
      subtitle: 'Support is available during business hours.',
      icon: Icons.schedule_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
  ];

  static const List<_GuideData> _guides = [
    _GuideData(
      title: 'Getting Started',
      subtitle: 'Learn the basics of FloraMind AI.',
      icon: Icons.play_circle_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _GuideData(
      title: 'Using AI Features',
      subtitle: 'Understand plant, disease, and fertilizer tools.',
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _GuideData(
      title: 'Understanding Recommendations',
      subtitle: 'See how plant and fertilizer suggestions are presented.',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFFF4A261),
    ),
  ];

  static const List<_TipData> _tips = [
    _TipData(
      title: 'Plant wilting',
      subtitle: 'Check soil moisture and watering schedule first.',
      icon: Icons.local_florist_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _TipData(
      title: 'Yellow leaves',
      subtitle: 'Look for overwatering, low nutrients, or poor drainage.',
      icon: Icons.eco_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _TipData(
      title: 'Brown spots',
      subtitle: 'Inspect for fungal issues and excess moisture.',
      icon: Icons.bug_report_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _TipData(
      title: 'Root rot',
      subtitle: 'Reduce watering and improve soil drainage.',
      icon: Icons.water_damage_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _TipData(
      title: 'Overwatering',
      subtitle: 'Let the soil dry slightly before watering again.',
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
    _TipData(
      title: 'Underwatering',
      subtitle: 'Increase watering frequency during dry weather.',
      icon: Icons.bubble_chart_rounded,
      accentColor: Color(0xFF5EAF61),
    ),
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _problemController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<_FaqData> get _filteredFaqs {
    final query = _searchController.text.trim().toLowerCase();
    return _faqs.where((faq) {
      return query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
    }).toList();
  }

  void _submitReport() {
    if (_problemController.text.trim().isEmpty) {
      _showMessage('Please describe your issue before submitting');
      return;
    }
    _showMessage('Problem report will be connected later');
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      _showMessage('Please share your feedback before submitting');
      return;
    }
    _showMessage('Feedback will be connected later');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final faqs = _filteredFaqs;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Help & Support'),
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
                final contactColumns = width >= 1120
                    ? 3
                    : width >= 760
                    ? 2
                    : 1;
                final guideColumns = width >= 1120
                    ? 3
                    : width >= 760
                    ? 2
                    : 1;
                final tipColumns = width >= 1120
                    ? 3
                    : width >= 760
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Need assistance? Find answers, contact support, and share your feedback.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _SearchCard(
                                controller: _searchController,
                                onChanged: (value) => setState(() {}),
                                onClear: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Frequently Asked Questions (FAQs)',
                                subtitle:
                                    'Tap a question to expand the answer and learn more about FloraMind AI.',
                              ),
                              const SizedBox(height: 16),
                              faqs.isEmpty
                                  ? _EmptyStateCard(
                                      onReset: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  : LayoutBuilder(
                                      builder: (context, faqConstraints) {
                                        final gap = 14.0;
                                        final cardWidth = width >= 980
                                            ? ((faqConstraints.maxWidth - gap) /
                                                      2)
                                                  .clamp(240.0, 520.0)
                                                  .toDouble()
                                            : faqConstraints.maxWidth;

                                        return Wrap(
                                          spacing: gap,
                                          runSpacing: gap,
                                          children: faqs
                                              .map(
                                                (faq) => SizedBox(
                                                  width: cardWidth,
                                                  child: HelpFaqCard(
                                                    question: faq.question,
                                                    answer: faq.answer,
                                                    icon: faq.icon,
                                                    accentColor:
                                                        faq.accentColor,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Contact Support',
                                subtitle:
                                    'Choose a contact method that works best for you.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, contactConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = contactColumns == 1
                                      ? contactConstraints.maxWidth
                                      : ((contactConstraints.maxWidth -
                                                    ((contactColumns - 1) *
                                                        gap)) /
                                                contactColumns)
                                            .clamp(220.0, 360.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _contacts
                                        .map(
                                          (contact) => SizedBox(
                                            width: cardWidth,
                                            child: HelpContactCard(
                                              title: contact.title,
                                              value: contact.value,
                                              subtitle: contact.subtitle,
                                              icon: contact.icon,
                                              accentColor: contact.accentColor,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              LayoutBuilder(
                                builder: (context, buttonConstraints) {
                                  final gap = 14.0;
                                  final buttonWidth =
                                      buttonConstraints.maxWidth >= 760
                                      ? ((buttonConstraints.maxWidth -
                                                    ((3 - 1) * gap)) /
                                                3)
                                            .clamp(220.0, 360.0)
                                            .toDouble()
                                      : buttonConstraints.maxWidth;

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      SizedBox(
                                        width: buttonWidth,
                                        child: FilledButton.icon(
                                          onPressed: () => _showMessage(
                                            'Send Email will be connected later',
                                          ),
                                          icon: const Icon(Icons.email_rounded),
                                          label: const Text('Send Email'),
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              52,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: buttonWidth,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showMessage(
                                            'Call Support will be connected later',
                                          ),
                                          icon: const Icon(Icons.call_rounded),
                                          label: const Text('Call Support'),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              52,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: buttonWidth,
                                        child: FilledButton.tonalIcon(
                                          onPressed: () => _showMessage(
                                            'Live Chat will be connected later',
                                          ),
                                          icon: const Icon(Icons.chat_rounded),
                                          label: const Text('Live Chat'),
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              52,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Report a Problem',
                                subtitle:
                                    'Describe anything that is not working properly.',
                              ),
                              const SizedBox(height: 16),
                              _TextInputSection(
                                controller: _problemController,
                                hintText: 'Describe your issue...',
                                buttonLabel: 'Submit Report',
                                buttonIcon: Icons.report_problem_rounded,
                                onSubmitted: _submitReport,
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Feedback',
                                subtitle:
                                    'Rate your experience and share suggestions to help improve FloraMind AI.',
                              ),
                              const SizedBox(height: 16),
                              HelpFeedbackCard(
                                rating: _rating,
                                controller: _feedbackController,
                                onRatingChanged: (value) {
                                  setState(() {
                                    _rating = value;
                                  });
                                  _showMessage(
                                    'Rating set to $value star${value == 1 ? '' : 's'}',
                                  );
                                },
                                onSubmit: _submitFeedback,
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'User Guide',
                                subtitle:
                                    'Quick guides for common tasks inside FloraMind AI.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, guideConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = guideColumns == 1
                                      ? guideConstraints.maxWidth
                                      : ((guideConstraints.maxWidth -
                                                    ((guideColumns - 1) *
                                                        gap)) /
                                                guideColumns)
                                            .clamp(220.0, 360.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _guides
                                        .map(
                                          (guide) => SizedBox(
                                            width: cardWidth,
                                            child: HelpGuideCard(
                                              title: guide.title,
                                              subtitle: guide.subtitle,
                                              icon: guide.icon,
                                              accentColor: guide.accentColor,
                                              onTap: () => _showMessage(
                                                '${guide.title} will be connected later',
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Emergency Tips',
                                subtitle:
                                    'Static quick tips for common plant care issues.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, tipConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = tipColumns == 1
                                      ? tipConstraints.maxWidth
                                      : ((tipConstraints.maxWidth -
                                                    ((tipColumns - 1) * gap)) /
                                                tipColumns)
                                            .clamp(220.0, 360.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _tips
                                        .map(
                                          (tip) => SizedBox(
                                            width: cardWidth,
                                            child: HelpEmergencyTipCard(
                                              title: tip.title,
                                              subtitle: tip.subtitle,
                                              icon: tip.icon,
                                              accentColor: tip.accentColor,
                                            ),
                                          ),
                                        )
                                        .toList(),
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

class _SearchCard extends StatelessWidget {
  const _SearchCard({
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.90),
              colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F4C2B).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search for help...',
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

class _TextInputSection extends StatelessWidget {
  const _TextInputSection({
    required this.controller,
    required this.hintText,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.26),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.86),
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F4C2B).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.description_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onSubmitted,
              icon: Icon(buttonIcon),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.26),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.84),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No help results found',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another search term or clear the search box.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Clear Search'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqData {
  const _FaqData({
    required this.question,
    required this.answer,
    required this.icon,
    required this.accentColor,
  });

  final String question;
  final String answer;
  final IconData icon;
  final Color accentColor;
}

class _ContactData {
  const _ContactData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}

class _GuideData {
  const _GuideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}

class _TipData {
  const _TipData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
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
