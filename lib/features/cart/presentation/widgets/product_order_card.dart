import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_cubit.dart';

class ProductOrderCard extends StatelessWidget {
  const ProductOrderCard({
    super.key,
    required this.item,
    required this.isSelected,
  });

  final CartItemEntity item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final titleColor = Colors.black87;
    final subtitleColor = Colors.black54;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.6)
              : Colors.black12,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Checkbox ─────────────────────────────────────────────
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => cubit.toggleSelectItem(item.cartItemId),
                activeColor: AppColors.primaryColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Colors.black26, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),

            // ── Thumbnail ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child:
                    item.productImage != null && item.productImage!.isNotEmpty
                    ? Image.asset(
                        'assets/images/${item.productImage!}',
                        fit: BoxFit.cover,
                      )
                    : _placeholder(),
              ),
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName.isNotEmpty ? item.productName : 'Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Color and size badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.size != null && item.size!.isNotEmpty
                          ? '${item.color} • ${item.size}'
                          : item.color,
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        subtitleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    AppNumberFormat.format(item.price * item.quantity),
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Quantity Controller ───────────────────────────────────
            Column(
              children: [
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => cubit.increaseQuantity(item.cartItemId),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${item.quantity}',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      titleColor,
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.remove,
                  onTap: item.quantity > 1
                      ? () => cubit.decreaseQuantity(item.cartItemId)
                      : null,
                ),
              ],
            ),

            // ── Delete Button ────────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              color: Colors.redAccent,
              onPressed: () => _showDeleteConfirm(context, item, cubit),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.black12,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.black38,
        size: 32,
      ),
    );
  }

  Future<void> _showDeleteConfirm(
    BuildContext context,
    CartItemEntity item,
    CartCubit cubit,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa san pham'),
        content: Text('Ban co muon xoa "${item.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cubit.deleteSelectedItems([item.cartItemId]);
    }
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryColor : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.black38,
        ),
      ),
    );
  }
}
