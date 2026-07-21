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

  @override
  String get analyticsIntelligence => 'Analytics & Intelligence';

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get exportedSuccessfully => 'Exported successfully!';

  @override
  String get country => 'Country';

  @override
  String get users => 'Users';

  @override
  String get onlineNow => 'Online Now';

  @override
  String get exportFinancialDataCsv => 'Export Financial Data (CSV)';

  @override
  String get daySavedSuccessfully => 'Day saved successfully!';

  @override
  String get saveTranslation => 'Save Translation';

  @override
  String get newSeries => 'New Series';

  @override
  String get newDevotionalSeries => 'New Devotional Series';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get publish => '✅ Publish';

  @override
  String get setDraft => '📝 Set Draft';

  @override
  String get archive => '🗄 Archive';

  @override
  String get editDays => 'Edit Days';

  @override
  String get eventManagement => 'Event Management';

  @override
  String get createEventComingSoon => 'Create Event coming soon';

  @override
  String get newEvent => 'New Event';

  @override
  String get noEventsFound => 'No events found.';

  @override
  String get edit => 'Edit';

  @override
  String get globalImpactDashboard => 'Global Impact Dashboard';

  @override
  String get leaderApplications => 'Leader Applications';

  @override
  String get noPendingApplications => 'No pending applications.';

  @override
  String get leaderRecognitionDashboard => 'Leader Recognition Dashboard';

  @override
  String get youtubeSyncCompleted => 'YouTube sync completed!';

  @override
  String get loadingSyncInfo => 'Loading sync info…';

  @override
  String get syncInfoUnavailable => 'Sync info unavailable';

  @override
  String get setPending => '⏳ Set Pending';

  @override
  String get sermon => 'Sermon';

  @override
  String get podcast => 'Podcast';

  @override
  String get teaching => 'Teaching';

  @override
  String get testimony => 'Testimony';

  @override
  String get announcement => 'Announcement';

  @override
  String get refresh => 'Refresh';

  @override
  String get viewOnYoutube => 'View on YouTube';

  @override
  String get memberManagement => 'Member Management';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get role => 'Role';

  @override
  String get status => 'Status';

  @override
  String get joined => 'Joined';

  @override
  String get actions => 'Actions';

  @override
  String get editRole => 'Edit Role';

  @override
  String get suspendSoftDelete => 'Suspend (Soft Delete)';

  @override
  String get member => 'Member';

  @override
  String get moderator => 'Moderator';

  @override
  String get admin => 'Admin';

  @override
  String get roleUpdatedSuccessfully => 'Role updated successfully';

  @override
  String get suspendUser => 'Suspend User';

  @override
  String get userSuspended => 'User suspended';

  @override
  String get suspend => 'Suspend';

  @override
  String get testimonyModeration => 'Testimony Moderation';

  @override
  String get noPendingTestimonies => 'No pending testimonies!';

  @override
  String get approvePublish => 'Approve & Publish';

  @override
  String get prayerModeration => 'Prayer Moderation';

  @override
  String get redirecting => 'Redirecting…';

  @override
  String get weCouldNotLoadTheModeration =>
      'We could not load the moderation queue. Please try again.';

  @override
  String get sermonManagement => 'Sermon Management';

  @override
  String get createSermonComingSoon => 'Create Sermon coming soon';

  @override
  String get addSermon => 'Add Sermon';

  @override
  String get noSermonsFound => 'No sermons found.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get members => 'Members';

  @override
  String get moderation => 'Moderation';

  @override
  String get prayerMod => 'Prayer Mod';

  @override
  String get media => 'Media';

  @override
  String get devotions => 'Devotions';

  @override
  String get tools => 'Tools';

  @override
  String get kingdomHeirCms => 'Kingdom Heir CMS';

  @override
  String get exitAdmin => 'Exit Admin';

  @override
  String get authenticationError => 'Authentication Error';

  @override
  String get useADifferentEmail => 'Use a different email';

  @override
  String get noMailAppAvailableOnThis =>
      'No mail app available on this device.';

  @override
  String get egJohn316Romans8Psalm => 'e.g. John 3:16 · Romans 8 · Psalm 23';

  @override
  String get verseCopiedToClipboard => 'Verse copied to clipboard';

  @override
  String get tryAgain => 'Try again';

  @override
  String get whatIsGodTeachingYouHere => 'What is God teaching you here?';

  @override
  String get couldNotOpenStoreLink => 'Could not open store link.';

  @override
  String get kingdomBookstore => 'Kingdom Bookstore';

  @override
  String get noProductsAvailable => 'No products available.';

  @override
  String get ninetyDayChallenge => '90-Day Challenge';

  @override
  String get groupReportingPacket => 'Group Reporting Packet';

  @override
  String get reportSubmittedSuccessfully => 'Report submitted successfully!';

  @override
  String get groupInformation => 'Group Information';

  @override
  String get home => 'Home';

  @override
  String get church => 'Church';

  @override
  String get business => 'Business';

  @override
  String get workplace => 'Workplace';

  @override
  String get online => 'Online';

  @override
  String get community => 'Community';

  @override
  String get participantSummary => 'Participant Summary';

  @override
  String get discipleshipImpact => 'Discipleship Impact';

  @override
  String get evangelismImpact => 'Evangelism Impact';

  @override
  String get leadershipDevelopment => 'Leadership Development';

  @override
  String get testimonies => 'Testimonies';

  @override
  String get mayWeContactThisIndividual => 'May we contact this individual?';

  @override
  String get photoPermissionGranted => 'Photo permission granted?';

  @override
  String get videoPermissionGranted => 'Video permission granted?';

  @override
  String get multiplicationReport => 'Multiplication Report';

  @override
  String get leaderSelfevaluation => 'Leader Self-Evaluation';

  @override
  String get completedReportingRequirements =>
      'Completed reporting requirements?';

  @override
  String get faithfullyFacilitatedYourGroup =>
      'Faithfully facilitated your group?';

  @override
  String get identifiedFutureLeaders => 'Identified future leaders?';

  @override
  String get wouldLikeToLeadAnotherGroup => 'Would like to lead another group?';

  @override
  String get wouldLikeAdditionalCoaching => 'Would like additional coaching?';

  @override
  String get myDiscipleshipJourney => 'My Discipleship Journey';

  @override
  String get history => 'History';

  @override
  String get notifications => 'Notifications';

  @override
  String get newInspiration => 'New inspiration';

  @override
  String get remindMe => 'Remind me';

  @override
  String get tryAgain_1 => 'Try Again';

  @override
  String get myJournal => 'My Journal';

  @override
  String get thisDayIsNotYetAvailable => 'This day is not yet available.';

  @override
  String get writeYourThoughtsPrayersOrInsights =>
      'Write your thoughts, prayers, or insights…';

  @override
  String get speakToGodInYourOwn => 'Speak to God in your own words…';

  @override
  String get devotionalNotFound => 'Devotional not found.';

  @override
  String get startThisJourney => 'Start this Journey';

  @override
  String get couldNotOpenAmazon => 'Could not open Amazon.';

  @override
  String get couldNotOpenAmazonPleaseTry =>
      'Could not open Amazon. Please try again.';

  @override
  String get viewJourney => 'View Journey';

  @override
  String get buyBook => 'Buy Book';

  @override
  String get whatIsGodSpeakingToYour =>
      'What is God speaking to your heart today? Write freely…';

  @override
  String get reflectionJournal => 'Reflection Journal';

  @override
  String get noJournalEntriesYet => 'No journal entries yet.';

  @override
  String get writeYourReflectionForToday =>
      'Write your reflection for today...';

  @override
  String get writeYourThoughtsHereOptional =>
      'Write your thoughts here… (optional)';

  @override
  String get you => 'You';

  @override
  String get eventsCalendar => 'Events Calendar';

  @override
  String get listView => 'List View';

  @override
  String get eventNotFoundOrHasPassed => 'Event not found or has passed.';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get ticketsAttendance => 'Tickets & Attendance';

  @override
  String get givingHistory => 'Giving History';

  @override
  String get export => 'Export';

  @override
  String get manage => 'Manage';

  @override
  String get givingStewardship => 'Giving & Stewardship';

  @override
  String get couldntLoadYourCommunity => 'Couldn’t load your community';

  @override
  String get attachScripture => 'Attach scripture';

  @override
  String get attach => 'Attach';

  @override
  String get shareImage => 'Share image';

  @override
  String get sharePrayerRequest => 'Share prayer request';

  @override
  String get shareScripture => 'Share scripture';

  @override
  String get shareGroup => 'Share group';

  @override
  String get muteNotifications => 'Mute notifications';

  @override
  String get egJohn316 => 'e.g. John 3:16';

  @override
  String get groupInfo => 'Group info';

  @override
  String get couldntLoadTheConversation => 'Couldn’t load the conversation';

  @override
  String get couldntLoadThisGroup => 'Couldn’t load this group';

  @override
  String get discoverCommunities => 'Discover communities';

  @override
  String get searchByNameTopicOrInterest =>
      'Search by name, topic, or interest…';

  @override
  String get couldntLoadEvents => 'Couldn’t load events';

  @override
  String get promoteFeatureComingSoon => 'Promote — feature coming soon';

  @override
  String get removeFeatureComingSoon => 'Remove — feature coming soon';

  @override
  String get announcementPosted => 'Announcement posted';

  @override
  String get post => 'Post';

  @override
  String get couldntLoadLeaderDashboard => 'Couldn’t load leader dashboard';

  @override
  String get shareAnUpdateWithTheGroup => 'Share an update with the group…';

  @override
  String get prayerWall => 'Prayer wall';

  @override
  String get couldntLoadPrayers => 'Couldn’t load prayers';

  @override
  String get typeAMessage => 'Type a message…';

  @override
  String get sendAsPrayer => 'Send as prayer';

  @override
  String get send => 'Send';

  @override
  String get whatsOnYourHeart => 'What’s on your heart?';

  @override
  String get memberListComingSoon => 'Member list coming soon';

  @override
  String get viewAll => 'View all';

  @override
  String get clearAll => 'Clear all';

  @override
  String get couldntLoadAnnouncements => 'Couldn’t load announcements';

  @override
  String get couldntLoadYourGroups => 'Couldn’t load your groups';

  @override
  String get couldntLoadPrayerRequests => 'Couldn’t load prayer requests';

  @override
  String get groupCreationComingSoonTalkTo =>
      'Group creation coming soon — talk to your leader';

  @override
  String get tapAGroupToShareAn => 'Tap a group to share an invite link';

  @override
  String get couldntLoadActiveGroups => 'Couldn’t load active groups';

  @override
  String get couldntLoadSuggestions => 'Couldn’t load suggestions';

  @override
  String get couldntLoadMeetings => 'Couldn’t load meetings';

  @override
  String get promote => 'Promote';

  @override
  String get memberActions => 'Member actions';

  @override
  String get approve => 'Approve';

  @override
  String get deny => 'Deny';

  @override
  String get yourePraying => 'You’re praying 🙏';

  @override
  String get iPrayed => 'I prayed';

  @override
  String get praiseReportFeatureComingSoon =>
      'Praise report — feature coming soon';

  @override
  String get praise => 'Praise';

  @override
  String get prayerRequestShared => 'Prayer request shared';

  @override
  String get shareWithTheGroup => 'Share with the group';

  @override
  String get kidsCheckin => 'Kids Check-In';

  @override
  String get noActiveKidsSessionsRightNow =>
      'No active kids sessions right now.';

  @override
  String get groupLeaderApplication => 'Group Leader Application';

  @override
  String get applicationSubmittedSuccessfully =>
      'Application submitted successfully!';

  @override
  String get leaderCovenant => 'Leader Covenant';

  @override
  String get youMustCheckAllAffirmationBoxes =>
      'You must check all affirmation boxes.';

  @override
  String get leaderResources => 'Leader Resources';

  @override
  String get leaderToolkitResources => 'Leader Toolkit & Resources';

  @override
  String get reportMessage => 'Report Message';

  @override
  String get shareYourPrayerRequestHereBe =>
      'Share your prayer request here. Be as specific as you like…';

  @override
  String get attachScripture_1 => 'Attach Scripture';

  @override
  String get takeNotesAsYouListenKey =>
      'Take notes as you listen… key scriptures, insights, how to apply this message…';

  @override
  String get memberDirectory => 'Member Directory';

  @override
  String get searchMembers => 'Search members…';

  @override
  String get couldn => 'Couldn';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get newsAnnouncements => 'News & Announcements';

  @override
  String get noNewsArticlesYet => 'No news articles yet.';

  @override
  String get readMore => 'Read More';

  @override
  String get podcastsAudioHub => 'Podcasts & Audio Hub';

  @override
  String get noEpisodesAvailable => 'No episodes available';

  @override
  String get selectAnEpisodeToStartPlaying =>
      'Select an episode to start playing';

  @override
  String get myPrayerRequests => 'My Prayer Requests';

  @override
  String get weCouldNotLoadYourPrayer =>
      'We could not load your prayer requests. Please try again.';

  @override
  String get prayerWall_1 => 'Prayer Wall';

  @override
  String get requestPrayer => 'Request Prayer';

  @override
  String get weCouldNotLoadPrayerRequests =>
      'We could not load prayer requests right now. Please try again.';

  @override
  String get avatarUpdatedSuccessfully => 'Avatar updated successfully!';

  @override
  String get profileSavedSuccessfully => 'Profile saved successfully!';

  @override
  String get myProfile => 'My Profile';

  @override
  String get settings => 'Settings';

  @override
  String get searchTheKingdom => 'Search the kingdom…';

  @override
  String get sermonNotFound => 'Sermon not found';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get audioDownloadComingSoon => 'Audio download — coming soon';

  @override
  String get watch => 'Watch';

  @override
  String get audio => 'Audio';

  @override
  String get downloads => 'Downloads';

  @override
  String get library => 'Library';

  @override
  String get filter => 'Filter';

  @override
  String get markCurrent => 'Mark current';

  @override
  String get resume => 'Resume';

  @override
  String get download => 'Download';

  @override
  String get writeANote => 'Write a note…';

  @override
  String get keepThisPrivate => 'Keep this private';

  @override
  String get onlyYouWillSeeThisResponse => 'Only you will see this response.';

  @override
  String get savePrayer => 'Save prayer';

  @override
  String get howIsGodStirringYourHeart =>
      'How is God stirring your heart to pray?';

  @override
  String get nextPrompt => 'Next prompt';

  @override
  String get writeYourReflection => 'Write your reflection…';

  @override
  String get copyLink => 'Copy link';

  @override
  String get seeAll => 'See all';

  @override
  String get watchNow => 'Watch now';

  @override
  String get resetAll => 'Reset all';

  @override
  String get favoritesOnly => 'Favorites only';

  @override
  String get downloadedOnly => 'Downloaded only';

  @override
  String get showResults => 'Show results';

  @override
  String get pictureinpictureComingSoon => 'Picture-in-picture — coming soon';

  @override
  String get captionsComingSoon => 'Captions — coming soon';

  @override
  String get castComingSoon => 'Cast — coming soon';

  @override
  String get quality => 'Quality';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get reportAProblem => 'Report a problem';

  @override
  String get pictureinpicture => 'Picture-in-picture';

  @override
  String get captions => 'Captions';

  @override
  String get speed => 'Speed';

  @override
  String get cast => 'Cast';

  @override
  String get openLink => 'Open link';

  @override
  String get back => 'Back';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully.';

  @override
  String get theme => 'Theme';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get changePassword => 'Change Password';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutKingdomHeir => 'About Kingdom Heir';

  @override
  String get signOut => 'Sign Out';

  @override
  String get areYouSureYouWantTo => 'Are you sure you want to sign out?';

  @override
  String get youHaveBeenSignedOut => 'You have been signed out.';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get aLetterFromOurFounder => 'A Letter from our Founder';

  @override
  String get impactStory => 'Impact & Story';

  @override
  String get statementOfFaith => 'Statement of Faith';

  @override
  String get testimonySubmittedForReviewThankYou =>
      '🙌 Testimony submitted for review. Thank you!';

  @override
  String get shareYourTestimony => 'Share Your Testimony';

  @override
  String get shareAnonymously => 'Share anonymously';

  @override
  String get ministryAssignments => 'Ministry Assignments';

  @override
  String get confirm => 'Confirm';

  @override
  String get volunteerHub => 'Volunteer Hub';

  @override
  String get mySchedule => 'My Schedule';

  @override
  String get remove => 'Remove';
}
