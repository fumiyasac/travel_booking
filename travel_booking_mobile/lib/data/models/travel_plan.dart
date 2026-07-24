import 'travel_plan_image.dart';
import 'itinerary_day.dart';
import 'review.dart';

class TravelPlan {
  final String id;
  final String title;
  final String description;
  final String destination;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final double price;
  final double? discountPrice;
  final double effectivePrice;
  final int durationDays;
  final int maxParticipants;
  final int currentBookings;
  final int availableSpots;
  final String category;
  final String difficulty;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final String language;
  final String meetingPoint;
  final String cancellationPolicy;
  final int? minimumAge;
  final List<String> tags;
  final List<TravelPlanImage> images;
  final List<String> highlights;
  final List<ItineraryDay> itinerary;
  final List<String> includedItems;
  final List<String> excludedItems;
  final List<Review> reviews;
  final DateTime createdAt;

  const TravelPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.price,
    this.discountPrice,
    required this.effectivePrice,
    required this.durationDays,
    required this.maxParticipants,
    required this.currentBookings,
    required this.availableSpots,
    required this.category,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.availableFrom,
    this.availableTo,
    required this.language,
    this.meetingPoint = '',
    this.cancellationPolicy = '',
    this.minimumAge,
    required this.tags,
    required this.images,
    required this.highlights,
    required this.itinerary,
    required this.includedItems,
    required this.excludedItems,
    required this.reviews,
    required this.createdAt,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  String get primaryImageUrl {
    if (images.isEmpty) return '';
    return images
        .firstWhere(
          (img) => img.isPrimary,
          orElse: () => images.first,
        )
        .url;
  }

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      destination: json['destination'] as String,
      country: json['country'] as String,
      region: json['region'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      effectivePrice: (json['effectivePrice'] as num?)?.toDouble() ??
          (json['discountPrice'] as num?)?.toDouble() ??
          (json['price'] as num).toDouble(),
      durationDays: json['durationDays'] as int,
      maxParticipants: json['maxParticipants'] as int,
      currentBookings: json['currentBookings'] as int? ?? 0,
      availableSpots: json['availableSpots'] as int? ??
          ((json['maxParticipants'] as int) -
              (json['currentBookings'] as int? ?? 0)),
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      availableFrom: json['availableFrom'] != null
          ? DateTime.tryParse(json['availableFrom'] as String)
          : null,
      availableTo: json['availableTo'] != null
          ? DateTime.tryParse(json['availableTo'] as String)
          : null,
      language: json['language'] as String? ?? '日本語',
      meetingPoint: json['meetingPoint'] as String? ?? '',
      cancellationPolicy: json['cancellationPolicy'] as String? ?? '',
      minimumAge: json['minimumAge'] as int?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ??
              [],
      images: (json['images'] as List<dynamic>?)
              ?.map((img) =>
                  TravelPlanImage.fromJson(img as Map<String, dynamic>))
              .toList() ??
          [],
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => (h as Map<String, dynamic>)['text'] as String)
              .toList() ??
          [],
      itinerary: (json['itinerary'] as List<dynamic>?)
              ?.map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      includedItems: (json['includedItems'] as List<dynamic>?)
              ?.map((item) => (item as Map<String, dynamic>)['item'] as String)
              .toList() ??
          [],
      excludedItems: (json['excludedItems'] as List<dynamic>?)
              ?.map((item) => (item as Map<String, dynamic>)['item'] as String)
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'destination': destination,
        'country': country,
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
        'price': price,
        'discountPrice': discountPrice,
        'effectivePrice': effectivePrice,
        'durationDays': durationDays,
        'maxParticipants': maxParticipants,
        'currentBookings': currentBookings,
        'availableSpots': availableSpots,
        'category': category,
        'difficulty': difficulty,
        'rating': rating,
        'reviewCount': reviewCount,
        'isAvailable': isAvailable,
        'availableFrom': availableFrom?.toIso8601String(),
        'availableTo': availableTo?.toIso8601String(),
        'language': language,
        'meetingPoint': meetingPoint,
        'cancellationPolicy': cancellationPolicy,
        'minimumAge': minimumAge,
        'tags': tags,
        'images': images.map((img) => img.toJson()).toList(),
        'highlights': highlights.map((h) => {'text': h}).toList(),
        'itinerary': itinerary.map((d) => d.toJson()).toList(),
        'includedItems': includedItems.map((item) => {'item': item}).toList(),
        'excludedItems': excludedItems.map((item) => {'item': item}).toList(),
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  TravelPlan copyWith({
    String? id,
    String? title,
    String? description,
    String? destination,
    String? country,
    String? region,
    double? latitude,
    double? longitude,
    double? price,
    double? discountPrice,
    double? effectivePrice,
    int? durationDays,
    int? maxParticipants,
    int? currentBookings,
    int? availableSpots,
    String? category,
    String? difficulty,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    DateTime? availableFrom,
    DateTime? availableTo,
    String? language,
    String? meetingPoint,
    String? cancellationPolicy,
    int? minimumAge,
    List<String>? tags,
    List<TravelPlanImage>? images,
    List<String>? highlights,
    List<ItineraryDay>? itinerary,
    List<String>? includedItems,
    List<String>? excludedItems,
    List<Review>? reviews,
    DateTime? createdAt,
  }) {
    return TravelPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      effectivePrice: effectivePrice ?? this.effectivePrice,
      durationDays: durationDays ?? this.durationDays,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentBookings: currentBookings ?? this.currentBookings,
      availableSpots: availableSpots ?? this.availableSpots,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      language: language ?? this.language,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      minimumAge: minimumAge ?? this.minimumAge,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      highlights: highlights ?? this.highlights,
      itinerary: itinerary ?? this.itinerary,
      includedItems: includedItems ?? this.includedItems,
      excludedItems: excludedItems ?? this.excludedItems,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelPlan && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TravelPlan(id: $id, title: $title)';
}
