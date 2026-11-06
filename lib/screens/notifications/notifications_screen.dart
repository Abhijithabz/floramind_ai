import 'package:flutter/material.dart';

import '../../models/notification_item.dart';
import '../../services/notifications/notifications_repository.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_filter_chip.dart';
import 'widgets/notification_summary_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final NotificationsRepository _repository;

  List<AppNotification> _notifications = <AppNotification>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';

  static const List<String> _filters = <String>[
    'All',
    'Disease Detection',
    'Plant Recommendations',
    'Community',
    'System',
  ];

  @override
  void initState() {
    super.initState();
    _repository = NotificationsRepositoryFactory.create();
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

    _loadNotifications();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _repository.loadNotifications();
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = <AppNotification>[];
        _errorMessage = 'Unable to load notifications right now.';
        _isLoading = false;
      });
    }
  }

  List<AppNotification> get _filteredNotifications {
    return _notifications
        .where((notification) {
          return _selectedFilter == 'All' ||
              notification.category.label == _selectedFilter;
        })
        .toList(growable: false);
  }

  int get _unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  int get _criticalCount =>
      _notifications.where((notification) => notification.isCritical).length;

  int get _resolvedCount =>
      _notifications.where((notification) => notification.isRead).length;

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) {
      return;
    }

    try {
      final updated = await _repository.markAsRead(notification.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = updated;
      });
    } catch (_) {
      _showMessage('Unable to update the notification right now.');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final updated = await _repository.markAllAsRead();
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = updated;
      });
    } catch (_) {
      _showMessage('Unable to update notifications right now.');
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      final updated = await _repository.deleteNotification(notification.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = updated;
      });
    } catch (_) {
      _showMessage('Unable to delete the notification right now.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notifications = _filteredNotifications;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Notifications'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: _notifications.isEmpty || _unreadCount == 0
                ? null
                : _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: _isLoading
                ? _LoadingStateCard()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final contentWidth = width >= 1240
                          ? 1160.0
                          : width >= 920
                          ? 900.0
                          : width - 32;
                      final cardColumns = width >= 1120
                          ? 2
                          : width >= 720
                          ? 2
                          : 1;
                      final summaryColumns = width >= 920 ? 2 : 1;

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
                                      'Stay updated with your garden\'s health, AI recommendations, and community activity.',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            height: 1.5,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    _SectionHeader(
                                      title: 'Notification Summary',
                                      subtitle:
                                          'A quick overview of your current garden alert activity.',
                                    ),
                                    const SizedBox(height: 16),
                                    LayoutBuilder(
                                      builder: (context, summaryConstraints) {
                                        final gap = 14.0;
                                        final cardWidth = summaryColumns == 1
                                            ? summaryConstraints.maxWidth
                                            : ((summaryConstraints.maxWidth -
                                                          gap) /
                                                      2)
                                                  .clamp(220.0, 420.0)
                                                  .toDouble();

                                        return Wrap(
                                          spacing: gap,
                                          runSpacing: gap,
                                          children: [
                                            SizedBox(
                                              width: cardWidth,
                                              child: NotificationSummaryCard(
                                                label: 'Total Notifications',
                                                value: _notifications.length
                                                    .toString(),
                                                icon:
                                                    Icons.notifications_rounded,
                                                accentColor: const Color(
                                                  0xFF2E7D32,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: cardWidth,
                                              child: NotificationSummaryCard(
                                                label: 'Unread Notifications',
                                                value: _unreadCount.toString(),
                                                icon: Icons
                                                    .mark_email_unread_rounded,
                                                accentColor: const Color(
                                                  0xFF43A047,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: cardWidth,
                                              child: NotificationSummaryCard(
                                                label: 'Critical Alerts',
                                                value: _criticalCount
                                                    .toString(),
                                                icon: Icons.error_rounded,
                                                accentColor: const Color(
                                                  0xFFF4A261,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: cardWidth,
                                              child: NotificationSummaryCard(
                                                label: 'Resolved Alerts',
                                                value: _resolvedCount
                                                    .toString(),
                                                icon: Icons.verified_rounded,
                                                accentColor: const Color(
                                                  0xFF66BB6A,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: _filters
                                            .map(
                                              (filter) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: NotificationFilterChip(
                                                  label: filter,
                                                  selected:
                                                      _selectedFilter == filter,
                                                  onSelected: () {
                                                    setState(() {
                                                      _selectedFilter = filter;
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
                                      title: 'Alerts',
                                      subtitle:
                                          'Updates from plant care, disease detection, community activity, and the app.',
                                    ),
                                    const SizedBox(height: 16),
                                    LayoutBuilder(
                                      builder: (context, notificationConstraints) {
                                        final gap = 14.0;
                                        final cardWidth = cardColumns == 1
                                            ? notificationConstraints.maxWidth
                                            : ((notificationConstraints
                                                              .maxWidth -
                                                          gap) /
                                                      2)
                                                  .clamp(260.0, 460.0)
                                                  .toDouble();

                                        if (_errorMessage != null) {
                                          return SizedBox(
                                            width: notificationConstraints
                                                .maxWidth,
                                            child: _ErrorStateCard(
                                              message: _errorMessage!,
                                              onRetry: _loadNotifications,
                                            ),
                                          );
                                        }

                                        if (_notifications.isEmpty) {
                                          return SizedBox(
                                            width: notificationConstraints
                                                .maxWidth,
                                            child: _EmptyStateCard(
                                              title: 'No notifications yet',
                                              message:
                                                  'Your future alerts from Plant Detection, Community, and System updates will appear here.',
                                              actionLabel: 'Reload',
                                              onAction: _loadNotifications,
                                            ),
                                          );
                                        }

                                        if (notifications.isEmpty) {
                                          return SizedBox(
                                            width: notificationConstraints
                                                .maxWidth,
                                            child: _EmptyStateCard(
                                              title: 'No notifications found',
                                              message:
                                                  'Try another filter or return to All notifications.',
                                              actionLabel: 'Reset Filter',
                                              onAction: () {
                                                setState(() {
                                                  _selectedFilter = 'All';
                                                });
                                              },
                                            ),
                                          );
                                        }

                                        return Wrap(
                                          spacing: gap,
                                          runSpacing: gap,
                                          children: notifications
                                              .map(
                                                (item) => SizedBox(
                                                  width: cardWidth,
                                                  child: NotificationCard(
                                                    icon: item.icon,
                                                    title: item.title,
                                                    description:
                                                        item.description,
                                                    dateTime: item.timeLabel,
                                                    priority: item.priority,
                                                    isRead: item.isRead,
                                                    accentColor:
                                                        item.accentColor,
                                                    onViewDetails: () =>
                                                        _markAsRead(item),
                                                    onMarkAsRead: item.isRead
                                                        ? null
                                                        : () =>
                                                              _markAsRead(item),
                                                    onDelete: () =>
                                                        _deleteNotification(
                                                          item,
                                                        ),
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

class _LoadingStateCard extends StatelessWidget {
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
                'Loading notifications...',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Preparing your garden alerts and updates.',
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
  const _ErrorStateCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            'Notifications unavailable',
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
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

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
              Icons.notifications_off_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
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
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(actionLabel),
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
