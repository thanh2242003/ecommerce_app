import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.productEntity});

  final ProductEntity productEntity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //tap vao thi chuyen den product detail tuong ung
      onTap: () {},
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
                  image: DecorationImage(
                    //sua thanh anh trong backend
                    //image: NetworkImage(product.images[0]),
                    image: AssetImage(
                      'assets/images/${productEntity.images[0]}',
                    ),
                    fit: BoxFit.cover,
                  ),
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
                              ? '${productEntity.price}\$'
                              : "${productEntity.discountedPrice}\$",
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Text(productEntity.discountedPrice == 0
                            ? ''
                            : "${productEntity.price}\$",
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            Colors.grey,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        )
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
