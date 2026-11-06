class StoreOperationResult {
  const StoreOperationResult({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final Object? data;
}
