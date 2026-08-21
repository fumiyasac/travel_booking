import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/data/datasources/local/recently_viewed_local_data_source.dart';
import 'package:travel_booking_mobile/data/models/travel_plan.dart';
import 'package:travel_booking_mobile/data/repositories/recently_viewed_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_list_viewmodel.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/recently_viewed_viewmodel.dart';

import 'recently_viewed_viewmodel_test.mocks.dart';

@GenerateMocks([RecentlyViewedRepository, RecentlyViewedLocalDataSource])
void main() {
  late MockRecentlyViewedRepository mockRepository;
  late MockRecentlyViewedLocalDataSource mockDataSource;
  late ProviderContainer container;
  late StreamController<List<String>> idsController;

  final mockPlan1 = TravelPlan(
    id: 'plan-1',
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

  final mockPlan2 = TravelPlan(
    id: 'plan-2',
    title: '京都伝統文化探訪4日間',
    description: '京都の文化を探訪するツアー',
    destination: '京都',
    country: '日本',
    region: 'アジア',
    latitude: 35.0116,
    longitude: 135.7681,
    price: 120000,
    effectivePrice: 120000,
    durationDays: 4,
    maxParticipants: 10,
    currentBookings: 7,
    availableSpots: 3,
    category: 'cultural',
    difficulty: 'easy',
    rating: 4.9,
    reviewCount: 215,
    isAvailable: true,
    language: '日本語',
    tags: ['京都'],
    images: [],
    highlights: [],
    itinerary: [],
    includedItems: [],
    excludedItems: [],
    reviews: [],
    createdAt: DateTime(2024, 1, 2),
  );

  setUp(() {
    mockRepository = MockRecentlyViewedRepository();
    mockDataSource = MockRecentlyViewedLocalDataSource();
    idsController = StreamController<List<String>>.broadcast();

    when(mockDataSource.watchRecentlyViewed())
        .thenAnswer((_) => idsController.stream);

    container = ProviderContainer(
      overrides: [
        recentlyViewedLocalDataSourceProvider.overrideWithValue(mockDataSource),
        recentlyViewedRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    idsController.close();
  });

  group('RecentlyViewedViewModel', () {
    test('initial state has isLoading true and empty plans', () {
      final state = container.read(recentlyViewedViewModelProvider);
      expect(state.isLoading, isTrue);
      expect(state.plans, isEmpty);
      expect(state.error, isNull);
    });

    test('plans list populates when stream emits ids', () async {
      when(mockRepository.getRecentlyViewedPlans())
          .thenAnswer((_) async => [mockPlan1, mockPlan2]);

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});

      idsController.add(['plan-1', 'plan-2']);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      final state = container.read(recentlyViewedViewModelProvider);
      expect(state.plans.length, 2);
      expect(state.isLoading, isFalse);
      expect(state.plans[0].id, 'plan-1');
      expect(state.plans[1].id, 'plan-2');
      sub.close();
    });

    test('isEmpty returns true when stream emits empty list', () async {
      when(mockRepository.getRecentlyViewedPlans()).thenAnswer((_) async => []);

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});

      idsController.add([]);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      final state = container.read(recentlyViewedViewModelProvider);
      expect(state.isEmpty, isTrue);
      expect(state.plans, isEmpty);
      expect(state.isLoading, isFalse);
      sub.close();
    });

    test('sets error when getRecentlyViewedPlans throws', () async {
      when(mockRepository.getRecentlyViewedPlans())
          .thenThrow(Exception('Network error'));

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});

      idsController.add(['plan-1']);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      final state = container.read(recentlyViewedViewModelProvider);
      expect(state.error, isNotNull);
      expect(state.error!.message, contains('Network error'));
      expect(state.isLoading, isFalse);
      sub.close();
    });

    test('clearHistory calls repository and clears plans after stream updates',
        () async {
      when(mockRepository.getRecentlyViewedPlans())
          .thenAnswer((_) async => [mockPlan1]);
      when(mockRepository.clearHistory()).thenAnswer((_) async {});

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});

      // Populate plans
      idsController.add(['plan-1']);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      expect(container.read(recentlyViewedViewModelProvider).plans.length, 1);

      // Clear history
      await container
          .read(recentlyViewedViewModelProvider.notifier)
          .clearHistory();

      verify(mockRepository.clearHistory()).called(1);

      // Simulate stream emitting empty after clear
      when(mockRepository.getRecentlyViewedPlans()).thenAnswer((_) async => []);
      idsController.add([]);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      final state = container.read(recentlyViewedViewModelProvider);
      expect(state.plans, isEmpty);
      sub.close();
    });

    test('clearHistory sets error on failure', () async {
      when(mockRepository.clearHistory()).thenThrow(Exception('DB error'));

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});
      idsController.add([]);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      await container
          .read(recentlyViewedViewModelProvider.notifier)
          .clearHistory();

      final state = container.read(recentlyViewedViewModelProvider);
      expect(state.error, isNotNull);
      sub.close();
    });

    test('clearError removes error state', () async {
      when(mockRepository.clearHistory()).thenThrow(Exception('error'));

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});
      idsController.add([]);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      await container
          .read(recentlyViewedViewModelProvider.notifier)
          .clearHistory();
      expect(container.read(recentlyViewedViewModelProvider).error, isNotNull);

      container.read(recentlyViewedViewModelProvider.notifier).clearError();
      expect(container.read(recentlyViewedViewModelProvider).error, isNull);
      sub.close();
    });

    test('plans list updates reactively on multiple stream emissions',
        () async {
      when(mockRepository.getRecentlyViewedPlans())
          .thenAnswer((_) async => [mockPlan1]);

      final sub = container.listen(recentlyViewedViewModelProvider, (_, __) {});

      idsController.add(['plan-1']);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      expect(container.read(recentlyViewedViewModelProvider).plans.length, 1);

      when(mockRepository.getRecentlyViewedPlans())
          .thenAnswer((_) async => [mockPlan2, mockPlan1]);
      idsController.add(['plan-2', 'plan-1']);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      expect(container.read(recentlyViewedViewModelProvider).plans.length, 2);
      expect(container.read(recentlyViewedViewModelProvider).plans[0].id,
          'plan-2');
      sub.close();
    });
  });
}
