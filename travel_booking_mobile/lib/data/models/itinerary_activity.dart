class ItineraryActivity {
  final String id;
  final String name;
  final String? startTime;
  final String duration;
  final String description;
  final String? location;

  const ItineraryActivity({
    required this.id,
    required this.name,
    this.startTime,
    required this.duration,
    required this.description,
    this.location,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: json['startTime'] as String?,
      duration: json['duration'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startTime': startTime,
        'duration': duration,
        'description': description,
        'location': location,
      };

  ItineraryActivity copyWith({
    String? id,
    String? name,
    String? startTime,
    String? duration,
    String? description,
    String? location,
  }) {
    return ItineraryActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
