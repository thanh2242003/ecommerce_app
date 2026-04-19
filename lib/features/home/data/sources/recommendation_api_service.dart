import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:http/http.dart' as http;

class RecommendationApiService {
  final String baseUrl = ApiConfig.baseUrl;

  final TokenStorage tokenStorage;

  RecommendationApiService({required this.tokenStorage});

  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.getAccessToken();
    final userId = await tokenStorage.getUserId();

    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      throw Exception('Unauthenticated');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': token,
      'x-client-id': userId,
    };
  }

  Future<List<ProductModel>> getRecommendations() async {
    final userId = await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/product/suggested/$userId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final metadata = body['metadata'];
      final List<dynamic> items = _extractItems(metadata);

      return items
          .map((item) => ProductModel.fromJson(_extractProductMap(item)))
          .toList();
    }

    throw Exception('Failed to load recommendations: ${response.body}');
  }

  List<dynamic> _extractItems(dynamic metadata) {
    if (metadata is List) {
      return metadata;
    }

    if (metadata is Map<String, dynamic>) {
      final candidates = [
        metadata['products'],
        metadata['items'],
        metadata['data'],
        metadata['history'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _extractProductMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      final product = item['product'];
      if (product is Map<String, dynamic>) {
        return product;
      }
      return item;
    }

    return <String, dynamic>{};
  }
}
