import 'package:flutter/material.dart';

import 'garden_store_controller.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../authentication/login_screen.dart';
import 'add_product_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'my_listings_screen.dart';
import 'product_details_screen.dart';
import 'seller_dashboard_screen.dart';
import 'seller_orders_screen.dart';
import 'wishlist_screen.dart';
import 'garden_store_home_screen.dart';

class GardenStoreScreen extends StatefulWidget {
  const GardenStoreScreen({super.key});

  @override
  State<GardenStoreScreen> createState() => _GardenStoreScreenState();
}

class _GardenStoreScreenState extends State<GardenStoreScreen> {
  int _selectedIndex = 0;

  static const List<_StoreTabData> _tabs = [
    _StoreTabData(
      label: 'Market',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      title: 'Market',
    ),
    _StoreTabData(
      label: 'Categories',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      title: 'Categories',
    ),
    _StoreTabData(
      label: 'Wishlist',
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      title: 'Wishlist',
    ),
    _StoreTabData(
      label: 'Cart',
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag_rounded,
      title: 'Cart',
    ),
    _StoreTabData(
      label: 'Sell',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      title: 'Seller Dashboard',
    ),
  ];

  void _openProductDetails(String productId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(productId: productId),
      ),
    );
  }

  void _openSellerDashboard() {
    if (!GardenStoreController.instance.isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SellerDashboardScreen(),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tab = _tabs[_selectedIndex];

    return AppBar(
      automaticallyImplyLeading: false,
      leading: const BackButton(),
      title: Text(tab.title),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
      surfaceTintColor: Colors.transparent,
      actions: [
        if (_selectedIndex != 3)
          IconButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
            icon: const Icon(Icons.shopping_bag_rounded),
            tooltip: 'Open cart',
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                                GardenStoreHomeScreen(
                  embedded: true,
                  onOpenProductDetails: _openProductDetails,
                  onOpenSellerDashboard: _openSellerDashboard,
                ),
                CategoriesScreen(
                  embedded: true,
                  onOpenProductDetails: _openProductDetails,
                ),
                WishlistScreen(
                  embedded: true,
                  onOpenProductDetails: _openProductDetails,
                ),
                CartScreen(
                  embedded: true,
                  onOpenProductDetails: _openProductDetails,
                ),
                SellerDashboardScreen(
                  embedded: true,
                  onOpenProductDetails: _openProductDetails,
                  onOpenAddProduct: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddProductScreen(),
                      ),
                    );
                  },
                  onOpenMyListings: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyListingsScreen(),
                      ),
                    );
                  },
                  onOpenOrders: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SellerOrdersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        elevation: 10,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.94),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StoreTabData {
  const _StoreTabData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.title,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String title;
}
