import '../../../product/domain/entities/product.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchProductsLoaded extends SearchState {
  final List<ProductEntity> products;

  SearchProductsLoaded({required this.products});
}

class SearchError extends SearchState {
  final String message;

  SearchError({this.message = 'Đã có lỗi xảy ra'});
}
