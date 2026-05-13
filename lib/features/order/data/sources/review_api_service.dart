import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/user_review_item.dart';
import 'package:http/http.dart' as http;

class ReviewApiService {
  ReviewApiService({required this.tokenStorage});

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

  Future<List<UserReviewItem>> getUserReviews({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/reviews?page=$page&limit=$limit'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user reviews: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final reviewItems = _extractReviewList(body);
    return reviewItems.map(UserReviewItem.fromJson).toList();
  }

  Future<void> createReview({
    required String productId,
    required String orderId,
    required String content,
    required double rating,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/product/$productId/reviews'),
      headers: await _headers(),
      body: jsonEncode({
        'content': content,
        'rating': rating,
        'orderId': orderId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception('Failed to create review: ${response.body}');
  }

  List<Map<String, dynamic>> _extractReviewList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is Map<String, dynamic>) {
        final dynamic reviews = metadata['reviews'];
        if (reviews is List) {
          return reviews.whereType<Map<String, dynamic>>().toList();
        }
      }

      final dynamic reviews = body['reviews'];
      if (reviews is List) {
        return reviews.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }
}
