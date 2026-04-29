import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';

class GetLatestProducts {
  final ProductRepository productRepository;

  GetLatestProducts(this.productRepository);

  Future<List<ProductEntity>> call({int? limit}) async {
    final products = await productRepository.getProducts(page: 1, limit: 10);
    if (limit == null) {
      return products;
    }

    return products.take(limit).toList();
  }
}
