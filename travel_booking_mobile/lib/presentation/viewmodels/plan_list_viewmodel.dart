import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/graphql_config.dart';
import '../../core/database/app_database.dart';
import '../../data/datasources/local/favorite_local_datasource.dart';
import '../../data/datasources/remote/travel_plan_remote_datasource.dart';
import '../../data/models/plan_filter.dart';
import '../../data/models/travel_plan.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../data/repositories/travel_plan_repository.dart';
import '../../data/repositories/travel_plan_repository_impl.dart';

part 'plan_list_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

// --- Providers ---

@Riverpod(keepAlive: true)
FavoritesStorage favoritesStorage(Ref ref) {
  return FavoritesStorage();
}

@riverpod
GraphQLHttpClient graphQLHttpClient(Ref ref) {
  final client = GraphQLHttpClient();
  ref.onDispose(client.dispose);
  return client;
}

@riverpod
TravelPlanRemoteDataSource travelPlanRemoteDataSource(Ref ref) {
  return TravelPlanRemoteDataSource(ref.watch(graphQLHttpClientProvider));
}

@riverpod
TravelPlanRepository travelPlanRepository(Ref ref) {
  return TravelPlanRepositoryImpl(ref.watch(travelPlanRemoteDataSourceProvider));
}

@Riverpod(keepAlive: true)
FavoriteLocalDataSource favoriteLocalDataSource(Ref ref) {
  final ds = FavoriteLocalDataSource(ref.watch(favoritesStorageProvider));
  ref.onDispose(ds.dispose);
  return ds;
}

@Riverpod(keepAlive: true)
FavoriteRepository favoriteRepository(Ref ref) {
  return FavoriteRepositoryImpl(ref.watch(favoriteLocalDataSourceProvider));
}

// autoDispose: カード単位で必要な間だけ生存すれば十分
@riverpod
Stream<bool> planIsFavorite(Ref ref, String planId) {
  final dataSource = ref.watch(favoriteLocalDataSourceProvider);
  return dataSource
      .watchFavorites()
      .map((favorites) => favorites.any((f) => f.planId == planId));
}

// --- State ---

class PlanListState {
  final List<TravelPlan> plans;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PlanFilter filter;
  final int currentPage;
  final bool hasNextPage;
  final int totalCount;
  final int totalPages;

  const PlanListState({
    this.plans = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filter = const PlanFilter(),
    this.currentPage = 1,
    this.hasNextPage = false,
    this.totalCount = 0,
    this.totalPages = 1,
  });

  PlanListState copyWith({
    List<TravelPlan>? plans,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PlanFilter? filter,
    int? currentPage,
    bool? hasNextPage,
    int? totalCount,
    int? totalPages,
    bool clearError = false,
  }) {
    return PlanListState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// --- ViewModel ---

@riverpod
class PlanListViewModel extends _$PlanListViewModel {
  static const int _pageSize = 20;

  @override
  PlanListState build() {
    return const PlanListState();
  }

  Future<void> loadPlans({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      plans: refresh ? [] : state.plans,
      currentPage: 1,
    );

    try {
      final repo = ref.read(travelPlanRepositoryProvider);
      final (plans, totalCount, hasNextPage, totalPages) = await repo.getPlans(
        filter: state.filter,
        page: 1,
        pageSize: _pageSize,
      );

      state = state.copyWith(
        plans: plans,
        totalCount: totalCount,
        hasNextPage: hasNextPage,
        totalPages: totalPages,
        currentPage: 1,
        isLoading: false,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('[PlanListVM] loadPlans error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasNextPage || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(travelPlanRepositoryProvider);
      final nextPage = state.currentPage + 1;
      final (newPlans, totalCount, hasNextPage, totalPages) = await repo.getPlans(
        filter: state.filter,
        page: nextPage,
        pageSize: _pageSize,
      );

      state = state.copyWith(
        plans: [...state.plans, ...newPlans],
        totalCount: totalCount,
        hasNextPage: hasNextPage,
        totalPages: totalPages,
        currentPage: nextPage,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateFilter(PlanFilter filter) async {
    state = state.copyWith(filter: filter);
    await loadPlans(refresh: true);
  }

  Future<void> updateKeyword(String keyword) async {
    final newFilter = keyword.isEmpty
        ? state.filter.copyWith(clearKeyword: true)
        : state.filter.copyWith(keyword: keyword);
    await updateFilter(newFilter);
  }

  Future<void> resetFilter() async {
    await updateFilter(const PlanFilter());
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
