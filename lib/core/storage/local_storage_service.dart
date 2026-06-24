import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around [SharedPreferences] for non-sensitive local preferences.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  Future<void> setBool({required String key, required bool value}) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setString({required String key, required String value}) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setInt({required String key, required int value}) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}

abstract final class LocalStorageKeys {
  static const onboardingComplete = 'onboarding_complete';
  static const selectedTheme = 'selected_theme';
  static const selectedLocale = 'selected_locale';
  static const userRole = 'user_role';
  static const lastSeenNotification = 'last_seen_notification';
  static const selectedCurrency = 'selected_currency'; // defaults to UGX
}
