import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/get_cart_usecase.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;

  CartCubit({required this.getCartUseCase}) : super(const CartState());

  // ─── Fetch Cart ──────────────────────────────────────────────────────────
  Future<void> fetchCart() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await getCartUseCase();
      // by default select all items
      final selectedIds = items.map((e) => e.cartItemId).toSet();
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: items,
        selectedIds: selectedIds,
        totalPrice: _calcTotal(items, selectedIds),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Toggle Select ────────────────────────────────────────────────────────
  void toggleSelectItem(String cartItemId) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(cartItemId)) {
      selected.remove(cartItemId);
    } else {
      selected.add(cartItemId);
    }
    emit(state.copyWith(
      selectedIds: selected,
      totalPrice: _calcTotal(state.items, selected),
    ));
  }

  // ─── Increase Quantity ────────────────────────────────────────────────────
  void increaseQuantity(String cartItemId) {
    final updatedItems = state.items.map((item) {
      if (item.cartItemId == cartItemId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    emit(state.copyWith(
      items: updatedItems,
      totalPrice: _calcTotal(updatedItems, state.selectedIds),
    ));
  }

  // ─── Decrease Quantity ────────────────────────────────────────────────────
  void decreaseQuantity(String cartItemId) {
    final updatedItems = state.items.map((item) {
      if (item.cartItemId == cartItemId && item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();

    emit(state.copyWith(
      items: updatedItems,
      totalPrice: _calcTotal(updatedItems, state.selectedIds),
    ));
  }

  // ─── Calculate Total ──────────────────────────────────────────────────────
  int _calcTotal(List<CartItemEntity> items, Set<String> selectedIds) {
    return items
        .where((item) => selectedIds.contains(item.cartItemId))
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}
