import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/favorite_plan.dart';

class FavoritesStorage {
  static const _key = 'favorite_plans';

  // Cached instance to avoid awaiting getInstance() on every operation
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<FavoritePlan>> getAll() async {
    final prefs = await _getPrefs();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((s) => FavoritePlan.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<FavoritePlan> favorites) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(
      _key,
      favorites.map((f) => jsonEncode(f.toJson())).toList(),
    );
  }

  Future<void> add(FavoritePlan plan) async {
    final current = await getAll();
    current.removeWhere((f) => f.planId == plan.planId);
    current.insert(0, plan);
    await _saveAll(current);
  }

  Future<void> remove(String planId) async {
    final current = await getAll();
    current.removeWhere((f) => f.planId == planId);
    await _saveAll(current);
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }

  Future<bool> contains(String planId) async {
    final current = await getAll();
    return current.any((f) => f.planId == planId);
  }
}
