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

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodNight => 'Good Night';

  @override
  String get morningTagline => 'Begin your day in the Word.';

  @override
  String get afternoonTagline => 'Walk boldly in Christ today.';

  @override
  String get eveningTagline => 'Reflect on His goodness today.';

  @override
  String get nightTagline => 'Rest in His peace tonight.';

  @override
  String get scriptureSave => 'Save';

  @override
  String get scriptureShare => 'Share';

  @override
  String get scriptureListen => 'Listen';

  @override
  String get scriptureReflect => 'Reflect';

  @override
  String get scriptureToday => 'TODAY\'S VERSE';
}
