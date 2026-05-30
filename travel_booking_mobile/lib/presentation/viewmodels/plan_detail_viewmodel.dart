import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/travel_plan.dart';
import 'plan_list_viewmodel.dart';

part 'plan_detail_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

class PlanDetailState {
  final TravelPlan? plan;
  final bool isLoading;
  final String? error;
  final bool isFavorite;
  final bool isFavoriteLoading;

  const PlanDetailState({
    this.plan,
    this.isLoading = false,
    this.error,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
  });

  PlanDetailState copyWith({
    TravelPlan? plan,
    bool? isLoading,
    String? error,
    bool? isFavorite,
    bool? isFavoriteLoading,
    bool clearError = false,
  }) {
    return PlanDetailState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isFavorite: isFavorite ?? this.isFavorite,
      isFavoriteLoading: isFavoriteLoading ?? this.isFavoriteLoading,
    );
  }
}

@riverpod
class PlanDetailViewModel extends _$PlanDetailViewModel {
  @override
  PlanDetailState build(String planId) {
    return const PlanDetailState(isLoading: true);
  }

  Future<void> loadPlan() async {
    if (state.isLoading && state.plan != null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(travelPlanRepositoryProvider);
      final favRepo = ref.read(favoriteRepositoryProvider);

      final results = await Future.wait([
        repo.getPlan(planId),
        favRepo.isFavorite(planId),
      ]);

      final plan = results[0] as TravelPlan;
      final isFav = results[1] as bool;

      state = state.copyWith(
        plan: plan,
        isLoading: false,
        isFavorite: isFav,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPlanById(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(travelPlanRepositoryProvider);
      final favRepo = ref.read(favoriteRepositoryProvider);

      final plan = await repo.getPlan(id);
      final isFav = await favRepo.isFavorite(id);

      state = state.copyWith(
        plan: plan,
        isLoading: false,
        isFavorite: isFav,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite() async {
    final plan = state.plan;
    if (plan == null || state.isFavoriteLoading) return;

    state = state.copyWith(isFavoriteLoading: true);

    try {
      final favRepo = ref.read(favoriteRepositoryProvider);

      if (state.isFavorite) {
        await favRepo.removeFavorite(plan.id);
        state = state.copyWith(isFavorite: false, isFavoriteLoading: false);
      } else {
        await favRepo.addFavorite(plan);
        state = state.copyWith(isFavorite: true, isFavoriteLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isFavoriteLoading: false,
        error: e.toString(),
      );
    }
  }
}
