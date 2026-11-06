import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/product.dart';
import '../../models/store_operation_result.dart';

class ProductService {
  const ProductService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  Stream<List<Product>> watchActiveProducts() {
    if (!isAvailable) {
      return Stream<List<Product>>.value(const <Product>[]);
    }

    return FirebaseFirestore.instance
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), docId: doc.id))
              .toList(growable: false)
            ..sort(_sortProducts),
        );
  }

  Stream<List<Product>> watchSellerProducts(String sellerId) {
    if (!isAvailable) {
      return Stream<List<Product>>.value(const <Product>[]);
    }

    return FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), docId: doc.id))
              .toList(growable: false)
            ..sort(_sortProducts),
        );
  }

  Future<Product?> fetchProduct(String productId) async {
    if (!isAvailable) {
      return null;
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('products').doc(productId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return Product.fromMap(snapshot.data()!, docId: snapshot.id);
  }

  Future<StoreOperationResult> saveProduct(Product product) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .set(product.toMap());
      return const StoreOperationResult(
        success: true,
        message: 'Product listed successfully.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to save product.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to save product.',
      );
    }
  }

  Future<StoreOperationResult> updateProduct(Product product) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
      return const StoreOperationResult(
        success: true,
        message: 'Product updated successfully.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to update product.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to update product.',
      );
    }
  }

  Future<StoreOperationResult> deactivateProduct(String productId) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const StoreOperationResult(
        success: true,
        message: 'Product deactivated successfully.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to deactivate product.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to deactivate product.',
      );
    }
  }

  Future<StoreOperationResult> setStock({
    required String productId,
    required int stock,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'stock': stock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const StoreOperationResult(
        success: true,
        message: 'Stock updated successfully.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to update stock.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to update stock.',
      );
    }
  }

  int _sortProducts(Product a, Product b) {
    if (a.isFeatured != b.isFeatured) {
      return a.isFeatured ? -1 : 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }
}

