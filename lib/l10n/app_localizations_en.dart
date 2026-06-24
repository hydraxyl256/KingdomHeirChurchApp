// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get sermonsTab => 'Sermons';

  @override
  String get eventsTab => 'Events';

  @override
  String get givingTab => 'Giving';

  @override
  String get prayerTab => 'Prayer';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Change app language';
}
