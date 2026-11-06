import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/community_post.dart';
import '../../services/community/community_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/community_post_card.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  const CommunityPostDetailScreen({
    super.key,
    required this.post,
  });

  final CommunityPost post;

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommunityService _communityService = const CommunityService();
  late CommunityPost _post;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  String get _currentUserName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'You';
  }

  void _updatePost(CommunityPost post) {
    setState(() {
      _post = post;
    });
  }

  Future<void> _toggleLike() async {
    final previousPost = _post;
    final updatedPost = _post.copyWith(
      isLiked: !_post.isLiked,
      likeCount: _post.likeCount + (_post.isLiked ? -1 : 1),
    );

    _updatePost(updatedPost);

    try {
      await _communityService.setLike(
        postId: _post.id,
        userId: _currentUserId,
        isLiked: updatedPost.isLiked,
      );
    } on CommunityServiceException catch (error) {
      _updatePost(previousPost);
      _showError(error.message);
    }
  }

  Future<void> _toggleSave() async {
    final previousPost = _post;
    final updatedPost = _post.copyWith(
      isSaved: !_post.isSaved,
      saveCount: _post.saveCount + (_post.isSaved ? -1 : 1),
    );

    _updatePost(updatedPost);

    try {
      await _communityService.setSave(
        postId: _post.id,
        userId: _currentUserId,
        isSaved: updatedPost.isSaved,
      );
    } on CommunityServiceException catch (error) {
      _updatePost(previousPost);
      _showError(error.message);
    }
  }

  Future<void> _addComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty || _isSubmittingComment) {
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await _communityService.addComment(
        postId: _post.id,
        authorId: _currentUserId,
        authorName: _currentUserName,
        message: message,
      );

      final comments = <CommunityComment>[
        ..._post.comments,
        CommunityComment(
          id: '${_post.id}-${DateTime.now().microsecondsSinceEpoch}',
          authorId: _currentUserId,
          authorName: _currentUserName,
          message: message,
          timeLabel: 'Just now',
        ),
      ];

      _commentController.clear();
      _updatePost(_post.copyWith(comments: comments));
    } on CommunityServiceException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  Future<void> _markHelpful(int index) async {
    final previousPost = _post;
    final comments = _post.comments.asMap().entries.map((entry) {
      return entry.value.copyWith(isHelpful: entry.key == index);
    }).toList(growable: false);

    _updatePost(_post.copyWith(comments: comments));

    try {
      final commentId = _post.comments[index].id;
      await _communityService.markHelpful(
        postId: _post.id,
        commentId: commentId,
      );
    } on CommunityServiceException catch (error) {
      _updatePost(previousPost);
      _showError(error.message);
    }
  }

  void _finishAndClose() {
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final helpfulAnswer = _post.helpfulAnswer;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _finishAndClose();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _finishAndClose,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Post Details'),
          backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: DashboardBackground()),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CommunityPostCard(
                          post: _post,
                          onTap: () {},
                          onLikeToggle: _toggleLike,
                          onSaveToggle: _toggleSave,
                        ),
                        const SizedBox(height: 18),
                        _SectionCard(
                          title: 'Helpful Answer',
                          child: helpfulAnswer == null
                              ? Text(
                                  'No helpful answer has been marked yet.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      helpfulAnswer.authorName,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      helpfulAnswer.message,
                                      style: textTheme.bodyMedium?.copyWith(
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 18),
                        _SectionCard(
                          title: 'Comments',
                          child: Column(
                            children: _post.comments.asMap().entries.map((entry) {
                              final comment = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CommentTile(
                                  comment: comment,
                                  onMarkHelpful: comment.isHelpful
                                      ? null
                                      : () => _markHelpful(entry.key),
                                ),
                              );
                            }).toList(growable: false),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SectionCard(
                          title: 'Add a comment',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _commentController,
                                minLines: 3,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Share advice, an observation, or a follow-up question...',
                                  alignLabelWithHint: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _isSubmittingComment
                                    ? null
                                    : _addComment,
                                icon: _isSubmittingComment
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded),
                                label: Text(
                                  _isSubmittingComment
                                      ? 'Posting...'
                                      : 'Post Comment',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.84),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onMarkHelpful,
  });

  final CommunityComment comment;
  final VoidCallback? onMarkHelpful;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.authorName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (comment.isHelpful)
                _Badge(
                  label: 'Helpful',
                  color: colorScheme.primary,
                )
              else if (onMarkHelpful != null)
                TextButton(
                  onPressed: onMarkHelpful,
                  child: const Text('Mark helpful'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.message,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comment.timeLabel,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
