// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bemba (`bem`).
class AppLocalizationsBem extends AppLocalizations {
  AppLocalizationsBem([String locale = 'bem']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Mwaiseni, $name';
  }

  @override
  String get sermonsTab => 'Amashiwi';

  @override
  String get eventsTab => 'Ifyakucitika';

  @override
  String get givingTab => 'Ukupeela';

  @override
  String get prayerTab => 'Ipepo';

  @override
  String get settingsLanguage => 'Ulwimi';

  @override
  String get settingsLanguageDesc => 'Cinja ulwimi';

  @override
  String get goodMorning => 'Mwauka wabombwe';

  @override
  String get goodAfternoon => 'Mwauka waaluchimi';

  @override
  String get goodEvening => 'Mwauka waaluchimi';

  @override
  String get goodNight => 'Mwauka waaluchimi';

  @override
  String get morningTagline => 'Bweni lyo cinshi pa Palo.';

  @override
  String get afternoonTagline => 'Tende na ubushingi ne Kristo lelo.';

  @override
  String get eveningTagline => 'Cellesele na bwilabenye ba Yehoowa lelo.';

  @override
  String get nightTagline => 'Pepuka pa cinshi lyako lelo.';

  @override
  String get scriptureSave => 'Cinga';

  @override
  String get scriptureShare => 'Shаника';

  @override
  String get scriptureListen => 'Yanganda';

  @override
  String get scriptureReflect => 'Cellesele';

  @override
  String get scriptureToday => 'VICHI LYA LESUKU';
}
