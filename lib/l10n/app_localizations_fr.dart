// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get sermonsTab => 'Sermons';

  @override
  String get eventsTab => 'Événements';

  @override
  String get givingTab => 'Dons';

  @override
  String get prayerTab => 'Prière';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageDesc => 'Changer la langue de l\'application';
}
