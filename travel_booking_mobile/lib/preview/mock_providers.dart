import '../core/database/app_database.dart';
import '../data/models/favorite_plan.dart';
import '../presentation/viewmodels/plan_list_viewmodel.dart';

class FakeInMemoryFavoritesStorage extends FavoritesStorage {
  final List<FavoritePlan> _favorites;

  FakeInMemoryFavoritesStorage({List<FavoritePlan>? initialFavorites})
      : _favorites =
            initialFavorites != null ? List.of(initialFavorites) : [];

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
