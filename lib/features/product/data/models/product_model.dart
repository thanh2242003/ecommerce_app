import 'package:ecommerce_app/features/product/domain/entities/product.dart';

import '../../domain/entities/color.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.categoryId,
    //required super.colors,
    //required super.createdDate,
    required super.discountedPrice,
    required super.gender,
    required super.images,
    required super.price,
    required super.sizes,
    required super.productId,
    required super.salesNumber,
    required super.title,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      salesNumber: json['salesNumber'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      // colors: (json['colors'] as List? ?? [])
      //     .map((e) => ProductColorEntity.fromJson(e))
      //     .toList(),
      gender: json['gender'] ?? 0,
      sizes: List<String>.from(json['sizes'] ?? []),
    );
  }

}
