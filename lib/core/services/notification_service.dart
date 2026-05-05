import 'dart:async';
import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/presentation/pages/order_detail_screen.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/sources/product_api_service.dart';
import 'package:ecommerce_app/features/product/domain/entities/color.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/entities/review.dart';
import 'package:ecommerce_app/features/product/domain/entities/variant.dart';
import 'package:ecommerce_app/features/product/presentation/pages/product_detail_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/core/services/notifications_store.dart';

/// Central place to configure Firebase Cloud Messaging and app navigation.
class NotificationService {
  NotificationService({
    required GlobalKey<NavigatorState> navigatorKey,
    required TokenStorage tokenStorage,
  }) : _navigatorKey = navigatorKey,
       _tokenStorage = tokenStorage;

  final GlobalKey<NavigatorState> _navigatorKey;
  final TokenStorage _tokenStorage;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _baseUrl = ApiConfig.baseUrl;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  bool _isInitialized = false;

  /// Initializes Firebase Messaging once and wires all notification listeners.
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    // Ask the user for notification permission on iOS and Android 13+.
    await _requestPermission();

    // Allow foreground notifications to be presented on Apple platforms.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Read and sync the initial token so the backend can identify this device.
    await syncFcmTokenToBackend();

    // Keep backend token registration in sync when Firebase rotates the token.
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      debugPrint('FCM Token refreshed: $token');
      await syncFcmTokenToBackend(currentToken: token);
    });

    // Handle notifications while the app is in foreground.
    // For foreground messages we show an in-app banner instead of navigating immediately.
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) => unawaited(_showInAppNotification(message)),
    );

    // Handle taps on notifications when the app is in background.
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => unawaited(_handleRemoteMessage(message)),
    );

    // Handle the case where the app is launched by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Save initial notification to store and handle navigation.
      NotificationsStore.instance.addFromRemoteMessage(initialMessage);
      _handleRemoteMessage(initialMessage);
    }
  }

  /// Requests notification permission from the platform.
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint(
      'Notification permission status: ${settings.authorizationStatus}',
    );
  }

  /// Sends the current token to the backend using the required headers/body.
  Future<void> syncFcmTokenToBackend({String? currentToken}) async {
    final accessToken = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('Skip FCM sync: access token is missing.');
      return;
    }

    if (userId == null || userId.isEmpty) {
      debugPrint('Skip FCM sync: user id is missing.');
      return;
    }

    final newToken = currentToken ?? await _messaging.getToken();
    if (newToken == null || newToken.isEmpty) {
      debugPrint('Skip FCM sync: current FCM token is missing.');
      return;
    }

    final oldToken = await _tokenStorage.getFcmToken();
    final body = <String, dynamic>{
      'userId': userId,
      'fcmToken': newToken,
      if (oldToken != null && oldToken.isNotEmpty && oldToken != newToken)
        'oldFcmToken': oldToken,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/users/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': userId,
        'authorization': accessToken,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _tokenStorage.saveFcmToken(newToken);
      debugPrint('FCM token saved to backend successfully: $newToken');
      return;
    }

    throw Exception('Failed to save FCM token: ${response.body}');
  }

  /// Removes the current token from the backend during logout.
  Future<void> removeFcmTokenFromBackend() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();
    final fcmToken = await _tokenStorage.getFcmToken();

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('Skip FCM delete: access token is missing.');
      return;
    }

    if (userId == null || userId.isEmpty) {
      debugPrint('Skip FCM delete: user id is missing.');
      return;
    }

    if (fcmToken == null || fcmToken.isEmpty) {
      debugPrint('Skip FCM delete: token is missing.');
      return;
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': userId,
        'authorization': accessToken,
      },
      body: jsonEncode({'userId': userId, 'fcmToken': fcmToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _tokenStorage.clearFcmToken();
      debugPrint('FCM token removed from backend successfully: $fcmToken');
      return;
    }

    throw Exception('Failed to remove FCM token: ${response.body}');
  }

  /// Shows a lightweight in-app notification banner for foreground messages.
  Future<void> _showInAppNotification(RemoteMessage message) async {
    // Persist notification to in-app store for later review.
    try {
      NotificationsStore.instance.addFromRemoteMessage(message);
    } catch (_) {}
    final title =
        _firstNonEmptyString([
          message.notification?.title,
          message.data['title'],
        ]) ??
        'Notification';

    final body =
        _firstNonEmptyString([
          message.notification?.body,
          message.data['body'],
        ]) ??
        '';

    final overlayState = _navigatorKey.currentState?.overlay;
    final context = _navigatorKey.currentState?.context;

    if (overlayState == null || context == null) {
      // Fallback to SnackBar when overlay not available.
      ScaffoldMessenger.of(
        context ?? _dummyContext(),
      ).showSnackBar(SnackBar(content: Text('$title\n$body')));
      return;
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final top = MediaQuery.of(context).viewPadding.top + 8.0;
        return Positioned(
          top: top,
          left: 16,
          right: 16,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: InkWell(
              onTap: () {
                entry.remove();
                unawaited(_handleRemoteMessage(message));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => entry.remove(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(entry);

    // Auto dismiss after 4 seconds if not tapped.
    await Future.delayed(const Duration(seconds: 4));
    if (entry.mounted) {
      entry.remove();
    }
  }

  BuildContext _dummyContext() {
    // This should never be used when overlay/context are available; provides
    // a minimal non-null context for SnackBar fallback by using the navigatorKey's
    // currentState.context if possible. If still null, throw to highlight misuse.
    final ctx = _navigatorKey.currentState?.context;
    if (ctx == null) {
      throw Exception('No context available for snackBar fallback');
    }
    return ctx;
  }

  /// Routes the user to the right screen based on the `data.type` payload.
  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    final type = data['type']?.toString();

    debugPrint('FCM message received: $data');

    switch (type) {
      case 'order':
        _openOrderDetail(data);
        break;
      case 'product':
        await _openProductDetail(message);
        break;
      default:
        debugPrint('Unsupported notification type: $type');
    }
  }

  /// Opens the order detail screen using the order id from the payload.
  void _openOrderDetail(Map<String, dynamic> data) {
    final orderId = _firstNonEmptyString([
      data['orderId'],
      data['order_id'],
      data['id'],
      data['orderID'],
    ]);

    if (orderId == null) {
      debugPrint('Missing order id in notification payload.');
      return;
    }

    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
    );
  }

  /// Opens the product detail screen and builds a safe fallback entity.
  Future<void> _openProductDetail(RemoteMessage message) async {
    final productId = _firstNonEmptyString([
      message.data['productId'],
      message.data['product_id'],
      message.data['id'],
    ]);

    ProductEntity product = _buildProductFromData(
      message.data,
      notificationTitle: message.notification?.title,
      notificationBody: message.notification?.body,
    );

    if (productId != null && productId.isNotEmpty) {
      try {
        // Prefer the live product from the backend when the notification carries an id.
        product = await ProductApiService.getProductById(productId);
      } catch (error) {
        debugPrint('Failed to load product detail for $productId: $error');
      }
    }

    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productEntity: product),
      ),
    );
  }

  /// Builds a `ProductEntity` from notification data with safe defaults.
  ProductEntity _buildProductFromData(
    Map<String, dynamic> data, {
    String? notificationTitle,
    String? notificationBody,
  }) {
    final title =
        _firstNonEmptyString([
          data['title'],
          data['productTitle'],
          notificationTitle,
        ]) ??
        'Product';

    final productId =
        _firstNonEmptyString([
          data['productId'],
          data['product_id'],
          data['id'],
        ]) ??
        '';

    final description =
        _firstNonEmptyString([
          data['description'],
          data['body'],
          notificationBody,
        ]) ??
        '';

    return ProductModel(
      categoryId: _stringValue(data['categoryId']),
      colors: _parseColors(data['colors']),
      discountedPrice: _intValue(data['discountedPrice']),
      gender: _intValue(data['gender']),
      images: _parseStringList(data['images']),
      price: _intValue(data['price']),
      sizes: _parseStringList(data['sizes']),
      variants: const <ProductVariantEntity>[],
      productId: productId,
      salesNumber: _intValue(data['salesNumber']),
      title: title,
      description: description,
      ratings: _doubleValue(data['ratings']),
      reviews: const <ReviewEntity>[],
      totalReviews: _intValue(data['totalReviews']),
    );
  }

  /// Parses a list of colors from the payload into entity objects.
  List<ProductColorEntity> _parseColors(dynamic rawColors) {
    if (rawColors is List) {
      return rawColors
          .map((color) {
            if (color is Map<String, dynamic>) {
              final title = _stringValue(color['title']);
              final rgb = _parseIntList(color['rgb']);
              if (title.isEmpty && rgb.isEmpty) {
                return null;
              }

              return ProductColorEntity(title: title, rgb: rgb);
            }

            final colorText = color?.toString().trim() ?? '';
            if (colorText.isEmpty) {
              return null;
            }

            return ProductColorEntity(
              title: colorText,
              rgb: const [200, 200, 200],
            );
          })
          .whereType<ProductColorEntity>()
          .toList();
    }

    if (rawColors is String && rawColors.trim().isNotEmpty) {
      return [
        ProductColorEntity(title: rawColors.trim(), rgb: const [200, 200, 200]),
      ];
    }

    return const <ProductColorEntity>[];
  }

  /// Parses strings that may arrive as a List, a comma-separated String, or null.
  List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const <String>[];
  }

  /// Parses integer values safely.
  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Parses floating-point values safely.
  double _doubleValue(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  /// Parses RGB values coming from the payload.
  List<int> _parseIntList(dynamic value) {
    if (value is List) {
      return value.map((item) => _intValue(item)).toList();
    }
    return const <int>[];
  }

  /// Converts any payload value into a trimmed string.
  String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  /// Picks the first non-empty string from a list of candidates.
  String? _firstNonEmptyString(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _stringValue(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  /// Releases listeners when the service is no longer needed.
  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
  }
}
