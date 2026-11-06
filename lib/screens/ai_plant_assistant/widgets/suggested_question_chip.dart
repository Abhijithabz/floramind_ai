import 'package:flutter/material.dart';

class SuggestedQuestionChip extends StatelessWidget {
  const SuggestedQuestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
      backgroundColor: Colors.white.withValues(alpha: 0.84),
      side: BorderSide(
        color: colorScheme.primary.withValues(alpha: 0.18),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
