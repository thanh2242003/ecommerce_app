import 'package:ecommerce_app/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    int? minPrice,
    int? maxPrice,
    int? gender,
    String? ageRange,
    String? sort,
    String? order,
  });

  Future<List<ProductEntity>> getTopSellingProducts();

  Future<List<ProductEntity>> getProductsDetail(String productId);
  Future<List<ProductEntity>> getProductsByTitle(
    String title, {
    String? categoryId,
    String? ageRange,
  });
  //Future<List<ProductEntity>> getNewProducts({int limit = 10});
}
