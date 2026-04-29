import '../../../product/domain/entities/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ProductEntity> topSellingProducts;
  final List<ProductEntity> latestProducts;

  HomeLoaded({required this.topSellingProducts, required this.latestProducts});
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
