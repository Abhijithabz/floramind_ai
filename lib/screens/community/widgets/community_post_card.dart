import 'package:flutter/material.dart';

import '../../../models/community_post.dart';

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikeToggle,
    required this.onSaveToggle,
  });

  final CommunityPost post;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;
  final VoidCallback onSaveToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final helpfulAnswer = post.helpfulAnswer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.84),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F4C2B).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          const Color(0xFF8BC34A),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        post.authorName.isNotEmpty
                            ? post.authorName[0].toUpperCase()
                            : '?',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${post.authorRole} - ${post.timeLabel}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PostChip(label: post.category, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              _PostImageArea(post: post),
              const SizedBox(height: 14),
              Text(
                post.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.problemDescription,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PostChip(label: post.plantName, color: const Color(0xFF6DA86D)),
                  _PostChip(
                    label: '${post.commentCount} comments',
                    color: const Color(0xFFE08A00),
                  ),
                  if (helpfulAnswer != null)
                    _PostChip(
                      label: 'Helpful Answer',
                      color: const Color(0xFF2E7D32),
                    ),
                ],
              ),
              if (helpfulAnswer != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colorScheme.primary.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Helpful Answer',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        helpfulAnswer.message,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onLikeToggle,
                    icon: Icon(
                      post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text('${post.likeCount}'),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: Text('${post.commentCount}'),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Helpful answer',
                    onPressed: onTap,
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                  ),
                  IconButton(
                    tooltip: 'Save',
                    onPressed: onSaveToggle,
                    icon: Icon(
                      post.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
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

class _PostChip extends StatelessWidget {
  const _PostChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PostImageArea extends StatelessWidget {
  const _PostImageArea({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.secondaryContainer.withValues(alpha: 0.36),
          ],
        ),
      ),
      child: _buildImageContent(context, colorScheme),
    );
  }

  Widget _buildImageContent(BuildContext context, ColorScheme colorScheme) {
    final imageBytes = post.imageBytes;
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    final imageUrl = post.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return Container(
              color: colorScheme.primary.withValues(alpha: 0.05),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackContent(context, colorScheme);
          },
        ),
      );
    }

    return _buildFallbackContent(context, colorScheme);
  }

  Widget _buildFallbackContent(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_florist_rounded,
          size: 54,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          '${post.plantName} problem image',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
