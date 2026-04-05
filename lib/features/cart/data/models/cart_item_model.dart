import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.cartItemId,
    required super.productId,
    required super.quantity,
    required super.color,
    required super.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['_id'] ?? json['cartItemId'] ?? '',
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      color: json['color'] ?? '',
      price: json['price'] ?? 0,
    );
  }

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
