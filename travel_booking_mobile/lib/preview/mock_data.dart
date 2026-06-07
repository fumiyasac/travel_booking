import '../data/models/travel_plan.dart';
import '../data/models/travel_plan_image.dart';

TravelPlan _makePlan({
  required String id,
  required String title,
  required String destination,
  required String country,
  required String category,
  required String difficulty,
  required double rating,
  required int reviewCount,
  required double price,
  double? discountPrice,
  required int durationDays,
  required String imagePhotoId,
}) {
  final effectivePrice = discountPrice ?? price;
  return TravelPlan(
    id: id,
    title: title,
    description: 'プレビュー用のサンプル説明文です。',
    destination: destination,
    country: country,
    region: 'サンプル地域',
    latitude: 35.0,
    longitude: 135.0,
    price: price,
    discountPrice: discountPrice,
    effectivePrice: effectivePrice,
    durationDays: durationDays,
    maxParticipants: 20,
    currentBookings: 5,
    availableSpots: 15,
    category: category,
    difficulty: difficulty,
    rating: rating,
    reviewCount: reviewCount,
    isAvailable: true,
    language: '日本語',
    tags: const [],
    images: [
      TravelPlanImage(
        id: '${id}_img',
        url:
            'https://images.unsplash.com/photo-$imagePhotoId?auto=format&fit=crop&w=800&q=60',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    highlights: const [],
    itinerary: const [],
    includedItems: const [],
    excludedItems: const [],
    reviews: const [],
    createdAt: DateTime(2025, 4, 1),
  );
}

final mockPlanTokyo = _makePlan(
  id: 'mock_tokyo',
  title: '東京エクスプローラー5日間',
  destination: '東京',
  country: '日本',
  category: 'city',
  difficulty: 'easy',
  rating: 4.8,
  reviewCount: 128,
  price: 150000,
  durationDays: 5,
  imagePhotoId: '1540959733332-eab4deabeeaf',
);

final mockPlanParis = _makePlan(
  id: 'mock_paris',
  title: 'パリ・ロマンス＆カルチャー6日間',
  destination: 'パリ',
  country: 'フランス',
  category: 'cultural',
  difficulty: 'moderate',
  rating: 4.5,
  reviewCount: 96,
  price: 320000,
  discountPrice: 268000,
  durationDays: 6,
  imagePhotoId: '1511739001486-6bfe10ce785f',
);

final mockPlanHimalayas = _makePlan(
  id: 'mock_himalayas',
  title: 'ヒマラヤ山岳トレッキング10日間',
  destination: 'カトマンズ',
  country: 'ネパール',
  category: 'adventure',
  difficulty: 'hard',
  rating: 4.9,
  reviewCount: 43,
  price: 480000,
  durationDays: 10,
  imagePhotoId: '1464822759023-fed622ff2c3b',
);
