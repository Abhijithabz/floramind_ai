import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/app_strings.dart';
import '../authentication/change_password_screen.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../legal/legal_document_screen.dart';
import 'widgets/settings_info_card.dart';
import 'widgets/settings_radio_tile.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String _selectedGardenType = 'Indoor';
  String _selectedPlantCategory = 'Flowering Plants';

  final Map<String, bool> _notificationSettings = {
    'Plant Detection Alerts': true,
    'Disease Detection Alerts': true,
    'AI Recommendation Alerts': true,
    'Weather Alerts': false,
  };

  static const List<_ThemeOption> _themeOptions = [
    _ThemeOption(
      mode: ThemeMode.light,
      icon: Icons.light_mode_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _ThemeOption(
      mode: ThemeMode.dark,
      icon: Icons.dark_mode_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _ThemeOption(
      mode: ThemeMode.system,
      icon: Icons.brightness_auto_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
  ];

  static const List<_LanguageOption> _languageOptions = [
    _LanguageOption(code: 'en', labelKey: 'languageEnglish'),
    _LanguageOption(code: 'ml', labelKey: 'languageMalayalam'),
    _LanguageOption(code: 'hi', labelKey: 'languageHindi'),
    _LanguageOption(code: 'ta', labelKey: 'languageTamil'),
    _LanguageOption(code: 'kn', labelKey: 'languageKannada'),
  ];

  static const List<_GardenPreferenceGroup> _gardenPreferenceGroups = [
    _GardenPreferenceGroup(
      title: 'Preferred Garden Type',
      options: ['Indoor', 'Outdoor', 'Balcony', 'Terrace'],
    ),
    _GardenPreferenceGroup(
      title: 'Preferred Plant Category',
      options: [
        'Flowering Plants',
        'Indoor Plants',
        'Medicinal Plants',
        'Decorative Plants',
        'Fruit Plants',
      ],
    ),
  ];

  static const List<_AboutData> _about = [
    _AboutData(label: 'Application Name', value: 'FloraMind AI'),
    _AboutData(label: 'Version', value: '1.0.0'),
    _AboutData(label: 'Developer', value: 'Your Name'),
    _AboutData(label: 'Project', value: 'AI Smart Garden Assistant'),
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
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setTheme(BuildContext context, ThemeMode mode) {
    FloraMindAppScope.of(context).setThemeMode(mode);
    final strings = AppStrings.of(context);
    final label = _themeOptions
        .firstWhere((option) => option.mode == mode)
        .label(strings);
    _showMessage('$label selected');
  }

  void _setLanguage(BuildContext context, String? languageCode) {
    if (languageCode == null) {
      return;
    }
    final locale = Locale(languageCode);
    FloraMindAppScope.of(context).setLocale(locale);
    final strings = AppStrings.of(context);
    final label = _languageOptions
        .firstWhere((option) => option.code == languageCode)
        .label(strings);
    _showMessage('$label selected');
  }

  void _setGardenType(String value) {
    setState(() {
      _selectedGardenType = value;
    });
    _showMessage('$value selected as garden type');
  }

  void _setPlantCategory(String value) {
    setState(() {
      _selectedPlantCategory = value;
    });
    _showMessage('$value selected as plant category');
  }

  void _toggleNotificationSetting(String key, bool value) {
    setState(() {
      _notificationSettings[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final appState = FloraMindAppScope.of(context);
    final selectedLanguageCode =
        appState.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(strings.settings),
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
                final twoColumn = width >= 980;
                final infoColumns = width >= 1120
                    ? 2
                    : width >= 760
                    ? 2
                    : 1;
                final aboutColumns = width >= 920 ? 2 : 1;
                final securityColumns = width >= 760 ? 2 : 1;

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
                                strings.customizeExperience,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SettingsSection(
                                title: strings.appearance,
                                subtitle: strings.appearanceSubtitle,
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: _themeOptions
                                    .map(
                                      (option) => SizedBox(
                                        width: twoColumn
                                            ? ((constraints.maxWidth - 14) / 2)
                                                  .clamp(220.0, 420.0)
                                                  .toDouble()
                                            : constraints.maxWidth,
                                        child: SettingsRadioTile(
                                          label: option.label(strings),
                                          selected:
                                              appState.themeMode == option.mode,
                                          icon: option.icon,
                                          accentColor: option.accentColor,
                                          onTap: () =>
                                              _setTheme(context, option.mode),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 20),
                              SettingsSection(
                                title: strings.language,
                                subtitle: strings.languageSubtitle,
                              ),
                              const SizedBox(height: 16),
                              _GlassCard(
                                child: DropdownButtonFormField<String>(
                                  value: selectedLanguageCode,
                                  decoration: InputDecoration(
                                    labelText: strings.appLanguage,
                                    border: InputBorder.none,
                                  ),
                                  items: _languageOptions
                                      .map(
                                        (language) => DropdownMenuItem<String>(
                                          value: language.code,
                                          child: Text(language.label(strings)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (languageCode) =>
                                      _setLanguage(context, languageCode),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SettingsSection(
                                title: strings.notificationSettings,
                                subtitle: strings.notificationSubtitle,
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, notificationConstraints) {
                                  final gap = 14.0;
                                  final tileWidth =
                                      notificationConstraints.maxWidth >= 980
                                      ? ((notificationConstraints.maxWidth -
                                                    gap) /
                                                2)
                                            .clamp(220.0, 420.0)
                                            .toDouble()
                                      : notificationConstraints.maxWidth;

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _notificationSettings.entries
                                        .map(
                                          (entry) => SizedBox(
                                            width: tileWidth,
                                            child: SettingsSwitchTile(
                                              label: entry.key,
                                              value: entry.value,
                                              icon: _iconForNotification(
                                                entry.key,
                                              ),
                                              onChanged: (value) =>
                                                  _toggleNotificationSetting(
                                                    entry.key,
                                                    value,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SettingsSection(
                                title: strings.gardenPreferences,
                                subtitle: strings.gardenPreferencesSubtitle,
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, prefConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = infoColumns == 1
                                      ? prefConstraints.maxWidth
                                      : ((prefConstraints.maxWidth - gap) / 2)
                                            .clamp(240.0, 520.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      SizedBox(
                                        width: cardWidth,
                                        child: _PreferenceGroupCard(
                                          title: strings.preferredGardenType,
                                          subtitle: strings
                                              .preferredGardenTypeSubtitle,
                                          options: _gardenPreferenceGroups
                                              .first
                                              .options,
                                          selectedValue: _selectedGardenType,
                                          onSelected: _setGardenType,
                                        ),
                                      ),
                                      SizedBox(
                                        width: cardWidth,
                                        child: _PreferenceGroupCard(
                                          title: strings.preferredPlantCategory,
                                          subtitle: strings
                                              .preferredPlantCategorySubtitle,
                                          options: _gardenPreferenceGroups
                                              .last
                                              .options,
                                          selectedValue: _selectedPlantCategory,
                                          onSelected: _setPlantCategory,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SettingsSection(
                                title: strings.security,
                                subtitle: strings.securitySubtitle,
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, securityConstraints) {
                                  final gap = 14.0;
                                  final tileWidth = securityColumns == 1
                                      ? securityConstraints.maxWidth
                                      : ((securityConstraints.maxWidth - gap) /
                                                2)
                                            .clamp(220.0, 420.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      ..._securityLabels.map(
                                        (label) => SizedBox(
                                          width: tileWidth,
                                          child: SettingsTile(
                                            label: label,
                                            icon: _iconForSecurity(label),
                                            onTap: () =>
                                                _openSecurityOption(label),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SettingsSection(
                                title: strings.backupRestore,
                                subtitle: strings.backupRestoreSubtitle,
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, backupConstraints) {
                                  final gap = 14.0;
                                  final buttonWidth =
                                      backupConstraints.maxWidth >= 760
                                      ? ((backupConstraints.maxWidth - gap) / 2)
                                            .clamp(220.0, 420.0)
                                            .toDouble()
                                      : backupConstraints.maxWidth;

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      _ActionButton(
                                        width: buttonWidth,
                                        label: 'Backup Data',
                                        icon: Icons.backup_rounded,
                                        onPressed: () => _showMessage(
                                          'Backup Data will be connected later',
                                        ),
                                      ),
                                      _ActionButton(
                                        width: buttonWidth,
                                        label: 'Restore Data',
                                        icon: Icons.restore_rounded,
                                        onPressed: () => _showMessage(
                                          'Restore Data will be connected later',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SettingsSection(
                                title: strings.aboutApplication,
                                subtitle: strings.aboutApplicationSubtitle,
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, aboutConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = aboutColumns == 1
                                      ? aboutConstraints.maxWidth
                                      : ((aboutConstraints.maxWidth - gap) / 2)
                                            .clamp(220.0, 420.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _about
                                        .map(
                                          (item) => SizedBox(
                                            width: cardWidth,
                                            child: SettingsInfoCard(
                                              label: item.label,
                                              value: item.value,
                                              icon: _iconForAbout(item.label),
                                              accentColor: _aboutAccent(
                                                item.label,
                                              ),
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

  IconData _iconForTheme(String theme) {
    switch (theme) {
      case 'Light Theme':
        return Icons.light_mode_rounded;
      case 'Dark Theme':
        return Icons.dark_mode_rounded;
      default:
        return Icons.brightness_auto_rounded;
    }
  }

  void _openSecurityOption(String label) {
    if (label == 'Change Password') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ChangePasswordScreen(),
        ),
      );
      return;
    }

    if (label == 'Privacy Policy') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const LegalDocumentScreen(
            type: LegalDocumentType.privacy,
          ),
        ),
      );
      return;
    }

    if (label == 'Terms & Conditions') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const LegalDocumentScreen(
            type: LegalDocumentType.terms,
          ),
        ),
      );
      return;
    }

    _showMessage('$label will be connected later');
  }

  Color _themeAccent(String theme) {
    switch (theme) {
      case 'Light Theme':
        return const Color(0xFFF4A261);
      case 'Dark Theme':
        return const Color(0xFF4C8BF5);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _iconForNotification(String label) {
    switch (label) {
      case 'Plant Detection Alerts':
        return Icons.photo_camera_rounded;
      case 'Disease Detection Alerts':
        return Icons.bug_report_rounded;
      case 'AI Recommendation Alerts':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  IconData _iconForSecurity(String label) {
    switch (label) {
      case 'Change Password':
        return Icons.lock_reset_rounded;
      case 'Privacy Policy':
        return Icons.privacy_tip_rounded;
      case 'Terms & Conditions':
        return Icons.description_rounded;
      case 'Delete Account':
        return Icons.delete_forever_rounded;
      default:
        return Icons.settings_rounded;
    }
  }

  IconData _iconForAbout(String label) {
    switch (label) {
      case 'Application Name':
        return Icons.apps_rounded;
      case 'Version':
        return Icons.confirmation_number_rounded;
      case 'Developer':
        return Icons.person_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  Color _aboutAccent(String label) {
    switch (label) {
      case 'Application Name':
        return const Color(0xFF2E7D32);
      case 'Version':
        return const Color(0xFF43A047);
      case 'Developer':
        return const Color(0xFF4C8BF5);
      default:
        return const Color(0xFF66BB6A);
    }
  }
}

class _PreferenceGroupCard extends StatelessWidget {
  const _PreferenceGroupCard({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options
                .map(
                  (option) => SettingsRadioTile(
                    label: option,
                    selected: selectedValue == option,
                    icon: Icons.circle_rounded,
                    accentColor: colorScheme.primary,
                    onTap: () => onSelected(option),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.width,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final double width;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
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
              (isDark ? colorScheme.surfaceContainerHigh : Colors.white)
                  .withValues(alpha: 0.86),
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
        child: child,
      ),
    );
  }
}

class _GardenPreferenceGroup {
  const _GardenPreferenceGroup({required this.title, required this.options});

  final String title;
  final List<String> options;
}

class _AboutData {
  const _AboutData({required this.label, required this.value});

  final String label;
  final String value;
}

class _ThemeOption {
  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.accentColor,
  });

  final ThemeMode mode;
  final IconData icon;
  final Color accentColor;

  String label(AppStrings strings) {
    switch (mode) {
      case ThemeMode.light:
        return strings.lightTheme;
      case ThemeMode.dark:
        return strings.darkTheme;
      case ThemeMode.system:
        return strings.systemTheme;
    }
  }
}

class _LanguageOption {
  const _LanguageOption({required this.code, required this.labelKey});

  final String code;
  final String labelKey;

  String label(AppStrings strings) {
    switch (labelKey) {
      case 'languageEnglish':
        return strings.languageEnglish;
      case 'languageMalayalam':
        return strings.languageMalayalam;
      case 'languageHindi':
        return strings.languageHindi;
      case 'languageTamil':
        return strings.languageTamil;
      case 'languageKannada':
        return strings.languageKannada;
      default:
        return strings.languageEnglish;
    }
  }
}

const List<String> _securityLabels = [
  'Change Password',
  'Privacy Policy',
  'Terms & Conditions',
  'Delete Account',
];
