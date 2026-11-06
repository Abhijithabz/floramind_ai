import 'package:flutter/material.dart';

import '../../../models/disease_severity.dart';
import '../../../models/plant_disease.dart';

class DiseaseImageBanner extends StatelessWidget {
  const DiseaseImageBanner({
    super.key,
    required this.disease,
    this.height = 190,
    this.compact = false,
    this.heroTag,
  });

  final PlantDisease disease;
  final double height;
  final bool compact;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final banner = _buildBanner(context);
    if (heroTag == null) {
      return banner;
    }

    return Hero(
      tag: heroTag!,
      child: banner,
    );
  }

  Widget _buildBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = disease.severity.color;
    final secondary = disease.isPest
        ? const Color(0xFFB54747)
        : const Color(0xFF4C9F70);
    final icon = disease.isPest
        ? Icons.bug_report_rounded
        : Icons.local_florist_rounded;

    final content = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 22 : 30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.95),
            secondary.withValues(alpha: 0.82),
            colorScheme.primaryContainer.withValues(alpha: 0.62),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -18,
            child: Container(
              width: compact ? 96 : 132,
              height: compact ? 96 : 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -24,
            child: Container(
              width: compact ? 80 : 110,
              height: compact ? 80 : 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          if (disease.imageUrl.trim().isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(compact ? 22 : 30),
                child: Image.network(
                  disease.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _fallbackContent(context, icon);
                  },
                ),
              ),
            )
          else
            _fallbackContent(context, icon),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                disease.typeLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 22 : 30),
      child: content,
    );
  }

  Widget _fallbackContent(BuildContext context, IconData icon) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Row(
        children: [
          Container(
            width: compact ? 62 : 78,
            height: compact ? 62 : 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
            child: Icon(
              icon,
              size: compact ? 32 : 40,
              color: Colors.white,
            ),
          ),
          SizedBox(width: compact ? 14 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  disease.imageLabel.isNotEmpty
                      ? disease.imageLabel
                      : disease.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  disease.severity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.94),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
