import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  final CartRepository cartRepository;

  AddToCartCubit({required this.cartRepository}) : super(AddToCartInitial());

  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String color,
    String? size,
  }) async {
    try {
      emit(AddToCartLoading());

      final cartItem = await cartRepository.addToCart(
        productId: productId,
        quantity: quantity,
        color: color,
        size: size,
      );

      emit(AddToCartSuccess(cartItem: cartItem));
    } on Exception catch (e) {
      emit(AddToCartError(message: e.toString()));
    }
  }
}
