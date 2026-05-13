import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/models/user_review_item.dart';

class PendingReviewItem extends Equatable {
  final String orderId;
  final String productId;
  final String title;
  final String? image;
  final DateTime orderDate;
  final int quantity;
  final String variantText;
  final String totalText;

  const PendingReviewItem({
    required this.orderId,
    required this.productId,
    required this.title,
    required this.orderDate,
    required this.quantity,
    required this.variantText,
    required this.totalText,
    this.image,
  });

  @override
  List<Object?> get props => [
    orderId,
    productId,
    title,
    image,
    orderDate,
    quantity,
    variantText,
    totalText,
  ];
}

class OrderReviewState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final List<UserReviewItem> reviews;
  final List<PendingReviewItem> pendingItems;
  final List<OrderResponse> orders;

  const OrderReviewState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.errorMessage,
    this.reviews = const [],
    this.pendingItems = const [],
    this.orders = const [],
  });

  OrderReviewState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    List<UserReviewItem>? reviews,
    List<PendingReviewItem>? pendingItems,
    List<OrderResponse>? orders,
  }) {
    return OrderReviewState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      reviews: reviews ?? this.reviews,
      pendingItems: pendingItems ?? this.pendingItems,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    errorMessage,
    reviews,
    pendingItems,
    orders,
  ];
}
