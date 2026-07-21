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

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bonsoir';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get goodNight => 'Bonne nuit';

  @override
  String get morningTagline => 'Commencez votre journée dans la Parole.';

  @override
  String get afternoonTagline => 'Marchez avec audace en Christ aujourd\'hui.';

  @override
  String get eveningTagline => 'Réfléchissez à sa bonté aujourd\'hui.';

  @override
  String get nightTagline => 'Reposez-vous dans sa paix ce soir.';

  @override
  String get scriptureSave => 'Sauvegarder';

  @override
  String get scriptureShare => 'Partager';

  @override
  String get scriptureListen => 'Écouter';

  @override
  String get scriptureReflect => 'Réfléchir';

  @override
  String get scriptureToday => 'VERSET DU JOUR';

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
