class ReturnItemResponse {
  final String productId;
  final String variantId;
  final String productName;
  final int quantity;
  final num? price;

  ReturnItemResponse({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.quantity,
    this.price,
  });

  factory ReturnItemResponse.fromJson(Map<String, dynamic> json) {
    return ReturnItemResponse(
      productId: (json['productId'] ?? json['product'] ?? json['_id'] ?? '')
          .toString(),
      variantId: (json['variantId'] ?? '').toString(),
      productName: (json['productName'] ?? json['name'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: json['price'] as num?,
    );
  }
}

class ReturnResponse {
  final String id;
  final String orderId;
  final String userId;
  final String shopId;
  final String reason;
  final String? description;
  final List<ReturnItemResponse> returnItems;
  final num returnPrice;
  final String status;
  final String? adminId;
  final String? approvalReason;
  final DateTime? requestedAt;
  final DateTime? approvedAt;
  final DateTime? returnedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  ReturnResponse({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.shopId,
    required this.reason,
    this.description,
    this.returnItems = const [],
    this.returnPrice = 0,
    this.status = '',
    this.adminId,
    this.approvalReason,
    this.requestedAt,
    this.approvedAt,
    this.returnedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory ReturnResponse.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['returnItems'] ?? json['items'] ?? [];
    final items = <ReturnItemResponse>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map<String, dynamic>) {
          items.add(ReturnItemResponse.fromJson(item));
        }
      }
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return ReturnResponse(
      id: (json['returnId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      shopId: (json['shopId'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      returnItems: items,
      returnPrice: json['returnPrice'] is num
          ? json['returnPrice'] as num
          : (json['refundAmount'] is num ? json['refundAmount'] as num : 0),
      status: (json['status'] ?? '').toString(),
      adminId: (json['adminId'] ?? '').toString().isEmpty
          ? null
          : (json['adminId'] as String?),
      approvalReason: (json['approvalReason'] ?? '').toString().isEmpty
          ? null
          : (json['approvalReason'] as String?),
      requestedAt: parseDate(
        json['requestedAt'] ?? json['createdAt'] ?? json['requested_at'],
      ),
      approvedAt: parseDate(json['approvedAt']),
      returnedAt: parseDate(json['returnedAt']),
      completedAt: parseDate(json['completedAt']),
      cancelledAt: parseDate(json['cancelledAt']),
    );
  }
}
