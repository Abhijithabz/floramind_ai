import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  const WishlistItem({
    required this.productId,
    required this.addedAt,
  });

  final String productId;
  final DateTime addedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    final addedAtValue = map['addedAt'];
    return WishlistItem(
      productId: (map['productId'] as String?) ?? '',
      addedAt: addedAtValue is Timestamp
          ? addedAtValue.toDate()
          : DateTime.tryParse(addedAtValue?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

