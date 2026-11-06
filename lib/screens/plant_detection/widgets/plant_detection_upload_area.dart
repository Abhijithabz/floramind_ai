import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../widgets/plant_illustration_placeholder.dart';

class PlantDetectionUploadArea extends StatelessWidget {
  const PlantDetectionUploadArea({
    super.key,
    required this.imageBytes,
    required this.imageName,
    required this.isLoading,
  });

  final Uint8List? imageBytes;
  final String? imageName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.40),
          width: 1.1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.75),
            colorScheme.primaryContainer.withValues(alpha: 0.28),
            colorScheme.secondaryContainer.withValues(alpha: 0.34),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.cloud_upload_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload your plant photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a clear image for the best identification result.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: imageBytes == null
                ? ConstrainedBox(
                    key: const ValueKey<String>('plant-placeholder'),
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: const PlantIllustrationPlaceholder(),
                  )
                : Column(
                    key: const ValueKey<String>('plant-preview'),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.35,
                                child: Image.memory(
                                  imageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              if (isLoading)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        imageName ?? 'Selected image',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready for AI analysis.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
          ),
          if (imageBytes == null) ...[
            const SizedBox(height: 14),
            Text(
              'Tap Capture or choose from your gallery to continue.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
