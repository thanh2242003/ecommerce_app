import 'package:ecommerce_app/features/categories/data/models/category_model.dart';

// chua ket noi backend
abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      CategoryModel(categoryId: "1", title: "Quần áo", image: "shoe.jpg"),
      CategoryModel(categoryId: "2", title: "Đồ chơi", image: "shoe2.jpg"),
      CategoryModel(categoryId: "3", title: "Giày dép", image: "shoes2.jpg"),
      CategoryModel(categoryId: "4", title: "Đồ ăn", image: "shoes2.jpg"),
      CategoryModel(categoryId: "5", title: "Khác", image: "shoes2.jpg"),
    ];
  }
}
