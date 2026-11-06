import 'package:flutter/material.dart';

class PlantDetectionActionButton extends StatelessWidget {
  const PlantDetectionActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = true,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: filled
          ? [
              colorScheme.primary,
              const Color(0xFF76B77A),
            ]
          : [
              Colors.white.withValues(alpha: 0.88),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.66),
            ],
    );

    final foregroundColor = filled
        ? Colors.white
        : colorScheme.onSurface.withValues(
            alpha: onPressed == null && !isLoading ? 0.55 : 1,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isLoading ? null : onPressed,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: gradient,
            border: filled
                ? null
                : Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                    width: 1.1,
                  ),
            boxShadow: onPressed == null && !isLoading
                ? [
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colorScheme.primary.withValues(
                        alpha: filled ? 0.18 : 0.08,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  )
                else
                  Icon(icon, size: 20, color: foregroundColor),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w800,
                        ),
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
