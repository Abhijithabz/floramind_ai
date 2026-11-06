import 'package:flutter/material.dart';

import '../../../models/disease_prediction.dart';

class DiseaseDetectionResultCard extends StatelessWidget {
  const DiseaseDetectionResultCard({
    super.key,
    required this.result,
    required this.isLoading,
    required this.errorMessage,
  });

  final DiseasePrediction? result;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.36),
          width: 1.1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.82),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F4C2B).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _buildContent(context, colorScheme, textTheme),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (isLoading || result?.isLoading == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _resultIcon(Icons.spa_rounded, colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identifying your leaf...',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The image is being analyzed by the FloraMind disease model.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      );
    }

    if (errorMessage != null && result == null) {
      return _messageState(
        context,
        colorScheme,
        textTheme,
        icon: Icons.warning_rounded,
        title: 'Identification unavailable',
        message: errorMessage!,
      );
    }

    if (result == null) {
      return _buildPreviewState(context, colorScheme, textTheme);
    }

    final prediction = result!;
    final diseaseName = prediction.diseaseName?.trim().isNotEmpty == true
        ? prediction.diseaseName!
        : 'Unknown disease';
    final confidencePercent = prediction.confidencePercent;
    final isHighConfidence = confidencePercent >= 80;
    final isMediumConfidence = confidencePercent >= 60 && confidencePercent < 80;
    final isLowConfidence = prediction.isUnknown;
    final badgeColor = isHighConfidence
        ? colorScheme.primary
        : isMediumConfidence
            ? const Color(0xFFE08A00)
            : const Color(0xFFC62828);
    final badgeLabel = isHighConfidence
        ? 'High Confidence'
        : isMediumConfidence
            ? 'Moderate Confidence'
            : 'Low Confidence';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    const Color(0xFF7FBF86),
                  ],
                ),
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disease Result',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prediction.message,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _SeverityChip(
              label: isLowConfidence ? 'Unknown' : badgeLabel,
              color: badgeColor,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SummaryTile(
          label: 'Disease Name',
          value: diseaseName,
          icon: Icons.sick_rounded,
          accentColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          label: 'Confidence',
          value: '$confidencePercent%',
          icon: Icons.auto_graph_rounded,
          accentColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          label: 'Status',
          value: isLowConfidence ? 'Unknown / Low Confidence' : badgeLabel,
          icon: Icons.priority_high_rounded,
          accentColor: badgeColor,
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: prediction.confidence.clamp(0, 1).toDouble(),
            minHeight: 10,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$confidencePercent% ${isLowConfidence ? 'Unknown / Low Confidence' : badgeLabel}',
          style: textTheme.labelLarge?.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (!isHighConfidence) ...[
          const SizedBox(height: 10),
          Text(
            isLowConfidence
                ? 'This prediction is low confidence. Try a clearer, closer leaf image.'
                : 'Try taking a clearer leaf image.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (prediction.symptoms.isNotEmpty) ...[
          _SectionBlock(label: 'Symptoms', items: prediction.symptoms),
          const SizedBox(height: 16),
        ],
        if (prediction.causes.isNotEmpty) ...[
          _SectionBlock(label: 'Possible Causes', items: prediction.causes),
          const SizedBox(height: 16),
        ],
        if (prediction.treatment.isNotEmpty) ...[
          _SectionBlock(
            label: 'Recommended Treatment / Pesticide Guidance',
            items: prediction.treatment,
          ),
          const SizedBox(height: 16),
        ],
        if (prediction.pesticideGuidance.isNotEmpty) ...[
          _SectionBlock(
            label: 'Pesticide Recommendation',
            items: prediction.pesticideGuidance,
          ),
          const SizedBox(height: 16),
        ],
        if (prediction.prevention.isNotEmpty)
          _SectionBlock(label: 'Prevention Tips', items: prediction.prevention),
      ],
    );
  }

  Widget _buildPreviewState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    const symptoms = <String>[
      'Brown circular spots',
      'Yellow leaf edges',
      'Dry patches',
    ];
    const causes = <String>[
      'Fungal infection',
      'Excess moisture',
      'Poor air circulation',
    ];
    const treatment = <String>[
      'Remove infected leaves',
      'Apply suitable fungicide',
      'Avoid overwatering',
      'Improve airflow',
    ];
    const prevention = <String>[
      'Water in the morning',
      'Maintain plant spacing',
      'Regular pruning',
      'Keep leaves dry',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    const Color(0xFF7FBF86),
                  ],
                ),
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disease Result',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sample disease preview for the frontend layout.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _SeverityChip(
              label: 'Medium',
              color: _severityColor(context, 'Medium'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SummaryTile(
          label: 'Disease Name',
          value: 'Leaf Spot',
          icon: Icons.sick_rounded,
          accentColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          label: 'Confidence',
          value: '96%',
          icon: Icons.auto_graph_rounded,
          accentColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          label: 'Severity',
          value: 'Medium',
          icon: Icons.priority_high_rounded,
          accentColor: _severityColor(context, 'Medium'),
        ),
        const SizedBox(height: 18),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 0.96),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '96% Confidence',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _SectionBlock(label: 'Symptoms', items: symptoms),
        const SizedBox(height: 16),
        _SectionBlock(label: 'Possible Causes', items: causes),
        const SizedBox(height: 16),
        _SectionBlock(label: 'Recommended Treatment', items: treatment),
        const SizedBox(height: 16),
        _SectionBlock(label: 'Prevention Tips', items: prevention),
      ],
    );
  }

  Widget _messageState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _resultIcon(
              icon,
              colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultIcon(IconData icon, Color tintColor) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor,
            tintColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: accentColor.withValues(alpha: 0.06),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.label,
    required this.items,
  });

  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

Color _severityColor(BuildContext context, String severity) {
  switch (severity.toLowerCase()) {
    case 'low':
      return const Color(0xFF2E7D32);
    case 'medium':
      return const Color(0xFFE08A00);
    case 'high':
      return const Color(0xFFC62828);
    default:
      return Theme.of(context).colorScheme.primary;
  }
}
