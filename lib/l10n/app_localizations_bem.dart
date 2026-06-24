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
}
