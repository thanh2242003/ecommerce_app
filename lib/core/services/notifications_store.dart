import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/app_notification.dart';

class NotificationsStore extends ChangeNotifier {
  NotificationsStore._internal();

  static final NotificationsStore instance = NotificationsStore._internal();

  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  void addFromRemoteMessage(RemoteMessage message) {
    final id =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final title = (message.notification?.title ?? message.data['title'] ?? '')
        .toString();
    final body = (message.notification?.body ?? message.data['body'] ?? '')
        .toString();
    final data = Map<String, dynamic>.from(message.data);

    _items.insert(
      0,
      AppNotification(
        id: id,
        title: title,
        body: body,
        data: data,
        receivedAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
