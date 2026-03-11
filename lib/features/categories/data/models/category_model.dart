import 'package:ecommerce_app/features/categories/domain/entities/category.dart';

class CategoryModel extends CategoryEntity{
  CategoryModel({
    required super.title,
    required super.categoryId,
    required super.image
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['_id'],
      title: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}