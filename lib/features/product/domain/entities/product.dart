import 'color.dart';
import 'review.dart';
import 'variant.dart';

class ProductEntity {
  final String categoryId;
  final List<ProductColorEntity> colors;
  //final DateTime createdAt;
  final int discountedPrice;
  final int gender;
  final List<String> images;
  final int price;
  final List<String> sizes;
  final List<ProductVariantEntity> variants;
  final String productId;
  final int salesNumber;
  final String title;
  final String description;
  final double ratings;
  final List<ReviewEntity> reviews;
  final int totalReviews;

  ProductEntity({
    required this.categoryId,
    required this.colors,
    //required this.createdAt,
    required this.discountedPrice,
    required this.gender,
    required this.images,
    required this.price,
    required this.sizes,
    required this.variants,
    required this.productId,
    required this.salesNumber,
    required this.title,
    required this.description,
    required this.ratings,
    required this.reviews,
    required this.totalReviews,
  });
}
