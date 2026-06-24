import 'dart:convert';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevotionalLocalCache {
  DevotionalLocalCache(this._prefs);
  final SharedPreferences _prefs;

  static const _dailyKey = 'devotional_daily';
  static const _previousKey = 'devotional_previous';

  Future<void> cacheDailyDevotional(Devotional devotional) async {
    await _prefs.setString(_dailyKey, jsonEncode(devotional.toJson()));
  }

  Devotional? getCachedDailyDevotional() {
    final str = _prefs.getString(_dailyKey);
    if (str == null) return null;
    return Devotional.fromJson(jsonDecode(str) as Map<String, dynamic>);
  }

  Future<void> cachePreviousDevotionals(List<Devotional> devotionals) async {
    final list = devotionals.map((d) => d.toJson()).toList();
    await _prefs.setString(_previousKey, jsonEncode(list));
  }

  List<Devotional>? getCachedPreviousDevotionals() {
    final str = _prefs.getString(_previousKey);
    if (str == null) return null;
    final list = jsonDecode(str) as List<dynamic>;
    return list
        .map((e) => Devotional.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
