import 'dart:convert';
import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserApiService {
  static const String baseUrl = '${ApiConfig.baseUrl}/user';

  // ================= HEADERS =================
  static Map<String, String> _headers({required String userId, String? token}) {
    return {
      'Content-Type': 'application/json',
      'x-client-id': userId,
      if (token != null) 'authorization': token, // token = accessToken raw
    };
  }

  // ================= GET PROFILE =================
  static Future<UserModel> getUser({
    required String token,
    required String userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(userId: userId, token: token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['metadata'];

      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }
}
