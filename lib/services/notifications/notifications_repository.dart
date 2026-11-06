import 'package:flutter/material.dart';

import '../../models/notification_item.dart';

abstract class NotificationsRepository {
  const NotificationsRepository();

  Future<List<AppNotification>> loadNotifications();

  Future<List<AppNotification>> markAsRead(String notificationId);

  Future<List<AppNotification>> markAllAsRead();

  Future<List<AppNotification>> deleteNotification(String notificationId);
}

class SampleNotificationsRepository extends NotificationsRepository {
  SampleNotificationsRepository() {
    _items = _seedNotifications.toList(growable: true);
  }

  late List<AppNotification> _items;

  static final List<AppNotification> _seedNotifications = <AppNotification>[
    AppNotification(
      id: 'notif-003',
      category: NotificationCategory.diseaseDetection,
      title: 'Disease detected on Rose plant.',
      description:
          'Leaf spot symptoms were detected during the last plant health scan.',
      timeLabel: 'Today, 9:30 AM',
      priority: 'High',
      icon: Icons.bug_report_rounded,
      accentColor: const Color(0xFFF4A261),
      isRead: false,
    ),
    AppNotification(
      id: 'notif-004',
      category: NotificationCategory.plantRecommendations,
      title: 'Hibiscus is recommended for your garden conditions.',
      description:
          'The current light, humidity, and temperature support Hibiscus growth.',
      timeLabel: 'Yesterday',
      priority: 'Normal',
      icon: Icons.spa_rounded,
      accentColor: const Color(0xFF66BB6A),
      isRead: true,
    ),
    AppNotification(
      id: 'notif-006',
      category: NotificationCategory.community,
      title: 'A helpful answer was marked on your post.',
      description:
          'One of the community replies on your post was marked as the best answer.',
      timeLabel: 'Today',
      priority: 'Low',
      icon: Icons.forum_rounded,
      accentColor: const Color(0xFF8BC34A),
      isRead: true,
    ),
    AppNotification(
      id: 'notif-007',
      category: NotificationCategory.system,
      title: 'FloraMind AI is ready for your next garden update.',
      description:
          'The app is running smoothly and your garden data is synced locally.',
      timeLabel: 'Today',
      priority: 'Low',
      icon: Icons.settings_rounded,
      accentColor: const Color(0xFFE08A00),
      isRead: true,
    ),
  ];

  @override
  Future<List<AppNotification>> loadNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return _copyItems();
  }

  @override
  Future<List<AppNotification>> markAsRead(String notificationId) async {
    _items = _items
        .map(
          (item) =>
              item.id == notificationId ? item.copyWith(isRead: true) : item,
        )
        .toList(growable: true);
    return _copyItems();
  }

  @override
  Future<List<AppNotification>> markAllAsRead() async {
    _items = _items
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: true);
    return _copyItems();
  }

  @override
  Future<List<AppNotification>> deleteNotification(
    String notificationId,
  ) async {
    _items = _items
        .where((item) => item.id != notificationId)
        .toList(growable: true);
    return _copyItems();
  }

  List<AppNotification> _copyItems() {
    return _items.map((item) => item.copyWith()).toList(growable: false);
  }
}

class FirestoreNotificationsRepository extends NotificationsRepository {
  const FirestoreNotificationsRepository();

  @override
  Future<List<AppNotification>> loadNotifications() {
    throw UnimplementedError('Connect notifications to Firestore later.');
  }

  @override
  Future<List<AppNotification>> markAsRead(String notificationId) {
    throw UnimplementedError('Connect notifications to Firestore later.');
  }

  @override
  Future<List<AppNotification>> markAllAsRead() {
    throw UnimplementedError('Connect notifications to Firestore later.');
  }

  @override
  Future<List<AppNotification>> deleteNotification(String notificationId) {
    throw UnimplementedError('Connect notifications to Firestore later.');
  }
}

class NotificationsRepositoryFactory {
  const NotificationsRepositoryFactory();

  static NotificationsRepository create() {
    return SampleNotificationsRepository();
  }
}
