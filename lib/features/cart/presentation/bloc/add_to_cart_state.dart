part of 'add_to_cart_cubit.dart';

abstract class AddToCartState extends Equatable {
  const AddToCartState();

  @override
  List<Object> get props => [];
}

class AddToCartInitial extends AddToCartState {
  const AddToCartInitial();
}

class AddToCartLoading extends AddToCartState {
  const AddToCartLoading();
}

class AddToCartSuccess extends AddToCartState {
  final CartItemEntity cartItem;

  const AddToCartSuccess({required this.cartItem});

  @override
  List<Object> get props => [cartItem];
}

class AddToCartError extends AddToCartState {
  final String message;

  const AddToCartError({required this.message});

  @override
  List<Object> get props => [message];
}
