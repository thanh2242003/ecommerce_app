import 'package:ecommerce_app/features/product/domain/entities/product.dart';

abstract class RecommendationRepository {
  Future<List<ProductEntity>> getRecommendations();
}
