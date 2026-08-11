import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/error/app_error.dart';
import '../../data/models/favorite_plan.dart';
import 'plan_list_viewmodel.dart';

part 'favorite_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

class FavoriteState {
  final List<FavoritePlan> favorites;
  final bool isLoading;
  final AppError? error;

  const FavoriteState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  bool get isEmpty => favorites.isEmpty && !isLoading;

  FavoriteState copyWith({
    List<FavoritePlan>? favorites,
    bool? isLoading,
    AppError? error,
    bool clearError = false,
  }) {
    return FavoriteState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class FavoriteViewModel extends _$FavoriteViewModel {
  @override
  FavoriteState build() {
    // ref.watch keeps favoriteLocalDataSourceProvider alive while this ViewModel
    // is active, so all callers (plan detail, etc.) share the same StreamController
    // instance and stream events are correctly propagated here.
    final dataSource = ref.watch(favoriteLocalDataSourceProvider);

    final subscription = dataSource.watchFavorites().listen(
      (favorites) {
        state = state.copyWith(favorites: favorites, isLoading: false);
      },
      onError: (Object e) {
        state = state.copyWith(
          isLoading: false,
          error: e is AppError ? e : UnknownError(e.toString()),
        );
      },
    );

    ref.onDispose(subscription.cancel);
    return const FavoriteState(isLoading: true);
  }

  Future<void> removeFavorite(String planId) async {
    try {
      final repo = ref.read(favoriteRepositoryProvider);
      await repo.removeFavorite(planId);
    } catch (e) {
      state = state.copyWith(error: e is AppError ? e : UnknownError(e.toString()));
    }
  }

  Future<void> clearAll() async {
    try {
      // Single atomic operation instead of N sequential removeFavorite calls
      final repo = ref.read(favoriteRepositoryProvider);
      await repo.clearFavorites();
    } catch (e) {
      state = state.copyWith(error: e is AppError ? e : UnknownError(e.toString()));
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
