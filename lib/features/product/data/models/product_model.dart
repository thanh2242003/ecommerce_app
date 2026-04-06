import '../../domain/entities/product.dart';

import '../../domain/entities/color.dart';
import '../../domain/entities/review.dart';
import 'color_model.dart';
import 'review_model.dart';

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
    required super.productId,
    required super.salesNumber,
    required super.title,
    required super.description,
    required super.ratings,
    required super.reviews,
    required super.totalReviews,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      salesNumber: json['salesNumber'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      colors: (json['colors'] as List? ?? [])
          .map((e) => ProductColorModel.fromJson(e).toEntity())
          .toList(),
      gender: json['gender'] ?? 0,
      sizes: List<String>.from(json['sizes'] ?? []),
      description: json['description'] ?? '',
      ratings: (json['ratings'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List? ?? [])
          .map((e) => ReviewModel.fromJson(e).toEntity())
          .toList(),
      totalReviews: json['totalReviews'] ?? 0,
      //createdAt: DateTime.parse(json['creatAt']),
    );
  }
}
