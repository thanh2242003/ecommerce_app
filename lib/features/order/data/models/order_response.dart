class OrderResponse {
  final String id;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final int itemCount;

  const OrderResponse({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.itemCount = 0,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    int resolvedItemCount =
        (json['itemCount'] as num?)?.toInt() ??
        (json['totalItems'] as num?)?.toInt() ??
        (json['quantity'] as num?)?.toInt() ??
        0;

    if (resolvedItemCount == 0) {
      final dynamic items =
          json['items'] ?? json['products'] ?? json['orderItems'];
      if (items is List) {
        resolvedItemCount = items.fold<int>(0, (sum, item) {
          if (item is Map<String, dynamic>) {
            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
            return sum + qty;
          }
          return sum + 1;
        });
      }
    }

    return OrderResponse(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      itemCount: resolvedItemCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'itemCount': itemCount,
    };
  }
}
