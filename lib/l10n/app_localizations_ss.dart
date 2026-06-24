// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swati (`ss`).
class AppLocalizationsSs extends AppLocalizations {
  AppLocalizationsSs([String locale = 'ss']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Wemukelekile, $name';
  }

  @override
  String get sermonsTab => 'Tishumayelo';

  @override
  String get eventsTab => 'Imicimbi';

  @override
  String get givingTab => 'Kunikela';

  @override
  String get prayerTab => 'Umkhuleko';

  @override
  String get settingsLanguage => 'Lulwimi';

  @override
  String get settingsLanguageDesc => 'Shintja lulwimi';
}
