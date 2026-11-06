import 'package:flutter/material.dart';

import '../../../models/disease_severity.dart';

class DiseaseSeverityBadge extends StatelessWidget {
  const DiseaseSeverityBadge({
    super.key,
    required this.severity,
    this.compact = false,
  });

  final DiseaseSeverity severity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = severity.color;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 9);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            severity.icon,
            size: compact ? 16 : 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            severity.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
