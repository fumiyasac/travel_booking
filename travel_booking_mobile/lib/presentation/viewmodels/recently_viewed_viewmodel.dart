import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/error/app_error.dart';
import '../../data/models/travel_plan.dart';
import 'plan_list_viewmodel.dart';

part 'recently_viewed_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

class RecentlyViewedState {
  final List<TravelPlan> plans;
  final bool isLoading;
  final AppError? error;

  const RecentlyViewedState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
  });

  bool get isEmpty => plans.isEmpty && !isLoading;

  RecentlyViewedState copyWith({
    List<TravelPlan>? plans,
    bool? isLoading,
    AppError? error,
    bool clearError = false,
  }) {
    return RecentlyViewedState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class RecentlyViewedViewModel extends _$RecentlyViewedViewModel {
  @override
  RecentlyViewedState build() {
    final dataSource = ref.watch(recentlyViewedLocalDataSourceProvider);

    final subscription = dataSource.watchRecentlyViewed().listen(
      (ids) async {
        try {
          final repo = ref.read(recentlyViewedRepositoryProvider);
          final plans = await repo.getRecentlyViewedPlans();
          state = state.copyWith(plans: plans, isLoading: false);
        } catch (e) {
          state = state.copyWith(
            isLoading: false,
            error: e is AppError ? e : UnknownError(e.toString()),
          );
        }
      },
      onError: (Object e) {
        state = state.copyWith(
          isLoading: false,
          error: e is AppError ? e : UnknownError(e.toString()),
        );
      },
    );

    ref.onDispose(subscription.cancel);
    return const RecentlyViewedState(isLoading: true);
  }

  Future<void> clearHistory() async {
    try {
      final repo = ref.read(recentlyViewedRepositoryProvider);
      await repo.clearHistory();
    } catch (e) {
      state =
          state.copyWith(error: e is AppError ? e : UnknownError(e.toString()));
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
