import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product_color_selection_cubit.dart';
import '../bloc/product_quantity_cubit.dart';
import '../../../../cart/data/repositories/cart_repository_impl.dart';
import '../../../../cart/data/sources/cart_api_service.dart';
import '../../../../cart/presentation/bloc/add_to_cart_cubit.dart';

class AddToCart extends StatelessWidget {
  final ProductEntity productEntity;

  const AddToCart({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddToCartCubit(
        cartRepository: CartRepositoryImpl(
          apiService: CartApiService(tokenStorage: TokenStorage()),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocListener<AddToCartCubit, AddToCartState>(
          listener: (context, state) {
            if (state is AddToCartSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thêm vào giỏ hàng thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is AddToCartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: BlocBuilder<AddToCartCubit, AddToCartState>(
            builder: (context, state) {
              final isLoading = state is AddToCartLoading;

              return ElevatedButton(
                onPressed: isLoading ? null : () => _handleAddToCart(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.primaryColor.withOpacity(
                    0.5,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productEntity.discountedPrice != 0
                                ? AppNumberFormat.format(
                                    productEntity.discountedPrice,
                                  )
                                : AppNumberFormat.format(productEntity.price),
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Thêm vào giỏ hàng',
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context) {
    final quantity = context.read<ProductQuantityCubit>().state;
    final colorIndex = context.read<ProductColorSelectionCubit>().state;

    // Lấy thông tin color
    if (colorIndex >= productEntity.colors.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn màu sắc!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedColor = productEntity.colors[colorIndex].title;

    // Gọi add to cart (token sẽ được xử lý trong ApiService)
    context.read<AddToCartCubit>().addToCart(
      productId: productEntity.productId,
      quantity: quantity,
      color: selectedColor,
    );
  }
}
