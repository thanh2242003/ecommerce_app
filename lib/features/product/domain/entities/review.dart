class ReviewEntity {
  final String userId;
  final String userName;
  final String content;
  final double rating;

  ReviewEntity({
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
  });
}
