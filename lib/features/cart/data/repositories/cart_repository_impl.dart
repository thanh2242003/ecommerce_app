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
  }) async {
    return await apiService.addToCart(
      productId: productId,
      quantity: quantity,
      color: color,
    );
  }
}
