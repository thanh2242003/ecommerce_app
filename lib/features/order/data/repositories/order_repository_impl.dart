import 'package:ecommerce_app/features/order/data/models/order_request.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required this.apiService});

  final OrderApiService apiService;

  @override
  Future<OrderResponse> createOrder(OrderRequest request) async {
    return apiService.createOrder(request);
  }

  @override
  Future<List<OrderResponse>> getOrders() async {
    return apiService.getOrders();
  }

  @override
  Future<OrderResponse> getOrderDetail(String id) async {
    return apiService.getOrderDetail(id);
  }

  @override
  Future<OrderResponse> cancelOrder(String id, {String? cancelReason}) async {
    return apiService.cancelOrder(id, cancelReason: cancelReason);
  }
}
