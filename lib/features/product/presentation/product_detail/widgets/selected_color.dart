import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/product/presentation/product_detail/widgets/product_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_bottomsheet.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product_color_selection_cubit.dart';

class SelectedColor extends StatelessWidget {
  final ProductEntity productEntity;
  const SelectedColor({
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
                value:BlocProvider.of<ProductColorSelectionCubit>(context),
                child: ProductColors(productEntity: productEntity,)
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
              'Màu sắc',
              style: AppTextStyle.bodyMedium,
            ),
            Row(
              children: [
                BlocBuilder<ProductColorSelectionCubit,int>(
                  builder: (context, state) =>  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                          productEntity.colors[state].rgb[0],
                          productEntity.colors[state].rgb[1],
                          productEntity.colors[state].rgb[2],
                          1
                      ),
                      shape: BoxShape.circle,
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