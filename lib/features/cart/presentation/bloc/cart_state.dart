part of 'cart_cubit.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState {
  final CartStatus status;
  final List<CartItemEntity> items;
  final Set<String> selectedIds;
  final int totalPrice;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.selectedIds = const {},
    this.totalPrice = 0,
    this.errorMessage,
  });

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    Set<String>? selectedIds,
    int? totalPrice,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      totalPrice: totalPrice ?? this.totalPrice,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
