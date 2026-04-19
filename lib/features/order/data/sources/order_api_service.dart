import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/order_request.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  OrderApiService({required this.tokenStorage});

  static const String baseUrl = ApiConfig.baseUrl;
  final TokenStorage tokenStorage;

  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.getAccessToken();
    final userId = await tokenStorage.getUserId();

    if (token == null || token.isEmpty) {
      throw Exception('Unauthenticated: Access token not found');
    }
    if (userId == null || userId.isEmpty) {
      throw Exception('Unauthenticated: User id not found');
    }

    return {
      'Content-Type': 'application/json',
      'x-client-id': userId,
      'authorization': token,
    };
  }

  Future<OrderResponse> createOrder(OrderRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/order/orders'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      final data = body is Map<String, dynamic>
          ? (body['metadata'] is Map<String, dynamic>
                ? body['metadata'] as Map<String, dynamic>
                : body)
          : <String, dynamic>{};

      return OrderResponse.fromJson(data);
    }

    String message = 'Failed to create order';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        message = (body['message'] ?? body['error'] ?? message).toString();
      }
    } catch (_) {
      message = '$message: ${response.body}';
    }

    throw Exception('$message (status: ${response.statusCode})');
  }

  Future<List<OrderResponse>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/orders'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractOrderList(body);
      return data.map(OrderResponse.fromJson).toList();
    }

    throw Exception('Failed to get orders: ${response.body}');
  }

  Future<OrderResponse> getOrderDetail(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/orders/$id'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractOrderMap(body);
      if (data != null) {
        return OrderResponse.fromJson(data);
      }

      throw Exception('Order detail response has no order payload');
    }

    throw Exception('Failed to get order detail: ${response.body}');
  }

  List<Map<String, dynamic>> _extractOrderList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is List) {
        return metadata.whereType<Map<String, dynamic>>().toList();
      }
      if (metadata is Map<String, dynamic>) {
        final dynamic orders = metadata['orders'] ?? metadata['items'];
        if (orders is List) {
          return orders.whereType<Map<String, dynamic>>().toList();
        }
      }
      final dynamic orders = body['orders'];
      if (orders is List) {
        return orders.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractOrderMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is Map<String, dynamic>) {
        final dynamic order = metadata['order'];
        if (order is Map<String, dynamic>) {
          return order;
        }
        return metadata;
      }
      final dynamic order = body['order'];
      if (order is Map<String, dynamic>) {
        return order;
      }
    }
    return null;
  }
}
