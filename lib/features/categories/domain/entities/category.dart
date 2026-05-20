class CategoryEntity {
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String image;

  const CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.image = '',
  });

  String get title => name;
}
