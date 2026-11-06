import 'package:flutter/material.dart';

enum DiseaseSeverity {
  low,
  moderate,
  high,
  critical,
}

extension DiseaseSeverityX on DiseaseSeverity {
  String get label {
    switch (this) {
      case DiseaseSeverity.low:
        return 'Low';
      case DiseaseSeverity.moderate:
        return 'Moderate';
      case DiseaseSeverity.high:
        return 'High';
      case DiseaseSeverity.critical:
        return 'Critical';
    }
  }

  String get description {
    switch (this) {
      case DiseaseSeverity.low:
        return 'Monitor regularly and act early if it spreads.';
      case DiseaseSeverity.moderate:
        return 'Treat soon to avoid wider damage.';
      case DiseaseSeverity.high:
        return 'Act quickly to protect nearby plants.';
      case DiseaseSeverity.critical:
        return 'Immediate intervention is recommended.';
    }
  }

  Color get color {
    switch (this) {
      case DiseaseSeverity.low:
        return const Color(0xFF2E7D32);
      case DiseaseSeverity.moderate:
        return const Color(0xFFB7791F);
      case DiseaseSeverity.high:
        return const Color(0xFFC65A1E);
      case DiseaseSeverity.critical:
        return const Color(0xFFB54747);
    }
  }

  IconData get icon {
    switch (this) {
      case DiseaseSeverity.low:
        return Icons.verified_rounded;
      case DiseaseSeverity.moderate:
        return Icons.warning_amber_rounded;
      case DiseaseSeverity.high:
        return Icons.priority_high_rounded;
      case DiseaseSeverity.critical:
        return Icons.emergency_rounded;
    }
  }
}
