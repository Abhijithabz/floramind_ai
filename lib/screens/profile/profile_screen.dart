import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../about_floramind_ai/about_floramind_ai_screen.dart';
import '../authentication/edit_profile_screen.dart';
import '../authentication/change_password_screen.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../help_support/help_support_screen.dart';
import '../legal/legal_document_screen.dart';
import '../settings/settings_screen.dart';
import '../welcome/welcome_screen.dart';
import '../../services/auth/auth_service.dart';
import 'widgets/profile_achievement_card.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_information_card.dart';
import 'widgets/profile_settings_tile.dart';
import 'widgets/profile_statistics_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  final AuthService _authService = const AuthService();
  String _userName = 'Guest User';
  String _userEmail = 'guest@example.com';

  static const List<_GardenInfoData> _gardenInfo = [
    _GardenInfoData(
      label: 'Garden Name',
      value: 'Home Garden',
      icon: Icons.park_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _GardenInfoData(
      label: 'Garden Size',
      value: 'Small Backyard',
      icon: Icons.space_dashboard_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _GardenInfoData(
      label: 'Location',
      value: 'Green Park, India',
      icon: Icons.location_on_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _GardenInfoData(
      label: 'Number of Plants',
      value: '24 Plants',
      icon: Icons.eco_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
    _GardenInfoData(
      label: 'Favorite Plant',
      value: 'Rose',
      icon: Icons.local_florist_rounded,
      accentColor: Color(0xFFF4A261),
    ),
  ];

  static const List<_AchievementData> _achievements = [
    _AchievementData(
      title: 'First Plant Scan',
      progressLabel: 'Completed',
      progress: 1.0,
      icon: Icons.emoji_nature_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _AchievementData(
      title: '10 Successful Recommendations',
      progressLabel: '10 / 10',
      progress: 1.0,
      icon: Icons.star_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
    _AchievementData(
      title: '7-Day Healthy Garden',
      progressLabel: 'In Progress',
      progress: 0.72,
      icon: Icons.verified_rounded,
      accentColor: Color(0xFFF4A261),
    ),
  ];

  static const List<_SettingsData> _settings = [
    _SettingsData(label: 'Edit Profile', icon: Icons.edit_rounded),
    _SettingsData(label: 'Change Password', icon: Icons.lock_reset_rounded),
    _SettingsData(
      label: 'Notification Preferences',
      icon: Icons.notifications_rounded,
    ),
    _SettingsData(label: 'Language', icon: Icons.language_rounded),
    _SettingsData(label: 'Privacy Policy', icon: Icons.privacy_tip_rounded),
    _SettingsData(label: 'Terms & Conditions', icon: Icons.description_rounded),
    _SettingsData(label: 'About FloraMind AI', icon: Icons.info_rounded),
    _SettingsData(label: 'Help & Support', icon: Icons.help_rounded),
    _SettingsData(label: 'Logout', icon: Icons.logout_rounded),
  ];

  static const List<_StatisticData> _statistics = [
    _StatisticData(
      label: 'Total Plant Scans',
      value: '--',
      icon: Icons.photo_camera_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _StatisticData(
      label: 'Disease Reports',
      value: '--',
      icon: Icons.bug_report_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _StatisticData(
      label: 'Recommendations',
      value: '--',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
    _StatisticData(
      label: 'Watering Sessions',
      value: '--',
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _refreshUser();
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

  void _refreshUser() {
    if (Firebase.apps.isEmpty) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    _userName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'Guest User';
    _userEmail = user.email?.trim().isNotEmpty == true
        ? user.email!.trim()
        : 'guest@example.com';
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const EditProfileScreen()),
    );
    if (updated == true && mounted) {
      setState(_refreshUser);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) {
      return;
    }

    final result = await _authService.signOut();
    if (!mounted) {
      return;
    }
    if (!result.success) {
      _showMessage(result.message);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('My Profile'),
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
                final infoColumns = width >= 1120
                    ? 3
                    : width >= 760
                    ? 2
                    : 1;
                final achievementColumns = width >= 1120
                    ? 2
                    : width >= 760
                    ? 2
                    : 1;
                final statColumns = width >= 920 ? 2 : 1;

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
                              ProfileHeaderCard(
                                userName: _userName,
                                email: _userEmail,
                                gardenType: 'Home Garden',
                                onEditProfile: _openEditProfile,
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Garden Information',
                                subtitle:
                                    'Sample garden details that will later be synced from your account.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, infoConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = infoColumns == 1
                                      ? infoConstraints.maxWidth
                                      : ((infoConstraints.maxWidth -
                                                    ((infoColumns - 1) * gap)) /
                                                infoColumns)
                                            .clamp(220.0, 360.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _gardenInfo
                                        .map(
                                          (info) => SizedBox(
                                            width: cardWidth,
                                            child: ProfileInformationCard(
                                              label: info.label,
                                              value: info.value,
                                              icon: info.icon,
                                              accentColor: info.accentColor,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Achievements',
                                subtitle:
                                    'Celebrate progress and gardening milestones inside FloraMind AI.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, achievementConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = achievementColumns == 1
                                      ? achievementConstraints.maxWidth
                                      : ((achievementConstraints.maxWidth -
                                                    ((achievementColumns - 1) *
                                                        gap)) /
                                                achievementColumns)
                                            .clamp(220.0, 420.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _achievements
                                        .map(
                                          (achievement) => SizedBox(
                                            width: cardWidth,
                                            child: ProfileAchievementCard(
                                              title: achievement.title,
                                              progressLabel:
                                                  achievement.progressLabel,
                                              progress: achievement.progress,
                                              icon: achievement.icon,
                                              accentColor:
                                                  achievement.accentColor,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Account Settings',
                                subtitle:
                                    'Manage your account, preferences, and app language.',
                              ),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 0,
                                color: colorScheme.surface.withValues(
                                  alpha: 0.18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: _settings
                                        .map(
                                          (setting) => ProfileSettingsTile(
                                            label: setting.label,
                                            icon: setting.icon,
                                            onTap: () => _openSetting(
                                              setting.label,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Garden Statistics',
                                subtitle:
                                    'Quick summary cards for your saved garden activity.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, statConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = statColumns == 1
                                      ? statConstraints.maxWidth
                                      : ((statConstraints.maxWidth - gap) / 2)
                                            .clamp(220.0, 420.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _statistics
                                        .map(
                                          (stat) => SizedBox(
                                            width: cardWidth,
                                            child: ProfileStatisticsCard(
                                              label: stat.label,
                                              value: stat.value,
                                              icon: stat.icon,
                                              accentColor: stat.accentColor,
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

  void _openSetting(String label) {
    switch (label) {
      case 'Change Password':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ChangePasswordScreen(),
          ),
        );
        return;
      case 'Edit Profile':
        _openEditProfile();
        return;
      case 'Language':
      case 'Notification Preferences':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
        );
        return;
      case 'About FloraMind AI':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AboutFloraMindAiScreen(),
          ),
        );
        return;
      case 'Privacy Policy':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const LegalDocumentScreen(
              type: LegalDocumentType.privacy,
            ),
          ),
        );
        return;
      case 'Terms & Conditions':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const LegalDocumentScreen(
              type: LegalDocumentType.terms,
            ),
          ),
        );
        return;
      case 'Help & Support':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const HelpSupportScreen()),
        );
        return;
      case 'Logout':
        _confirmLogout();
        return;
      default:
        _showMessage('$label will be connected later');
    }
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

class _GardenInfoData {
  const _GardenInfoData({
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

class _AchievementData {
  const _AchievementData({
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String progressLabel;
  final double progress;
  final IconData icon;
  final Color accentColor;
}

class _SettingsData {
  const _SettingsData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _StatisticData {
  const _StatisticData({
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
