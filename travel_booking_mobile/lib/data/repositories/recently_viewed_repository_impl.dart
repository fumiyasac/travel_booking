import '../../core/error/app_error.dart';
import '../datasources/local/recently_viewed_local_data_source.dart';
import '../datasources/remote/travel_plan_remote_datasource.dart';
import '../models/travel_plan.dart';
import 'recently_viewed_repository.dart';

class RecentlyViewedRepositoryImpl implements RecentlyViewedRepository {
  final RecentlyViewedLocalDataSource _localDataSource;
  final TravelPlanRemoteDataSource _remoteDataSource;

  const RecentlyViewedRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
  );

  @override
  Stream<List<String>> watchRecentlyViewed() =>
      _localDataSource.watchRecentlyViewed();

  @override
  Future<void> addViewedPlan(String planId) async {
    try {
      await _localDataSource.addViewedPlan(planId);
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<TravelPlan>> getRecentlyViewedPlans() async {
    try {
      final ids = await _localDataSource.getRecentlyViewedIds();
      final plans = <TravelPlan>[];
      for (final id in ids) {
        try {
          final plan = await _remoteDataSource.getTravelPlan(id);
          plans.add(plan);
        } catch (_) {
          // Skip plans that can no longer be fetched
        }
      }
      return plans;
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _localDataSource.clearHistory();
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}
