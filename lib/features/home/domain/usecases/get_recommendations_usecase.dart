import 'package:ecommerce_app/features/home/domain/repositories/recommendation_repository.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';

class GetRecommendationsUseCase {
  final RecommendationRepository repository;

  GetRecommendationsUseCase({required this.repository});

  Future<List<ProductEntity>> call({int? limit}) async {
    final products = await repository.getRecommendations();
    if (limit == null) {
      return products;
    }

    return products.take(limit).toList();
  }
}
