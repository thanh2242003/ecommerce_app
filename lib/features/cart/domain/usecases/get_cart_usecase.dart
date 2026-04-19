import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase({required this.repository});

  Future<List<CartItemEntity>> call() {
    return repository.getCart();
  }
}
