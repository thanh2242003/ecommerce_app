import 'package:ecommerce_app/features/categories/domain/entities/category.dart';
import 'package:flutter/foundation.dart';

abstract class CategoriesState{}

class CategoriesInitial extends CategoriesState{}

class CategoriesLoading extends CategoriesState{}

class CategoriesLoaded extends CategoriesState{
  final List<CategoryEntity> categories;

  CategoriesLoaded(this.categories);
}

class CategoriesError extends CategoriesState{
  final String error;

  CategoriesError(this.error);
}