import 'dart:convert';
import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductApiService {
  static const String baseUrl = '${ApiConfig.baseUrl}/product';

  // ================= HEADERS =================
  static Map<String, String> _headers({String? token, String? userId}) {
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'x-client-id': userId,
      if (token != null) 'authorization': token,
    };
  }

  // ================= GET ALL =================
  static Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    final response = await http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['metadata'] as List;

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  // ================= GET BY ID =================
  static Future<ProductModel> getProductById(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$productId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['metadata'];

      return ProductModel.fromJson(data);
    } else {
      throw Exception('Product not found: ${response.body}');
    }
  }

  // ================= SEARCH =================
  static Future<List<ProductModel>> searchProducts(
    String keyword, {
    String? categoryId,
  }) async {
    final tokenStorage = TokenStorage();
    final userId = await tokenStorage.getUserId();
    final accessToken = await tokenStorage.getAccessToken();

    final queryParameters = <String, String>{
      'q': keyword,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/search').replace(queryParameters: queryParameters),
      headers: _headers(token: accessToken, userId: userId),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['metadata'] as List;

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Tìm kiếm thất bại: ${response.body}');
    }
  }

  // ================= TOP SELLING =================
  static Future<List<ProductModel>> getTopSelling({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/top-selling?limit=$limit'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['metadata'] as List;

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Top selling failed: ${response.body}');
    }
  }
}
