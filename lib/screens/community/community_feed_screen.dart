import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/community_post.dart';
import '../../services/community/community_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'community_post_detail_screen.dart';
import 'create_community_post_screen.dart';
import 'widgets/community_post_card.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  static const String routeName = '/community';

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CommunityService _communityService = const CommunityService();
  late final String _currentUserId;
  late Stream<List<CommunityPost>> _postsStream;

  static const List<String> _categories = <String>[
    'All',
    'Disease',
    'Care',
    'Pests',
    'Propagation',
    'Watering',
    'Leaves',
  ];

  String _selectedCategory = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    _refreshPostsStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshPostsStream() {
    _postsStream = _communityService.watchPosts(currentUserId: _currentUserId);
  }

  List<CommunityPost> _filterPosts(List<CommunityPost> posts) {
    final normalizedQuery = _query.trim().toLowerCase();

    return posts.where((post) {
      final matchesCategory =
          _selectedCategory == 'All' || post.category == _selectedCategory;
      final matchesQuery = normalizedQuery.isEmpty ||
          post.title.toLowerCase().contains(normalizedQuery) ||
          post.problemDescription.toLowerCase().contains(normalizedQuery) ||
          post.plantName.toLowerCase().contains(normalizedQuery) ||
          post.authorName.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  Future<void> _openCreatePost() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const CreateCommunityPostScreen(),
      ),
    );
  }

  Future<void> _openPostDetail(CommunityPost post) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CommunityPostDetailScreen(post: post),
      ),
    );
  }

  Future<void> _toggleLike(CommunityPost post) async {
    try {
      await _communityService.setLike(
        postId: post.id,
        userId: _currentUserId,
        isLiked: !post.isLiked,
      );
    } on CommunityServiceException catch (error) {
      _showError(error.message);
    }
  }

  Future<void> _toggleSave(CommunityPost post) async {
    try {
      await _communityService.setSave(
        postId: post.id,
        userId: _currentUserId,
        isSaved: !post.isSaved,
      );
    } on CommunityServiceException catch (error) {
      _showError(error.message);
    }
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

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Community'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Create post',
            onPressed: _openCreatePost,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        icon: const Icon(Icons.create_rounded),
        label: const Text('Create Post'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final contentWidth = width >= 1160
                    ? 1100.0
                    : width >= 820
                        ? 760.0
                        : width - 32;
                final isWide = contentWidth >= 760;

                return StreamBuilder<List<CommunityPost>>(
                  stream: _postsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: contentWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'A local community space for plant questions, problem photos, and helpful answers.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _CommunityErrorState(
                                  message: snapshot.error is CommunityServiceException
                                      ? (snapshot.error as CommunityServiceException).message
                                      : 'Unable to load the community feed right now.',
                                  onRetry: () {
                                    setState(_refreshPostsStream);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: contentWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'A local community space for plant questions, problem photos, and helpful answers.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const _CommunityLoadingState(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final allPosts = snapshot.data ?? const <CommunityPost>[];
                    final posts = _filterPosts(allPosts);

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'A local community space for plant questions, problem photos, and helpful answers.',
                                style: textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _CommunityHeaderCard(
                                totalPosts: allPosts.length,
                                filteredPosts: posts.length,
                                helpfulAnswers: allPosts
                                    .where((post) => post.helpfulAnswer != null)
                                    .length,
                              ),
                              const SizedBox(height: 16),
                              _CommunitySearchBar(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _query = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 44,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final isSelected =
                                        _selectedCategory == category;
                                    return ChoiceChip(
                                      label: Text(category),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      },
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      selectedColor: colorScheme.primary
                                          .withValues(alpha: 0.10),
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.78),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (allPosts.isEmpty)
                                _EmptyCommunityState(
                                  title: 'No community posts yet',
                                  message:
                                      'Be the first to share a plant question or problem photo.',
                                  onCreatePost: _openCreatePost,
                                )
                              else if (posts.isEmpty)
                                _EmptyCommunityState(
                                  title: 'No posts matched your search',
                                  message:
                                      'Try a different keyword or clear the current filters.',
                                  onCreatePost: _openCreatePost,
                                )
                              else
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: posts.map((post) {
                                    return SizedBox(
                                      width: isWide
                                          ? ((contentWidth - 16) / 2)
                                              .clamp(320.0, 520.0)
                                              .toDouble()
                                          : contentWidth,
                                      child: CommunityPostCard(
                                        post: post,
                                        onTap: () => _openPostDetail(post),
                                        onLikeToggle: () => _toggleLike(post),
                                        onSaveToggle: () => _toggleSave(post),
                                      ),
                                    );
                                  }).toList(growable: false),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunitySearchBar extends StatelessWidget {
  const _CommunitySearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search posts, plants, or problems',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}

class _CommunityHeaderCard extends StatelessWidget {
  const _CommunityHeaderCard({
    required this.totalPosts,
    required this.filteredPosts,
    required this.helpfulAnswers,
  });

  final int totalPosts;
  final int filteredPosts;
  final int helpfulAnswers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.86),
            colorScheme.primaryContainer.withValues(alpha: 0.28),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.forum_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community feed',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Posts: $totalPosts  |  Showing: $filteredPosts  |  Helpful answers: $helpfulAnswers',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _CommunityLoadingState extends StatelessWidget {
  const _CommunityLoadingState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            'Loading community posts...',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityErrorState extends StatelessWidget {
  const _CommunityErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 46,
            color: colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Community feed unavailable',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCommunityState extends StatelessWidget {
  const _EmptyCommunityState({
    required this.title,
    required this.message,
    required this.onCreatePost,
  });

  final String title;
  final String message;
  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 46,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onCreatePost,
            icon: const Icon(Icons.create_rounded),
            label: const Text('Create Post'),
          ),
        ],
      ),
    );
  }
}
