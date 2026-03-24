import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../categories/domain/repositories/categories_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ProductRepository productRepository;
  final CategoriesRepository categoryRepository;

  SearchCubit({
    required this.productRepository,
    required this.categoryRepository,
  }) : super(SearchInitial());

  // 🏠 Load categories (khi mở màn hình)
  Future<void> loadCategories() async {
    try {
      emit(SearchLoading());

      final categories = await categoryRepository.getCategories();

      emit(SearchCategoriesLoaded(categories: categories));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  // 🔍 Search products
  Future<void> searchProducts(String keyword) async {
    try {
      emit(SearchLoading());

      final products =
      await productRepository.getProductsByTitle(keyword);

      emit(SearchProductsLoaded(products: products));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  // 🔄 Clear search → quay lại categories
  void clearSearch() {
    loadCategories();
  }
}
