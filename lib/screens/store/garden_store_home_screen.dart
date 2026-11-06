import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product.dart';
import '../../widgets/store/product_card.dart';
import '../../widgets/store/store_search_bar.dart';
import 'garden_store_controller.dart';

class GardenStoreHomeScreen extends StatefulWidget {
  const GardenStoreHomeScreen({
    super.key,
    this.embedded = false,
    required this.onOpenProductDetails,
    required this.onOpenSellerDashboard,
  });

  final bool embedded;
  final ValueChanged<String> onOpenProductDetails;
  final VoidCallback onOpenSellerDashboard;

  @override
  State<GardenStoreHomeScreen> createState() => _GardenStoreHomeScreenState();
}

class _GardenStoreHomeScreenState extends State<GardenStoreHomeScreen>
    {
  late final GardenStoreController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _controller = GardenStoreController.instance;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Product> _featuredPlants() {
    return _controller.filterProducts(
      query: _searchController.text,
      selectedCategory: _selectedCategory,
      onlyPlants: true,
    ).where((product) => product.isFeatured).toList(growable: false);
  }

  List<Product> _gardeningEssentials() {
    return _controller.filterProducts(
      query: _searchController.text,
      selectedCategory: _selectedCategory,
    ).where((product) => !product.isPlant).toList(growable: false);
  }

  void _openProduct(Product product) {
    widget.onOpenProductDetails(product.id);
  }

  String get _marketplaceQuery {
    final query = _searchController.text.trim();
    return query.isEmpty ? 'plant gardening products' : query;
  }

  Future<void> _openMarketplace(String name, Uri uri) async {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      _showMessage('Unable to open $name right now.');
    }
  }

  Widget _buildMarketplacePanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final marketplaceQuery = _marketplaceQuery;
    final encodedQuery = Uri.encodeComponent(marketplaceQuery);
    final marketplaces = <({String name, IconData icon, Uri uri})>[
      (
        name: 'Amazon',
        icon: Icons.shopping_bag_rounded,
        uri: Uri.parse('https://www.amazon.in/s?k=$encodedQuery'),
      ),
      (
        name: 'Flipkart',
        icon: Icons.storefront_rounded,
        uri: Uri.parse('https://www.flipkart.com/search?q=$encodedQuery'),
      ),
      (
        name: 'Meesho',
        icon: Icons.local_mall_rounded,
        uri: Uri.parse('https://www.meesho.com/search?q=$encodedQuery'),
      ),
      (
        name: 'IndiaMART',
        icon: Icons.business_rounded,
        uri: Uri.parse('https://dir.indiamart.com/search.mp?ss=$encodedQuery'),
      ),
      (
        name: 'More stores',
        icon: Icons.travel_explore_rounded,
        uri: Uri.parse('https://www.google.com/search?tbm=shop&q=$encodedQuery'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shop on real marketplaces',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Search for "$marketplaceQuery" and compare current products, prices, and availability on each platform.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: marketplaces
                .map(
                  (marketplace) => OutlinedButton.icon(
                    onPressed: () => _openMarketplace(
                      marketplace.name,
                      marketplace.uri,
                    ),
                    icon: Icon(marketplace.icon, size: 18),
                    label: Text(marketplace.name),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    List<Product> products,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : 2;
        final childAspectRatio = width >= 900 ? 0.77 : 0.62;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.96, end: 1),
              duration: Duration(milliseconds: 240 + (index * 30)),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: ProductCard(
                product: product,
                isWishlisted: _controller.isFavorite(product.id),
                onTap: () => _openProduct(product),
                onAddToCart: () {
                  _controller.addToCart(product.id);
                  _showMessage('${product.name} added to cart');
                },
                onToggleWishlist: () async {
                  final result = await _controller.toggleFavorite(product.id);
                  _showMessage(result.message);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: colorScheme.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.nature_people_rounded,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No products match your filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term or pick another category.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _searchController.clear();
              });
            },
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final products = _controller.filterProducts(
          query: _searchController.text,
          selectedCategory: _selectedCategory,
        );
        final categories = <String>['All', ..._controller.categories]
            .toSet()
            .toList(growable: false);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Market',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onOpenSellerDashboard,
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: 'Seller options',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              StoreSearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                onClear: () {
                  setState(_searchController.clear);
                },
              ),
              const SizedBox(height: 14),
              _buildMarketplacePanel(context),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = _selectedCategory == category;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(category),
                      avatar: Icon(_categoryIcon(category), size: 18),
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: colorScheme.primaryContainer,
                      backgroundColor: colorScheme.surface,
                      side: BorderSide(color: colorScheme.outlineVariant),
                      labelStyle: TextStyle(
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _selectedCategory == 'All'
                    ? 'Garden essentials'
                    : _selectedCategory,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${products.length} products',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              products.isEmpty
                  ? _buildEmptyState(context)
                  : _buildProductGrid(context, products),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildBody(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Market'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(child: _buildBody(context)),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    if (category == 'All') return Icons.grid_view_rounded;
    switch (category) {
      case 'Plants':
        return Icons.spa_rounded;
      case 'Flowers':
        return Icons.local_florist_rounded;
      case 'Seeds':
        return Icons.grass_rounded;
      case 'Indoor Plants':
        return Icons.home_filled;
      case 'Garden Plants':
        return Icons.park_rounded;
      case 'Saplings':
        return Icons.eco_rounded;
      case 'Pots & Planters':
        return Icons.inbox_rounded;
      case 'Gardening Tools':
        return Icons.handyman_rounded;
      case 'Fertilizers':
        return Icons.science_rounded;
      case 'Plant Care':
        return Icons.favorite_rounded;
      default:
        return Icons.category_outlined;
    }
  }
}
