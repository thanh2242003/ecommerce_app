import 'package:ecommerce_app/features/order/data/models/order_request.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit({required this.orderRepository}) : super(const OrderInitial());

  final OrderRepository orderRepository;

  Future<void> createCartOrder(String addressId) async {
    emit(const OrderLoading());
    try {
      final request = OrderRequest(type: 'cart', addressId: addressId);
      final response = await orderRepository.createOrder(request);
      emit(OrderSuccess(response));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> createBuyNowOrder(
    String addressId,
    String productId,
    int quantity,
    String color,
  ) async {
    emit(const OrderLoading());
    try {
      final request = OrderRequest(
        type: 'buy_now',
        addressId: addressId,
        productId: productId,
        quantity: quantity,
        color: color,
      );
      final response = await orderRepository.createOrder(request);
      emit(OrderSuccess(response));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }
}
