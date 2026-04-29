import 'dart:convert';
import 'package:ecommerce_app/core/services/notification_service.dart';
import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/features/auth/data/models/auth_response_model.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';

class AuthApiService {
  // static const String baseUrl =
  //     'http://192.168.50.217:3000/v1/api'; //'http://10.0.2.2:3000/v1/api';
  final String baseUrl = ApiConfig.baseUrl;
  final TokenStorage tokenStorage;
  final NotificationService notificationService;

  AuthApiService({
    required this.tokenStorage,
    required this.notificationService,
  });

  Future<AuthResponseModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
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
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['metadata'];
      final auth = AuthResponseModel.fromJson(data);
      await tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      await tokenStorage.saveUserId(auth.user.id);
      await notificationService.syncFcmTokenToBackend();
      return auth;
    } else {
      throw Exception('Sign in failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    await notificationService.removeFcmTokenFromBackend();
    await tokenStorage.clearTokens();
  }

  Future<AuthResponseModel> refreshAccessToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    final userId = await tokenStorage.getUserId();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Unauthenticated: Refresh token not found');
    }

    if (userId == null || userId.isEmpty) {
      throw Exception('Unauthenticated: User id not found');
    }

    // Endpoint: POST /v1/api/handlerRefreshToken
    // Headers: x-client-id, x-rtoken-id (authorization NOT required)
    final response = await http.post(
      Uri.parse('$baseUrl/handlerRefreshToken'),
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': userId,
        'x-rtoken-id': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['metadata'];
      final authResponse = AuthResponseModel.fromJson(data);

      // Update tokens
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await notificationService.syncFcmTokenToBackend();

      return authResponse;
    } else {
      throw Exception('Refresh token failed: ${response.body}');
    }
  }
}
