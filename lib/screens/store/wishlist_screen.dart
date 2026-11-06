import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../authentication/login_screen.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/product_card.dart';
import '../../widgets/store/store_section_header.dart';
import 'garden_store_controller.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({
    super.key,
    this.embedded = false,
    this.onOpenProductDetails,
  });

  final bool embedded;
  final ValueChanged<String>? onOpenProductDetails;

  void _openProduct(BuildContext context, Product product) {
    if (onOpenProductDetails != null) {
      onOpenProductDetails!(product.id);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(productId: product.id),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final controller = GardenStoreController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.wishlistProducts;

        if (!controller.isAuthenticated) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _AuthPrompt(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth >= 1240
                  ? 1160.0
                  : constraints.maxWidth;
              final columns = constraints.maxWidth >= 1200
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
                      const StoreSectionHeader(
                        title: 'Saved products',
                        subtitle:
                            'Wishlist items saved in Firestore for the signed-in account.',
                      ),
                      const SizedBox(height: 14),
                      if (items.isEmpty)
                        _EmptyState(
                          onBrowse: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Switch to the Store tab to browse products.'),
                              ),
                            );
                          },
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final product = items[index];
                            return ProductCard(
                              product: product,
                              isWishlisted: true,
                              wishlistMode: true,
                              onTap: () => _openProduct(context, product),
                              onAddToCart: () {
                                controller.addToCart(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${product.name} added to cart')),
                                );
                              },
                              onToggleWishlist: () async {
                                final result =
                                    await controller.removeFromWishlist(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result.message)),
                                );
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
    if (embedded) {
      return _buildBody(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Wishlist'),
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});

  final VoidCallback onBrowse;

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
            Icons.favorite_border_rounded,
            size: 46,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('Your wishlist is empty'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onBrowse,
            child: const Text('Browse store'),
          ),
        ],
      ),
    );
  }
}

class _AuthPrompt extends StatelessWidget {
  const _AuthPrompt({required this.onPressed});

  final VoidCallback onPressed;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 46,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('Login to use your wishlist'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPressed,
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}
