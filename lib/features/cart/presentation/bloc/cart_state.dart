part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final Set<String> selectedIds;
  final int totalPrice;

  const CartLoaded({
    required this.items,
    this.selectedIds = const {},
    this.totalPrice = 0,
  });

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    Set<String>? selectedIds,
    int? totalPrice,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [items, selectedIds, totalPrice];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
