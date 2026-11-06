import 'dart:ui';

import 'package:flutter/material.dart';

import 'plant_recommendation_action_button.dart';
import 'plant_recommendation_image_placeholder.dart';

class PlantRecommendationCard extends StatelessWidget {
  const PlantRecommendationCard({
    super.key,
    required this.name,
    required this.scientificName,
    required this.reason,
    required this.waterRequirement,
    required this.sunlightRequirement,
    required this.difficultyLevel,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onViewDetails,
    required this.onSaveRecommendation,
  });

  final String name;
  final String scientificName;
  final String reason;
  final String waterRequirement;
  final String sunlightRequirement;
  final String difficultyLevel;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onViewDetails;
  final VoidCallback onSaveRecommendation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.84),
                accentColor.withValues(alpha: 0.08),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F4C2B).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wideLayout = constraints.maxWidth >= 360;
                  final image = PlantRecommendationImagePlaceholder(
                    icon: icon,
                    accentColor: accentColor,
                    title: name,
                  );

                  final info = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scientificName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Reason',
                        style: textTheme.labelLarge?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );

                  if (wideLayout) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 128, child: image),
                        const SizedBox(width: 14),
                        Expanded(child: info),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      image,
                      const SizedBox(height: 14),
                      info,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(label: 'Water', value: waterRequirement),
                  _InfoChip(label: 'Sunlight', value: sunlightRequirement),
                  _InfoChip(label: 'Difficulty', value: difficultyLevel),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 180,
                    child: PlantRecommendationActionButton(
                      label: 'View Details',
                      icon: Icons.visibility_rounded,
                      filled: false,
                      compact: true,
                      onPressed: onViewDetails,
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: PlantRecommendationActionButton(
                      label: 'Save Recommendation',
                      icon: Icons.bookmark_add_rounded,
                      compact: true,
                      onPressed: onSaveRecommendation,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
