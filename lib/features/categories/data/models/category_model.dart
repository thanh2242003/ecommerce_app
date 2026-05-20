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
    super.image,
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
      image: json['image'] is String
          ? (json['image'] as String)
          : (json['thumbnail'] is String
              ? (json['thumbnail'] as String)
              : ''),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
