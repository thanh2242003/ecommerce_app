class CartItemEntity {
  final String cartItemId;
  final String productId;
  final int quantity;
  final String color;
  final String? size;
  final int price;
  final String productName;
  final String? productImage;

  const CartItemEntity({
    required this.cartItemId,
    required this.productId,
    required this.quantity,
    required this.color,
    this.size,
    required this.price,
    this.productName = '',
    this.productImage,
  });

  CartItemEntity copyWith({
    String? cartItemId,
    String? productId,
    int? quantity,
    String? color,
    String? size,
    int? price,
    String? productName,
    String? productImage,
  }) {
    return CartItemEntity(
      cartItemId: cartItemId ?? this.cartItemId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      size: size ?? this.size,
      price: price ?? this.price,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
    );
  }
}
