import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase({required this.repository});

  Future<CartItemEntity> call({
    required String productId,
    required int quantity,
    required String color,
    String? size,
    String? variantId,
  }) {
    return repository.addToCart(
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
      variantId: variantId,
    );
  }
}
