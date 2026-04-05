import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/product/presentation/product_detail/widgets/product_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_bottomsheet.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product_size_selection_cubit.dart';

class SelectedSize extends StatelessWidget {
  final ProductEntity productEntity;
  const SelectedSize({
    required this.productEntity,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        AppBottomsheet.display(
            context,
            BlocProvider.value(
                value:BlocProvider.of<ProductSizeSelectionCubit>(context),
                child: ProductSizes(productEntity: productEntity,)
            )
        );
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Size',
              style: AppTextStyle.bodyMedium,
            ),
            Row(
              children: [
                BlocBuilder<ProductSizeSelectionCubit,int>(
                  builder: (context, state) =>  Text(
                    productEntity.sizes[state],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                const SizedBox(width: 15,),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}