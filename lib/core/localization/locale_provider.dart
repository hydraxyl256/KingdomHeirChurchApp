import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:logger/logger.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _loadLocale();
  }

  final Ref _ref;
  static const _localeKey = 'preferred_language_code';
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  Future<void> _loadLocale() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final savedLanguageCode = prefs.getString(_localeKey);

    if (savedLanguageCode != null) {
      state = Locale(savedLanguageCode);
      _logger.d('Loaded cached locale: $savedLanguageCode');
    } else {
      // Fallback to system locale if supported, otherwise English.
      final systemLocale = PlatformDispatcher.instance.locale;
      const supported = ['en', 'fr', 'ur', 'pt', 'bem', 'zu', 'ss'];

      if (supported.contains(systemLocale.languageCode)) {
        state = Locale(systemLocale.languageCode);
      } else {
        state = const Locale('en');
      }
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;

    // Update local state
    state = Locale(languageCode);

    // Persist locally
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeKey, languageCode);

    // Update Supabase preferences if logged in
    final supabase = _ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        await supabase.from('user_language_preferences').upsert({
          'user_id': user.id,
          'preferred_language': languageCode,
          'updated_at': DateTime.now().toIso8601String(),
        });
        _logger.d('Synced locale $languageCode to Supabase');
      } catch (e) {
        _logger.w('Failed to sync locale to Supabase: $e');
      }
    }
  }
}
