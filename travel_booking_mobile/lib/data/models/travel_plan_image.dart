class TravelPlanImage {
  final String id;
  final String url;
  final String? caption;
  final bool isPrimary;
  final int displayOrder;

  const TravelPlanImage({
    required this.id,
    required this.url,
    this.caption,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory TravelPlanImage.fromJson(Map<String, dynamic> json) {
    return TravelPlanImage(
      id: json['id'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'caption': caption,
        'isPrimary': isPrimary,
        'displayOrder': displayOrder,
      };

  TravelPlanImage copyWith({
    String? id,
    String? url,
    String? caption,
    bool? isPrimary,
    int? displayOrder,
  }) {
    return TravelPlanImage(
      id: id ?? this.id,
      url: url ?? this.url,
      caption: caption ?? this.caption,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelPlanImage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
