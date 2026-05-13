import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/utils/date_time_utils.dart';
import 'package:ecommerce_app/core/widgets/order_product_image.dart';

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({
    super.key,
    required this.order,
    this.onReviewPressed,
    this.onReturnPressed,
    this.onCancelPressed,
    this.reviewButtonLabel = 'Đánh giá',
    this.returnButtonLabel = 'Trả hàng',
    this.cancelButtonLabel = 'Hủy đơn',
    this.cardPadding = const EdgeInsets.all(14),
    this.borderRadius = 16.0,
    this.isTwoButton = true,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.cancelButtonColor,
  });

  final OrderResponse order;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onReturnPressed;
  final VoidCallback? onCancelPressed;

  /// Custom label for review button (defaults to 'Đánh giá')
  final String reviewButtonLabel;

  /// Custom label for return button (defaults to 'Trả hàng')
  final String returnButtonLabel;

  /// Custom label for cancel button (defaults to 'Hủy đơn')
  final String cancelButtonLabel;

  /// Custom padding for the card content (defaults to EdgeInsets.all(14))
  final EdgeInsets cardPadding;

  /// Border radius for the card (defaults to 16.0)
  final double borderRadius;

  /// Display two buttons (return + review) or one button (only review). Defaults to true
  final bool isTwoButton;

  /// Custom color for primary button (review). Defaults to AppColors.primaryColor
  final Color? primaryButtonColor;

  /// Custom color for secondary button (return). Defaults to Colors.white (outlined)
  final Color? secondaryButtonColor;

  /// Custom color for cancel button. Defaults to Colors.red
  final Color? cancelButtonColor;

  @override
  Widget build(BuildContext context) {
    final previewItem = order.items.isNotEmpty ? order.items.first : null;
    final quantity =
        previewItem?.quantity ?? (order.itemCount > 0 ? order.itemCount : 1);
    final variantParts = <String>[
      if ((previewItem?.color ?? '').trim().isNotEmpty)
        'Màu: ${previewItem!.color}',
      if ((previewItem?.size ?? '').trim().isNotEmpty)
        'Size: ${previewItem!.size}',
    ];
    final variantText = variantParts.isEmpty
        ? 'Phân loại: Chưa có'
        : 'Phân loại: ${variantParts.join(' • ')}';
    final formattedTime = formatDateTimeShort(order.createdAt);
    final totalText = AppNumberFormat.format(order.totalPrice);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: OrderProductImage(
                      image: previewItem?.image,
                      width: 76,
                      height: 76,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        previewItem?.name.isNotEmpty == true
                            ? previewItem!.name
                            : 'Sản phẩm đã đặt',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Số lượng: x$quantity',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        variantText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian đặt: $formattedTime',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng tiền',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Colors.black87,
                    ),
                  ),
                  Text(
                    totalText,
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildActionButtons(),
            const SizedBox(height: 10),
            Text(
              'Mã đơn: #${order.id}',
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!isTwoButton) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onReviewPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryButtonColor ?? AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(reviewButtonLabel),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReturnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: secondaryButtonColor ?? Colors.black87,
              side: BorderSide(color: secondaryButtonColor ?? Colors.black12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(returnButtonLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onReviewPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryButtonColor ?? AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(reviewButtonLabel),
          ),
        ),
      ],
    );
  }
}
