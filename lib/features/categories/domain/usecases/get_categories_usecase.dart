import 'package:ecommerce_app/features/categories/domain/repositories/categories_repository.dart';

import '../entities/category.dart';

class GetCategoriesUseCase{
  final CategoriesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() async{
    return await repository.getCategories();
  }
}