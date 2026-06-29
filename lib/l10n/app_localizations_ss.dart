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
    return 'Sawubona, $name';
  }

  @override
  String get sermonsTab => 'Amasermoni';

  @override
  String get eventsTab => 'Emizimbalo';

  @override
  String get givingTab => 'Kutekela';

  @override
  String get prayerTab => 'Umtsiya';

  @override
  String get settingsLanguage => 'Lugati';

  @override
  String get settingsLanguageDesc => 'Shiya lugati';

  @override
  String get goodMorning => 'Sawubona';

  @override
  String get goodAfternoon => 'Sawubona';

  @override
  String get goodEvening => 'Sawubona';

  @override
  String get goodNight => 'Lilahleka kakhulu';

  @override
  String get morningTagline => 'Qala lenyaka leyo naKhetho.';

  @override
  String get afternoonTagline => 'Hambani ngamandla noKristu namuhla.';

  @override
  String get eveningTagline => 'Yibonisani ngoqobo kwaKhe namuhla.';

  @override
  String get nightTagline => 'Phuhlani emoyeniKhe namuhla.';

  @override
  String get scriptureSave => 'Shiya';

  @override
  String get scriptureShare => 'Phatlalatse';

  @override
  String get scriptureListen => 'Ngikhathele';

  @override
  String get scriptureReflect => 'Yibonisani';

  @override
  String get scriptureToday => 'VERSI YALANGOLO';
}
