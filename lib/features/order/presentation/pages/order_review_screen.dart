import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/date_time_utils.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/core/widgets/order_product_image.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/models/user_review_item.dart';
import 'package:ecommerce_app/features/order/presentation/bloc/order_review_cubit.dart';
import 'package:ecommerce_app/features/order/presentation/widgets/history_order_card.dart';
import 'package:flutter/material.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderReviewCubit()..loadData(),
      child: Builder(
        builder: (context) {
          return _OrderReviewView();
        },
      ),
    );
  }
}

class _OrderReviewView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderReviewCubit, OrderReviewState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: BasicAppbar(titleText: 'Đánh giá'),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: BasicAppbar(titleText: 'Đánh giá'),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppColors.primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: 'Chưa đánh giá'),
                    Tab(text: 'Đã đánh giá'),
                  ],
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _ErrorCard(
                      message: state.errorMessage!,
                      onRetry: () =>
                          context.read<OrderReviewCubit>().loadData(),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPendingTab(
                        context,
                        state.orders,
                        state.reviews,
                        state,
                      ),
                      _buildReviewedTab(context, state.reviews, state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// logic moved to OrderReviewCubit

// submission handled by OrderReviewCubit

Widget _buildPendingTab(
  BuildContext context,
  List<OrderResponse> orders,
  List<UserReviewItem> reviews,
  OrderReviewState state,
) {
  final reviewedProductIds = reviews
      .map((review) => review.productId.trim())
      .where((productId) => productId.isNotEmpty)
      .toSet();

  final pendingOrders = <OrderResponse>[];
  for (final order in orders) {
    if (order.status.toLowerCase() != 'delivered') continue;
    for (final item in order.items) {
      final productId = item.productId.trim();
      if (productId.isEmpty || reviewedProductIds.contains(productId)) {
        continue;
      }
      pendingOrders.add(order);
      break;
    }
  }

  if (pendingOrders.isEmpty) {
    return RefreshIndicator(
      onRefresh: () => context.read<OrderReviewCubit>().loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: const [
          SizedBox(height: 140),
          _EmptyReviewState(
            title: 'Không có sản phẩm nào cần đánh giá',
            subtitle:
                'Các sản phẩm đã review sẽ tự động chuyển sang tab bên phải.',
            icon: Icons.task_alt,
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => context.read<OrderReviewCubit>().loadData(),
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: pendingOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = pendingOrders[index];
        return HistoryOrderCard(
          order: order,
          onReviewPressed: state.isSubmitting
              ? null
              : () => _openReviewComposer(context, order, state.reviews),
        );
      },
    ),
  );
}

Widget _buildReviewedTab(
  BuildContext context,
  List<UserReviewItem> reviews,
  OrderReviewState state,
) {
  if (reviews.isEmpty) {
    return RefreshIndicator(
      onRefresh: () => context.read<OrderReviewCubit>().loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: const [
          SizedBox(height: 140),
          _EmptyReviewState(
            title: 'Chưa có đánh giá nào',
            subtitle: 'Sau khi gửi review, nội dung sẽ hiển thị tại đây.',
            icon: Icons.star_outline,
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => context.read<OrderReviewCubit>().loadData(),
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _ReviewedReviewCard(review: review);
      },
    ),
  );
}

Future<void> _openReviewComposer(
  BuildContext context,
  OrderResponse order,
  List<UserReviewItem> reviews,
) async {
  final orderReviewCubit = context.read<OrderReviewCubit>();

  // Find the first unreviewed product in this order
  final reviewedProductIds = reviews
      .map((review) => review.productId.trim())
      .where((productId) => productId.isNotEmpty)
      .toSet();

  OrderItemPreview? unreviewed;
  for (final item in order.items) {
    final productId = item.productId.trim();
    if (productId.isEmpty || reviewedProductIds.contains(productId)) {
      continue;
    }
    unreviewed = item;
    break;
  }

  if (unreviewed == null) return;

  final item = PendingReviewItem(
    orderId: order.id,
    productId: unreviewed.productId.trim(),
    title: unreviewed.name.isNotEmpty ? unreviewed.name : 'Sản phẩm đã mua',
    image: (unreviewed.image.trim().isEmpty) ? null : unreviewed.image,
    orderDate: order.createdAt,
    quantity: unreviewed.quantity,
    variantText: _buildVariantText(unreviewed),
    totalText: AppNumberFormat.format(
      order.finalPrice > 0 ? order.finalPrice : order.totalPrice,
    ),
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BlocProvider.value(
        value: orderReviewCubit,
        child: _ReviewComposerSheet(
          item: item,
          onSubmit: (content, rating) async {
            await orderReviewCubit.submitReview(item, content, rating);
          },
        ),
      );
    },
  );
}

String _buildVariantText(OrderItemPreview item) {
  final variantParts = <String>[];
  if ((item.color ?? '').trim().isNotEmpty) {
    variantParts.add('Màu: ${item.color!.trim()}');
  }
  if ((item.size ?? '').trim().isNotEmpty) {
    variantParts.add('Size: ${item.size!.trim()}');
  }
  return variantParts.isEmpty
      ? 'Phân loại: Chưa có'
      : 'Phân loại: ${variantParts.join(' • ')}';
}

// Custom card widgets removed; using HistoryOrderCard from widgets

class _ReviewedReviewCard extends StatelessWidget {
  const _ReviewedReviewCard({required this.review});

  final UserReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: OrderProductImage(
                image: review.image,
                width: 72,
                height: 72,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (index) {
                    final filled = index < review.rating.round();
                    return Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 18,
                      color: Colors.amber.shade700,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    Colors.black87,
                  ),
                ),
                if (review.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    formatDateTimeShort(review.createdAt!),
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewComposerSheet extends StatefulWidget {
  const _ReviewComposerSheet({required this.item, required this.onSubmit});

  final PendingReviewItem item;
  final Future<void> Function(String content, double rating) onSubmit;

  @override
  State<_ReviewComposerSheet> createState() => _ReviewComposerSheetState();
}

class _ReviewComposerSheetState extends State<_ReviewComposerSheet> {
  final TextEditingController _contentController = TextEditingController();
  double _rating = 5;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      setState(() {
        _error = 'Vui lòng nhập nội dung đánh giá.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await widget.onSubmit(content, _rating);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Đánh giá sản phẩm',
            style: AppTextStyle.withColor(AppTextStyle.h2, Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            widget.item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final selected = starValue <= _rating;

              return IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _rating = starValue.toDouble();
                        });
                      },
                iconSize: 34,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                icon: Icon(
                  selected ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade700,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${_rating.toInt()}/5',
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            enabled: !_isSubmitting,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Chia sẻ cảm nhận của bạn về sản phẩm...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Gửi đánh giá'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.withColor(
              AppTextStyle.buttonMedium,
              Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.withColor(
              AppTextStyle.bodySmall,
              Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

// OrderProductImage widget moved to lib/core/widgets/order_product_image.dart
