import '../models/travel_plan.dart';

abstract class RecentlyViewedRepository {
  Stream<List<String>> watchRecentlyViewed();
  Future<void> addViewedPlan(String planId);
  Future<List<TravelPlan>> getRecentlyViewedPlans();
  Future<void> clearHistory();
}
