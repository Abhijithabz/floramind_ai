import 'dart:ui';

import 'package:flutter/material.dart';

class NurseryCard extends StatelessWidget {
  const NurseryCard({
    super.key,
    required this.nurseryName,
    required this.address,
    required this.distance,
    required this.rating,
    required this.openingHours,
    required this.openingStatus,
    required this.isOpenNow,
    required this.contactNumber,
    required this.availableServices,
    required this.homeDelivery,
    required this.description,
    required this.accentColor,
    required this.onViewDetails,
    required this.onCallNursery,
    required this.onGetDirections,
  });

  final String nurseryName;
  final String address;
  final String distance;
  final double rating;
  final String openingHours;
  final String openingStatus;
  final bool isOpenNow;
  final String contactNumber;
  final List<String> availableServices;
  final bool homeDelivery;
  final String description;
  final Color accentColor;
  final VoidCallback onViewDetails;
  final VoidCallback onCallNursery;
  final VoidCallback onGetDirections;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
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
                Colors.white.withValues(alpha: 0.85),
                accentColor.withValues(alpha: 0.08),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
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
              _NurseryHeader(
                nurseryName: nurseryName,
                distance: distance,
                rating: rating,
                accentColor: accentColor,
              ),
              const SizedBox(height: 10),
              _OpeningStatusBadge(
                label: openingStatus,
                isOpenNow: isOpenNow,
                accentColor: accentColor,
              ),
              const SizedBox(height: 16),
              _NurseryImagePlaceholder(accentColor: accentColor),
              const SizedBox(height: 16),
              Text(
                address,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              _InfoRow(label: 'Opening Hours', value: openingHours),
              const SizedBox(height: 6),
              _InfoRow(label: 'Contact', value: contactNumber),
              const SizedBox(height: 10),
              Text(
                'Available Services',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableServices
                    .map(
                      (service) => _ServiceChip(
                        label: service,
                        color: accentColor,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              _DeliveryBadge(
                enabled: homeDelivery,
                accentColor: accentColor,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final gap = 10.0;
                  final buttonWidth = constraints.maxWidth >= 660
                      ? ((constraints.maxWidth - ((3 - 1) * gap)) / 3)
                          .clamp(170.0, 260.0)
                          .toDouble()
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: FilledButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.visibility_rounded),
                          label: const Text('View Details'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: OutlinedButton.icon(
                          onPressed: onCallNursery,
                          icon: const Icon(Icons.call_rounded),
                          label: const Text('Call Nursery'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: FilledButton.tonalIcon(
                          onPressed: onGetDirections,
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Get Directions'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NurseryHeader extends StatelessWidget {
  const _NurseryHeader({
    required this.nurseryName,
    required this.distance,
    required this.rating,
    required this.accentColor,
  });

  final String nurseryName;
  final String distance;
  final double rating;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nurseryName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      distance,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _RatingBadge(rating: rating, accentColor: accentColor),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({
    required this.rating,
    required this.accentColor,
  });

  final double rating;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accentColor.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: accentColor),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _NurseryImagePlaceholder extends StatelessWidget {
  const _NurseryImagePlaceholder({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.22),
            const Color(0xFFF6FBF4),
            accentColor.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -10,
            child: Icon(
              Icons.spa_rounded,
              size: 110,
              color: accentColor.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                  child: Icon(
                    Icons.local_florist_rounded,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Nursery Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: accentColor,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _DeliveryBadge extends StatelessWidget {
  const _DeliveryBadge({
    required this.enabled,
    required this.accentColor,
  });

  final bool enabled;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = enabled ? const Color(0xFF2E7D32) : Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.delivery_dining_rounded : Icons.cancel_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            enabled ? 'Home Delivery Available' : 'No Home Delivery',
            style: textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningStatusBadge extends StatelessWidget {
  const _OpeningStatusBadge({
    required this.label,
    required this.isOpenNow,
    required this.accentColor,
  });

  final String label;
  final bool isOpenNow;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = isOpenNow ? const Color(0xFF2E7D32) : accentColor;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOpenNow ? Icons.store_rounded : Icons.store_mall_directory_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
