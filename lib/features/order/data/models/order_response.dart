class OrderResponse {
  final String id;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final int itemCount;
  final List<OrderItemPreview> items;
  final String? receiverName;
  final String? receiverPhone;
  final String? address;

  const OrderResponse({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.itemCount = 0,
    this.items = const [],
    this.receiverName,
    this.receiverPhone,
    this.address,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final parsedItems = _parseItems(json);
    int resolvedItemCount =
        (json['itemCount'] as num?)?.toInt() ??
        (json['totalItems'] as num?)?.toInt() ??
        (json['quantity'] as num?)?.toInt() ??
        0;

    if (resolvedItemCount == 0) {
      if (parsedItems.isNotEmpty) {
        resolvedItemCount = parsedItems.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
      }

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
      items: parsedItems,
      receiverName: (json['receiverName'] ?? '').toString().isEmpty
          ? null
          : (json['receiverName'] as String?),
      receiverPhone: (json['receiverPhone'] ?? '').toString().isEmpty
          ? null
          : (json['receiverPhone'] as String?),
      address: (json['address'] ?? '').toString().isEmpty
          ? null
          : (json['address'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'itemCount': itemCount,
      'items': items.map((item) => item.toJson()).toList(),
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'address': address,
    };
  }

  static List<OrderItemPreview> _parseItems(Map<String, dynamic> json) {
    final dynamic items =
        json['items'] ?? json['products'] ?? json['orderItems'];
    if (items is! List) {
      return const <OrderItemPreview>[];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(OrderItemPreview.fromJson)
        .toList();
  }
}

class OrderItemPreview {
  final String image;
  final String name;
  final int quantity;
  final String? color;
  final String? size;

  const OrderItemPreview({
    required this.image,
    required this.name,
    required this.quantity,
    this.color,
    this.size,
  });

  factory OrderItemPreview.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final productMap = product is Map<String, dynamic>
        ? product
        : const <String, dynamic>{};

    String readString(List<String> keys) {
      for (final source in [json, productMap]) {
        for (final key in keys) {
          final value = source[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString();
          }
        }
      }
      return '';
    }

    return OrderItemPreview(
      image: readString([
        'image',
        'imageUrl',
        'thumbnail',
        'thumbnailUrl',
        'photo',
        'avatar',
      ]),
      name: readString(['name', 'title', 'productName']),
      quantity:
          (json['quantity'] as num?)?.toInt() ??
          (json['qty'] as num?)?.toInt() ??
          1,
      color: readString(['color', 'colour']),
      size: readString(['size']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'name': name,
      'quantity': quantity,
      'color': color,
      'size': size,
    };
  }
}
