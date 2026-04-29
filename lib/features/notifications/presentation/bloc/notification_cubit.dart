import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/notifications/data/models/notification_model.dart';
import 'package:ecommerce_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:ecommerce_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required this.repository,
    required this.tokenStorage,
    this.limit = 20,
  }) : super(const NotificationState());

  final NotificationRepository repository;
  final TokenStorage tokenStorage;
  final int limit;

  int _page = 1;
  String? _userId;

  String? get currentUserId => _userId;

  Future<void> initForCurrentUser({bool refresh = true}) async {
    final userId = await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          error: 'Unauthenticated',
        ),
      );
      return;
    }
    _userId = userId;
    await loadNotifications(userId, refresh: refresh);
    await fetchUnreadCount(userId);
  }

  Future<void> refreshUnreadForCurrentUser() async {
    final userId = _userId ?? await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    _userId = userId;
    await fetchUnreadCount(userId);
  }

  Future<void> loadNotifications(String userId, {bool refresh = false}) async {
    if (state.loading || state.loadingMore) {
      return;
    }

    _userId = userId;

    if (refresh) {
      _page = 1;
      await repository.clearCache();
      emit(
        state.copyWith(
          notifications: const <NotificationModel>[],
          loading: true,
          hasMore: true,
          clearError: true,
        ),
      );
    } else {
      emit(state.copyWith(loading: true, clearError: true));
    }

    try {
      final rows = _sortByNewest(
        await repository.getNotifications(userId, _page, limit),
      );
      emit(
        state.copyWith(
          notifications: rows,
          loading: false,
          hasMore: rows.length >= limit,
        ),
      );
      _page = 2;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadMore(String userId) async {
    if (state.loading || state.loadingMore || !state.hasMore) {
      return;
    }

    emit(state.copyWith(loadingMore: true, clearError: true));

    try {
      final rows = _sortByNewest(
        await repository.getNotifications(userId, _page, limit),
      );
      final merged = <NotificationModel>[...state.notifications, ...rows];
      emit(
        state.copyWith(
          notifications: _uniqueById(merged),
          loadingMore: false,
          hasMore: rows.length >= limit,
        ),
      );
      _page += 1;
    } catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.toString()));
    }
  }

  Future<void> loadMoreForCurrentUser() async {
    final userId = _userId ?? await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    _userId = userId;
    await loadMore(userId);
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _userId ?? await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    _userId = userId;

    final oldList = state.notifications;
    final idx = oldList.indexWhere((n) => n.id == notificationId);
    if (idx < 0) {
      return;
    }

    final target = oldList[idx];
    if (target.isRead) {
      return;
    }

    final optimistic = List<NotificationModel>.from(oldList);
    optimistic[idx] = target.copyWith(isRead: true);

    emit(
      state.copyWith(
        notifications: optimistic,
        unreadCount: (state.unreadCount - 1).clamp(0, 1 << 30),
      ),
    );

    try {
      await repository.markAsRead(notificationId);
      await fetchUnreadCount(userId);
    } catch (e) {
      emit(state.copyWith(notifications: oldList, error: e.toString()));
      await fetchUnreadCount(userId);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    _userId = userId;

    final oldList = state.notifications;
    final optimistic = oldList.map((n) => n.copyWith(isRead: true)).toList();

    emit(state.copyWith(notifications: optimistic, unreadCount: 0));

    try {
      await repository.markAllAsRead(userId);
      await loadNotifications(userId, refresh: true);
      await fetchUnreadCount(userId);
    } catch (e) {
      emit(state.copyWith(notifications: oldList, error: e.toString()));
      await fetchUnreadCount(userId);
    }
  }

  Future<void> markAllAsReadForCurrentUser() async {
    final userId = _userId ?? await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    await markAllAsRead(userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _userId ?? await tokenStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    _userId = userId;

    final oldList = state.notifications;
    final optimistic = oldList.where((n) => n.id != notificationId).toList();

    emit(state.copyWith(notifications: optimistic));

    try {
      await repository.deleteNotification(
        userId: userId,
        notificationId: notificationId,
      );
      await fetchUnreadCount(userId);
    } catch (e) {
      emit(state.copyWith(notifications: oldList, error: e.toString()));
      await fetchUnreadCount(userId);
    }
  }

  Future<void> fetchUnreadCount(String userId) async {
    _userId = userId;

    try {
      final count = await repository.getUnreadCount(userId);
      emit(state.copyWith(unreadCount: count));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  List<NotificationModel> _uniqueById(List<NotificationModel> input) {
    final map = <String, NotificationModel>{};
    for (final item in input) {
      map[item.id] = item;
    }
    return map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<NotificationModel> _sortByNewest(List<NotificationModel> input) {
    final rows = List<NotificationModel>.from(input);
    rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rows;
  }
}
