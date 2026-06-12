import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/entities/product.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ProductRepository productRepository;

  SearchCubit({required this.productRepository}) : super(SearchInitial());

  Future<void> searchProducts({
    String keyword = '',
    String? categoryId,
    int? minPrice,
    int? maxPrice,
    int? gender,
    String? ageRange,
    String? sort,
  }) async {
    try {
      emit(SearchLoading());

      final normalizedKeyword = keyword.trim();
      final products = normalizedKeyword.isNotEmpty
          ? await productRepository.getProductsByTitle(
              normalizedKeyword,
              categoryId: categoryId,
              ageRange: ageRange,
            )
          : await productRepository.getProducts(
              page: 1,
              limit: 20,
              categoryId: categoryId,
              minPrice: minPrice,
              maxPrice: maxPrice,
              gender: gender,
              ageRange: ageRange,
              sort: sort,
            );

      emit(
        SearchProductsLoaded(
          products: _applyFilters(
            products,
            keyword: normalizedKeyword,
            minPrice: minPrice,
            maxPrice: maxPrice,
            gender: gender,
            ageRange: ageRange,
            sort: sort,
          ),
        ),
      );
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  void resetResults() {
    emit(SearchInitial());
  }

  List<ProductEntity> _applyFilters(
    List<ProductEntity> products, {
    required String keyword,
    int? minPrice,
    int? maxPrice,
    int? gender,
    String? ageRange,
    String? sort,
  }) {
    final filteredProducts = products.where((product) {
      final matchesKeyword =
          keyword.isEmpty ||
          product.title.toLowerCase().contains(keyword.toLowerCase());
      final matchesMinPrice = minPrice == null || product.price >= minPrice;
      final matchesMaxPrice = maxPrice == null || product.price <= maxPrice;
      final matchesGender = gender == null || product.gender == gender;
      final matchesAgeRange =
          ageRange == null ||
          ageRange.isEmpty ||
          product.ageRange == ageRange;

      return matchesKeyword &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesGender &&
          matchesAgeRange;
    }).toList();

    switch (sort) {
      case 'price_asc':
        filteredProducts.sort(
          (left, right) => left.price.compareTo(right.price),
        );
        break;
      case 'price_desc':
        filteredProducts.sort(
          (left, right) => right.price.compareTo(left.price),
        );
        break;
    }

    return filteredProducts;
  }
}
