import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

class HomeTabProductsScreen extends StatelessWidget {
  const HomeTabProductsScreen({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        titleText: title,
        titleStyle: AppTextStyle.h2.copyWith(color: Colors.black87),
      ),
      body: products.isEmpty
          ? const Center(child: Text('Không có sản phẩm'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                return ProductCard(productEntity: products[index]);
              },
            ),
    );
  }
}
