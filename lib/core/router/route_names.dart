/// Typed route name constants for GoRouter.
abstract final class RouteNames {
  // ── Splash / Onboarding ────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboardingVision = '/onboarding/vision';
  static const onboardingProfileSetup = '/onboarding/profile-setup';

  // ── Start Here (Public Hub) ─────────────────────────────────────────────
  static const startHere = '/start-here';
  static const startHereVision = '/start-here/vision';
  static const startHereFounder = '/start-here/founder';
  static const startHereStatementOfFaith = '/start-here/statement-of-faith';
  static const startHereStory = '/start-here/story';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const roleSelection = '/auth/role-selection';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // ── Home Shell ───────────────────────────────────────────────────────────
  static const home = '/home';

  // ── More (secondary nav hub) ─────────────────────────────────────────────
  static const more = '/home/more';

  // ── Dashboard ────────────────────────────────────────────────────────────
  static const dashboard = '/home/dashboard';

  // ── Challenge ────────────────────────────────────────────────────────────
  static const challenge = '/home/challenge';
  static const challengeParticipant = '/home/challenge/participant';
  static const challengeReporting = '/home/challenge/reporting';

  // ── Sermons ──────────────────────────────────────────────────────────────
  static const sermons = '/home/sermons';
  static const sermonLibrary = '/home/sermons/library';
  static const sermonContinue = '/home/sermons/continue';
  static const sermonDownloads = '/home/sermons/downloads';

  /// Sermon details page (pre-player).
  static const sermonDetails = '/home/sermons/:id';

  /// Legacy alias — keeps the existing deep-link resolvable.
  static const sermonDetail = sermonDetails;
  static const sermonPlayer = '/home/sermons/:id/player';
  static const sermonAudio = '/home/sermons/:id/audio';
  static const sermonSeries = '/home/sermons/:id/series/:seriesId';

  // ── Bible ─────────────────────────────────────────────────────────────────
  static const bible = '/home/bible';
  static const bibleSearch = '/home/bible/search';
  static const bibleBookmarks = '/bible/bookmarks';
  static const biblePlans = '/bible/plans';

  // ── Events ────────────────────────────────────────────────────────────────
  static const events = '/home/events';
  static const eventsCalendar = '/home/events/calendar';
  static const eventDetail = '/home/events/:id';
  static const tickets = '/home/events/tickets';

  // ── More / Secondary Navigation ───────────────────────────────────────────
  static const live = '/home/live';
  static const giving = '/home/giving';
  static const givingHistory = '/home/giving/history';
  static const checkout = '/home/giving/checkout';
  static const groups = '/home/groups';
  static const groupDiscover = '/home/groups/discover';
  static const groupDetail = '/home/groups/:id';
  static const groupChat = '/home/groups/:id/chat';
  static const groupEvents = '/home/groups/:id/events';
  static const groupPrayer = '/home/groups/:id/prayer';
  static const groupLeader = '/home/groups/:id/leader';
  static const devotionals = '/home/devotionals';
  static const journal = '/home/devotionals/journal';

  // ── Devotional Journey (7-step flow) ──────────────────────────────────────
  static const devotionalReader = '/home/devotionals/:id';
  static const devotionalScripture = '/home/devotionals/:id/scripture';
  static const devotionalContent = '/home/devotionals/:id/content';
  static const devotionalReflection = '/home/devotionals/:id/reflection';
  static const devotionalPrayer = '/home/devotionals/:id/prayer';
  static const devotionalJournal = '/home/devotionals/:id/journal';
  static const devotionalComplete = '/home/devotionals/:id/complete';
  static const podcasts = '/home/podcasts';
  static const kids = '/home/kids';
  static const bookstore = '/home/bookstore';
  static const volunteers = '/home/volunteers';
  static const ministryAssignments = '/home/volunteers/assignments';
  static const members = '/home/members';
  static const memberProfile = '/home/members/:id';
  static const myProfile = '/home/my-profile';
  static const news = '/home/news';
  static const newsDetails = '/home/news/details';
  static const settings = '/home/settings';

  // ── Prayer Requests ───────────────────────────────────────────────────────
  static const prayerFeed = '/home/prayer';
  static const submitPrayer = '/home/prayer/submit';

  // ── Testimonies ────────────────────────────────────────────────────────────
  static const testimonies = '/home/testimonies';
  static const submitTestimony = '/home/testimonies/submit';

  // ── Leadership ────────────────────────────────────────────────────────────
  static const leaderApplication = '/home/leadership/apply';
  static const leaderApplicationStatus = '/home/leadership/status';
  static const leaderCovenantSignature = '/home/leadership/covenant';
  static const leaderResources = '/home/leadership/resources';
}
