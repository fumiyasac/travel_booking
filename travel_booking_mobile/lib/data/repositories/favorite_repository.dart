import '../models/favorite_plan.dart';
import '../models/travel_plan.dart';

abstract class FavoriteRepository {
  Stream<List<FavoritePlan>> watchFavorites();
  Future<List<FavoritePlan>> getFavorites();
  Future<bool> isFavorite(String planId);
  Future<void> addFavorite(TravelPlan plan);
  Future<void> removeFavorite(String planId);
}
