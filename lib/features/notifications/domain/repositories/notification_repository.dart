import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(
    String userId,
    int page,
    int limit,
  );

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<int> getUnreadCount(String userId);

  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  });

  Future<void> clearCache();
}
