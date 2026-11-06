import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../models/product.dart';
import '../../models/seller_profile.dart';
import '../../models/store_cart_entry.dart';
import '../../models/store_operation_result.dart';
import '../../models/store_order.dart';
import '../../services/store/order_service.dart';
import '../../services/store/product_service.dart';
import '../../services/store/seller_service.dart';
import '../../services/store/storage_service.dart';
import '../../services/store/wishlist_service.dart';

class GardenStoreController extends ChangeNotifier {
  GardenStoreController._() {
    if (Firebase.apps.isNotEmpty) {
      _bindFirebase();
    }
  }

  static final GardenStoreController instance = GardenStoreController._();

  static const List<String> categoryOrder = <String>[
    'Plants',
    'Flowers',
    'Seeds',
    'Indoor Plants',
    'Garden Plants',
    'Saplings',
    'Pots & Planters',
    'Gardening Tools',
    'Fertilizers',
    'Plant Care',
  ];

  static const String defaultSellerName = 'FloraMind Seller';

  final ProductService _productService = const ProductService();
  final WishlistService _wishlistService = const WishlistService();
  final SellerService _sellerService = const SellerService();
  final StorageService _storageService = const StorageService();
  final OrderService _orderService = const OrderService();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<Set<String>>? _wishlistSubscription;
  StreamSubscription<SellerProfile?>? _sellerProfileSubscription;
  StreamSubscription<List<StoreOrder>>? _ordersSubscription;

  User? _currentUser;
  SellerProfile? _sellerProfile;
  List<Product> _products = <Product>[];
  Set<String> _wishlistIds = <String>{};
  final List<StoreCartEntry> _cartEntries = <StoreCartEntry>[];
  List<StoreOrder> _orders = <StoreOrder>[];
  bool _loadingProducts = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  bool get isAuthenticated => _currentUser != null;

  bool get isLoadingProducts => _loadingProducts;

  String? get errorMessage => _errorMessage;

  String get currentSellerName =>
      _sellerProfile?.name ??
      _currentUser?.displayName ??
      _currentUser?.email ??
      defaultSellerName;

  String get currentSellerEmail => _sellerProfile?.email ?? _currentUser?.email ?? '';

  String get currentSellerPhone => _sellerProfile?.phone ?? '';

  String get currentSellerLocation => _sellerProfile?.location ?? '';

  String? get currentSellerId => _currentUser?.uid;

  List<Product> get products => List<Product>.unmodifiable(_products);

  List<Product> get featuredProducts => _products
      .where((product) => product.isActive && product.isFeatured)
      .toList(growable: false);

  List<Product> get featuredPlants => _products
      .where((product) => product.isActive && product.isFeatured && product.isPlant)
      .toList(growable: false);

  List<Product> get gardeningEssentials =>
      _products.where((product) => product.isActive && !product.isPlant).toList(
            growable: false,
          );

  List<Product> get wishlistProducts =>
      _products.where((product) => _wishlistIds.contains(product.id)).toList(
            growable: false,
          );

  List<StoreCartEntry> get cartEntries =>
      List<StoreCartEntry>.unmodifiable(_cartEntries);

  double get cartSubtotal => _cartEntries.fold<double>(
        0,
        (sum, entry) => sum + _cartEntryTotal(entry),
      );

  double get deliveryCharge => cartSubtotal <= 0 ? 0 : 0;

  double get cartTotal => cartSubtotal + deliveryCharge;

  List<StoreOrder> get orders => List<StoreOrder>.unmodifiable(_orders);

  List<Product> get sellerListings => _products
      .where((product) => product.sellerId == _currentUser?.uid)
      .toList(growable: false);

  int get activeListingsCount =>
      sellerListings.where((product) => product.isActive && !product.isOutOfStock).length;

  int get outOfStockCount =>
      sellerListings.where((product) => product.isOutOfStock).length;

  int get pendingOrdersCount =>
      _orders.where((order) => order.status == 'Pending').length;

  int get draftCount =>
      sellerListings.where((product) => product.listingStatus == 'Draft').length;

  double get totalSales => 0;

  List<String> get categories => <String>[
        'All',
        ...categoryOrder,
      ];

  String get totalProductsStat => isAuthenticated ? '${sellerListings.length}' : '--';

  String get activeListingsStat {
    if (!isAuthenticated) {
      return '--';
    }
    return '${sellerListings.where((product) => product.isActive && !product.isOutOfStock).length}';
  }

  String get outOfStockStat {
    if (!isAuthenticated) {
      return '--';
    }
    return '${sellerListings.where((product) => product.isOutOfStock).length}';
  }

  String get pendingOrdersStat {
    if (!isAuthenticated || _orders.isEmpty) {
      return '--';
    }
    return '${_orders.where((order) => order.status == 'Pending').length}';
  }

  String get totalSalesStat => '--';

  Product? productById(String id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  bool isFavorite(String productId) => _wishlistIds.contains(productId);

  double _cartEntryTotal(StoreCartEntry entry) {
    final product = productById(entry.productId);
    if (product == null) {
      return 0;
    }

    final unitPrice = product.discountPrice ?? product.price;
    return unitPrice * entry.quantity;
  }

  void _bindFirebase() {
    _loadingProducts = true;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _handleAuthStateChanged,
      onError: (Object error) {
        _errorMessage = 'Unable to read Firebase auth state.';
        notifyListeners();
      },
    );

    _productsSubscription = _productService.watchActiveProducts().listen(
      (products) {
        _products = products;
        _loadingProducts = false;
        _syncFavoriteFlags();
        notifyListeners();
      },
      onError: (Object error) {
        _loadingProducts = false;
        _errorMessage = 'Unable to load marketplace products.';
        _products = <Product>[];
        notifyListeners();
      },
    );
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    _currentUser = user;
    _sellerProfile = null;
    _orders = <StoreOrder>[];
    _wishlistIds = <String>{};

    await _wishlistSubscription?.cancel();
    await _sellerProfileSubscription?.cancel();
    await _ordersSubscription?.cancel();
    _wishlistSubscription = null;
    _sellerProfileSubscription = null;
    _ordersSubscription = null;

    if (user != null) {
      _wishlistSubscription = _wishlistService.watchWishlistProductIds(user.uid).listen(
        (wishlistIds) {
          _wishlistIds = wishlistIds;
          _syncFavoriteFlags();
          notifyListeners();
        },
        onError: (Object error) {
          _errorMessage = 'Unable to load wishlist.';
          notifyListeners();
        },
      );

      _sellerProfileSubscription =
          _sellerService.watchSellerProfile(user.uid).listen((profile) {
        _sellerProfile = profile;
        notifyListeners();
      });

      _ordersSubscription = _orderService.watchSellerOrders(user.uid).listen(
        (orders) {
          _orders = orders;
          notifyListeners();
        },
        onError: (Object error) {
          _orders = <StoreOrder>[];
          notifyListeners();
        },
      );
    }

    notifyListeners();
  }

  Future<StoreOperationResult> toggleFavorite(String productId) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to save products.',
      );
    }

    final wasFavorite = _wishlistIds.contains(productId);
    if (wasFavorite) {
      _wishlistIds.remove(productId);
      _syncFavoriteFlags();
      notifyListeners();
      final result = await _wishlistService.removeItem(
        user: _currentUser!,
        productId: productId,
      );
      if (!result.success) {
        _wishlistIds.add(productId);
        _syncFavoriteFlags();
        notifyListeners();
      }
      return result;
    }

    _wishlistIds.add(productId);
    _syncFavoriteFlags();
    notifyListeners();
    final result = await _wishlistService.addItem(
      user: _currentUser!,
      productId: productId,
    );
    if (!result.success) {
      _wishlistIds.remove(productId);
      _syncFavoriteFlags();
      notifyListeners();
    }
    return result;
  }

  Future<StoreOperationResult> addToWishlist(String productId) async {
    return toggleFavorite(productId);
  }

  Future<StoreOperationResult> removeFromWishlist(String productId) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to save products.',
      );
    }

    if (!_wishlistIds.contains(productId)) {
      return const StoreOperationResult(
        success: true,
        message: 'Product removed from wishlist.',
      );
    }

    _wishlistIds.remove(productId);
    _syncFavoriteFlags();
    notifyListeners();
    final result = await _wishlistService.removeItem(
      user: _currentUser!,
      productId: productId,
    );
    if (!result.success) {
      _wishlistIds.add(productId);
      _syncFavoriteFlags();
      notifyListeners();
    }
    return result;
  }

  void addToCart(String productId, {int quantity = 1}) {
    if (quantity <= 0) {
      return;
    }

    final product = productById(productId);
    if (product == null || product.isOutOfStock) {
      return;
    }

    final existingIndex = _cartEntries.indexWhere(
      (entry) => entry.productId == productId,
    );
    if (existingIndex >= 0) {
      final current = _cartEntries[existingIndex];
      final nextQuantity = (current.quantity + quantity).clamp(1, product.stock);
      _cartEntries[existingIndex] =
          current.copyWith(quantity: nextQuantity.toInt());
    } else {
      _cartEntries.add(
        StoreCartEntry(
          productId: productId,
          quantity: quantity.clamp(1, product.stock).toInt(),
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    final previousLength = _cartEntries.length;
    _cartEntries.removeWhere((entry) => entry.productId == productId);
    if (_cartEntries.length != previousLength) {
      notifyListeners();
    }
  }

  void setCartQuantity(String productId, int quantity) {
    final product = productById(productId);
    final index = _cartEntries.indexWhere((entry) => entry.productId == productId);
    if (product == null || index < 0) {
      return;
    }

    if (quantity <= 0) {
      _cartEntries.removeAt(index);
    } else {
      _cartEntries[index] = _cartEntries[index].copyWith(
        quantity: quantity.clamp(1, product.stock).toInt(),
      );
    }
    notifyListeners();
  }

  void incrementCartQuantity(String productId) {
    final entry = _cartEntries.firstWhere(
      (item) => item.productId == productId,
      orElse: () => const StoreCartEntry(productId: '', quantity: 0),
    );
    if (entry.productId.isEmpty) {
      return;
    }
    setCartQuantity(productId, entry.quantity + 1);
  }

  void decrementCartQuantity(String productId) {
    final entry = _cartEntries.firstWhere(
      (item) => item.productId == productId,
      orElse: () => const StoreCartEntry(productId: '', quantity: 0),
    );
    if (entry.productId.isEmpty) {
      return;
    }
    setCartQuantity(productId, entry.quantity - 1);
  }

  Future<StoreOperationResult> publishProduct({
    required Product product,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to sell products.',
      );
    }

    final sellerId = _currentUser!.uid;
    final sellerName = currentSellerName;
    final productId = product.id.isEmpty ? _generateProductId(sellerId) : product.id;
    String imageUrl = product.imageUrl;

    if (imageBytes != null) {
      final uploadedUrl = await _storageService.uploadProductImage(
        sellerId: sellerId,
        productId: productId,
        imageBytes: imageBytes,
        fileName: imageName ?? 'product.jpg',
      );
      if (uploadedUrl == null) {
        return const StoreOperationResult(
          success: false,
          message: 'Unable to upload product image.',
        );
      }
      imageUrl = uploadedUrl;
    }

    final payload = product.copyWith(
      id: productId,
      sellerId: sellerId,
      sellerName: sellerName,
      imageUrl: imageUrl,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await _productService.saveProduct(payload);
    if (result.success) {
      return const StoreOperationResult(
        success: true,
        message: 'Product listed successfully.',
      );
    }
    return result;
  }

  Future<StoreOperationResult> addProduct(
    Product product, {
    Uint8List? imageBytes,
    String? imageName,
  }) {
    return publishProduct(
      product: product,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }

  Future<StoreOperationResult> updateProduct({
    required Product product,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to sell products.',
      );
    }

    final sellerId = _currentUser!.uid;
    String imageUrl = product.imageUrl;

    if (imageBytes != null) {
      final uploadedUrl = await _storageService.uploadProductImage(
        sellerId: sellerId,
        productId: product.id,
        imageBytes: imageBytes,
        fileName: imageName ?? 'product.jpg',
      );
      if (uploadedUrl == null) {
        return const StoreOperationResult(
          success: false,
          message: 'Unable to upload product image.',
        );
      }
      imageUrl = uploadedUrl;
    }

    final payload = product.copyWith(
      sellerId: sellerId,
      sellerName: currentSellerName,
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    return _productService.updateProduct(payload);
  }

  Future<StoreOperationResult> deactivateProduct(String productId) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to sell products.',
      );
    }

    return _productService.deactivateProduct(productId);
  }

  Future<StoreOperationResult> deleteProduct(String productId) {
    return deactivateProduct(productId);
  }

  Future<StoreOperationResult> updateStock({
    required String productId,
    required int stock,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to sell products.',
      );
    }

    return _productService.setStock(productId: productId, stock: stock);
  }

  Future<StoreOperationResult> saveSellerProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
    String profileImage = '',
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return const StoreOperationResult(
        success: false,
        message: 'Please login to sell products.',
      );
    }

    final now = DateTime.now();
    final profile = SellerProfile(
      userId: _currentUser!.uid,
      name: name,
      email: email,
      phone: phone,
      location: location,
      profileImage: profileImage,
      createdAt: _sellerProfile?.createdAt ?? now,
      updatedAt: now,
    );

    return _sellerService.saveSellerProfile(profile);
  }

  List<Product> filterProducts({
    required String query,
    String selectedCategory = 'All',
    bool onlyPlants = false,
    bool onlyFeatured = false,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      final matchesPlantFilter = !onlyPlants || product.isPlant;
      final matchesFeatured = !onlyFeatured || product.isFeatured;
      final matchesQuery = normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery) ||
          product.type.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery) ||
          product.sellerName.toLowerCase().contains(normalizedQuery) ||
          product.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      return product.isActive &&
          matchesCategory &&
          matchesPlantFilter &&
          matchesFeatured &&
          matchesQuery;
    }).toList(growable: false);
  }

  List<Product> productsForCategory(String category) {
    if (category == 'All') {
      return products;
    }
    return _products
        .where((product) => product.isActive && product.category == category)
        .toList(growable: false);
  }

  void _syncFavoriteFlags() {
    for (var i = 0; i < _products.length; i++) {
      _products[i] = _products[i].copyWith(
        isFavorite: _wishlistIds.contains(_products[i].id),
      );
    }
  }

  String _generateProductId(String sellerId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'product_${sellerId}_$timestamp';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _productsSubscription?.cancel();
    _wishlistSubscription?.cancel();
    _sellerProfileSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
