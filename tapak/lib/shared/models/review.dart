class Review {
  final String id;
  final String placeId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime? visitDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined
  final String? userDisplayName;
  final String? userAvatarUrl;

  const Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.rating,
    this.comment,
    this.visitDate,
    required this.createdAt,
    required this.updatedAt,
    this.userDisplayName,
    this.userAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profiles'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userDisplayName: profileJson?['display_name'] as String?,
      userAvatarUrl: profileJson?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'place_id': placeId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
        'visit_date': visitDate?.toIso8601String().split('T').first,
      };
}
