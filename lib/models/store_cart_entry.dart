class StoreCartEntry {
  const StoreCartEntry({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  StoreCartEntry copyWith({
    String? productId,
    int? quantity,
  }) {
    return StoreCartEntry(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}

