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

  /// Section title for devotional series
  ///
  /// In en, this message translates to:
  /// **'Devotional Series'**
  String get devotionalSeries;

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total}'**
  String dayOf(int current, int total);

  /// Streak label
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String currentStreak(int count);

  /// CTA button on day reader
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markComplete;

  /// Amazon purchase CTA
  ///
  /// In en, this message translates to:
  /// **'Buy Physical Copy on Amazon'**
  String get buyPhysicalCopy;

  /// Banner shown when translation is missing
  ///
  /// In en, this message translates to:
  /// **'Available in English — translation coming soon.'**
  String get availableInEnglish;

  /// CTA to join the challenge
  ///
  /// In en, this message translates to:
  /// **'Start the 90-Day Challenge'**
  String get startChallenge;

  /// CTA to continue the challenge
  ///
  /// In en, this message translates to:
  /// **'Continue Day {day}'**
  String continueDayN(int day);

  /// Message after completing today's day
  ///
  /// In en, this message translates to:
  /// **'Day {day} Complete — return tomorrow'**
  String completedToday(int day);

  /// Celebration message
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed all 90 days!'**
  String get allDaysComplete;

  /// Admin button to trigger YouTube sync
  ///
  /// In en, this message translates to:
  /// **'Sync YouTube Channel'**
  String get syncYouTube;

  /// Status label for media content
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// Admin screen title
  ///
  /// In en, this message translates to:
  /// **'Media Review Queue'**
  String get mediaReviewQueue;

  /// No description provided for @analyticsIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Intelligence'**
  String get analyticsIntelligence;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get noDataToExport;

  /// No description provided for @exportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully!'**
  String get exportedSuccessfully;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @onlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online Now'**
  String get onlineNow;

  /// No description provided for @exportFinancialDataCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Financial Data (CSV)'**
  String get exportFinancialDataCsv;

  /// No description provided for @daySavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Day saved successfully!'**
  String get daySavedSuccessfully;

  /// No description provided for @saveTranslation.
  ///
  /// In en, this message translates to:
  /// **'Save Translation'**
  String get saveTranslation;

  /// No description provided for @newSeries.
  ///
  /// In en, this message translates to:
  /// **'New Series'**
  String get newSeries;

  /// No description provided for @newDevotionalSeries.
  ///
  /// In en, this message translates to:
  /// **'New Devotional Series'**
  String get newDevotionalSeries;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'✅ Publish'**
  String get publish;

  /// No description provided for @setDraft.
  ///
  /// In en, this message translates to:
  /// **'📝 Set Draft'**
  String get setDraft;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'🗄 Archive'**
  String get archive;

  /// No description provided for @editDays.
  ///
  /// In en, this message translates to:
  /// **'Edit Days'**
  String get editDays;

  /// No description provided for @eventManagement.
  ///
  /// In en, this message translates to:
  /// **'Event Management'**
  String get eventManagement;

  /// No description provided for @createEventComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Event coming soon'**
  String get createEventComingSoon;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found.'**
  String get noEventsFound;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @globalImpactDashboard.
  ///
  /// In en, this message translates to:
  /// **'Global Impact Dashboard'**
  String get globalImpactDashboard;

  /// No description provided for @leaderApplications.
  ///
  /// In en, this message translates to:
  /// **'Leader Applications'**
  String get leaderApplications;

  /// No description provided for @noPendingApplications.
  ///
  /// In en, this message translates to:
  /// **'No pending applications.'**
  String get noPendingApplications;

  /// No description provided for @leaderRecognitionDashboard.
  ///
  /// In en, this message translates to:
  /// **'Leader Recognition Dashboard'**
  String get leaderRecognitionDashboard;

  /// No description provided for @youtubeSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'YouTube sync completed!'**
  String get youtubeSyncCompleted;

  /// No description provided for @loadingSyncInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading sync info…'**
  String get loadingSyncInfo;

  /// No description provided for @syncInfoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sync info unavailable'**
  String get syncInfoUnavailable;

  /// No description provided for @setPending.
  ///
  /// In en, this message translates to:
  /// **'⏳ Set Pending'**
  String get setPending;

  /// No description provided for @sermon.
  ///
  /// In en, this message translates to:
  /// **'Sermon'**
  String get sermon;

  /// No description provided for @podcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get podcast;

  /// No description provided for @teaching.
  ///
  /// In en, this message translates to:
  /// **'Teaching'**
  String get teaching;

  /// No description provided for @testimony.
  ///
  /// In en, this message translates to:
  /// **'Testimony'**
  String get testimony;

  /// No description provided for @announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @viewOnYoutube.
  ///
  /// In en, this message translates to:
  /// **'View on YouTube'**
  String get viewOnYoutube;

  /// No description provided for @memberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get memberManagement;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @editRole.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get editRole;

  /// No description provided for @suspendSoftDelete.
  ///
  /// In en, this message translates to:
  /// **'Suspend (Soft Delete)'**
  String get suspendSoftDelete;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @moderator.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get moderator;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @roleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Role updated successfully'**
  String get roleUpdatedSuccessfully;

  /// No description provided for @suspendUser.
  ///
  /// In en, this message translates to:
  /// **'Suspend User'**
  String get suspendUser;

  /// No description provided for @userSuspended.
  ///
  /// In en, this message translates to:
  /// **'User suspended'**
  String get userSuspended;

  /// No description provided for @suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspend;

  /// No description provided for @testimonyModeration.
  ///
  /// In en, this message translates to:
  /// **'Testimony Moderation'**
  String get testimonyModeration;

  /// No description provided for @noPendingTestimonies.
  ///
  /// In en, this message translates to:
  /// **'No pending testimonies!'**
  String get noPendingTestimonies;

  /// No description provided for @approvePublish.
  ///
  /// In en, this message translates to:
  /// **'Approve & Publish'**
  String get approvePublish;

  /// No description provided for @prayerModeration.
  ///
  /// In en, this message translates to:
  /// **'Prayer Moderation'**
  String get prayerModeration;

  /// No description provided for @redirecting.
  ///
  /// In en, this message translates to:
  /// **'Redirecting…'**
  String get redirecting;

  /// No description provided for @weCouldNotLoadTheModeration.
  ///
  /// In en, this message translates to:
  /// **'We could not load the moderation queue. Please try again.'**
  String get weCouldNotLoadTheModeration;

  /// No description provided for @sermonManagement.
  ///
  /// In en, this message translates to:
  /// **'Sermon Management'**
  String get sermonManagement;

  /// No description provided for @createSermonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Sermon coming soon'**
  String get createSermonComingSoon;

  /// No description provided for @addSermon.
  ///
  /// In en, this message translates to:
  /// **'Add Sermon'**
  String get addSermon;

  /// No description provided for @noSermonsFound.
  ///
  /// In en, this message translates to:
  /// **'No sermons found.'**
  String get noSermonsFound;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @moderation.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get moderation;

  /// No description provided for @prayerMod.
  ///
  /// In en, this message translates to:
  /// **'Prayer Mod'**
  String get prayerMod;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @devotions.
  ///
  /// In en, this message translates to:
  /// **'Devotions'**
  String get devotions;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @kingdomHeirCms.
  ///
  /// In en, this message translates to:
  /// **'Kingdom Heir CMS'**
  String get kingdomHeirCms;

  /// No description provided for @exitAdmin.
  ///
  /// In en, this message translates to:
  /// **'Exit Admin'**
  String get exitAdmin;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationError;

  /// No description provided for @useADifferentEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get useADifferentEmail;

  /// No description provided for @noMailAppAvailableOnThis.
  ///
  /// In en, this message translates to:
  /// **'No mail app available on this device.'**
  String get noMailAppAvailableOnThis;

  /// No description provided for @egJohn316Romans8Psalm.
  ///
  /// In en, this message translates to:
  /// **'e.g. John 3:16 · Romans 8 · Psalm 23'**
  String get egJohn316Romans8Psalm;

  /// No description provided for @verseCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Verse copied to clipboard'**
  String get verseCopiedToClipboard;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @whatIsGodTeachingYouHere.
  ///
  /// In en, this message translates to:
  /// **'What is God teaching you here?'**
  String get whatIsGodTeachingYouHere;

  /// No description provided for @couldNotOpenStoreLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open store link.'**
  String get couldNotOpenStoreLink;

  /// No description provided for @kingdomBookstore.
  ///
  /// In en, this message translates to:
  /// **'Kingdom Bookstore'**
  String get kingdomBookstore;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get noProductsAvailable;

  /// No description provided for @ninetyDayChallenge.
  ///
  /// In en, this message translates to:
  /// **'90-Day Challenge'**
  String get ninetyDayChallenge;

  /// No description provided for @groupReportingPacket.
  ///
  /// In en, this message translates to:
  /// **'Group Reporting Packet'**
  String get groupReportingPacket;

  /// No description provided for @reportSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully!'**
  String get reportSubmittedSuccessfully;

  /// No description provided for @groupInformation.
  ///
  /// In en, this message translates to:
  /// **'Group Information'**
  String get groupInformation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @church.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get church;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @workplace.
  ///
  /// In en, this message translates to:
  /// **'Workplace'**
  String get workplace;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @participantSummary.
  ///
  /// In en, this message translates to:
  /// **'Participant Summary'**
  String get participantSummary;

  /// No description provided for @discipleshipImpact.
  ///
  /// In en, this message translates to:
  /// **'Discipleship Impact'**
  String get discipleshipImpact;

  /// No description provided for @evangelismImpact.
  ///
  /// In en, this message translates to:
  /// **'Evangelism Impact'**
  String get evangelismImpact;

  /// No description provided for @leadershipDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Leadership Development'**
  String get leadershipDevelopment;

  /// No description provided for @testimonies.
  ///
  /// In en, this message translates to:
  /// **'Testimonies'**
  String get testimonies;

  /// No description provided for @mayWeContactThisIndividual.
  ///
  /// In en, this message translates to:
  /// **'May we contact this individual?'**
  String get mayWeContactThisIndividual;

  /// No description provided for @photoPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Photo permission granted?'**
  String get photoPermissionGranted;

  /// No description provided for @videoPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Video permission granted?'**
  String get videoPermissionGranted;

  /// No description provided for @multiplicationReport.
  ///
  /// In en, this message translates to:
  /// **'Multiplication Report'**
  String get multiplicationReport;

  /// No description provided for @leaderSelfevaluation.
  ///
  /// In en, this message translates to:
  /// **'Leader Self-Evaluation'**
  String get leaderSelfevaluation;

  /// No description provided for @completedReportingRequirements.
  ///
  /// In en, this message translates to:
  /// **'Completed reporting requirements?'**
  String get completedReportingRequirements;

  /// No description provided for @faithfullyFacilitatedYourGroup.
  ///
  /// In en, this message translates to:
  /// **'Faithfully facilitated your group?'**
  String get faithfullyFacilitatedYourGroup;

  /// No description provided for @identifiedFutureLeaders.
  ///
  /// In en, this message translates to:
  /// **'Identified future leaders?'**
  String get identifiedFutureLeaders;

  /// No description provided for @wouldLikeToLeadAnotherGroup.
  ///
  /// In en, this message translates to:
  /// **'Would like to lead another group?'**
  String get wouldLikeToLeadAnotherGroup;

  /// No description provided for @wouldLikeAdditionalCoaching.
  ///
  /// In en, this message translates to:
  /// **'Would like additional coaching?'**
  String get wouldLikeAdditionalCoaching;

  /// No description provided for @myDiscipleshipJourney.
  ///
  /// In en, this message translates to:
  /// **'My Discipleship Journey'**
  String get myDiscipleshipJourney;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @newInspiration.
  ///
  /// In en, this message translates to:
  /// **'New inspiration'**
  String get newInspiration;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @tryAgain_1.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain_1;

  /// No description provided for @myJournal.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get myJournal;

  /// No description provided for @thisDayIsNotYetAvailable.
  ///
  /// In en, this message translates to:
  /// **'This day is not yet available.'**
  String get thisDayIsNotYetAvailable;

  /// No description provided for @writeYourThoughtsPrayersOrInsights.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts, prayers, or insights…'**
  String get writeYourThoughtsPrayersOrInsights;

  /// No description provided for @speakToGodInYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Speak to God in your own words…'**
  String get speakToGodInYourOwn;

  /// No description provided for @devotionalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Devotional not found.'**
  String get devotionalNotFound;

  /// No description provided for @startThisJourney.
  ///
  /// In en, this message translates to:
  /// **'Start this Journey'**
  String get startThisJourney;

  /// No description provided for @couldNotOpenAmazon.
  ///
  /// In en, this message translates to:
  /// **'Could not open Amazon.'**
  String get couldNotOpenAmazon;

  /// No description provided for @couldNotOpenAmazonPleaseTry.
  ///
  /// In en, this message translates to:
  /// **'Could not open Amazon. Please try again.'**
  String get couldNotOpenAmazonPleaseTry;

  /// No description provided for @viewJourney.
  ///
  /// In en, this message translates to:
  /// **'View Journey'**
  String get viewJourney;

  /// No description provided for @buyBook.
  ///
  /// In en, this message translates to:
  /// **'Buy Book'**
  String get buyBook;

  /// No description provided for @whatIsGodSpeakingToYour.
  ///
  /// In en, this message translates to:
  /// **'What is God speaking to your heart today? Write freely…'**
  String get whatIsGodSpeakingToYour;

  /// No description provided for @reflectionJournal.
  ///
  /// In en, this message translates to:
  /// **'Reflection Journal'**
  String get reflectionJournal;

  /// No description provided for @noJournalEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet.'**
  String get noJournalEntriesYet;

  /// No description provided for @writeYourReflectionForToday.
  ///
  /// In en, this message translates to:
  /// **'Write your reflection for today...'**
  String get writeYourReflectionForToday;

  /// No description provided for @writeYourThoughtsHereOptional.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts here… (optional)'**
  String get writeYourThoughtsHereOptional;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @eventsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Events Calendar'**
  String get eventsCalendar;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @eventNotFoundOrHasPassed.
  ///
  /// In en, this message translates to:
  /// **'Event not found or has passed.'**
  String get eventNotFoundOrHasPassed;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @ticketsAttendance.
  ///
  /// In en, this message translates to:
  /// **'Tickets & Attendance'**
  String get ticketsAttendance;

  /// No description provided for @givingHistory.
  ///
  /// In en, this message translates to:
  /// **'Giving History'**
  String get givingHistory;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @givingStewardship.
  ///
  /// In en, this message translates to:
  /// **'Giving & Stewardship'**
  String get givingStewardship;

  /// No description provided for @couldntLoadYourCommunity.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your community'**
  String get couldntLoadYourCommunity;

  /// No description provided for @attachScripture.
  ///
  /// In en, this message translates to:
  /// **'Attach scripture'**
  String get attachScripture;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareImage;

  /// No description provided for @sharePrayerRequest.
  ///
  /// In en, this message translates to:
  /// **'Share prayer request'**
  String get sharePrayerRequest;

  /// No description provided for @shareScripture.
  ///
  /// In en, this message translates to:
  /// **'Share scripture'**
  String get shareScripture;

  /// No description provided for @shareGroup.
  ///
  /// In en, this message translates to:
  /// **'Share group'**
  String get shareGroup;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get muteNotifications;

  /// No description provided for @egJohn316.
  ///
  /// In en, this message translates to:
  /// **'e.g. John 3:16'**
  String get egJohn316;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get groupInfo;

  /// No description provided for @couldntLoadTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the conversation'**
  String get couldntLoadTheConversation;

  /// No description provided for @couldntLoadThisGroup.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this group'**
  String get couldntLoadThisGroup;

  /// No description provided for @discoverCommunities.
  ///
  /// In en, this message translates to:
  /// **'Discover communities'**
  String get discoverCommunities;

  /// No description provided for @searchByNameTopicOrInterest.
  ///
  /// In en, this message translates to:
  /// **'Search by name, topic, or interest…'**
  String get searchByNameTopicOrInterest;

  /// No description provided for @couldntLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load events'**
  String get couldntLoadEvents;

  /// No description provided for @promoteFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Promote — feature coming soon'**
  String get promoteFeatureComingSoon;

  /// No description provided for @removeFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Remove — feature coming soon'**
  String get removeFeatureComingSoon;

  /// No description provided for @announcementPosted.
  ///
  /// In en, this message translates to:
  /// **'Announcement posted'**
  String get announcementPosted;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @couldntLoadLeaderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load leader dashboard'**
  String get couldntLoadLeaderDashboard;

  /// No description provided for @shareAnUpdateWithTheGroup.
  ///
  /// In en, this message translates to:
  /// **'Share an update with the group…'**
  String get shareAnUpdateWithTheGroup;

  /// No description provided for @prayerWall.
  ///
  /// In en, this message translates to:
  /// **'Prayer wall'**
  String get prayerWall;

  /// No description provided for @couldntLoadPrayers.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load prayers'**
  String get couldntLoadPrayers;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessage;

  /// No description provided for @sendAsPrayer.
  ///
  /// In en, this message translates to:
  /// **'Send as prayer'**
  String get sendAsPrayer;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @whatsOnYourHeart.
  ///
  /// In en, this message translates to:
  /// **'What’s on your heart?'**
  String get whatsOnYourHeart;

  /// No description provided for @memberListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Member list coming soon'**
  String get memberListComingSoon;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @couldntLoadAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load announcements'**
  String get couldntLoadAnnouncements;

  /// No description provided for @couldntLoadYourGroups.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your groups'**
  String get couldntLoadYourGroups;

  /// No description provided for @couldntLoadPrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load prayer requests'**
  String get couldntLoadPrayerRequests;

  /// No description provided for @groupCreationComingSoonTalkTo.
  ///
  /// In en, this message translates to:
  /// **'Group creation coming soon — talk to your leader'**
  String get groupCreationComingSoonTalkTo;

  /// No description provided for @tapAGroupToShareAn.
  ///
  /// In en, this message translates to:
  /// **'Tap a group to share an invite link'**
  String get tapAGroupToShareAn;

  /// No description provided for @couldntLoadActiveGroups.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load active groups'**
  String get couldntLoadActiveGroups;

  /// No description provided for @couldntLoadSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load suggestions'**
  String get couldntLoadSuggestions;

  /// No description provided for @couldntLoadMeetings.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load meetings'**
  String get couldntLoadMeetings;

  /// No description provided for @promote.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote;

  /// No description provided for @memberActions.
  ///
  /// In en, this message translates to:
  /// **'Member actions'**
  String get memberActions;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @yourePraying.
  ///
  /// In en, this message translates to:
  /// **'You’re praying 🙏'**
  String get yourePraying;

  /// No description provided for @iPrayed.
  ///
  /// In en, this message translates to:
  /// **'I prayed'**
  String get iPrayed;

  /// No description provided for @praiseReportFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Praise report — feature coming soon'**
  String get praiseReportFeatureComingSoon;

  /// No description provided for @praise.
  ///
  /// In en, this message translates to:
  /// **'Praise'**
  String get praise;

  /// No description provided for @prayerRequestShared.
  ///
  /// In en, this message translates to:
  /// **'Prayer request shared'**
  String get prayerRequestShared;

  /// No description provided for @shareWithTheGroup.
  ///
  /// In en, this message translates to:
  /// **'Share with the group'**
  String get shareWithTheGroup;

  /// No description provided for @kidsCheckin.
  ///
  /// In en, this message translates to:
  /// **'Kids Check-In'**
  String get kidsCheckin;

  /// No description provided for @noActiveKidsSessionsRightNow.
  ///
  /// In en, this message translates to:
  /// **'No active kids sessions right now.'**
  String get noActiveKidsSessionsRightNow;

  /// No description provided for @groupLeaderApplication.
  ///
  /// In en, this message translates to:
  /// **'Group Leader Application'**
  String get groupLeaderApplication;

  /// No description provided for @applicationSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully!'**
  String get applicationSubmittedSuccessfully;

  /// No description provided for @leaderCovenant.
  ///
  /// In en, this message translates to:
  /// **'Leader Covenant'**
  String get leaderCovenant;

  /// No description provided for @youMustCheckAllAffirmationBoxes.
  ///
  /// In en, this message translates to:
  /// **'You must check all affirmation boxes.'**
  String get youMustCheckAllAffirmationBoxes;

  /// No description provided for @leaderResources.
  ///
  /// In en, this message translates to:
  /// **'Leader Resources'**
  String get leaderResources;

  /// No description provided for @leaderToolkitResources.
  ///
  /// In en, this message translates to:
  /// **'Leader Toolkit & Resources'**
  String get leaderToolkitResources;

  /// No description provided for @reportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report Message'**
  String get reportMessage;

  /// No description provided for @shareYourPrayerRequestHereBe.
  ///
  /// In en, this message translates to:
  /// **'Share your prayer request here. Be as specific as you like…'**
  String get shareYourPrayerRequestHereBe;

  /// No description provided for @attachScripture_1.
  ///
  /// In en, this message translates to:
  /// **'Attach Scripture'**
  String get attachScripture_1;

  /// No description provided for @takeNotesAsYouListenKey.
  ///
  /// In en, this message translates to:
  /// **'Take notes as you listen… key scriptures, insights, how to apply this message…'**
  String get takeNotesAsYouListenKey;

  /// No description provided for @memberDirectory.
  ///
  /// In en, this message translates to:
  /// **'Member Directory'**
  String get memberDirectory;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members…'**
  String get searchMembers;

  /// No description provided for @couldn.
  ///
  /// In en, this message translates to:
  /// **'Couldn'**
  String get couldn;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @newsAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'News & Announcements'**
  String get newsAnnouncements;

  /// No description provided for @noNewsArticlesYet.
  ///
  /// In en, this message translates to:
  /// **'No news articles yet.'**
  String get noNewsArticlesYet;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @podcastsAudioHub.
  ///
  /// In en, this message translates to:
  /// **'Podcasts & Audio Hub'**
  String get podcastsAudioHub;

  /// No description provided for @noEpisodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No episodes available'**
  String get noEpisodesAvailable;

  /// No description provided for @selectAnEpisodeToStartPlaying.
  ///
  /// In en, this message translates to:
  /// **'Select an episode to start playing'**
  String get selectAnEpisodeToStartPlaying;

  /// No description provided for @myPrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'My Prayer Requests'**
  String get myPrayerRequests;

  /// No description provided for @weCouldNotLoadYourPrayer.
  ///
  /// In en, this message translates to:
  /// **'We could not load your prayer requests. Please try again.'**
  String get weCouldNotLoadYourPrayer;

  /// No description provided for @prayerWall_1.
  ///
  /// In en, this message translates to:
  /// **'Prayer Wall'**
  String get prayerWall_1;

  /// No description provided for @requestPrayer.
  ///
  /// In en, this message translates to:
  /// **'Request Prayer'**
  String get requestPrayer;

  /// No description provided for @weCouldNotLoadPrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'We could not load prayer requests right now. Please try again.'**
  String get weCouldNotLoadPrayerRequests;

  /// No description provided for @avatarUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully!'**
  String get avatarUpdatedSuccessfully;

  /// No description provided for @profileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccessfully;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchTheKingdom.
  ///
  /// In en, this message translates to:
  /// **'Search the kingdom…'**
  String get searchTheKingdom;

  /// No description provided for @sermonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sermon not found'**
  String get sermonNotFound;

  /// No description provided for @continueWatching.
  ///
  /// In en, this message translates to:
  /// **'Continue watching'**
  String get continueWatching;

  /// No description provided for @audioDownloadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Audio download — coming soon'**
  String get audioDownloadComingSoon;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @markCurrent.
  ///
  /// In en, this message translates to:
  /// **'Mark current'**
  String get markCurrent;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @writeANote.
  ///
  /// In en, this message translates to:
  /// **'Write a note…'**
  String get writeANote;

  /// No description provided for @keepThisPrivate.
  ///
  /// In en, this message translates to:
  /// **'Keep this private'**
  String get keepThisPrivate;

  /// No description provided for @onlyYouWillSeeThisResponse.
  ///
  /// In en, this message translates to:
  /// **'Only you will see this response.'**
  String get onlyYouWillSeeThisResponse;

  /// No description provided for @savePrayer.
  ///
  /// In en, this message translates to:
  /// **'Save prayer'**
  String get savePrayer;

  /// No description provided for @howIsGodStirringYourHeart.
  ///
  /// In en, this message translates to:
  /// **'How is God stirring your heart to pray?'**
  String get howIsGodStirringYourHeart;

  /// No description provided for @nextPrompt.
  ///
  /// In en, this message translates to:
  /// **'Next prompt'**
  String get nextPrompt;

  /// No description provided for @writeYourReflection.
  ///
  /// In en, this message translates to:
  /// **'Write your reflection…'**
  String get writeYourReflection;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get watchNow;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @downloadedOnly.
  ///
  /// In en, this message translates to:
  /// **'Downloaded only'**
  String get downloadedOnly;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResults;

  /// No description provided for @pictureinpictureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture — coming soon'**
  String get pictureinpictureComingSoon;

  /// No description provided for @captionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Captions — coming soon'**
  String get captionsComingSoon;

  /// No description provided for @castComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Cast — coming soon'**
  String get castComingSoon;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @reportAProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportAProblem;

  /// No description provided for @pictureinpicture.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture'**
  String get pictureinpicture;

  /// No description provided for @captions.
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get captions;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @cast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutKingdomHeir.
  ///
  /// In en, this message translates to:
  /// **'About Kingdom Heir'**
  String get aboutKingdomHeir;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @areYouSureYouWantTo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantTo;

  /// No description provided for @youHaveBeenSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You have been signed out.'**
  String get youHaveBeenSignedOut;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @aLetterFromOurFounder.
  ///
  /// In en, this message translates to:
  /// **'A Letter from our Founder'**
  String get aLetterFromOurFounder;

  /// No description provided for @impactStory.
  ///
  /// In en, this message translates to:
  /// **'Impact & Story'**
  String get impactStory;

  /// No description provided for @statementOfFaith.
  ///
  /// In en, this message translates to:
  /// **'Statement of Faith'**
  String get statementOfFaith;

  /// No description provided for @testimonySubmittedForReviewThankYou.
  ///
  /// In en, this message translates to:
  /// **'🙌 Testimony submitted for review. Thank you!'**
  String get testimonySubmittedForReviewThankYou;

  /// No description provided for @shareYourTestimony.
  ///
  /// In en, this message translates to:
  /// **'Share Your Testimony'**
  String get shareYourTestimony;

  /// No description provided for @shareAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Share anonymously'**
  String get shareAnonymously;

  /// No description provided for @ministryAssignments.
  ///
  /// In en, this message translates to:
  /// **'Ministry Assignments'**
  String get ministryAssignments;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @volunteerHub.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Hub'**
  String get volunteerHub;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;
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
