part of 'recommendation_cubit.dart';

abstract class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<ProductEntity> products;

  RecommendationLoaded({required this.products});
}

class RecommendationError extends RecommendationState {
  final String message;

  RecommendationError({required this.message});
}
