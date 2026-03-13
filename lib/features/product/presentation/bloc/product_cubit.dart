import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_top_selling_products.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {

  final GetTopSellingProducts getTopSellingProducts;

  ProductCubit(this.getTopSellingProducts) : super(ProductInitial()){
    loadProducts();
  }

  void loadProducts() async {

    try {

      emit(ProductLoading());

      final products = await getTopSellingProducts();

      emit(ProductLoaded(products));

    } catch (e) {

      emit(ProductError(e.toString()));

    }

  }

}
