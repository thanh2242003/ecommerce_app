import '../../../product/domain/entities/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ProductEntity> topSellingProducts;

  HomeLoaded({required this.topSellingProducts});
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
