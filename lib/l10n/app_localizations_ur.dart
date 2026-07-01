// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Kingdom Heir';

  @override
  String welcomeMessage(String name) {
    return 'خوش آمدید، $name';
  }

  @override
  String get sermonsTab => 'เทศเทศ';

  @override
  String get eventsTab => 'تقریبات';

  @override
  String get givingTab => 'donations';

  @override
  String get prayerTab => 'دعا';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageDesc => 'زبان تبدیل کریں';

  @override
  String get goodMorning => 'صبح بخیر';

  @override
  String get goodAfternoon => 'عصر بخیر';

  @override
  String get goodEvening => 'شام بخیر';

  @override
  String get goodNight => 'شب بخیر';

  @override
  String get morningTagline => 'اپنا دن قرآن کی آواز سے شروع کریں۔';

  @override
  String get afternoonTagline => 'مسيح میں بدھلی کے ساتھ چلو۔';

  @override
  String get eveningTagline => 'اس کی بھلائی پر غور کریں۔';

  @override
  String get nightTagline => 'اس کی aman میں آرام کریں۔';

  @override
  String get scriptureSave => 'محفوظ کریں';

  @override
  String get scriptureShare => 'اشتراک کریں';

  @override
  String get scriptureListen => 'سنیں';

  @override
  String get scriptureReflect => 'سوچیں';

  @override
  String get scriptureToday => 'آج کی آیت';

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
