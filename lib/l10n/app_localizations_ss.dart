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
