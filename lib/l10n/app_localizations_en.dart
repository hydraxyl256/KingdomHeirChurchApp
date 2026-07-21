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

  @override
  String get devotionalSeries => 'Devotional Series';

  @override
  String dayOf(int current, int total) {
    return 'Day $current of $total';
  }

  @override
  String currentStreak(int count) {
    return '$count day streak';
  }

  @override
  String get markComplete => 'Mark as Complete';

  @override
  String get buyPhysicalCopy => 'Buy Physical Copy on Amazon';

  @override
  String get availableInEnglish =>
      'Available in English — translation coming soon.';

  @override
  String get startChallenge => 'Start the 90-Day Challenge';

  @override
  String continueDayN(int day) {
    return 'Continue Day $day';
  }

  @override
  String completedToday(int day) {
    return 'Day $day Complete — return tomorrow';
  }

  @override
  String get allDaysComplete => 'You\'ve completed all 90 days!';

  @override
  String get syncYouTube => 'Sync YouTube Channel';

  @override
  String get pendingReview => 'Pending Review';

  @override
  String get mediaReviewQueue => 'Media Review Queue';
}
