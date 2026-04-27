import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/usecases/get_top_selling_products.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTopSellingProducts getTopSellingProducts;

  HomeCubit({required this.getTopSellingProducts}) : super(HomeInitial());

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
      final products = await getTopSellingProducts();
      emit(HomeLoaded(topSellingProducts: products));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
