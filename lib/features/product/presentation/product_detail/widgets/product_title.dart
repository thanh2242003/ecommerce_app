import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';

class ProductTitle extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductTitle({
    required this.productEntity,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        productEntity.title,
        style: AppTextStyle.h3,
      ),
    );
  }
}