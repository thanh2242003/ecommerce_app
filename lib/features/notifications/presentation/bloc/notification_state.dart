import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.notifications = const <NotificationModel>[],
    this.loading = false,
    this.loadingMore = false,
    this.unreadCount = 0,
    this.hasMore = true,
    this.error,
  });

  final List<NotificationModel> notifications;
  final bool loading;
  final bool loadingMore;
  final int unreadCount;
  final bool hasMore;
  final String? error;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? loading,
    bool? loadingMore,
    int? unreadCount,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    loading,
    loadingMore,
    unreadCount,
    hasMore,
    error,
  ];
}
