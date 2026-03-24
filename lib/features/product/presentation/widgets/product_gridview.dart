import 'package:ecommerce_app/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductGridView extends StatelessWidget{
  final List<ProductEntity> products;

  const ProductGridView({super.key, required this.products});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index){
        final product = products[index];
        return ProductCard(productEntity: product);
      },
    );
  }
}