class UserReviewItem {
  final String productId;
  final String title;
  final String? image;
  final String? reviewId;
  final String content;
  final double rating;
  final String? orderId;
  final DateTime? createdAt;

  const UserReviewItem({
    required this.productId,
    required this.title,
    required this.content,
    required this.rating,
    this.image,
    this.reviewId,
    this.orderId,
    this.createdAt,
  });

  factory UserReviewItem.fromJson(Map<String, dynamic> json) {
    final review = json['review'];
    final reviewMap = review is Map<String, dynamic>
        ? review
        : const <String, dynamic>{};

    String readString(List<String> keys) {
      for (final source in [json, reviewMap]) {
        for (final key in keys) {
          final value = source[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString();
          }
        }
      }
      return '';
    }

    double readDouble(List<String> keys) {
      for (final source in [json, reviewMap]) {
        for (final key in keys) {
          final value = source[key];
          if (value is num) {
            return value.toDouble();
          }
          final parsed = double.tryParse(value?.toString() ?? '');
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return 0;
    }

    DateTime? readDate(List<String> keys) {
      for (final source in [json, reviewMap]) {
        for (final key in keys) {
          final value = source[key];
          if (value == null) {
            continue;
          }

          final parsed = DateTime.tryParse(value.toString());
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return null;
    }

    final imageValue = readString(['image', 'imageUrl']);
    final reviewIdValue = readString(['reviewId', '_id', 'id']);
    final orderIdValue = readString(['orderId', 'order_id']);

    return UserReviewItem(
      productId: readString(['productId', 'product_id']),
      title: readString(['title', 'productTitle', 'productName', 'name']),
      image: imageValue.isEmpty ? null : imageValue,
      reviewId: reviewIdValue.isEmpty ? null : reviewIdValue,
      content: readString(['content', 'text', 'comment']),
      rating: readDouble(['rating', 'stars']),
      orderId: orderIdValue.isEmpty ? null : orderIdValue,
      createdAt: readDate(['createdAt', 'created_at']),
    );
  }
}
