import 'dart:ui';

import 'package:flutter/material.dart';

class SettingsRadioTile extends StatelessWidget {
  const SettingsRadioTile({
    super.key,
    required this.label,
    required this.selected,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.26),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? colorScheme.surfaceContainerHigh : Colors.white)
                      .withValues(alpha: 0.86),
                  accentColor.withValues(alpha: 0.08),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
                ],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? accentColor : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Radio<bool>(
                  value: true,
                  groupValue: selected,
                  onChanged: (_) => onTap(),
                  activeColor: accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
