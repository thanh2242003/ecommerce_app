import 'package:ecommerce_app/features/categories/domain/entities/category.dart';

abstract class CategoriesRepository{
  Future<List<CategoryEntity>> getCategories();
}