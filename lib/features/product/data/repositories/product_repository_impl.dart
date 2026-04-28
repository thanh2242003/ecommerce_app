import '../sources/product_api_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductEntity>> getTopSellingProducts() async {
    try {
      // Gọi trực tiếp từ ApiService
      return await ProductApiService.getTopSelling();
    } catch (e) {
      // Có thể xử lý lỗi hoặc trả về list rỗng nếu lỗi
      return [];
    }
  }

  @override
  Future<List<ProductEntity>> getProductsDetail(String productId) async {
    try {
      final product = await ProductApiService.getProductById(productId);
      return [product]; // Trả về list theo đúng interface hiện tại của bạn
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByTitle(String title) async {
    try {
      if (title.isEmpty) return [];
      return await ProductApiService.searchProducts(title);
    } catch (e) {
      return [];
    }
  }
}
