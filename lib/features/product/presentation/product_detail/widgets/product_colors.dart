import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product_color_selection_cubit.dart';
import '../bloc/product_size_selection_cubit.dart';
import 'variant_stock_helper.dart';

class ProductColors extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductColors({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Màu sắc',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return BlocBuilder<ProductColorSelectionCubit, int>(
                  builder: (context, state) {
                    final selectedSizeIndex = context
                        .read<ProductSizeSelectionCubit>()
                        .state;
                    final selectedSize =
                        selectedSizeIndex >= 0 &&
                            selectedSizeIndex < productEntity.sizes.length
                        ? productEntity.sizes[selectedSizeIndex]
                        : null;
                    final color = productEntity.colors[index].title;
                    final stock = VariantStockHelper.getColorStock(
                      productEntity,
                      color,
                      selectedSize,
                    );
                    final isDisabled = stock <= 0;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () {
                              context
                                  .read<ProductColorSelectionCubit>()
                                  .itemSelection(index);
                              Navigator.pop(context);
                            },
                      child: Opacity(
                        opacity: isDisabled ? 0.45 : 1,
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: state == index
                                ? AppColors.primaryColor
                                : AppColors.secondColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    color,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    stock > 0 ? 'Còn $stock' : 'Hết hàng',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDisabled
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(
                                        productEntity.colors[index].rgb[0],
                                        productEntity.colors[index].rgb[1],
                                        productEntity.colors[index].rgb[2],
                                        1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  state == index
                                      ? const Icon(Icons.check, size: 30)
                                      : Container(width: 30),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: productEntity.colors.length,
            ),
          ),
        ],
      ),
    );
  }
}
