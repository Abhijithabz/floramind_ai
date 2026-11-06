import 'package:flutter/material.dart';

import '../../../models/plant_info.dart';
import '../../../models/plant_prediction.dart';
import 'plant_detection_action_button.dart';

class PlantDetectionResultCard extends StatelessWidget {
  const PlantDetectionResultCard({
    super.key,
    required this.result,
    required this.plantInfo,
    required this.isPlantInfoLoading,
    required this.isLoading,
    required this.errorMessage,
  });

  final PlantPrediction? result;
  final PlantInfo? plantInfo;
  final bool isPlantInfoLoading;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            (isDark ? colorScheme.surfaceContainerHigh : Colors.white)
                .withValues(alpha: 0.82),
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
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _resultIcon(
                Icons.spa_rounded,
                colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identifying your plant...',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The image is being analyzed by the FloraMind AI model.',
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

    if (result == null || result!.prediction == null) {
      return _messageState(
        context,
        colorScheme,
        textTheme,
        icon: Icons.search_rounded,
        title: 'No result yet',
        message: 'Pick a plant photo and tap Identify Plant to see the result.',
      );
    }

    final prediction = result!.prediction!;
    final confidencePercent = prediction.confidencePercent;
    final isHighConfidence = confidencePercent >= 80;
    final isMediumConfidence = confidencePercent >= 60 && confidencePercent < 80;
    final isLowConfidence = result!.isUnknown;
    final badgeColor = isHighConfidence
        ? colorScheme.primary
        : isMediumConfidence
            ? const Color(0xFFB7791F)
            : const Color(0xFFB54747);
    final badgeLabel = isHighConfidence
        ? 'High Confidence'
        : isMediumConfidence
            ? 'Moderate Confidence'
            : 'Low Confidence';

    final tiles = <_ResultInfoData>[
      _ResultInfoData(label: 'Plant Name', value: prediction.commonName),
      _ResultInfoData(label: 'Scientific Name', value: prediction.scientificName),
      _ResultInfoData(label: 'Family', value: prediction.family),
      _ResultInfoData(label: 'Genus', value: prediction.genus),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _resultIcon(Icons.check_rounded, colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detection Result',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plant prediction output mapped into a clean FloraMind summary.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: _ConfidenceChip(
            value: '$confidencePercent%',
            label: isLowConfidence ? 'Unknown' : badgeLabel,
            color: badgeColor,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = constraints.maxWidth >= 720
                ? ((constraints.maxWidth - 14) / 2).toDouble()
                : constraints.maxWidth;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: tiles
                  .map(
                    (tile) => SizedBox(
                      width: tileWidth,
                      child: _InfoTile(
                        label: tile.label,
                        value: tile.value,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
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
                ? 'This prediction is low confidence. Try a clearer, closer image.'
                : 'Try taking a clearer image.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 18),
        _SectionLabel(label: 'Alternative Identifications'),
        const SizedBox(height: 10),
        if (result!.alternatives.isEmpty)
          Text(
            'No alternative identifications were returned.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          Column(
            children: result!.alternatives.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final alternative = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlternativeTile(
                  index: index,
                  commonName: alternative.commonName,
                  scientificName: alternative.scientificName,
                  confidenceLabel: '${alternative.confidencePercent}%',
                ),
              );
            }).toList(),
        ),
        const SizedBox(height: 18),
        _PlantInfoSection(
          plantInfo: plantInfo,
          isLoading: isPlantInfoLoading,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            errorMessage!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
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

class _PlantInfoSection extends StatelessWidget {
  const _PlantInfoSection({
    required this.plantInfo,
    required this.isLoading,
  });

  final PlantInfo? plantInfo;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'Plant Information'),
        const SizedBox(height: 10),
        if (isLoading)
          _message(
            context,
            Icons.hourglass_top_rounded,
            'Loading plant information...',
            colorScheme.onSurfaceVariant,
          )
        else if (plantInfo == null)
          _message(
            context,
            Icons.info_outline_rounded,
            'Plant information unavailable',
            colorScheme.onSurfaceVariant,
          )
        else ...[
          _PlantInfoTile(
            label: 'Description',
            value: _valueOrPlaceholder(plantInfo!.description),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth >= 720
                  ? ((constraints.maxWidth - 14) / 2).toDouble()
                  : constraints.maxWidth;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _PlantInfoTile(
                      label: 'Watering',
                      value: _valueOrPlaceholder(plantInfo!.watering),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _PlantInfoTile(
                      label: 'Sunlight',
                      value: _valueOrPlaceholder(plantInfo!.sunlight),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _PlantInfoTile(
                      label: 'Soil',
                      value: _valueOrPlaceholder(plantInfo!.soil),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _PlantInfoTile(
                      label: 'Temperature',
                      value: _valueOrPlaceholder(plantInfo!.temperature),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _PlantInfoTile(
                      label: 'Humidity',
                      value: _valueOrPlaceholder(plantInfo!.humidity),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          _BulletSection(
            label: 'Care Tips',
            items: plantInfo!.careTips,
          ),
          const SizedBox(height: 10),
          _BulletSection(
            label: 'Common Problems',
            items: plantInfo!.commonProblems,
          ),
        ],
      ],
    );
  }

  Widget _message(
    BuildContext context,
    IconData icon,
    String message,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
          ),
        ),
      ],
    );
  }

  String _valueOrPlaceholder(String value) {
    return value.trim().isNotEmpty ? value : 'Not provided';
  }
}

class _ResultInfoData {
  const _ResultInfoData({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.primary.withValues(alpha: 0.06),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlantInfoTile extends StatelessWidget {
  const _PlantInfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
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
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'Not provided',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 7),
                          width: 7,
                          height: 7,
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
                              height: 1.4,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
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
          Icon(Icons.auto_graph_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '$value $label',
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

class _AlternativeTile extends StatelessWidget {
  const _AlternativeTile({
    required this.index,
    required this.commonName,
    required this.scientificName,
    required this.confidenceLabel,
  });

  final int index;
  final String commonName;
  final String scientificName;
  final String confidenceLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. $commonName',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            scientificName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confidence: $confidenceLabel',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
