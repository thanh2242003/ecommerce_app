import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product_quantity_cubit.dart';

class ProductQuantity extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductQuantity({
    required this.productEntity,
    super.key
  });

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
          Text(
            'Số lượng',
            style: AppTextStyle.bodyMedium,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: (){
                    context.read<ProductQuantityCubit>().decrement();
                  },
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove,
                        size: 30,
                      ),
                    ),
                  )
              ),
              const SizedBox(width: 10,),
              BlocBuilder<ProductQuantityCubit,int>(
                builder: (context, state) => Text(
                  state.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              IconButton(
                  onPressed: (){
                    context.read<ProductQuantityCubit>().increment();
                  },
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  )
              ),

            ],
          )
        ],
      ),
    );
  }
}