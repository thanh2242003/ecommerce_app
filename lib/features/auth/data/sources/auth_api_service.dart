import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/features/auth/data/models/auth_response_model.dart';

class AuthApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/v1/api';

  Future<AuthResponseModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body)['metadata'];
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('Sign up failed: ${response.body}');
    }
  }

  Future<AuthResponseModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/signin'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['metadata'];
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('Sign in failed: ${response.body}');
    }
  }

  Future<void> logout({required String accessToken}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/handlerRefreshToken'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken', // Backend dùng refreshToken trong header
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['metadata'];
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('Refresh token failed: ${response.body}');
    }
  }
}