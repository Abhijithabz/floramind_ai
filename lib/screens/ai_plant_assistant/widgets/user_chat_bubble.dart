import 'dart:ui';

import 'package:flutter/material.dart';

class UserChatBubble extends StatelessWidget {
  const UserChatBubble({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    const Color(0xFF66BB6A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F4C2B).withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                message,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
