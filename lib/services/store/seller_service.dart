import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/product.dart';
import '../../models/seller_profile.dart';
import '../../models/store_operation_result.dart';

class SellerService {
  const SellerService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  Stream<SellerProfile?> watchSellerProfile(String userId) {
    if (!isAvailable) {
      return Stream<SellerProfile?>.value(null);
    }

    return FirebaseFirestore.instance
        .collection('seller_profiles')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return SellerProfile.fromMap(data, docId: snapshot.id);
    });
  }

  Future<StoreOperationResult> saveSellerProfile(SellerProfile profile) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('seller_profiles')
          .doc(profile.userId)
          .set(profile.toMap(), SetOptions(merge: true));
      return const StoreOperationResult(
        success: true,
        message: 'Seller profile saved successfully.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to save seller profile.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to save seller profile.',
      );
    }
  }

  Future<int> countProducts({
    required String sellerId,
    bool? isActive,
    bool? inStock,
  }) async {
    if (!isAvailable) {
      return 0;
    }

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('products').where('sellerId', isEqualTo: sellerId);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    final snapshot = await query.get();
    final products = snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), docId: doc.id))
        .toList(growable: false);

    if (inStock == null) {
      return products.length;
    }

    return products.where((product) => inStock ? !product.isOutOfStock : product.isOutOfStock).length;
  }
}

