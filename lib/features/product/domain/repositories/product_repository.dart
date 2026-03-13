import 'package:ecommerce_app/features/product/domain/entities/product.dart';

abstract class ProductRepository{
  Future<List<ProductEntity>> getTopSellingProducts();

  Future<List<ProductEntity>> getProductsDetail(String productId);

}