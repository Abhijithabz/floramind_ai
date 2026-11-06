import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/store_operation_result.dart';
import '../../models/wishlist_item.dart';

class WishlistService {
  const WishlistService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  Stream<Set<String>> watchWishlistProductIds(String userId) {
    if (!isAvailable) {
      return Stream<Set<String>>.value(<String>{});
    }

    return FirebaseFirestore.instance
        .collection('wishlists')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<StoreOperationResult> addItem({
    required User user,
    required String productId,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('wishlists')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .set(
            WishlistItem(
              productId: productId,
              addedAt: DateTime.now(),
            ).toMap(),
          );
      return const StoreOperationResult(
        success: true,
        message: 'Product saved to wishlist.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to save product to wishlist.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to save product to wishlist.',
      );
    }
  }

  Future<StoreOperationResult> removeItem({
    required User user,
    required String productId,
  }) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('wishlists')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .delete();
      return const StoreOperationResult(
        success: true,
        message: 'Product removed from wishlist.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to remove product from wishlist.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to remove product from wishlist.',
      );
    }
  }
}

