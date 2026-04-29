import 'package:ecommerce_app/features/categories/domain/entities/category.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.categoryId,
    required super.name,
    required super.slug,
    required super.description,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['_id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
