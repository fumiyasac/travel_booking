import '../datasources/local/favorite_local_datasource.dart';
import '../models/favorite_plan.dart';
import '../models/travel_plan.dart';
import 'favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _localDataSource;

  const FavoriteRepositoryImpl(this._localDataSource);

  @override
  Stream<List<FavoritePlan>> watchFavorites() =>
      _localDataSource.watchFavorites();

  @override
  Future<List<FavoritePlan>> getFavorites() => _localDataSource.getFavorites();

  @override
  Future<bool> isFavorite(String planId) =>
      _localDataSource.isFavorite(planId);

  @override
  Future<void> addFavorite(TravelPlan plan) =>
      _localDataSource.addFavorite(plan);

  @override
  Future<void> removeFavorite(String planId) =>
      _localDataSource.removeFavorite(planId);

  @override
  Future<void> clearFavorites() => _localDataSource.deleteAllFavorites();
}
