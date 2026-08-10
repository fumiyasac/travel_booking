import 'dart:async';

import '../core/database/app_database.dart';
import '../data/models/booking.dart';
import '../data/models/favorite_plan.dart';
import '../data/models/plan_filter.dart';
import '../data/models/travel_plan.dart';
import '../data/repositories/travel_plan_repository.dart';
import '../presentation/viewmodels/plan_list_viewmodel.dart';
import 'mock_data.dart';

class FakeInMemoryFavoritesStorage extends FavoritesStorage {
  final List<FavoritePlan> _favorites;

  FakeInMemoryFavoritesStorage({List<FavoritePlan>? initialFavorites})
      : _favorites = initialFavorites != null ? List.of(initialFavorites) : [];

  @override
  Future<List<FavoritePlan>> getAll() async => List.of(_favorites);

  @override
  Future<void> add(FavoritePlan plan) async {
    _favorites.removeWhere((f) => f.planId == plan.planId);
    _favorites.insert(0, plan);
  }

  @override
  Future<void> remove(String planId) async {
    _favorites.removeWhere((f) => f.planId == planId);
  }

  @override
  Future<void> clear() async => _favorites.clear();

  @override
  Future<bool> contains(String planId) async =>
      _favorites.any((f) => f.planId == planId);
}

final previewProviderOverrides = [
  favoritesStorageProvider.overrideWith(
    (ref) => FakeInMemoryFavoritesStorage(),
  ),
];

// ── FakeTravelPlanRepository ─────────────────────────────────────────────────

class FakeTravelPlanRepository implements TravelPlanRepository {
  final TravelPlan? plan;
  final bool throwError;
  final bool loading;

  const FakeTravelPlanRepository({
    this.plan,
    this.throwError = false,
    this.loading = false,
  });

  @override
  Future<TravelPlan> getPlan(String id) {
    if (loading) return Completer<TravelPlan>().future; // 意図的に未解決のまま保持
    if (throwError) throw Exception('Preview: データ取得エラー');
    return Future.value(plan ?? mockPlanTokyo);
  }

  @override
  Future<(List<TravelPlan>, int, bool, int)> getPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async =>
      (const <TravelPlan>[], 0, false, 1);

  @override
  Future<Booking> createBooking({
    required String planId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required int numberOfPeople,
    required DateTime travelDate,
    String? specialRequests,
    String? paymentMethod,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {}

  @override
  Future<List<Booking>> fetchBookings(String customerEmail) async =>
      const [];
}

/// PlanDetailScreen / PlanListScreen などの Screen Preview 用 override リスト。
/// [plan] を省略すると mockPlanTokyo を返す。
// ignore: always_declare_return_types
previewOverridesWith({
  TravelPlan? plan,
  bool throwError = false,
  bool loading = false,
}) =>
    [
      ...previewProviderOverrides,
      travelPlanRepositoryProvider.overrideWithValue(
        FakeTravelPlanRepository(
          plan: plan,
          throwError: throwError,
          loading: loading,
        ),
      ),
    ];
