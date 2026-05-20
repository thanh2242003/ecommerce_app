import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/discount_amount_result.dart';
import 'package:http/http.dart' as http;

class DiscountApiService {
  DiscountApiService({required this.tokenStorage});

  final TokenStorage tokenStorage;

  Future<DiscountAmountResult> calculateDiscount({
    required String codeId,
    required List<Map<String, dynamic>> products,
    String? shopId,
  }) async {
    final userId = await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('Unauthenticated: User id not found');
    }

    final payload = <String, dynamic>{
      'codeId': codeId.trim().toUpperCase(),
      'code': codeId.trim().toUpperCase(),
      'userId': userId,
      'products': products,
      if (shopId != null && shopId.trim().isNotEmpty) 'shopId': shopId.trim(),
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/discount/amount'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      final data = _extractDiscountMap(body);
      if (data != null) {
        return DiscountAmountResult.fromJson(data);
      }
      throw Exception('Discount response has no payload');
    }

    String message = 'Failed to calculate discount';
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

  Map<String, dynamic>? _extractDiscountMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final metadata = body['metadata'];
      if (metadata is Map<String, dynamic>) {
        return metadata;
      }
      return body;
    }
    return null;
  }
}
