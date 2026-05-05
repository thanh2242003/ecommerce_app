import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../cart/domain/entities/cart_item.dart';
import '../../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/variant.dart';
import '../../../../order/presentation/pages/orders_screen.dart';
import '../bloc/product_color_selection_cubit.dart';
import '../bloc/product_quantity_cubit.dart';
import '../bloc/product_size_selection_cubit.dart';
import 'variant_stock_helper.dart';

class AddToCart extends StatelessWidget {
  final ProductEntity productEntity;

  const AddToCart({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final isLoading = state is CartLoading;
          final effectivePrice = productEntity.discountedPrice != 0
              ? productEntity.discountedPrice
              : productEntity.price;
          final selectedColor = _getSelectedColor(context);
          final selectedSize = _getSelectedSize(context);
          final selectedVariantStock = selectedColor == null
              ? 0
              : VariantStockHelper.getVariantStock(
                  productEntity,
                  selectedColor,
                  selectedSize,
                );
          final canProceed = !isLoading && selectedVariantStock > 0;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    AppNumberFormat.format(effectivePrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? () => _handleAddToCart(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: Colors.white,
                      disabledForegroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            selectedVariantStock > 0
                                ? 'Thêm vào giỏ hàng'
                                : 'Hết hàng',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: canProceed ? () => _goToOrders(context) : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: Colors.white,
                      disabledForegroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      selectedVariantStock > 0 ? 'Mua ngay' : 'Hết hàng',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    final quantity = context.read<ProductQuantityCubit>().state;
    final selectedColor = _getSelectedColor(context);
    final selectedSize = _getSelectedSize(context);

    if (selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn màu sắc!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final variantId = _resolveVariantId(
      productEntity,
      selectedColor,
      selectedSize,
    );
    final variantStock = VariantStockHelper.getVariantStock(
      productEntity,
      selectedColor,
      selectedSize,
    );
    if (variantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy biến thể sản phẩm phù hợp!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (variantStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biến thể này đã hết hàng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await context.read<CartCubit>().addToCart(
        productId: productEntity.productId,
        quantity: quantity,
        color: selectedColor,
        size: selectedSize,
        variantId: variantId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm vào giỏ hàng thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _goToOrders(BuildContext context) {
    final quantity = context.read<ProductQuantityCubit>().state;
    final selectedColor = _getSelectedColor(context);
    final selectedSize = _getSelectedSize(context);

    if (selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn màu sắc!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final variantId = _resolveVariantId(
      productEntity,
      selectedColor,
      selectedSize,
    );
    final variantStock = VariantStockHelper.getVariantStock(
      productEntity,
      selectedColor,
      selectedSize,
    );
    if (variantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy biến thể sản phẩm phù hợp!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (variantStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biến thể này đã hết hàng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrdersScreen(
          product: CartItemEntity(
            cartItemId: '${productEntity.productId}_buy_now',
            productId: productEntity.productId,
            variantId: variantId,
            quantity: quantity,
            color: selectedColor,
            size: selectedSize,
            price: productEntity.discountedPrice != 0
                ? productEntity.discountedPrice
                : productEntity.price,
            productName: productEntity.title,
            productImage: productEntity.images.isNotEmpty
                ? productEntity.images.first
                : null,
          ),
        ),
      ),
    );
  }

  String? _getSelectedColor(BuildContext context) {
    if (productEntity.colors.isEmpty) {
      return null;
    }

    final colorIndex = context.read<ProductColorSelectionCubit>().state;
    if (colorIndex < 0 || colorIndex >= productEntity.colors.length) {
      return null;
    }

    return productEntity.colors[colorIndex].title;
  }

  String? _getSelectedSize(BuildContext context) {
    if (productEntity.sizes.isEmpty) {
      return null;
    }

    final sizeIndex = context.read<ProductSizeSelectionCubit>().state;
    if (sizeIndex < 0 || sizeIndex >= productEntity.sizes.length) {
      return null;
    }

    return productEntity.sizes[sizeIndex];
  }

  String? _resolveVariantId(ProductEntity product, String color, String? size) {
    return VariantStockHelper.resolveVariant(product, color, size)?.variantId;
  }
}
