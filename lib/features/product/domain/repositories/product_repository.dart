import 'package:ecommerce_app/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int page = 1, int limit = 10});

  Future<List<ProductEntity>> getTopSellingProducts();

  Future<List<ProductEntity>> getProductsDetail(String productId);
  Future<List<ProductEntity>> getProductsByTitle(
    String title, {
    String? categoryId,
  });
  //Future<List<ProductEntity>> getNewProducts({int limit = 10});
}
