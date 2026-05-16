import 'travel_plan.dart';

class FavoritePlan {
  final String planId;
  final String title;
  final String destination;
  final String country;
  final double price;
  final double? discountPrice;
  final double effectivePrice;
  final double rating;
  final int durationDays;
  final String category;
  final String difficulty;
  final String primaryImageUrl;
  final String region;
  final DateTime savedAt;

  const FavoritePlan({
    required this.planId,
    required this.title,
    required this.destination,
    required this.country,
    required this.price,
    this.discountPrice,
    required this.effectivePrice,
    required this.rating,
    required this.durationDays,
    required this.category,
    required this.difficulty,
    required this.primaryImageUrl,
    required this.region,
    required this.savedAt,
  });

  factory FavoritePlan.fromTravelPlan(TravelPlan plan) => FavoritePlan(
        planId: plan.id,
        title: plan.title,
        destination: plan.destination,
        country: plan.country,
        price: plan.price,
        discountPrice: plan.discountPrice,
        effectivePrice: plan.effectivePrice,
        rating: plan.rating,
        durationDays: plan.durationDays,
        category: plan.category,
        difficulty: plan.difficulty,
        primaryImageUrl: plan.primaryImageUrl,
        region: plan.region,
        savedAt: DateTime.now(),
      );

  factory FavoritePlan.fromJson(Map<String, dynamic> json) => FavoritePlan(
        planId: json['planId'] as String,
        title: json['title'] as String,
        destination: json['destination'] as String,
        country: json['country'] as String,
        price: (json['price'] as num).toDouble(),
        discountPrice: json['discountPrice'] != null
            ? (json['discountPrice'] as num).toDouble()
            : null,
        effectivePrice: (json['effectivePrice'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        durationDays: json['durationDays'] as int,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        primaryImageUrl: json['primaryImageUrl'] as String,
        region: json['region'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'title': title,
        'destination': destination,
        'country': country,
        'price': price,
        'discountPrice': discountPrice,
        'effectivePrice': effectivePrice,
        'rating': rating,
        'durationDays': durationDays,
        'category': category,
        'difficulty': difficulty,
        'primaryImageUrl': primaryImageUrl,
        'region': region,
        'savedAt': savedAt.toIso8601String(),
      };
}
