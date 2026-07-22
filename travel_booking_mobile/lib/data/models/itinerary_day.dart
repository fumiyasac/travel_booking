import 'itinerary_activity.dart';

class ItineraryDay {
  final String id;
  final int dayNumber;
  final String title;
  final String description;
  final String? accommodation;
  final String meals;
  final List<ItineraryActivity> activities;

  const ItineraryDay({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    this.accommodation,
    required this.meals,
    required this.activities,
  });

  List<String> get mealList =>
      meals.isEmpty ? [] : meals.split(',').map((m) => m.trim()).toList();

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      accommodation: json['accommodation'] as String?,
      meals: json['meals'] as String? ?? '',
      activities: (json['activities'] as List<dynamic>?)
              ?.map(
                  (a) => ItineraryActivity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayNumber': dayNumber,
        'title': title,
        'description': description,
        'accommodation': accommodation,
        'meals': meals,
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  ItineraryDay copyWith({
    String? id,
    int? dayNumber,
    String? title,
    String? description,
    String? accommodation,
    String? meals,
    List<ItineraryActivity>? activities,
  }) {
    return ItineraryDay(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      accommodation: accommodation ?? this.accommodation,
      meals: meals ?? this.meals,
      activities: activities ?? this.activities,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryDay &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
