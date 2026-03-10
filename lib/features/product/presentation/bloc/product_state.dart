import '../../../home/domain/entities/product.dart';

abstract class ProductState{}

class ProductInitial extends ProductState{}

class ProductLoading extends ProductState{}

class ProductLoaded extends ProductState{
  final List<ProductEntity> products;

  ProductLoaded(this.products);
}

class ProductError extends ProductState{
  final String error;

  ProductError(this.error);
}