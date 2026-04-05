class CartItemEntity {
  final String cartItemId;
  final String productId;
  final int quantity;
  final String color;
  final int price;

  const CartItemEntity({
    required this.cartItemId,
    required this.productId,
    required this.quantity,
    required this.color,
    required this.price,
  });
}
