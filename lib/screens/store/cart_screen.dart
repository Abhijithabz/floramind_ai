import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/price_display.dart';
import '../../widgets/store/quantity_selector.dart';
import '../../widgets/store/store_section_header.dart';
import 'garden_store_controller.dart';
import 'product_details_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
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
        final items = controller.cartEntries;
        final visibleEntries = items
            .where((entry) => controller.productById(entry.productId) != null)
            .toList(growable: false);
        final products = visibleEntries
            .map((entry) => controller.productById(entry.productId))
            .whereType<Product>()
            .toList(growable: false);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth >= 1240
                  ? 1160.0
                  : constraints.maxWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const StoreSectionHeader(
                        title: 'Your cart',
                        subtitle:
                            'Local session cart only. Checkout will connect later.',
                      ),
                      const SizedBox(height: 14),
                      if (products.isEmpty)
                        _EmptyState(
                          onBrowse: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Browse the store from the Store tab.')),
                            );
                          },
                        )
                      else
                        Column(
                          children: [
                            ...List.generate(products.length, (index) {
                              final product = products[index];
                              final quantity = visibleEntries[index].quantity;
                              return Padding(
                                padding: EdgeInsets.only(bottom: index == products.length - 1 ? 0 : 14),
                                child: _CartItemCard(
                                  product: product,
                                  quantity: quantity,
                                  onTap: () => _openProduct(context, product),
                                  onRemove: () => controller.removeFromCart(product.id),
                                  onIncrement: () => controller.incrementCartQuantity(product.id),
                                  onDecrement: () => controller.decrementCartQuantity(product.id),
                                ),
                              );
                            }),
                            const SizedBox(height: 18),
                            _SummaryCard(
                              subtotal: controller.cartSubtotal,
                              deliveryCharge: controller.deliveryCharge,
                              total: controller.cartTotal,
                              onCheckout: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Checkout will be connected later.')),
                                );
                              },
                            ),
                          ],
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
        title: const Text('Cart'),
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

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: 0.76),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: product.isPlant
                        ? const [Color(0xFF7CB342), Color(0xFF4CAF50)]
                        : const [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  ),
                ),
                child: Icon(
                  product.isPlant ? Icons.local_florist_rounded : Icons.store_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.sellerName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PriceDisplay(
                      price: product.price,
                      discountPrice: product.discountPrice,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Remove item',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              QuantitySelector(
                quantity: quantity,
                compact: true,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
              const Spacer(),
              TextButton(
                onPressed: onTap,
                child: const Text('View details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.onCheckout,
  });

  final double subtotal;
  final double deliveryCharge;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: 0.80),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal', value: 'Rs. ${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Delivery charge',
            value: deliveryCharge == 0 ? 'Free' : 'Rs. ${deliveryCharge.toStringAsFixed(0)}',
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Total',
            value: 'Rs. ${total.toStringAsFixed(0)}',
            emphasize: true,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onCheckout,
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            label: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
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
            Icons.shopping_bag_outlined,
            size: 46,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('Cart is empty'),
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
