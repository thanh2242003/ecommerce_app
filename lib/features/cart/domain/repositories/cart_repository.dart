import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<CartItemEntity> addToCart({
    required String productId,
    required int quantity,
    required String color,
  });
}
