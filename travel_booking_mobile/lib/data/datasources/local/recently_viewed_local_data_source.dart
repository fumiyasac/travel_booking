import '../../../core/database/recently_viewed_storage.dart';

class RecentlyViewedLocalDataSource {
  final RecentlyViewedStorage _storage;

  RecentlyViewedLocalDataSource(this._storage);

  Stream<List<String>> watchRecentlyViewed() async* {
    yield await _storage.getRecentIds();
    yield* _storage.stream;
  }

  Future<List<String>> getRecentlyViewedIds() => _storage.getRecentIds();

  Future<void> addViewedPlan(String planId) => _storage.addPlan(planId);

  Future<void> clearHistory() => _storage.clearAll();

  void dispose() => _storage.dispose();
}
