import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/data/models/plan_filter.dart';
import 'package:travel_booking_mobile/data/models/travel_plan.dart';
import 'package:travel_booking_mobile/data/repositories/travel_plan_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_list_viewmodel.dart';

import 'plan_list_viewmodel_test.mocks.dart';

@GenerateMocks([TravelPlanRepository])
void main() {
  late MockTravelPlanRepository mockRepository;
  late ProviderContainer container;

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
    tags: ['東京', '都市'],
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
    tags: ['京都', '文化'],
    images: [],
    highlights: [],
    itinerary: [],
    includedItems: [],
    excludedItems: [],
    reviews: [],
    createdAt: DateTime(2024, 1, 2),
  );

  setUp(() {
    mockRepository = MockTravelPlanRepository();
    container = ProviderContainer(
      overrides: [
        travelPlanRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PlanListViewModel', () {
    test('initial state has empty plans and no loading', () {
      final state = container.read(planListViewModelProvider);
      expect(state.plans, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.error, isNull);
      expect(state.filter, const PlanFilter());
      expect(state.currentPage, 1);
      expect(state.hasNextPage, isFalse);
      expect(state.totalCount, 0);
    });

    test('loadPlans sets isLoading to true then false on success', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer(
        (_) async => ([mockPlan1, mockPlan2], 2, false, 1),
      );

      final notifier = container.read(planListViewModelProvider.notifier);
      final future = notifier.loadPlans();

      await future;

      final state = container.read(planListViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.plans.length, 2);
      expect(state.totalCount, 2);
      expect(state.hasNextPage, isFalse);
    });

    test('loadPlans populates plans correctly', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan1, mockPlan2], 2, false, 1));

      await container.read(planListViewModelProvider.notifier).loadPlans();

      final state = container.read(planListViewModelProvider);
      expect(state.plans[0].id, 'plan-1');
      expect(state.plans[1].id, 'plan-2');
      expect(state.plans[0].title, '東京エクスプローラー5日間');
    });

    test('loadPlans sets error on failure', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenThrow(Exception('Network error'));

      await container.read(planListViewModelProvider.notifier).loadPlans();

      final state = container.read(planListViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.plans, isEmpty);
      expect(state.error, isNotNull);
      expect(state.error, contains('Network error'));
    });

    test('updateFilter updates filter and triggers reload', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan1], 1, false, 1));

      const newFilter = PlanFilter(category: 'city', region: 'アジア');
      await container.read(planListViewModelProvider.notifier).updateFilter(newFilter);

      final state = container.read(planListViewModelProvider);
      expect(state.filter.category, 'city');
      expect(state.filter.region, 'アジア');
      expect(state.plans.length, 1);
    });

    test('resetFilter resets to default filter', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan1, mockPlan2], 2, false, 1));

      const customFilter = PlanFilter(category: 'city');
      await container.read(planListViewModelProvider.notifier).updateFilter(customFilter);

      await container.read(planListViewModelProvider.notifier).resetFilter();

      final state = container.read(planListViewModelProvider);
      expect(state.filter, const PlanFilter());
    });

    test('loadMore appends new plans to existing list', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: 1,
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan1], 2, true, 2));

      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: 2,
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan2], 2, false, 2));

      await container.read(planListViewModelProvider.notifier).loadPlans();
      await container.read(planListViewModelProvider.notifier).loadMore();

      final state = container.read(planListViewModelProvider);
      expect(state.plans.length, 2);
      expect(state.plans[0].id, 'plan-1');
      expect(state.plans[1].id, 'plan-2');
      expect(state.currentPage, 2);
      expect(state.hasNextPage, isFalse);
    });

    test('loadMore does not load when hasNextPage is false', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan1, mockPlan2], 2, false, 1));

      await container.read(planListViewModelProvider.notifier).loadPlans();

      expect(container.read(planListViewModelProvider).hasNextPage, isFalse);

      await container.read(planListViewModelProvider.notifier).loadMore();

      verify(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).called(1);
    });

    test('updateKeyword updates filter keyword and reloads', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => ([mockPlan1], 1, false, 1));

      await container.read(planListViewModelProvider.notifier).updateKeyword('東京');

      final state = container.read(planListViewModelProvider);
      expect(state.filter.keyword, '東京');
    });

    test('clearError clears the error state', () async {
      when(mockRepository.getPlans(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenThrow(Exception('error'));

      await container.read(planListViewModelProvider.notifier).loadPlans();
      expect(container.read(planListViewModelProvider).error, isNotNull);

      container.read(planListViewModelProvider.notifier).clearError();
      expect(container.read(planListViewModelProvider).error, isNull);
    });
  });
}
