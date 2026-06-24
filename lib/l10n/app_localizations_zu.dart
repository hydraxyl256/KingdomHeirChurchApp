// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Zulu (`zu`).
class AppLocalizationsZu extends AppLocalizations {
  AppLocalizationsZu([String locale = 'zu']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Siyakwemukela, $name';
  }

  @override
  String get sermonsTab => 'Izintshumayelo';

  @override
  String get eventsTab => 'Imicimbi';

  @override
  String get givingTab => 'Ukunikela';

  @override
  String get prayerTab => 'Umkhuleko';

  @override
  String get settingsLanguage => 'Ulimi';

  @override
  String get settingsLanguageDesc => 'Shintsha ulimi';
}
