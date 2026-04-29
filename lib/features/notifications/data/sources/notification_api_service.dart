import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  NotificationApiService({required this.tokenStorage});

  final String baseUrl = ApiConfig.baseUrl;
  final TokenStorage tokenStorage;

  Future<Map<String, String>> _headers(String userId) async {
    final token = await tokenStorage.getAccessToken();

    if (token == null || token.isEmpty || userId.isEmpty) {
      throw Exception('Unauthenticated');
    }

    return {
      'Content-Type': 'application/json',
      'x-client-id': userId,
      'authorization': token,
    };
  }

  Future<List<NotificationModel>> getNotifications({
    required String userId,
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$userId?page=$page&limit=$limit'),
      headers: await _headers(userId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications: ${response.body}');
    }

    final payload = json.decode(response.body) as Map<String, dynamic>;
    final metadata = payload['metadata'];
    final rows = _extractNotificationRows(metadata);

    return rows
        .map((row) => NotificationModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractNotificationRows(dynamic metadata) {
    if (metadata is List) {
      return metadata;
    }

    if (metadata is Map<String, dynamic>) {
      final items = metadata['items'];
      if (items is List) {
        return items;
      }
    }

    return <dynamic>[];
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read/$notificationId'),
      headers: await _headers(userId),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark as read: ${response.body}');
    }
  }

  Future<void> markAllAsRead({required String userId}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read-all/$userId'),
      headers: await _headers(userId),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark all as read: ${response.body}');
    }
  }

  Future<int> getUnreadCount({required String userId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count/$userId'),
      headers: await _headers(userId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get unread count: ${response.body}');
    }

    final payload = json.decode(response.body) as Map<String, dynamic>;
    final metadata = payload['metadata'];
    if (metadata is int) {
      return metadata;
    }
    if (metadata is num) {
      return metadata.toInt();
    }
    return int.tryParse(metadata.toString()) ?? 0;
  }

  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _headers(userId),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete notification: ${response.body}');
    }
  }
}
