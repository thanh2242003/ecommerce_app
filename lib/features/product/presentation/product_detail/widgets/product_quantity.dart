import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product_color_selection_cubit.dart';
import '../bloc/product_quantity_cubit.dart';
import '../bloc/product_size_selection_cubit.dart';
import 'variant_stock_helper.dart';

class ProductQuantity extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductQuantity({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: AppColors.secondColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Số lượng', style: AppTextStyle.bodyMedium),
          BlocBuilder<ProductQuantityCubit, int>(
            builder: (context, state) {
              final selectedColorIndex = context
                  .read<ProductColorSelectionCubit>()
                  .state;
              final selectedSizeIndex = context
                  .read<ProductSizeSelectionCubit>()
                  .state;
              final selectedColor =
                  selectedColorIndex >= 0 &&
                      selectedColorIndex < productEntity.colors.length
                  ? productEntity.colors[selectedColorIndex].title
                  : null;
              final selectedSize =
                  selectedSizeIndex >= 0 &&
                      selectedSizeIndex < productEntity.sizes.length
                  ? productEntity.sizes[selectedSizeIndex]
                  : null;
              final variantStock = selectedColor == null
                  ? 0
                  : VariantStockHelper.getVariantStock(
                      productEntity,
                      selectedColor,
                      selectedSize,
                    );
              final canIncrease = variantStock > 0 && state < variantStock;

              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<ProductQuantityCubit>().decrement();
                    },
                    icon: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: const Center(child: Icon(Icons.remove, size: 30)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    state.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: canIncrease
                        ? () {
                            context.read<ProductQuantityCubit>().increment();
                          }
                        : null,
                    icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: canIncrease
                            ? AppColors.primaryColor
                            : AppColors.primaryColor.withValues(alpha: 0.35),
                      ),
                      child: const Center(child: Icon(Icons.add, size: 30)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
