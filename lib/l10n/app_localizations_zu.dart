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
    return 'Sawubona, $name';
  }

  @override
  String get sermonsTab => 'Izilumko';

  @override
  String get eventsTab => 'Izizathu';

  @override
  String get givingTab => 'Ukunika';

  @override
  String get prayerTab => 'Ukuthandaza';

  @override
  String get settingsLanguage => 'Ulimi';

  @override
  String get settingsLanguageDesc => 'Shintsha ulimi';

  @override
  String get goodMorning => 'Sawubona';

  @override
  String get goodAfternoon => 'Sawubona';

  @override
  String get goodEvening => 'Sawubona';

  @override
  String get goodNight => 'Lilahleka kakhulu';

  @override
  String get morningTagline => 'Qala lakho usuku nomoya oNgcwele.';

  @override
  String get afternoonTagline => 'Hambela ngamandla noKristu namuhla.';

  @override
  String get eveningTagline => 'Yibonisane ngoqobo kwaKhe namuhla.';

  @override
  String get nightTagline => 'Phela ngoThixo owaphile namuhla.';

  @override
  String get scriptureSave => 'Gcina';

  @override
  String get scriptureShare => 'Sharel';

  @override
  String get scriptureListen => 'Khuluma';

  @override
  String get scriptureReflect => 'Qeqesha';

  @override
  String get scriptureToday => 'UMBHALO WOLUSUKO';
}
