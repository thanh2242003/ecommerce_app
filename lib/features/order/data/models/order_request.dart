class OrderRequest {
  final String type;
  final String addressId;
  final String? productId;
  final int? quantity;
  final String? color;
  final String? size;

  const OrderRequest({
    required this.type,
    required this.addressId,
    this.productId,
    this.quantity,
    this.color,
    this.size,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      type: (json['type'] ?? '').toString(),
      addressId: (json['addressId'] ?? '').toString(),
      productId: json['productId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type, 'addressId': addressId};

    if (productId != null) {
      map['productId'] = productId;
    }
    if (quantity != null) {
      map['quantity'] = quantity;
    }
    if (color != null) {
      map['color'] = color;
    }
    if (size != null) {
      map['size'] = size;
    }

    return map;
  }
}
