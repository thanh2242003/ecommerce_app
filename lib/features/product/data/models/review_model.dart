import 'package:ecommerce_app/features/product/domain/entities/review.dart';

class ReviewModel {
  final String userId;
  final String userName;
  final String content;
  final double rating;

  ReviewModel({
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      userId: userId,
      userName: userName,
      content: content,
      rating: rating,
    );
  }
}
