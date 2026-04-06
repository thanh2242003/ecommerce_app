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
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/core/storage/token_storage.dart';
import '../models/cart_item_model.dart';

class CartApiService {
  static const String baseUrl = 'http://192.168.50.215:3000/v1/api';
  final TokenStorage tokenStorage;

  CartApiService({required this.tokenStorage});

  // ================= HEADERS =================
  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.getAccessToken();
    final userId = await tokenStorage.getUserId();
    print("ACCESS TOKEN: $token");
    print("USER ID: $userId");

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
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: await _headers(),
      body: json.encode({
        'productId': productId,
        'quantity': quantity,
        'color': color,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body)['metadata'];
      return CartItemModel.fromJson(data);
    } else {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }
}
