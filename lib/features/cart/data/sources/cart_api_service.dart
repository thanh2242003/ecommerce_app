// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:ecommerce_app/core/storage/token_storage.dart';
// import '../models/cart_item_model.dart';

// class CartApiService {
//   static const String baseUrl = 'http://192.168.50.215:3000/v1/api';
//   final TokenStorage tokenStorage;

//   CartApiService({required this.tokenStorage});

//   Future<String> _getAccessToken() async {
//     final token = await tokenStorage.getAccessToken();
//     if (token == null || token.isEmpty) {
//       throw Exception('Unauthenticated: Access token not found');
//     }
//     return token;
//   }

//   Future<CartItemModel> addToCart({
//     required String productId,
//     required int quantity,
//     required String color,
//   }) async {
//     final accessToken = await _getAccessToken();
//     final response = await http.post(
//       Uri.parse('$baseUrl/cart/add'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: json.encode({
//         'productId': productId,
//         'quantity': quantity,
//         'color': color,
//       }),
//     );

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       final data = json.decode(response.body)['metadata'];
//       return CartItemModel.fromJson(data);
//     } else {
//       throw Exception('Failed to add to cart: ${response.body}');
//     }
//   }
// }
import 'dart:convert';
import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/core/storage/token_storage.dart';
import '../models/cart_item_model.dart';

class CartApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final TokenStorage tokenStorage;

  CartApiService({required this.tokenStorage});

  // ================= HEADERS =================
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

  // ================= ADD TO CART =================
  Future<CartItemModel> addToCart({
    required String productId,
    required int quantity,
    required String color,
    String? size,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: await _headers(),
      body: json.encode({
        'productId': productId,
        'quantity': quantity,
        'color': color,
        if (size != null) 'size': size,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body)['metadata'];
      return CartItemModel.fromJson(data);
    } else {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }

  // ================= UPDATE QUANTITY =================
  Future<List<CartItemModel>> updateQuantity({
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/update'),
      headers: await _headers(),
      body: json.encode({
        'productId': productId,
        'quantity': quantity,
        if (color != null) 'color': color,
        if (size != null) 'size': size,
      }),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final metadata = body['metadata'];
      List<dynamic> items = [];
      if (metadata is Map<String, dynamic>) {
        items = metadata['items'] ?? [];
      } else if (metadata is List) {
        items = metadata;
      }
      return items
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to update cart: ${response.body}');
    }
  }

  // ================= DELETE ITEM =================
  Future<List<CartItemModel>> deleteItem({
    required String productId,
    String? color,
    String? size,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: await _headers(),
      body: json.encode({
        'productId': productId,
        if (color != null) 'color': color,
        if (size != null) 'size': size,
      }),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final metadata = body['metadata'];
      List<dynamic> items = [];
      if (metadata is Map<String, dynamic>) {
        items = metadata['items'] ?? [];
      } else if (metadata is List) {
        items = metadata;
      }
      return items
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to delete from cart: ${response.body}');
    }
  }

  // ================= GET CART =================
  //   Future<CartModel> getCart() async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/cart'),
  //     headers: await _headers(),
  //   );

  //   if (response.statusCode == 200) {
  //     final body = json.decode(response.body);
  //     final metadata = body['metadata'];

  //     return CartModel.fromJson(metadata);
  //   } else {
  //     throw Exception('Failed to fetch cart: ${response.body}');
  //   }
  // }

  Future<List<CartItemModel>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final metadata = body['metadata'];
      List<dynamic> items = [];
      if (metadata is Map<String, dynamic>) {
        items = metadata['items'] ?? [];
      } else if (metadata is List) {
        items = metadata;
      }
      return items
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch cart: ${response.body}');
    }
  }
}
