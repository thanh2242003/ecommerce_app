import '../../domain/entities/variant.dart';

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.variantId,
    required super.color,
    required super.size,
    required super.stock,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      variantId: (json['_id'] ?? json['variantId'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  ProductVariantEntity toEntity() => ProductVariantEntity(
    variantId: variantId,
    color: color,
    size: size,
    stock: stock,
  );
}
