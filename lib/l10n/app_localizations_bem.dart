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

  @override
  String get reminderSet => 'We will remind you 30 minutes before service.';

  @override
  String get directionsOpen => 'Opening directions…';

  @override
  String get liveNow => 'LIVE NOW';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get prayedFor => 'prayed for';

  @override
  String get joinOnline => 'Join Online';

  @override
  String get joinInPerson => 'Join In Person';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get noEventsToday => 'No events today';

  @override
  String get noPrayerRequests =>
      'No prayer requests yet. Be the first to share.';

  @override
  String get submitPrayerRequest => 'Submit Prayer Request';

  @override
  String get browseEvents => 'Browse Events';

  @override
  String get watchLatestSermon => 'Watch Latest Sermon';

  @override
  String get noSermonsWatched => 'No sermons watched yet';

  @override
  String get scheduleTBD => 'Schedule coming soon';

  @override
  String get partlyCloudy => 'Partly Cloudy';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '$count day streak',
    );
    return '$_temp0';
  }

  @override
  String get noSermonsWatchedDescription =>
      'Tap “See all” to browse the latest sermons.';
}
