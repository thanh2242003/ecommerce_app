import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase({required this.repository});

  Future<CartItemEntity> call({
    required String productId,
    required int quantity,
    required String color,
  }) {
    return repository.addToCart(
      productId: productId,
      quantity: quantity,
      color: color,
    );
  }
}
