import 'package:ecommerce_app/features/home/data/sources/recommendation_api_service.dart';
import 'package:ecommerce_app/features/home/domain/repositories/recommendation_repository.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationApiService apiService;

  RecommendationRepositoryImpl({required this.apiService});

  @override
  Future<List<ProductEntity>> getRecommendations() async {
    try {
      return await apiService.getRecommendations();
    } catch (e) {
      return [];
    }
  }
}
