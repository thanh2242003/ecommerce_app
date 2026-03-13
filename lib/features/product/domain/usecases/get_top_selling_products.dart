import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';

class GetTopSellingProducts {
  final ProductRepository productRepository;

  GetTopSellingProducts(this.productRepository);

  Future<List<ProductEntity>> call() async {
    return await productRepository.getTopSellingProducts();
  }
}
