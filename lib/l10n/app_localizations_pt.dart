// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'Bem-vindo, $name';
  }

  @override
  String get sermonsTab => 'Sermões';

  @override
  String get eventsTab => 'Eventos';

  @override
  String get givingTab => 'Doações';

  @override
  String get prayerTab => 'Oração';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc => 'Mudar idioma do aplicativo';

  @override
  String get goodMorning => 'Bom Dia';

  @override
  String get goodAfternoon => 'Boa Tarde';

  @override
  String get goodEvening => 'Boa Noite';

  @override
  String get goodNight => 'Boa Noite';

  @override
  String get morningTagline => 'Comece seu dia na Palavra.';

  @override
  String get afternoonTagline => 'Ande com ousadia em Cristo hoje.';

  @override
  String get eveningTagline => 'Reflita sobre sua bondade hoje.';

  @override
  String get nightTagline => 'Descanso em sua paz esta noite.';

  @override
  String get scriptureSave => 'Salvar';

  @override
  String get scriptureShare => 'Compartilhar';

  @override
  String get scriptureListen => 'Ouvir';

  @override
  String get scriptureReflect => 'Refletir';

  @override
  String get scriptureToday => 'VERSO DO DIA';

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
