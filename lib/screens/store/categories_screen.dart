import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/category_card.dart';
import '../../widgets/store/product_card.dart';
import '../../widgets/store/store_search_bar.dart';
import '../../widgets/store/store_section_header.dart';
import 'garden_store_controller.dart';
import 'product_details_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    this.embedded = false,
    this.onOpenProductDetails,
  });

  final bool embedded;
  final ValueChanged<String>? onOpenProductDetails;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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

  void _openProduct(Product product) {
    if (widget.onOpenProductDetails != null) {
      widget.onOpenProductDetails!(product.id);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(productId: product.id),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = _controller.categories;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final filteredProducts = _controller.filterProducts(
          query: _searchController.text,
          selectedCategory: _selectedCategory,
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth >= 1240
                  ? 1160.0
                  : constraints.maxWidth;
              final categoryColumns = constraints.maxWidth >= 1000
                  ? 5
                  : constraints.maxWidth >= 760
                      ? 3
                      : 2;
              final productColumns = constraints.maxWidth >= 1200
                  ? 4
                  : constraints.maxWidth >= 900
                      ? 3
                      : 2;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.90),
                              const Color(0xFF5EAF61),
                              const Color(0xFF9AD26A),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore all categories',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Filter live marketplace products by category, then tap a card to view details.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      StoreSearchBar(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        onClear: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      const StoreSectionHeader(
                        title: 'Category Cards',
                        subtitle: 'A quick visual index of the marketplace sections.',
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: categoryColumns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            title: category,
                            icon: _categoryIcon(category),
                            itemCount: _controller.productsForCategory(category).length,
                            selected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      StoreSectionHeader(
                        title: _selectedCategory == 'All'
                            ? 'All matching products'
                            : 'Products in $_selectedCategory',
                        subtitle:
                            'Search results are filtered from the current Firestore catalog.',
                      ),
                      const SizedBox(height: 14),
                      if (filteredProducts.isEmpty)
                        _EmptyState(
                          onReset: () {
                            setState(() {
                              _selectedCategory = 'All';
                              _searchController.clear();
                            });
                          },
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredProducts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: productColumns,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
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
        title: const Text('Categories'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(child: _buildBody(context)),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
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
        return Icons.grid_view_rounded;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: 0.76),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 46,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('No products found'),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onReset,
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }
}
