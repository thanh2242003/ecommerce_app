import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';
import 'package:ecommerce_app/features/notifications/data/sources/notification_api_service.dart';
import 'package:ecommerce_app/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required this.apiService});

  final NotificationApiService apiService;

  final Map<String, List<NotificationModel>> _memoryPageCache =
      <String, List<NotificationModel>>{};

  @override
  Future<List<NotificationModel>> getNotifications(
    String userId,
    int page,
    int limit,
  ) async {
    final cacheKey = '$userId:$page:$limit';
    final cached = _memoryPageCache[cacheKey];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final rows = await apiService.getNotifications(
      userId: userId,
      page: page,
      limit: limit,
    );
    _memoryPageCache[cacheKey] = rows;
    return rows;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = await apiService.tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('Unauthenticated');
    }

    await apiService.markAsRead(userId: userId, notificationId: notificationId);
    _clearCache();
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await apiService.markAllAsRead(userId: userId);
    _clearCache();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return apiService.getUnreadCount(userId: userId);
  }

  @override
  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    await apiService.deleteNotification(
      userId: userId,
      notificationId: notificationId,
    );
    _clearCache();
  }

  @override
  Future<void> clearCache() async {
    _clearCache();
  }

  void _clearCache() {
    _memoryPageCache.clear();
  }
}
