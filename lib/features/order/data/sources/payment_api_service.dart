import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/payment_response.dart';
import 'package:http/http.dart' as http;

class PaymentApiService {
  PaymentApiService({required this.tokenStorage});

  static const String baseUrl = ApiConfig.paymentBaseUrl;
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

  Future<PaymentResponse> createSepayPayment(String orderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sepay/create'),
      headers: await _headers(),
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentResponse.fromJson(_extractMetadata(response.body));
    }

    throw Exception(_readError(response, 'Failed to create SePay payment'));
  }

  Future<PaymentResponse> getPaymentStatus(String paymentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$paymentId/status'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return PaymentResponse.fromJson(_extractMetadata(response.body));
    }

    throw Exception(_readError(response, 'Failed to get payment status'));
  }

  Future<List<PaymentResponse>> getPaymentHistory({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history?page=$page&limit=$limit'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final metadata = body['metadata'];
        final items = metadata is Map<String, dynamic>
            ? metadata['items']
            : body['items'];
        if (items is List) {
          return items
              .whereType<Map<String, dynamic>>()
              .map(PaymentResponse.fromJson)
              .toList();
        }
      }
      return const <PaymentResponse>[];
    }

    throw Exception(_readError(response, 'Failed to get payment history'));
  }

  Map<String, dynamic> _extractMetadata(String responseBody) {
    final body = jsonDecode(responseBody);
    if (body is Map<String, dynamic>) {
      final metadata = body['metadata'];
      if (metadata is Map<String, dynamic>) {
        return metadata;
      }
      return body;
    }
    return <String, dynamic>{};
  }

  String _readError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'] ?? body['error'];
        if (message != null) {
          return '$message (status: ${response.statusCode})';
        }
      }
    } catch (_) {
      // Keep fallback below.
    }
    return '$fallback (status: ${response.statusCode}): ${response.body}';
  }
}
