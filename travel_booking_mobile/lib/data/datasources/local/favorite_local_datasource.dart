import 'dart:async';
import '../../../core/database/app_database.dart';
import '../../models/favorite_plan.dart';
import '../../models/travel_plan.dart';

class FavoriteLocalDataSource {
  final FavoritesStorage _storage;
  final _controller = StreamController<List<FavoritePlan>>.broadcast();

  FavoriteLocalDataSource(this._storage) {
    _emitCurrent();
  }

  Future<void> _emitCurrent() async {
    final favorites = await _storage.getAll();
    if (!_controller.isClosed) _controller.add(favorites);
  }

  Stream<List<FavoritePlan>> watchFavorites() {
    _emitCurrent();
    return _controller.stream;
  }

  Future<List<FavoritePlan>> getFavorites() => _storage.getAll();

  Future<bool> isFavorite(String planId) => _storage.contains(planId);

  Future<void> addFavorite(TravelPlan plan) async {
    await _storage.add(FavoritePlan.fromTravelPlan(plan));
    await _emitCurrent();
  }

  Future<void> removeFavorite(String planId) async {
    await _storage.remove(planId);
    await _emitCurrent();
  }

  Future<void> deleteAllFavorites() async {
    await _storage.clear();
    await _emitCurrent();
  }

  void dispose() => _controller.close();
}
