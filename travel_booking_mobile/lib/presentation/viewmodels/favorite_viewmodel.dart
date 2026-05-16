import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/favorite_plan.dart';
import 'plan_list_viewmodel.dart';

part 'favorite_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

class FavoriteState {
  final List<FavoritePlan> favorites;
  final bool isLoading;
  final String? error;

  const FavoriteState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  bool get isEmpty => favorites.isEmpty && !isLoading;

  FavoriteState copyWith({
    List<FavoritePlan>? favorites,
    bool? isLoading,
    String? error,
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
  StreamSubscription<List<FavoritePlan>>? _subscription;

  @override
  FavoriteState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    _startWatching();
    return const FavoriteState(isLoading: true);
  }

  void _startWatching() {
    final repo = ref.read(favoriteRepositoryProvider);
    _subscription = repo.watchFavorites().listen(
      (favorites) {
        state = state.copyWith(favorites: favorites, isLoading: false);
      },
      onError: (Object e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  Future<void> removeFavorite(String planId) async {
    try {
      final repo = ref.read(favoriteRepositoryProvider);
      await repo.removeFavorite(planId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAll() async {
    try {
      final repo = ref.read(favoriteRepositoryProvider);
      for (final fav in List.of(state.favorites)) {
        await repo.removeFavorite(fav.planId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
