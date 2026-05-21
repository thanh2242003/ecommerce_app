import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/return/data/models/return_request.dart';
import 'package:ecommerce_app/features/return/data/models/return_response.dart';
import 'package:http/http.dart' as http;

class ReturnApiService {
  ReturnApiService({required this.tokenStorage});

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

  Future<ReturnResponse> createReturn(ReturnRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/return/request'),
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

      return ReturnResponse.fromJson(data);
    }

    String message = 'Failed to create return request';
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

  Future<List<ReturnResponse>> getReturns({String? status}) async {
    final uri = Uri.parse(
      '$baseUrl/return/requests${status != null ? '?status=$status' : ''}',
    );
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractList(body);
      return data.map(ReturnResponse.fromJson).toList();
    }

    throw Exception('Failed to get returns: ${response.body}');
  }

  Future<ReturnResponse> getReturnDetail(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/return/requests/$id'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractMap(body);
      if (data != null) return ReturnResponse.fromJson(data);
      throw Exception('Return detail response has no payload');
    }

    throw Exception('Failed to get return detail: ${response.body}');
  }

  Future<ReturnResponse> markReturned(
    String id, {
    String? trackingNumber,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/return/requests/$id/mark-returned'),
      headers: await _headers(),
      body: jsonEncode({
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractMap(body);
      if (data != null) return ReturnResponse.fromJson(data);
      if (body is Map<String, dynamic>) return ReturnResponse.fromJson(body);
      throw Exception('Mark returned response has no payload');
    }

    throw Exception('Failed to mark returned: ${response.body}');
  }

  Future<ReturnResponse> cancelReturn(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/return/requests/$id/cancel'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractMap(body);
      if (data != null) return ReturnResponse.fromJson(data);
      if (body is Map<String, dynamic>) return ReturnResponse.fromJson(body);
      throw Exception('Cancel return response has no payload');
    }

    throw Exception('Failed to cancel return: ${response.body}');
  }

  List<Map<String, dynamic>> _extractList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is List) {
        return metadata.whereType<Map<String, dynamic>>().toList();
      }
      if (metadata is Map<String, dynamic>) {
        final dynamic items =
            metadata['data'] ?? metadata['items'] ?? metadata['returns'];
        if (items is List)
          return items.whereType<Map<String, dynamic>>().toList();
      }
      final dynamic items = body['returns'] ?? body['data'] ?? body['items'];
      if (items is List)
        return items.whereType<Map<String, dynamic>>().toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is Map<String, dynamic>) {
        final dynamic ret = metadata['return'] ?? metadata['data'];
        if (ret is Map<String, dynamic>) return ret;
        return metadata;
      }
      final dynamic ret = body['return'] ?? body['data'];
      if (ret is Map<String, dynamic>) return ret;
    }
    return null;
  }
}
