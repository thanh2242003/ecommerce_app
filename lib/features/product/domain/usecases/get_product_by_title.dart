import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsByTitleUseCase {
  final ProductRepository repository;

  GetProductsByTitleUseCase(this.repository);

  Future<List<ProductEntity>> call(
    String title, {
    String? categoryId,
    String? ageRange,
  }) async {
    return await repository.getProductsByTitle(
      title,
      categoryId: categoryId,
      ageRange: ageRange,
    );
  }
}
