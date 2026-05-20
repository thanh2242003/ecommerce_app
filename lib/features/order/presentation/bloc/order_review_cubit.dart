import 'package:flutter_bloc/flutter_bloc.dart';
export 'order_review_state.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/models/user_review_item.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/data/sources/review_api_service.dart';
import 'package:ecommerce_app/features/order/presentation/bloc/order_review_state.dart';

// State types are defined in order_review_state.dart

class OrderReviewCubit extends Cubit<OrderReviewState> {
  static const int _loadLimit = 100;

  final TokenStorage _tokenStorage = TokenStorage();
  late final OrderRepositoryImpl _orderRepository;
  late final ReviewApiService _reviewService;

  OrderReviewCubit() : super(OrderReviewState()) {
    _orderRepository = OrderRepositoryImpl(
      apiService: OrderApiService(tokenStorage: _tokenStorage),
    );
    _reviewService = ReviewApiService(tokenStorage: _tokenStorage);
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        _orderRepository.getOrders(),
        _reviewService.getUserReviews(page: 1, limit: _loadLimit),
      ]);

      final orders = results[0] as List<OrderResponse>;
      final reviews = results[1] as List<UserReviewItem>;

      final pending = _buildPendingItems(orders, reviews);

      emit(
        state.copyWith(
          isLoading: false,
          reviews: reviews,
          pendingItems: pending,
          orders: orders,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  List<PendingReviewItem> _buildPendingItems(
    List<OrderResponse> orders,
    List<UserReviewItem> reviews,
  ) {
    final reviewedProductIds = reviews
        .map((review) => review.productId.trim())
        .where((productId) => productId.isNotEmpty)
        .toSet();

    final pendingItems = <PendingReviewItem>[];

    for (final order in orders) {
      if (order.status.toLowerCase() != 'delivered') continue;

      for (final item in order.items) {
        final productId = item.productId.trim();
        if (productId.isEmpty || reviewedProductIds.contains(productId)) {
          continue;
        }

        final variantParts = <String>[];
        if ((item.color ?? '').trim().isNotEmpty) {
          variantParts.add('Màu: ${item.color!.trim()}');
        }
        if ((item.size ?? '').trim().isNotEmpty) {
          variantParts.add('Size: ${item.size!.trim()}');
        }

        final variantText = variantParts.isEmpty
            ? 'Phân loại: Chưa có'
            : 'Phân loại: ${variantParts.join(' • ')}';

        pendingItems.add(
          PendingReviewItem(
            orderId: order.id,
            productId: productId,
            title: item.name.isNotEmpty ? item.name : 'Sản phẩm đã mua',
            image: item.image.trim().isEmpty ? null : item.image,
            orderDate: order.createdAt,
            quantity: item.quantity,
            variantText: variantText,
            totalText: AppNumberFormat.format(order.totalPrice),
          ),
        );
      }
    }

    pendingItems.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return pendingItems;
  }

  Future<void> submitReview(
    PendingReviewItem item,
    String content,
    double rating,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _reviewService.createReview(
        productId: item.productId,
        orderId: item.orderId,
        content: content,
        rating: rating,
      );

      await loadData();
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      rethrow;
    }
  }
}
