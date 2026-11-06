import 'package:flutter/material.dart';

class PlantRecommendationActionButton extends StatelessWidget {
  const PlantRecommendationActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = true,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 48.0 : 56.0;
    final padding = EdgeInsets.symmetric(horizontal: compact ? 14 : 18);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );

    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: compact ? 18 : 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(height),
          padding: padding,
          shape: shape,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: compact ? 18 : 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        padding: padding,
        shape: shape,
      ),
    );
  }
}
