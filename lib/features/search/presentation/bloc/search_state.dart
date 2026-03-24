import '../../../categories/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchCategoriesLoaded extends SearchState {
  final List<CategoryEntity> categories;

  SearchCategoriesLoaded({required this.categories});
}

class SearchProductsLoaded extends SearchState {
  final List<ProductEntity> products;

  SearchProductsLoaded({required this.products});
}

class SearchError extends SearchState {
  final String message;

  SearchError({this.message = "Something went wrong"});
}
