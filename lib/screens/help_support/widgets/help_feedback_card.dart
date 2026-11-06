import 'dart:ui';

import 'package:flutter/material.dart';

class HelpFeedbackCard extends StatelessWidget {
  const HelpFeedbackCard({
    super.key,
    required this.rating,
    required this.controller,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final int rating;
  final TextEditingController controller;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.26),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.86),
                colorScheme.primary.withValues(alpha: 0.05),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate your experience',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  final star = index + 1;
                  final active = star <= rating;
                  return IconButton(
                    onPressed: () => onRatingChanged(star),
                    icon: Icon(
                      active ? Icons.star_rounded : Icons.star_border_rounded,
                      color: active ? const Color(0xFFE08A00) : colorScheme.outline,
                    ),
                    tooltip: '$star star',
                  );
                }),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your feedback...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.feedback_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit Feedback'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
