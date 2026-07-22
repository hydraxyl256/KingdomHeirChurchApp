import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/config/app_config.dart';
import 'package:kingdom_heir/core/storage/cache_manager.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// Infrastructure Providers
// ─────────────────────────────────────────────

/// Provides the [AppConfig] built from dart-defines.
/// Must be overridden in ProviderScope at app startup.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in bootstrap');
});

/// Provides the initialized [SupabaseClient].
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides [SharedPreferences] instance (loaded during bootstrap).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap',
  );
});

/// Provides [CacheManager].
final cacheManagerProvider = Provider<CacheManager>((ref) {
  throw UnimplementedError(
    'cacheManagerProvider must be overridden in bootstrap',
  );
});

/// Provides [LocalStorageService].
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

// ─────────────────────────────────────────────
// Theme & Locale Providers
// ─────────────────────────────────────────────

/// Persisted theme mode (light / dark / system).
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final storage = ref.watch(localStorageServiceProvider);
    return ThemeModeNotifier(storage);
  },
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(_loadTheme(_storage));

  final LocalStorageService _storage;

  static ThemeMode _loadTheme(LocalStorageService storage) {
    final saved = storage.getString(LocalStorageKeys.selectedTheme);
    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.setString(
      key: LocalStorageKeys.selectedTheme,
      value: mode.name,
    );
  }
}

// ─────────────────────────────────────────────
// Currency Provider
// ─────────────────────────────────────────────

/// Supported currencies: code → display label.
/// Expand this list as needed.
const kSupportedCurrencies = {
  'UGX': 'UGX — Ugandan Shilling',
  'USD': 'USD — US Dollar',
  'EUR': 'EUR — Euro',
  'GBP': 'GBP — British Pound',
  'KES': 'KES — Kenyan Shilling',
  'TZS': 'TZS — Tanzanian Shilling',
  'RWF': 'RWF — Rwandan Franc',
  'GHS': 'GHS — Ghanaian Cedi',
  'NGN': 'NGN — Nigerian Naira',
  'ZAR': 'ZAR — South African Rand',
  'ETB': 'ETB — Ethiopian Birr',
  'XOF': 'XOF — West African CFA Franc',
  'XAF': 'XAF — Central African CFA Franc',
  'CAD': 'CAD — Canadian Dollar',
  'AUD': 'AUD — Australian Dollar',
  'INR': 'INR — Indian Rupee',
  'AED': 'AED — UAE Dirham',
  'SAR': 'SAR — Saudi Riyal',
  'CNY': 'CNY — Chinese Yuan',
  'JPY': 'JPY — Japanese Yen',
};

/// Persisted currency preference — defaults to UGX.
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return CurrencyNotifier(storage);
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier(this._storage)
      : super(_storage.getString(LocalStorageKeys.selectedCurrency) ?? 'UGX');

  final LocalStorageService _storage;

  Future<void> setCurrency(String code) async {
    state = code;
    await _storage.setString(
      key: LocalStorageKeys.selectedCurrency,
      value: code,
    );
  }
}
