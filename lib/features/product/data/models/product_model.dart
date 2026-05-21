import '../../domain/entities/product.dart';

import '../../domain/entities/color.dart';
import '../../domain/entities/variant.dart';
import 'color_model.dart';
import 'review_model.dart';
import 'variant_model.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.categoryId,
    required super.colors,
    //required super.createdAt,
    required super.discountedPrice,
    required super.gender,
    required super.images,
    required super.price,
    required super.sizes,
    required super.variants,
    required super.productId,
    required super.salesNumber,
    required super.title,
    required super.description,
    required super.ratings,
    required super.reviews,
    required super.totalReviews,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final parsedReviews = (json['reviews'] as List? ?? [])
        .map((e) => ReviewModel.fromJson(e).toEntity())
        .toList();

    return ProductModel(
      productId: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      salesNumber: json['salesNumber'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      colors: _parseColors(json),
      gender: json['gender'] ?? 0,
      sizes: List<String>.from(json['sizes'] ?? []),
      variants: _parseVariants(json),
      description: json['description'] ?? '',
      ratings: (json['ratings'] as num?)?.toDouble() ?? 0.0,
      reviews: parsedReviews,
      totalReviews: json['totalReviews'] ?? parsedReviews.length,
    );
  }

  static List<ProductColorEntity> _parseColors(Map<String, dynamic> json) {
    final dynamic rawColors =
        json['colors'] ??
        json['color'] ??
        (json['attributes'] is Map<String, dynamic>
            ? (json['attributes']['colors'] ?? json['attributes']['color'])
            : null) ??
        (json['product_attributes'] is Map<String, dynamic>
            ? (json['product_attributes']['colors'] ??
                  json['product_attributes']['color'])
            : null);

    if (rawColors is List) {
      return rawColors
          .map((e) {
            if (e is Map<String, dynamic>) {
              return ProductColorModel.fromJson(e).toEntity();
            }

            if (e is String && e.trim().isNotEmpty) {
              return ProductColorModel.fromAttribute(e).toEntity();
            }

            return null;
          })
          .whereType<ProductColorEntity>()
          .toList();
    }

    if (rawColors is String && rawColors.trim().isNotEmpty) {
      return [ProductColorModel.fromAttribute(rawColors).toEntity()];
    }

    return <ProductColorEntity>[];
  }

  static List<ProductVariantEntity> _parseVariants(Map<String, dynamic> json) {
    final dynamic rawVariants =
        json['variants'] ??
        (json['product_variants'] is Map<String, dynamic>
            ? json['product_variants']['variants']
            : null);

    if (rawVariants is List) {
      return rawVariants
          .whereType<Map<String, dynamic>>()
          .map((variant) => ProductVariantModel.fromJson(variant).toEntity())
          .toList();
    }

    return <ProductVariantEntity>[];
  }
}
