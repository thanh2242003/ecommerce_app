import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/features/product/data/sources/product_api_service.dart';
import 'package:ecommerce_app/features/product/presentation/pages/product_detail_screen.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.productEntity});

  final ProductEntity productEntity;

  Future<void> _openProductDetail(BuildContext context) async {
    ProductEntity targetProduct = productEntity;

    try {
      final detailedProduct = await ProductApiService.getProductById(
        productEntity.productId,
      );
      targetProduct = detailedProduct;
    } catch (_) {
      // Keep fallback data to avoid blocking navigation when detail API fails.
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productEntity: targetProduct),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = productEntity.images.isNotEmpty
        ? productEntity.images.first
        : null;

    return GestureDetector(
      //tap vao thi chuyen den product detail tuong ung
      onTap: () => _openProductDetail(context),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Color(0x12342f3f),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productEntity.title,
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          productEntity.discountedPrice == 0
                              ? AppNumberFormat.format(productEntity.price)
                              : AppNumberFormat.format(
                                  productEntity.discountedPrice,
                                ),
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            Colors.black,
                          ),
                        ),

                        const SizedBox(width: 10),
                        Text(
                          productEntity.discountedPrice == 0
                              ? ''
                              : AppNumberFormat.format(productEntity.price),
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            Colors.grey,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
