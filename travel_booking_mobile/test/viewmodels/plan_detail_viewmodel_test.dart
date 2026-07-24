import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/data/models/travel_plan.dart';
import 'package:travel_booking_mobile/data/repositories/favorite_repository.dart';
import 'package:travel_booking_mobile/data/repositories/travel_plan_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_detail_viewmodel.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_list_viewmodel.dart';

import 'plan_detail_viewmodel_test.mocks.dart';

@GenerateMocks([TravelPlanRepository, FavoriteRepository])
void main() {
  late MockTravelPlanRepository mockPlanRepository;
  late MockFavoriteRepository mockFavoriteRepository;
  late ProviderContainer container;

  const planId = 'plan-1';

  final mockPlan = TravelPlan(
    id: planId,
    title: '東京エクスプローラー5日間',
    description: '東京を探訪するツアー',
    destination: '東京',
    country: '日本',
    region: 'アジア',
    latitude: 35.6762,
    longitude: 139.6503,
    price: 150000,
    effectivePrice: 135000,
    discountPrice: 135000,
    durationDays: 5,
    maxParticipants: 12,
    currentBookings: 4,
    availableSpots: 8,
    category: 'city',
    difficulty: 'easy',
    rating: 4.7,
    reviewCount: 128,
    isAvailable: true,
    language: '日本語',
    tags: ['東京'],
    images: [],
    highlights: [],
    itinerary: [],
    includedItems: [],
    excludedItems: [],
    reviews: [],
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockPlanRepository = MockTravelPlanRepository();
    mockFavoriteRepository = MockFavoriteRepository();

    container = ProviderContainer(
      overrides: [
        travelPlanRepositoryProvider.overrideWithValue(mockPlanRepository),
        favoriteRepositoryProvider.overrideWithValue(mockFavoriteRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PlanDetailViewModel', () {
    test('initial state has isLoading true', () {
      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isLoading, isTrue);
      expect(state.plan, isNull);
    });

    test('loadPlanById loads plan and checks favorite status', () async {
      when(mockPlanRepository.getPlan(planId))
          .thenAnswer((_) async => mockPlan);
      when(mockFavoriteRepository.isFavorite(planId))
          .thenAnswer((_) async => false);

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .loadPlanById(planId);

      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isLoading, isFalse);
      expect(state.plan, isNotNull);
      expect(state.plan!.id, planId);
      expect(state.isFavorite, isFalse);
      expect(state.error, isNull);
    });

    test('loadPlanById marks plan as favorite when it is saved', () async {
      when(mockPlanRepository.getPlan(planId))
          .thenAnswer((_) async => mockPlan);
      when(mockFavoriteRepository.isFavorite(planId))
          .thenAnswer((_) async => true);

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .loadPlanById(planId);

      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isFavorite, isTrue);
    });

    test('loadPlanById sets error on plan repository failure', () async {
      when(mockPlanRepository.getPlan(planId))
          .thenThrow(Exception('Plan not found'));

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .loadPlanById(planId);

      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isLoading, isFalse);
      expect(state.plan, isNull);
      expect(state.error, isNotNull);
      expect(state.error, contains('Plan not found'));
    });

    test('toggleFavorite adds to favorites when not favorited', () async {
      when(mockPlanRepository.getPlan(planId))
          .thenAnswer((_) async => mockPlan);
      when(mockFavoriteRepository.isFavorite(planId))
          .thenAnswer((_) async => false);
      when(mockFavoriteRepository.addFavorite(any)).thenAnswer((_) async {});

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .loadPlanById(planId);

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .toggleFavorite();

      verify(mockFavoriteRepository.addFavorite(any)).called(1);
      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isFavorite, isTrue);
      expect(state.isFavoriteLoading, isFalse);
    });

    test('toggleFavorite removes from favorites when already favorited',
        () async {
      when(mockPlanRepository.getPlan(planId))
          .thenAnswer((_) async => mockPlan);
      when(mockFavoriteRepository.isFavorite(planId))
          .thenAnswer((_) async => true);
      when(mockFavoriteRepository.removeFavorite(planId))
          .thenAnswer((_) async {});

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .loadPlanById(planId);

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .toggleFavorite();

      verify(mockFavoriteRepository.removeFavorite(planId)).called(1);
      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isFavorite, isFalse);
    });

    test('toggleFavorite sets error when repository fails', () async {
      when(mockPlanRepository.getPlan(planId))
          .thenAnswer((_) async => mockPlan);
      when(mockFavoriteRepository.isFavorite(planId))
          .thenAnswer((_) async => false);
      when(mockFavoriteRepository.addFavorite(any))
          .thenThrow(Exception('DB error'));

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .loadPlanById(planId);

      await container
          .read(planDetailViewModelProvider(planId).notifier)
          .toggleFavorite();

      final state = container.read(planDetailViewModelProvider(planId));
      expect(state.isFavoriteLoading, isFalse);
      expect(state.error, isNotNull);
    });
  });
}
