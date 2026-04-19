import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.cartItemId,
    required super.productId,
    required super.quantity,
    required super.color,
    required super.price,
    super.productName,
    super.productImage,
  });
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String productId = '';
    String productName = '';
    String? productImage;

    if (product is Map<String, dynamic>) {
      productId = product['_id'] ?? '';
      productName = product['title'] ?? '';
      final images = product['images'];
      if (images is List && images.isNotEmpty) {
        productImage = images.first as String?;
      }
    } else if (product is String) {
      productId = product;
    }

    return CartItemModel(
      cartItemId:
          json['_id'] ??
          json['cartItemId'] ??
          '${productId}_${json['color'] ?? ''}',

      productId: productId,
      quantity: json['quantity'] ?? 0,
      color: json['color'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,

      productName: productName,
      productImage: productImage,
    );
  }

  // factory CartItemModel.fromJson(Map<String, dynamic> json) {
  //   // product can be a populated object or just an id string
  //   final product = json['product'];
  //   String productId = '';
  //   String productName = '';
  //   String? productImage;

  //   if (product is Map<String, dynamic>) {
  //     productId = product['_id'] ?? '';
  //     productName = product['title'] ?? '';
  //     final images = product['images'];
  //     if (images is List && images.isNotEmpty) {
  //       productImage = images.first as String?;
  //     }
  //   } else if (product is String) {
  //     productId = product;
  //   }

  //   return CartItemModel(
  //     cartItemId: json['_id'] ?? json['cartItemId'] ?? '',
  //     productId: productId,
  //     quantity: json['quantity'] ?? 0,
  //     color: json['color'] ?? '',
  //     price: json['price'] ?? 0,
  //     productName: productName,
  //     productImage: productImage,
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'productId': productId,
      'quantity': quantity,
      'color': color,
      'price': price,
    };
  }
}
