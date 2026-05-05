class OrderRequest {
  final String type;
  final String addressId;
  final String? productId;
  final String? variantId;
  final int? quantity;
  final int finalPrice;

  const OrderRequest({
    required this.type,
    required this.addressId,
    required this.finalPrice,
    this.productId,
    this.variantId,
    this.quantity,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      type: (json['type'] ?? '').toString(),
      addressId: (json['addressId'] ?? '').toString(),
      finalPrice: (json['finalPrice'] as num?)?.toInt() ?? 0,
      productId: json['productId']?.toString(),
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'addressId': addressId,
      'finalPrice': finalPrice,
    };

    if (productId != null) {
      map['productId'] = productId;
    }
    if (variantId != null) {
      map['variantId'] = variantId;
    }
    if (quantity != null) {
      map['quantity'] = quantity;
    }

    return map;
  }
}
