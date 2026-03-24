import 'package:ecommerce_app/features/product/domain/entities/product.dart';

abstract class ProductRepository{
  Future<List<ProductEntity>> getTopSellingProducts();

  Future<List<ProductEntity>> getProductsDetail(String productId);
  Future<List<ProductEntity>> getProductsByTitle(String title);
  //Future<List<ProductEntity>> getNewProducts({int limit = 10});
}