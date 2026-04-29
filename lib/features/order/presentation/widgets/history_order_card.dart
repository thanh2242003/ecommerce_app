import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({super.key, required this.order});

  final OrderResponse order;

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
    final formattedTime = _formatOrderTime(order.createdAt);
    final isDelivered = order.status.toLowerCase() == 'delivered';
    final totalText = AppNumberFormat.format(order.totalPrice);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                    child: _OrderProductImage(image: previewItem?.image),
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
            if (isDelivered)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Trả hàng'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Đánh giá'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hủy đơn'),
                ),
              ),
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
}

class _OrderProductImage extends StatelessWidget {
  const _OrderProductImage({this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.trim().isEmpty) {
      return _placeholder();
    }

    final value = image!.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final assetPath = value.startsWith('assets/')
        ? value
        : 'assets/images/$value';

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF2F2F2),
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.black38),
    );
  }
}

String _formatOrderTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}
