part of 'order_cubit.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderSuccess extends OrderState {
  const OrderSuccess(this.order);

  final OrderResponse order;
}

class OrderFailure extends OrderState {
  const OrderFailure(this.message);

  final String message;
}
