import '../../core/error/app_error.dart';
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
  Future<List<FavoritePlan>> getFavorites() async {
    try {
      return await _localDataSource.getFavorites();
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<bool> isFavorite(String planId) async {
    try {
      return await _localDataSource.isFavorite(planId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<void> addFavorite(TravelPlan plan) async {
    try {
      return await _localDataSource.addFavorite(plan);
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<void> removeFavorite(String planId) async {
    try {
      return await _localDataSource.removeFavorite(planId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      return await _localDataSource.deleteAllFavorites();
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}
