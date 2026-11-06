import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../authentication/login_screen.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../../widgets/store/order_card.dart';
import '../../widgets/store/seller_product_card.dart';
import '../../widgets/store/seller_stats_card.dart';
import '../../widgets/store/store_section_header.dart';
import 'add_product_screen.dart';
import 'garden_store_controller.dart';
import 'my_listings_screen.dart';
import 'product_details_screen.dart';
import 'seller_orders_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({
    super.key,
    this.embedded = false,
    this.onOpenProductDetails,
    this.onOpenAddProduct,
    this.onOpenMyListings,
    this.onOpenOrders,
  });

  final bool embedded;
  final ValueChanged<String>? onOpenProductDetails;
  final VoidCallback? onOpenAddProduct;
  final VoidCallback? onOpenMyListings;
  final VoidCallback? onOpenOrders;

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

  void _openAddProduct(BuildContext context) {
    if (onOpenAddProduct != null) {
      onOpenAddProduct!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddProductScreen(),
      ),
    );
  }

  void _openMyListings(BuildContext context) {
    if (onOpenMyListings != null) {
      onOpenMyListings!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MyListingsScreen(),
      ),
    );
  }

  void _openOrders(BuildContext context) {
    if (onOpenOrders != null) {
      onOpenOrders!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SellerOrdersScreen(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final controller = GardenStoreController.instance;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final listings = controller.sellerListings;
        final orders = controller.orders;

        if (!controller.isAuthenticated) {
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
                    child: _AuthPrompt(
                      title: 'Sign in to manage your store',
                      message:
                          'Firebase seller listings, stock updates, and order tracking are available after login.',
                      actionLabel: 'Login to Sell',
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
              },
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
              final statColumns = constraints.maxWidth >= 980 ? 2 : 1;
              final listingColumns = constraints.maxWidth >= 1100 ? 2 : 1;
              final orderColumns = constraints.maxWidth >= 1100 ? 2 : 1;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
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
                            Text(
                              'Sell on FloraMind',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your Firebase-backed listings, orders, and seller actions from one place.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => _openAddProduct(context),
                                  icon: const Icon(Icons.add_circle_outline_rounded),
                                  label: const Text('Add New Product'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: colorScheme.primary,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _openMyListings(context),
                                  icon: const Icon(Icons.inventory_2_rounded),
                                  label: const Text('My Listings'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, statsConstraints) {
                          final gap = 12.0;
                          final statWidth = statColumns == 1
                              ? statsConstraints.maxWidth
                              : ((statsConstraints.maxWidth - gap) / 2)
                                  .clamp(240.0, 500.0)
                                  .toDouble();

                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              SizedBox(
                                width: statWidth,
                                child: SellerStatsCard(
                                  label: 'Total Products',
                                  value: '${listings.length}',
                                  icon: Icons.inventory_2_rounded,
                                  accentColor: const Color(0xFF2E7D32),
                                ),
                              ),
                              SizedBox(
                                width: statWidth,
                                child: SellerStatsCard(
                                  label: 'Active Listings',
                                  value: '${controller.activeListingsCount}',
                                  icon: Icons.check_circle_rounded,
                                  accentColor: const Color(0xFF43A047),
                                ),
                              ),
                              SizedBox(
                                width: statWidth,
                                child: SellerStatsCard(
                                  label: 'Out of Stock',
                                  value: '${controller.outOfStockCount}',
                                  icon: Icons.remove_shopping_cart_rounded,
                                  accentColor: const Color(0xFFF4A261),
                                ),
                              ),
                              SizedBox(
                                width: statWidth,
                                child: SellerStatsCard(
                                  label: 'Total Sales',
                                  value: 'Rs. ${controller.totalSales.toStringAsFixed(0)}',
                                  icon: Icons.payments_rounded,
                                  accentColor: const Color(0xFF4C8BF5),
                                ),
                              ),
                              SizedBox(
                                width: statWidth,
                                child: SellerStatsCard(
                                  label: 'Pending Orders',
                                  value: '${controller.pendingOrdersCount}',
                                  icon: Icons.hourglass_top_rounded,
                                  accentColor: const Color(0xFF66BB6A),
                                ),
                              ),
                              SizedBox(
                                width: statWidth,
                                child: SellerStatsCard(
                                  label: 'Draft Listings',
                                  value: '${controller.draftCount}',
                                  icon: Icons.edit_note_rounded,
                                  accentColor: const Color(0xFF7CB342),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      StoreSectionHeader(
                        title: 'My Listings',
                        subtitle: 'Preview the products tied to your Firestore seller profile.',
                        actionLabel: 'Open All',
                        onActionTap: () => _openMyListings(context),
                      ),
                      const SizedBox(height: 14),
                      if (listings.isEmpty)
                        _EmptyCard(
                          icon: Icons.inventory_2_outlined,
                          message: 'No seller listings yet',
                          buttonLabel: 'Add New Product',
                          onPressed: () => _openAddProduct(context),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, listingConstraints) {
                            final gap = 14.0;
                            final cardWidth = listingColumns == 1
                                ? listingConstraints.maxWidth
                                : ((listingConstraints.maxWidth - gap) / 2)
                                    .clamp(260.0, 520.0)
                                    .toDouble();

                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: listings.take(2).map(
                                (product) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: SellerProductCard(
                                      product: product,
                                      onTap: () => _openProduct(context, product),
                                      onEdit: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => AddProductScreen(existingProduct: product),
                                        ),
                                      ),
                                      onDelete: () => controller.deleteProduct(product.id),
                                    ),
                                  );
                                },
                              ).toList(),
                            );
                          },
                        ),
                      const SizedBox(height: 22),
                      StoreSectionHeader(
                        title: 'Orders',
                        subtitle: 'Sample order cards for the seller dashboard.',
                        actionLabel: 'Open Orders',
                        onActionTap: () => _openOrders(context),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, orderConstraints) {
                          final gap = 14.0;
                          final cardWidth = orderColumns == 1
                              ? orderConstraints.maxWidth
                              : ((orderConstraints.maxWidth - gap) / 2)
                                  .clamp(260.0, 520.0)
                                  .toDouble();

                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: orders.take(2).map((order) {
                              return SizedBox(
                                width: cardWidth,
                                child: OrderCard(order: order),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      StoreSectionHeader(
                        title: 'Sales Summary',
                        subtitle: 'High-level numbers for your connected marketplace account.',
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: colorScheme.surface.withValues(alpha: 0.76),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.26),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current seller',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'EarthRoot Garden Store',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'All orders, payouts, and seller verification are wired through Firebase and backend services.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      StoreSectionHeader(
                        title: 'Seller Profile',
                        subtitle: 'A small profile summary for the connected seller account.',
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: colorScheme.surface.withValues(alpha: 0.76),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.26),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EarthRoot Garden Store',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bengaluru, Karnataka',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Seller profile details will reflect your Firebase account and profile data.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
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
        title: const Text('Seller Dashboard'),
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String buttonLabel;
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
        children: [
          Icon(icon, size: 44, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _AuthPrompt extends StatelessWidget {
  const _AuthPrompt({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
