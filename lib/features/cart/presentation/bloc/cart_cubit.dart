import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/repositories/cart_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final CartRepository repository;

  bool _isFetching = false;
  bool _isAdding = false;

  CartCubit({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.repository,
  }) : super(const CartInitial());

  // ─── Fetch Cart ──────────────────────────────────────────────────────────
  Future<void> fetchCart({bool forceRefresh = false}) async {
    if (_isFetching) {
      return;
    }

    if (!forceRefresh && state is CartLoaded) {
      return;
    }

    _isFetching = true;
    emit(const CartLoading());

    try {
      final items = await getCartUseCase();
      // by default select all items
      final selectedIds = items.map((e) => e.cartItemId).toSet();
      emit(
        CartLoaded(
          items: items,
          selectedIds: selectedIds,
          totalPrice: _calcTotal(items, selectedIds),
        ),
      );
    } catch (e) {
      emit(CartError(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String color,
    String? size,
  }) async {
    if (_isAdding) {
      return;
    }

    _isAdding = true;
    emit(const CartLoading());

    try {
      await addToCartUseCase(
        productId: productId,
        quantity: quantity,
        color: color,
        size: size,
      );

      await fetchCart(forceRefresh: true);
    } catch (e) {
      emit(CartError(message: e.toString()));
      rethrow;
    } finally {
      _isAdding = false;
    }
  }

  // ─── Toggle Select ────────────────────────────────────────────────────────
  void toggleSelectItem(String cartItemId) {
    final currentState = state;
    if (currentState is! CartLoaded) {
      return;
    }

    final selected = Set<String>.from(currentState.selectedIds);
    if (selected.contains(cartItemId)) {
      selected.remove(cartItemId);
    } else {
      selected.add(cartItemId);
    }
    emit(
      currentState.copyWith(
        selectedIds: selected,
        totalPrice: _calcTotal(currentState.items, selected),
      ),
    );
  }

  // ─── Increase Quantity (with backend sync) ────────────────────────────────
  Future<void> increaseQuantity(String cartItemId) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    CartItemEntity? item;
    for (final candidate in currentState.items) {
      if (candidate.cartItemId == cartItemId) {
        item = candidate;
        break;
      }
    }
    if (item == null) return;

    try {
      final newQty = item.quantity + 1;
      final items = await repository.updateQuantity(
        productId: item.productId,
        quantity: newQty,
        color: item.color,
        size: item.size,
      );

      emit(
        CartLoaded(
          items: items,
          selectedIds: currentState.selectedIds,
          totalPrice: _calcTotal(items, currentState.selectedIds),
        ),
      );
    } catch (e) {
      emit(CartError(message: 'Failed to increase quantity: ${e.toString()}'));
    }
  }

  // ─── Decrease Quantity (with backend sync) ────────────────────────────────
  Future<void> decreaseQuantity(String cartItemId) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    CartItemEntity? item;
    for (final candidate in currentState.items) {
      if (candidate.cartItemId == cartItemId) {
        item = candidate;
        break;
      }
    }
    if (item == null || item.quantity <= 1) return;

    try {
      final newQty = item.quantity - 1;
      final items = await repository.updateQuantity(
        productId: item.productId,
        quantity: newQty,
        color: item.color,
        size: item.size,
      );

      emit(
        CartLoaded(
          items: items,
          selectedIds: currentState.selectedIds,
          totalPrice: _calcTotal(items, currentState.selectedIds),
        ),
      );
    } catch (e) {
      emit(CartError(message: 'Failed to decrease quantity: ${e.toString()}'));
    }
  }

  // ─── Calculate Total ──────────────────────────────────────────────────────
  int _calcTotal(List<CartItemEntity> items, Set<String> selectedIds) {
    return items
        .where((item) => selectedIds.contains(item.cartItemId))
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // ─── Delete Selected Items (with backend sync) ─────────────────────────────
  Future<void> deleteSelectedItems(List<String> ids) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    try {
      // Get items to delete
      final itemsToDelete = currentState.items
          .where((i) => ids.contains(i.cartItemId))
          .toList();

      // Delete each item from backend
      for (final item in itemsToDelete) {
        await repository.deleteItem(
          productId: item.productId,
          color: item.color,
          size: item.size,
        );
      }

      await fetchCart(forceRefresh: true);
    } catch (e) {
      emit(CartError(message: 'Failed to delete items: ${e.toString()}'));
    }
  }
}
