class ReturnItemRequest {
  final String variantId;
  final int quantity;

  ReturnItemRequest({required this.variantId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'quantity': quantity,
    };
  }
}

class ReturnRequest {
  final String orderId;
  final String reason;
  final String? description;
  final List<ReturnItemRequest> returnItems;

  ReturnRequest({
    required this.orderId,
    required this.reason,
    this.description,
    this.returnItems = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'reason': reason,
      if (description != null) 'description': description,
      if (returnItems.isNotEmpty)
        'returnItems': returnItems.map((i) => i.toJson()).toList(),
    };
  }
}
