import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/get_latest_products.dart';
import '../../../product/domain/usecases/get_top_selling_products.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTopSellingProducts getTopSellingProducts;
  final GetLatestProducts getLatestProducts;

  HomeCubit({
    required this.getTopSellingProducts,
    required this.getLatestProducts,
  }) : super(HomeInitial());

  Future<void> loadHomeIfNeeded({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (state is HomeLoading) {
        return;
      }

      if (state is HomeLoaded &&
          (state as HomeLoaded).topSellingProducts.isNotEmpty) {
        return;
      }
    }

    emit(HomeLoading());
    try {
      final results = await Future.wait<List<ProductEntity>>([
        getTopSellingProducts(limit: 4),
        getLatestProducts(limit: 4),
      ]);

      emit(
        HomeLoaded(topSellingProducts: results[0], latestProducts: results[1]),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
