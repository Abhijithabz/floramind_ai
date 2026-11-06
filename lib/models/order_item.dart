class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.sellerId,
    required this.sellerName,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
    required this.subtotal,
  });

  final String productId;
  final String productName;
  final String sellerId;
  final String sellerName;
  final int quantity;
  final double unitPrice;
  final String imageUrl;
  final double subtotal;

  factory OrderItem.fromProduct({
    required String productId,
    required String productName,
    required String sellerId,
    required String sellerName,
    required int quantity,
    required double unitPrice,
    required String imageUrl,
  }) {
    return OrderItem(
      productId: productId,
      productName: productName,
      sellerId: sellerId,
      sellerName: sellerName,
      quantity: quantity,
      unitPrice: unitPrice,
      imageUrl: imageUrl,
      subtotal: unitPrice * quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'imageUrl': imageUrl,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: (map['productId'] as String?) ?? '',
      productName: (map['productName'] as String?) ?? '',
      sellerId: (map['sellerId'] as String?) ?? '',
      sellerName: (map['sellerName'] as String?) ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      imageUrl: (map['imageUrl'] as String?) ?? '',
      subtotal: (map['subtotal'] as num?)?.toDouble() ??
          ((map['unitPrice'] as num?)?.toDouble() ?? 0) *
              ((map['quantity'] as num?)?.toInt() ?? 0),
    );
  }
}
