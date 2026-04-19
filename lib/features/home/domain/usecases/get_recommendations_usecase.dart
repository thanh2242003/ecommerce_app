import 'package:ecommerce_app/features/home/domain/repositories/recommendation_repository.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';

class GetRecommendationsUseCase {
  final RecommendationRepository repository;

  GetRecommendationsUseCase({required this.repository});

  Future<List<ProductEntity>> call() {
    return repository.getRecommendations();
  }
}
