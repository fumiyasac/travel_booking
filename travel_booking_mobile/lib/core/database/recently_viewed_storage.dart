import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedStorage {
  static const _key = 'recently_viewed_plan_ids';
  static const _maxItems = 20;

  SharedPreferences? _prefs;
  final _controller = StreamController<List<String>>.broadcast();

  Stream<List<String>> get stream => _controller.stream;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<String>> getRecentIds() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> _saveIds(List<String> ids) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_key, ids);
    if (!_controller.isClosed) _controller.add(ids);
  }

  Future<void> addPlan(String planId) async {
    final ids = await getRecentIds();
    ids.remove(planId);
    ids.insert(0, planId);
    if (ids.length > _maxItems) ids.removeRange(_maxItems, ids.length);
    await _saveIds(ids);
  }

  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
    if (!_controller.isClosed) _controller.add([]);
  }

  void dispose() => _controller.close();
}
