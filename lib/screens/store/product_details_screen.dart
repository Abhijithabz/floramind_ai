import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

import '../../models/product.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/price_display.dart';
import '../../widgets/store/quantity_selector.dart';
import '../../widgets/store/rating_widget.dart';
import '../../widgets/store/wishlist_button.dart';
import 'garden_store_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final GardenStoreController _controller;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = GardenStoreController.instance;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openMarketplaceLink(Uri uri, String marketplaceName) async {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _showMessage('Unable to open $marketplaceName right now.');
    }
  }

  List<_MarketplaceLink> _marketplaceLinksForProduct(Product product) {
    final queryParts = <String>[
      product.name,
      if (product.scientificName.trim().isNotEmpty) product.scientificName,
      if (product.category.trim().isNotEmpty) product.category,
    ];
    final encodedQuery = Uri.encodeComponent(queryParts.join(' '));

    return <_MarketplaceLink>[
      _MarketplaceLink(
        label: 'Amazon',
        description: 'Search on Amazon',
        icon: Icons.shopping_bag_rounded,
        uri: Uri.parse('https://www.amazon.in/s?k=$encodedQuery'),
      ),
      _MarketplaceLink(
        label: 'Flipkart',
        description: 'Search on Flipkart',
        icon: Icons.storefront_rounded,
        uri: Uri.parse('https://www.flipkart.com/search?q=$encodedQuery'),
      ),
      _MarketplaceLink(
        label: 'Meesho',
        description: 'Search on Meesho',
        icon: Icons.local_mall_rounded,
        uri: Uri.parse('https://www.meesho.com/search?q=$encodedQuery'),
      ),
      _MarketplaceLink(
        label: 'IndiaMART',
        description: 'Search suppliers on IndiaMART',
        icon: Icons.business_rounded,
        uri: Uri.parse('https://dir.indiamart.com/search.mp?ss=$encodedQuery'),
      ),
      _MarketplaceLink(
        label: 'More stores',
        description: 'Search the wider web',
        icon: Icons.travel_explore_rounded,
        uri: Uri.parse('https://www.google.com/search?tbm=shop&q=$encodedQuery'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final product = _controller.productById(widget.productId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Product Details'),
        ),
        body: const Center(
          child: Text('This product is no longer available.'),
        ),
      );
    }

    final marketplaceLinks = _marketplaceLinksForProduct(product);
    final amazonLink = marketplaceLinks.first;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Product Details'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth >= 920
                          ? 900.0
                          : constraints.maxWidth;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Hero(
                                tag: 'product-${product.id}',
                                child: Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF2E7D32),
                                        Color(0xFF5EAF61),
                                        Color(0xFF9AD26A),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF20502B).withValues(alpha: 0.16),
                                        blurRadius: 18,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.16),
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text(
                                                    product.category,
                                                    style: theme.textTheme.labelLarge?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  product.name,
                                                  style: theme.textTheme.headlineSmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -0.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  product.sellerName,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    color: Colors.white.withValues(alpha: 0.92),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          WishlistButton(
                                            active: _controller.isFavorite(product.id),
                                            onTap: () async {
                                              final result =
                                                  await _controller.toggleFavorite(product.id);
                                              _showMessage(result.message);
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Center(
                                        child: Container(
                                          width: 170,
                                          height: 170,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(alpha: 0.12),
                                          ),
                                          child: Icon(
                                            product.isPlant
                                                ? Icons.local_florist_rounded
                                                : Icons.store_rounded,
                                            size: 90,
                                            color: Colors.white.withValues(alpha: 0.96),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          PriceDisplay(
                                            price: product.price,
                                            discountPrice: product.discountPrice,
                                            priceStyle: theme.textTheme.headlineSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const Spacer(),
                                          RatingWidget(
                                            rating: product.rating,
                                            reviewCount: product.reviewCount,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _InfoChip(label: 'Location: ${product.location}'),
                                  _InfoChip(
                                    label: product.isOutOfStock
                                        ? 'Out of stock'
                                        : 'Stock: ${product.stock}',
                                  ),
                                  _InfoChip(label: 'Seller: ${product.sellerName}'),
                                  _InfoChip(label: 'Reviews: ${product.reviewCount}'),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _SectionCard(
                                title: 'Description',
                                child: Text(
                                  product.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                title: 'Benefits',
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: product.benefits.isEmpty
                                      ? [
                                          Text(
                                            'Benefits will be listed here for future Firebase data.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ]
                                      : product.benefits
                                          .map(
                                            (benefit) => _Pill(text: benefit),
                                          )
                                          .toList(),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                title: product.isPlant
                                    ? 'Plant Care Information'
                                    : 'Product Information',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: product.isPlant
                                      ? [
                                          _DetailRow(
                                            label: 'Scientific Name',
                                            value: product.scientificName,
                                          ),
                                          _DetailRow(
                                            label: 'Sunlight Requirement',
                                            value: product.sunlight,
                                          ),
                                          _DetailRow(
                                            label: 'Water Requirement',
                                            value: product.watering,
                                          ),
                                          _DetailRow(
                                            label: 'Soil Requirement',
                                            value: product.soil,
                                          ),
                                          _DetailRow(
                                            label: 'Plant Size',
                                            value: product.height,
                                          ),
                                        ]
                                      : [
                                          _DetailRow(
                                            label: 'Product Type',
                                            value: product.type,
                                          ),
                                          _DetailRow(
                                            label: 'Best For',
                                            value:
                                                'Indoor and garden use depending on the product setup.',
                                          ),
                                          _DetailRow(
                                            label: 'Usage Notes',
                                            value: product.careNotes.isEmpty
                                                ? 'Usage instructions will be added later.'
                                                : product.careNotes.first,
                                          ),
                                        ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                title: 'Delivery Information',
                                child: Text(
                                  product.deliveryInfo,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                title: 'Buy Online',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Compare current listings and prices from real marketplaces. Prices and availability are provided by each platform and may change.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.5,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    LayoutBuilder(
                                      builder: (context, buttonConstraints) {
                                        final buttonWidth = buttonConstraints.maxWidth >= 640
                                            ? ((buttonConstraints.maxWidth - 12) / 2)
                                                .clamp(220.0, 320.0)
                                                .toDouble()
                                            : buttonConstraints.maxWidth;

                                        return Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: marketplaceLinks
                                              .map(
                                                (link) => SizedBox(
                                                  width: buttonWidth,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => _openMarketplaceLink(
                                                      link.uri,
                                                      link.label,
                                                    ),
                                                    icon: Icon(link.icon),
                                                    label: Text(link.label),
                                                    style: OutlinedButton.styleFrom(
                                                      minimumSize: const Size.fromHeight(48),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(16),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(growable: false),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                title: 'Select Quantity',
                                child: QuantitySelector(
                                  quantity: _quantity,
                                  onIncrement: () {
                                    setState(() {
                                      _quantity = math.min(
                                        _quantity + 1,
                                        product.stock == 0 ? 1 : product.stock,
                                      );
                                    });
                                  },
                                  onDecrement: () {
                                    setState(() {
                                      _quantity = math.max(1, _quantity - 1);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, buttonConstraints) {
                                  final isWide = buttonConstraints.maxWidth >= 640;
                                  final addToCartButton = FilledButton.icon(
                                    onPressed: product.isOutOfStock
                                        ? null
                                        : () {
                                            _controller.addToCart(
                                              product.id,
                                              quantity: _quantity,
                                            );
                                            _showMessage(
                                              '${product.name} added to cart',
                                            );
                                          },
                                    icon: const Icon(Icons.add_shopping_cart_rounded),
                                    label: const Text('Add to Cart'),
                                  );
                                  final buyNowButton = FilledButton.tonalIcon(
                                    onPressed: product.isOutOfStock
                                        ? null
                                        : () => _openMarketplaceLink(
                                              amazonLink.uri,
                                              amazonLink.label,
                                            ),
                                    icon: const Icon(Icons.flash_on_rounded),
                                    label: const Text('Buy Now'),
                                  );

                                  if (isWide) {
                                    return Row(
                                      children: [
                                        Expanded(child: addToCartButton),
                                        const SizedBox(width: 12),
                                        Expanded(child: buyNowButton),
                                      ],
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      addToCartButton,
                                      const SizedBox(height: 12),
                                      buyNowButton,
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () async {
                                  final result =
                                      await _controller.toggleFavorite(product.id);
                                  _showMessage(result.message);
                                },
                                icon: Icon(
                                  _controller.isFavorite(product.id)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                                label: const Text('Add to Wishlist'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
        color: colorScheme.surface.withValues(alpha: 0.76),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F4C2B).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? 'To be connected later' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MarketplaceLink {
  const _MarketplaceLink({
    required this.label,
    required this.description,
    required this.icon,
    required this.uri,
  });

  final String label;
  final String description;
  final IconData icon;
  final Uri uri;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
