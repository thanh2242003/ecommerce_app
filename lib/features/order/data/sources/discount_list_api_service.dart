import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/discount_code_model.dart';
import 'package:http/http.dart' as http;

class DiscountListApiService {
  DiscountListApiService({required this.tokenStorage});

  final TokenStorage tokenStorage;

  Future<List<DiscountCodeModel>> getDiscountCodes({
    String? shopId,
    String? code,
    int page = 1,
    int limit = 20,
  }) async {
    final userId = await tokenStorage.getUserId();

    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (shopId != null && shopId.trim().isNotEmpty) 'shopId': shopId.trim(),
      if (code != null && code.trim().isNotEmpty) 'code': code.trim(),
      if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/discount/list_product_code',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractList(body);
      return data.map(DiscountCodeModel.fromJson).toList();
    }

    String message = 'Failed to load discount codes';
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

  List<Map<String, dynamic>> _extractList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is List) {
        return metadata.whereType<Map<String, dynamic>>().toList();
      }
      if (metadata is Map<String, dynamic>) {
        final dynamic items =
            metadata['items'] ?? metadata['discounts'] ?? metadata['codes'];
        if (items is List) {
          return items.whereType<Map<String, dynamic>>().toList();
        }
      }
      final dynamic items = body['items'] ?? body['discounts'] ?? body['codes'];
      if (items is List) {
        return items.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }
}
