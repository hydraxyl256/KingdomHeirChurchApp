/// Centralized registry for all cache keys to prevent hardcoding.
abstract final class CacheKeys {
  static const String schemaVersionKey = 'system_cache_schema_version';

  // Dashboard
  static const String dashboardGreeting = 'cache_dashboard_greeting';
  static const String dashboardScripture = 'cache_dashboard_scripture';
  static const String dashboardPrayerCorner = 'cache_dashboard_prayer_corner';
  static const String dashboardRecentSermon = 'cache_dashboard_recent_sermon';
  static const String dashboardActiveSeries = 'cache_dashboard_active_series';
  static const String dashboardFeaturedEvent = 'cache_dashboard_featured_event';
  static const String dashboardServiceStatus = 'cache_dashboard_service_status';
  static const String dashboardAnnouncements = 'cache_dashboard_announcements';
  
  // Sermons
  static const String sermonsList = 'cache_sermons_list';
  static const String sermonContinue = 'cache_sermon_continue';

  // Bible
  static String bibleBooks(int versionId) => 'cache_bible_books_$versionId';
  static String bibleChapters(int versionId, String bookId) => 'cache_bible_chapters_${versionId}_$bookId';
  static String bibleContent(int versionId, String chapterId) => 'cache_bible_content_${versionId}_$chapterId';
  
  static const String bibleLastVersion = 'cache_bible_last_version_id';
  static const String bibleLastBook = 'cache_bible_last_book_id';
  static const String bibleLastChapter = 'cache_bible_last_chapter_id';
  static const String bibleRecentSearches = 'cache_bible_recent_searches';

  // Groups
  static const String groupsList = 'cache_groups_list';
  static String groupDetail(String groupId) => 'cache_group_detail_$groupId';
  
  // Devotionals
  static const String devotionalsActiveSeries = 'cache_devotionals_active_series';
  static const String devotionalsPastSeries = 'cache_devotionals_past_series';
  static String devotionalSeriesDetail(String id) => 'cache_devotionals_detail_$id';
  static String devotionalDays(String id) => 'cache_devotionals_days_$id';

  // Live Services
  static const String liveChatOfflineQueue = 'cache_live_chat_offline_queue';
  static const String liveSermonNotes = 'cache_live_sermon_notes';
}
