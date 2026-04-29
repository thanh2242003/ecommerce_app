import 'package:flutter/material.dart';

import '../../../../../core/widgets/basic_app_bar.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/review.dart';

class ProductReviews extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductReviews({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = productEntity.reviews.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (reviews.isEmpty)
            const Text('Chưa có đánh giá nào.')
          else
            ...reviews.map((review) => _buildReviewItem(review)),
          if (productEntity.reviews.length > 5)
            TextButton(
              onPressed: () {
                // Navigate to full reviews screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReviewsScreen(productEntity: productEntity),
                  ),
                );
              },
              child: const Text('Xem tất cả đánh giá'),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewEntity review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(review.content),
        ],
      ),
    );
  }
}

class ReviewsScreen extends StatelessWidget {
  final ProductEntity productEntity;
  const ReviewsScreen({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(titleText: 'Tất cả đánh giá'),
      body: ListView.builder(
        itemCount: productEntity.reviews.length,
        itemBuilder: (context, index) {
          final review = productEntity.reviews[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(review.content),
              ],
            ),
          );
        },
      ),
    );
  }
}
