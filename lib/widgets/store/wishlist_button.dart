import 'package:flutter/material.dart';

class WishlistButton extends StatelessWidget {
  const WishlistButton({
    super.key,
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: active
          ? colorScheme.error.withValues(alpha: 0.12)
          : colorScheme.surface.withValues(alpha: 0.76),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey<bool>(active),
              size: 22,
              color: active ? colorScheme.error : colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

