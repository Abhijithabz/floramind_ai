import 'package:flutter/material.dart';

enum NotificationCategory {
  diseaseDetection,
  plantRecommendations,
  community,
  system,
}

extension NotificationCategoryX on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.diseaseDetection:
        return 'Disease Detection';
      case NotificationCategory.plantRecommendations:
        return 'Plant Recommendations';
      case NotificationCategory.community:
        return 'Community';
      case NotificationCategory.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.diseaseDetection:
        return Icons.bug_report_rounded;
      case NotificationCategory.plantRecommendations:
        return Icons.spa_rounded;
      case NotificationCategory.community:
        return Icons.forum_rounded;
      case NotificationCategory.system:
        return Icons.settings_rounded;
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.priority,
    required this.icon,
    required this.accentColor,
    required this.isRead,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String description;
  final String timeLabel;
  final String priority;
  final IconData icon;
  final Color accentColor;
  final bool isRead;

  bool get isCritical => priority.toLowerCase() == 'high' && !isRead;

  AppNotification copyWith({
    String? id,
    NotificationCategory? category,
    String? title,
    String? description,
    String? timeLabel,
    String? priority,
    IconData? icon,
    Color? accentColor,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLabel: timeLabel ?? this.timeLabel,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      isRead: isRead ?? this.isRead,
    );
  }
}
