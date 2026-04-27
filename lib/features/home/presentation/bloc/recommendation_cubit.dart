import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_recommendations_usecase.dart';
import '../../../product/domain/entities/product.dart';

part 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final GetRecommendationsUseCase getRecommendationsUseCase;

  RecommendationCubit({required this.getRecommendationsUseCase})
    : super(RecommendationInitial());

  Future<void> loadRecommendationsIfNeeded({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (state is RecommendationLoading) {
        return;
      }

      if (state is RecommendationLoaded &&
          (state as RecommendationLoaded).products.isNotEmpty) {
        return;
      }
    }

    try {
      emit(RecommendationLoading());

      final products = await getRecommendationsUseCase();

      emit(RecommendationLoaded(products: products));
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
}
