import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../sources/cart_api_service.dart';

class CartRepositoryImpl implements CartRepository {
  final CartApiService apiService;

  CartRepositoryImpl({required this.apiService});

  @override
  Future<CartItemEntity> addToCart({
    required String productId,
    required int quantity,
    required String color,
    String? size,
  }) async {
    return await apiService.addToCart(
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
    );
  }

  @override
  Future<List<CartItemEntity>> getCart() async {
    return await apiService.getCart();
  }

  @override
  Future<List<CartItemEntity>> updateQuantity({
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) async {
    return await apiService.updateQuantity(
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
    );
  }

  @override
  Future<List<CartItemEntity>> deleteItem({
    required String productId,
    String? color,
    String? size,
  }) async {
    return await apiService.deleteItem(
      productId: productId,
      color: color,
      size: size,
    );
  }
}
