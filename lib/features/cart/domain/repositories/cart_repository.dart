import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<CartItemEntity> addToCart({
    required String productId,
    required int quantity,
    required String color,
    String? size,
    String? variantId,
  });

  Future<List<CartItemEntity>> getCart();

  Future<List<CartItemEntity>> updateQuantity({
    required String productId,
    required int quantity,
    String? color,
    String? size,
    String? variantId,
  });

  Future<List<CartItemEntity>> deleteItem({
    required String productId,
    String? color,
    String? size,
    String? variantId,
  });
}
