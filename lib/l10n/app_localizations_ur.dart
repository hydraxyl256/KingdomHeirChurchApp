// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'کنگڈم ہیئر';

  @override
  String welcomeMessage(String name) {
    return 'خوش آمدید، $name';
  }

  @override
  String get sermonsTab => 'خطبات';

  @override
  String get eventsTab => 'تقریبات';

  @override
  String get givingTab => 'عطیہ';

  @override
  String get prayerTab => 'دعا';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageDesc => 'ایپ کی زبان تبدیل کریں';
}
