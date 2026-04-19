import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/sources/cart_api_service.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../bloc/cart_cubit.dart';
import '../widgets/product_order_card.dart';
import '../../../order/presentation/pages/orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // TODO: Replace with DI (get_it) when ready
        final tokenStorage = TokenStorage();
        final apiService = CartApiService(tokenStorage: tokenStorage);
        final repository = CartRepositoryImpl(apiService: apiService);
        final usecase = GetCartUseCase(repository: repository);
        return CartCubit(getCartUseCase: usecase)..fetchCart();
      },
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        scrolledUnderElevation: 0,
        title: Text(
          'My Cart',
          style: AppTextStyle.withColor(AppTextStyle.h2, Colors.black87),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFff5722)),
            );
          }

          if (state.status == CartStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.primaryColor,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load cart',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyLarge,
                        AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? '',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CartCubit>().fetchCart(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff5722),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.items.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              // ── Select All ──────────────────────────────────────────
              _SelectAllBar(
                totalItems: state.items.length,
                selectedCount: state.selectedIds.length,
              ),

              // ── Cart Items List ─────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return ProductOrderCard(
                      item: item,
                      isSelected: state.selectedIds.contains(item.cartItemId),
                    );
                  },
                ),
              ),

              // ── Bottom Bar ─────────────────────────────────────────
              _BottomCheckoutBar(
                totalPrice: state.totalPrice,
                selectedCount: state.selectedIds.length,
                selectedItems: state.items
                    .where(
                      (item) => state.selectedIds.contains(item.cartItemId),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Select All Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SelectAllBar extends StatelessWidget {
  const _SelectAllBar({required this.totalItems, required this.selectedCount});
  final int totalItems;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final allSelected = selectedCount == totalItems;
    final cubit = context.read<CartCubit>();

    return Container(
      color: AppColors.lightBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: allSelected,
              tristate: true,
              onChanged: (_) {
                if (allSelected) {
                  // Deselect all
                  for (final item in cubit.state.items) {
                    if (cubit.state.selectedIds.contains(item.cartItemId)) {
                      cubit.toggleSelectItem(item.cartItemId);
                    }
                  }
                } else {
                  // Select all
                  for (final item in cubit.state.items) {
                    if (!cubit.state.selectedIds.contains(item.cartItemId)) {
                      cubit.toggleSelectItem(item.cartItemId);
                    }
                  }
                }
              },
              activeColor: const Color(0xFFff5722),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: Colors.black26, width: 1.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Select All  ($selectedCount/$totalItems)',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Checkout Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomCheckoutBar extends StatelessWidget {
  const _BottomCheckoutBar({
    required this.totalPrice,
    required this.selectedCount,
    required this.selectedItems,
  });
  final int totalPrice;
  final int selectedCount;
  final List<CartItemEntity> selectedItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.lightCard),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        children: [
          // ── Total Price ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppNumberFormat.format(totalPrice),
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    Color(0xFFff5722),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ── Checkout Button ───────────────────────────────────────
          Expanded(
            flex: 2,
            child: AnimatedOpacity(
              opacity: selectedCount > 0 ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: selectedCount > 0
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                OrdersScreen(selectedItems: selectedItems),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  selectedCount > 0
                      ? 'Checkout ($selectedCount)'
                      : 'Select Items',
                  style: AppTextStyle.buttonMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Cart
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black45),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: AppTextStyle.withColor(
              AppTextStyle.bodySmall,
              Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
