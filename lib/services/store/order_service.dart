import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/order_item.dart';
import '../../models/store_order.dart';
import '../../models/store_operation_result.dart';

class OrderService {
  const OrderService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  Stream<List<StoreOrder>> watchSellerOrders(String sellerId) {
    if (!isAvailable) {
      return Stream<List<StoreOrder>>.value(const <StoreOrder>[]);
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StoreOrder.fromMap(doc.data(), docId: doc.id))
              .toList(growable: false),
        );
  }

  Future<StoreOperationResult> createOrder(StoreOrder order) async {
    if (!isAvailable) {
      return const StoreOperationResult(
        success: false,
        message: 'Firebase is not configured for this build.',
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .set(order.toMap());
      return const StoreOperationResult(
        success: true,
        message: 'Order saved successfully.',
      );
    } on FirebaseException catch (error) {
      return StoreOperationResult(
        success: false,
        message: error.message ?? 'Unable to save order.',
      );
    } catch (_) {
      return const StoreOperationResult(
        success: false,
        message: 'Unable to save order.',
      );
    }
  }

  StoreOrder draftFromCart({
    required String orderId,
    required String buyerId,
    required String buyerName,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    required String sellerId,
    required String sellerName,
  }) {
    return StoreOrder(
      orderId: orderId,
      buyerId: buyerId,
      buyerName: buyerName,
      items: items,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      orderStatus: 'Pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sellerId: sellerId,
      sellerName: sellerName,
    );
  }
}

