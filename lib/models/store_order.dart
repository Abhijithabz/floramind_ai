import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item.dart';

class StoreOrder {
  const StoreOrder({
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.sellerId,
    required this.sellerName,
  });

  final String orderId;
  final String buyerId;
  final String buyerName;
  final List<OrderItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sellerId;
  final String sellerName;

  String get id => orderId;

  String get productName => items.isEmpty ? 'Order' : items.first.productName;

  int get quantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get amount => totalAmount;

  DateTime get orderDate => createdAt;

  String get status => orderStatus;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'orderStatus': orderStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }

  factory StoreOrder.fromMap(Map<String, dynamic> map, {String? docId}) {
    return StoreOrder(
      orderId: (map['orderId'] as String?) ?? docId ?? '',
      buyerId: (map['buyerId'] as String?) ?? '',
      buyerName: (map['buyerName'] as String?) ?? '',
      items: _readItems(map['items']),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      deliveryAddress: (map['deliveryAddress'] as String?) ?? '',
      orderStatus: (map['orderStatus'] as String?) ?? 'Pending',
      createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _toDate(map['updatedAt']) ?? DateTime.now(),
      sellerId: (map['sellerId'] as String?) ?? '',
      sellerName: (map['sellerName'] as String?) ?? '',
    );
  }

  static List<OrderItem> _readItems(dynamic value) {
    if (value is! List) {
      return const <OrderItem>[];
    }
    return value
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromMap)
        .toList(growable: false);
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

