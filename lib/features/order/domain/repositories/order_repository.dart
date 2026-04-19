import '../../data/models/order_request.dart';
import '../../data/models/order_response.dart';

abstract class OrderRepository {
  Future<OrderResponse> createOrder(OrderRequest request);
  Future<List<OrderResponse>> getOrders();
  Future<OrderResponse> getOrderDetail(String id);
}
