import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bem.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ss.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bem'),
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
    Locale('ss'),
    Locale('ur'),
    Locale('zu')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Kingdom Heir'**
  String get appTitle;

  /// Welcome greeting for the user
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeMessage(String name);

  /// No description provided for @sermonsTab.
  ///
  /// In en, this message translates to:
  /// **'Sermons'**
  String get sermonsTab;

  /// No description provided for @eventsTab.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTab;

  /// No description provided for @givingTab.
  ///
  /// In en, this message translates to:
  /// **'Giving'**
  String get givingTab;

  /// No description provided for @prayerTab.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayerTab;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get settingsLanguageDesc;

  /// Greeting for morning time
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Greeting for afternoon time
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Greeting for evening time
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Greeting for night time
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get goodNight;

  /// Tagline for morning greeting
  ///
  /// In en, this message translates to:
  /// **'Begin your day in the Word.'**
  String get morningTagline;

  /// Tagline for afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Walk boldly in Christ today.'**
  String get afternoonTagline;

  /// Tagline for evening greeting
  ///
  /// In en, this message translates to:
  /// **'Reflect on His goodness today.'**
  String get eveningTagline;

  /// Tagline for night greeting
  ///
  /// In en, this message translates to:
  /// **'Rest in His peace tonight.'**
  String get nightTagline;

  /// Label for save scripture button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get scriptureSave;

  /// Label for share scripture button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get scriptureShare;

  /// Label for listen scriptore button
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get scriptureListen;

  /// Label for reflect scripture button
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get scriptureReflect;

  /// Label for today's verse header
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S VERSE'**
  String get scriptureToday;

  /// Snackbar when reminder is set
  ///
  /// In en, this message translates to:
  /// **'We will remind you 30 minutes before service.'**
  String get reminderSet;

  /// Snackbar when opening maps
  ///
  /// In en, this message translates to:
  /// **'Opening directions…'**
  String get directionsOpen;

  /// Live service badge
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get liveNow;

  /// Upcoming events label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Past tense label
  ///
  /// In en, this message translates to:
  /// **'prayed for'**
  String get prayedFor;

  /// Join online CTA
  ///
  /// In en, this message translates to:
  /// **'Join Online'**
  String get joinOnline;

  /// Join in person CTA
  ///
  /// In en, this message translates to:
  /// **'Join In Person'**
  String get joinInPerson;

  /// Coming soon label
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Add to calendar CTA
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No events today'**
  String get noEventsToday;

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'No prayer requests yet. Be the first to share.'**
  String get noPrayerRequests;

  /// Submit CTA
  ///
  /// In en, this message translates to:
  /// **'Submit Prayer Request'**
  String get submitPrayerRequest;

  /// Browse events CTA
  ///
  /// In en, this message translates to:
  /// **'Browse Events'**
  String get browseEvents;

  /// Watch CTA
  ///
  /// In en, this message translates to:
  /// **'Watch Latest Sermon'**
  String get watchLatestSermon;

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'No sermons watched yet'**
  String get noSermonsWatched;

  /// Empty state for service schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule coming soon'**
  String get scheduleTBD;

  /// Weather badge text
  ///
  /// In en, this message translates to:
  /// **'Partly Cloudy'**
  String get partlyCloudy;

  /// Streak pill text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day streak} other{{count} day streak}}'**
  String dayStreak(int count);

  /// Empty state body
  ///
  /// In en, this message translates to:
  /// **'Tap “See all” to browse the latest sermons.'**
  String get noSermonsWatchedDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bem',
        'en',
        'fr',
        'pt',
        'ss',
        'ur',
        'zu'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bem':
      return AppLocalizationsBem();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ss':
      return AppLocalizationsSs();
    case 'ur':
      return AppLocalizationsUr();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
