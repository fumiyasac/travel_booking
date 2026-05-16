class Review {
  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime travelDate;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.travelDate,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      reviewerName: json['reviewerName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      travelDate: DateTime.parse(json['travelDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reviewerName': reviewerName,
        'rating': rating,
        'comment': comment,
        'travelDate': travelDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  Review copyWith({
    String? id,
    String? reviewerName,
    double? rating,
    String? comment,
    DateTime? travelDate,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      reviewerName: reviewerName ?? this.reviewerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      travelDate: travelDate ?? this.travelDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
