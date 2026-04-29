class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final parsedType = (json['noti_type'] ?? json['type'] ?? 'system')
        .toString()
        .toLowerCase();

    final normalizedType =
        {'order', 'promo', 'system', 'test'}.contains(parsedType)
        ? parsedType
        : 'system';

    final rawIsRead = json['noti_isRead'] ?? json['isRead'] ?? false;

    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: (json['noti_userId'] ?? json['userId'] ?? '').toString(),
      title: (json['noti_title'] ?? json['title'] ?? '').toString(),
      body: (json['noti_body'] ?? json['body'] ?? '').toString(),
      type: normalizedType,
      isRead: rawIsRead == true || rawIsRead.toString().toLowerCase() == 'true',
      createdAt:
          DateTime.tryParse(
            (json['createdAt'] ?? json['noti_createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      data: rawData is Map<String, dynamic> ? rawData : <String, dynamic>{},
    );
  }
}
