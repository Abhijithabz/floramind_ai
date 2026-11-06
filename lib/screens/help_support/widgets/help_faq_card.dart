import 'dart:ui';

import 'package:flutter/material.dart';

class HelpFaqCard extends StatelessWidget {
  const HelpFaqCard({
    super.key,
    required this.question,
    required this.answer,
    required this.icon,
    required this.accentColor,
  });

  final String question;
  final String answer;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
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
                  Colors.white.withValues(alpha: 0.86),
                  accentColor.withValues(alpha: 0.08),
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
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              title: Text(
                question,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              iconColor: accentColor,
              collapsedIconColor: colorScheme.onSurfaceVariant,
              children: [
                Text(
                  answer,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
