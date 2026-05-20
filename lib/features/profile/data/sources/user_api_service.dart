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

  // ================= UPDATE PROFILE =================
  static Future<UserModel> updateUser({
    required String token,
    required String userId,
    required String name,
    required String phone,
    required String address,
    String? avatar,
    String? avatarFilePath,
  }) async {
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/profile'),
    );
    request.headers.addAll(_headers(userId: userId, token: token));
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['address'] = address;

    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFilePath),
      );
    } else if (avatar != null && avatar.isNotEmpty) {
      request.fields['avatar'] = avatar;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['metadata'];

      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }
}
