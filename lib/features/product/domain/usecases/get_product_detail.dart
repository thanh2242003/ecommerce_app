import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';

import '../entities/product.dart';

class GetProductDetail{
  final ProductRepository productRepository;
  GetProductDetail(this.productRepository);

  Future<List<ProductEntity>> call(String productId) async{
    return await productRepository.getProductsDetail(productId);
  }
}
