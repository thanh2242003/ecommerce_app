class OrderRequest {
  final String type;
  final String addressId;
  final String? productId;
  final String? variantId;
  final int? quantity;
  final int finalPrice;
  final String paymentMethod;
  final String? discountCode;
  final List<Map<String, String>>? selectedCartItems;

  const OrderRequest({
    required this.type,
    required this.addressId,
    required this.finalPrice,
    this.paymentMethod = 'cod',
    this.discountCode,
    this.productId,
    this.variantId,
    this.quantity,
    this.selectedCartItems,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      type: (json['type'] ?? '').toString(),
      addressId: (json['addressId'] ?? '').toString(),
      finalPrice: (json['finalPrice'] as num?)?.toInt() ?? 0,
      paymentMethod: (json['paymentMethod'] ?? 'cod').toString(),
      discountCode: json['discountCode']?.toString(),
      productId: json['productId']?.toString(),
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt(),
      selectedCartItems: _readSelectedCartItems(json['selectedCartItems']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'addressId': addressId,
      'finalPrice': finalPrice,
      'paymentMethod': paymentMethod,
      if (discountCode != null && discountCode!.trim().isNotEmpty)
        'discountCode': discountCode,
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
    if (selectedCartItems != null && selectedCartItems!.isNotEmpty) {
      map['selectedCartItems'] = selectedCartItems;
    }

    return map;
  }

  static List<Map<String, String>>? _readSelectedCartItems(dynamic value) {
    if (value is! List) {
      return null;
    }

    return value
        .whereType<Map>()
        .map((item) {
          final productId = item['productId']?.toString();
          final variantId = item['variantId']?.toString();
          if (productId == null || variantId == null) {
            return null;
          }
          return <String, String>{
            'productId': productId,
            'variantId': variantId,
          };
        })
        .whereType<Map<String, String>>()
        .toList();
  }
}
