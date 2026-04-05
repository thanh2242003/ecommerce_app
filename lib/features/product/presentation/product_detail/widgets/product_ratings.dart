import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';

class ProductRatings extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductRatings({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            productEntity.ratings.toStringAsFixed(1),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '(${productEntity.totalReviews} reviews)',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
