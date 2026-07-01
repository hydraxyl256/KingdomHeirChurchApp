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
