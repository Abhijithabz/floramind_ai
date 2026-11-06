class CartItem {
  const CartItem({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  CartItem copyWith({
    String? productId,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: (map['productId'] as String?) ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}
