import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/seller_product_card.dart';
import '../../widgets/store/store_section_header.dart';
import 'add_product_screen.dart';
import 'garden_store_controller.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  void _confirmDelete(BuildContext context, Product product) {
    final controller = GardenStoreController.instance;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete listing?'),
          content: Text('Remove ${product.name} from the local marketplace?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                controller.deleteProduct(product.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = GardenStoreController.instance;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('My Listings'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final listings = controller.sellerListings;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth >= 1240
                          ? 1160.0
                          : constraints.maxWidth;
                      final columns = constraints.maxWidth >= 1100 ? 2 : 1;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const StoreSectionHeader(
                                title: 'My listings',
                                subtitle:
                                    'Edit or delete local seller products before Firebase sync is added.',
                              ),
                              const SizedBox(height: 14),
                              if (listings.isEmpty)
                                _EmptyState(
                                  onAddProduct: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const AddProductScreen(),
                                      ),
                                    );
                                  },
                                )
                              else
                                LayoutBuilder(
                                  builder: (context, listingConstraints) {
                                    final gap = 14.0;
                                    final cardWidth = columns == 1
                                        ? listingConstraints.maxWidth
                                        : ((listingConstraints.maxWidth - gap) / 2)
                                            .clamp(260.0, 520.0)
                                            .toDouble();

                                    return Wrap(
                                      spacing: gap,
                                      runSpacing: gap,
                                      children: listings
                                          .map(
                                            (product) => SizedBox(
                                              width: cardWidth,
                                              child: SellerProductCard(
                                                product: product,
                                                onEdit: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute<void>(
                                                      builder: (_) => AddProductScreen(
                                                        existingProduct: product,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                onDelete: () => _confirmDelete(context, product),
                                              ),
                                            ),
                                          )
                                          .toList(),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddProduct});

  final VoidCallback onAddProduct;

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
            Icons.inventory_2_outlined,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('No seller products yet'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onAddProduct,
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
