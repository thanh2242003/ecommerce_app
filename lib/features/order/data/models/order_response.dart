class OrderResponse {
  final String id;
  final int totalPrice;
  final int finalPrice;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? paymentExpiredAt;
  final DateTime? paidAt;
  final String? transactionId;
  final String? cancelReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;
  final int itemCount;
  final List<OrderItemPreview> items;
  final String? receiverName;
  final String? receiverPhone;
  final String? address;

  const OrderResponse({
    required this.id,
    required this.totalPrice,
    required this.finalPrice,
    required this.status,
    this.paymentMethod = '',
    this.paymentStatus = '',
    required this.createdAt,
    this.paymentExpiredAt,
    this.paidAt,
    this.transactionId,
    this.cancelReason,
    this.cancelledBy,
    this.cancelledAt,
    this.refundedAt,
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

    final totalPrice = _readInt(json, const ['totalPrice', 'finalPrice']);
    final finalPrice = _readInt(json, const ['finalPrice', 'totalPrice']);

    return OrderResponse(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      totalPrice: totalPrice,
      finalPrice: finalPrice,
      status: (json['status'] ?? '').toString(),
      paymentMethod: (json['paymentMethod'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      paymentExpiredAt: _readDate(json['paymentExpiredAt']),
      paidAt: _readDate(json['paidAt']),
      transactionId: _readNullableString(json['transactionId']),
      cancelReason: _readNullableString(json['cancelReason']),
      cancelledBy: _readNullableString(json['cancelledBy']),
      cancelledAt: _readDate(json['cancelledAt']),
      refundedAt: _readDate(json['refundedAt']),
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
      'finalPrice': finalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'paymentExpiredAt': paymentExpiredAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
      'cancelReason': cancelReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
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

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _readNullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }
}

class OrderItemPreview {
  final String productId;
  final String image;
  final String name;
  final int quantity;
  final String? color;
  final String? size;

  const OrderItemPreview({
    required this.productId,
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
      productId: readString(['productId', '_id', 'id']),
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
      'productId': productId,
    };
  }
}
