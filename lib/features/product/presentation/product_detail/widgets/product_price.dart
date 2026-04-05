import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../domain/entities/product.dart';

class ProductPrice extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductPrice({
    required this.productEntity,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        productEntity.discountedPrice != 0 ?
        AppNumberFormat.format(productEntity.discountedPrice) :
        AppNumberFormat.format(productEntity.price),
        style: AppTextStyle.bodyMedium,
      ),
    );
  }
}