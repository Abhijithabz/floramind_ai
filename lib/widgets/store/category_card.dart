import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.itemCount,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int itemCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.26),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      colorScheme.primary.withValues(alpha: 0.18),
                      colorScheme.tertiary.withValues(alpha: 0.12),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F4C2B).withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$itemCount items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

