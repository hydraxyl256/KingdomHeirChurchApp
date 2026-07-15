// Kingdom Heir — DevotionalSeriesProgress Domain Model Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';

DevotionalSeriesProgress _makeProgress({
  int currentDay = 1,
  int highestUnlockedDay = 1,
  List<int> completedDays = const [],
  int currentStreak = 0,
  int longestStreak = 0,
  DateTime? lastCompletedAt,
  DateTime? completedAt,
}) {
  return DevotionalSeriesProgress(
    id:                 'progress-id',
    userId:             'user-id',
    seriesId:           'series-id',
    currentDay:         currentDay,
    highestUnlockedDay: highestUnlockedDay,
    completedDays:      completedDays,
    currentStreak:      currentStreak,
    longestStreak:      longestStreak,
    startedAt:          DateTime(2026),
    lastCompletedAt:    lastCompletedAt,
    completedAt:        completedAt,
  );
}

void main() {
  group('DevotionalSeriesProgress', () {
    test('isAllComplete returns true when completedAt is set', () {
      final p = _makeProgress(completedAt: DateTime(2026, 3, 31));
      expect(p.isAllComplete, isTrue);
    });

    test('isAllComplete returns false when completedAt is null', () {
      final p = _makeProgress();
      expect(p.isAllComplete, isFalse);
    });

    test('completedToday returns true when lastCompletedAt is today', () {
      final today = DateTime.now();
      final p = _makeProgress(lastCompletedAt: today);
      expect(p.completedToday, isTrue);
    });

    test('completedToday returns false when lastCompletedAt is yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final p = _makeProgress(lastCompletedAt: yesterday);
      expect(p.completedToday, isFalse);
    });

    test('completedToday returns false when null', () {
      final p = _makeProgress();
      expect(p.completedToday, isFalse);
    });

    test('isDayUnlocked returns true for day <= highestUnlockedDay', () {
      final p = _makeProgress(highestUnlockedDay: 5);
      expect(p.isDayUnlocked(1), isTrue);
      expect(p.isDayUnlocked(5), isTrue);
    });

    test('isDayUnlocked returns false for day > highestUnlockedDay', () {
      final p = _makeProgress(highestUnlockedDay: 3);
      expect(p.isDayUnlocked(4), isFalse);
    });

    test('isDayCompleted returns true when day is in completedDays', () {
      final p = _makeProgress(completedDays: [1, 2, 3]);
      expect(p.isDayCompleted(2), isTrue);
    });

    test('isDayCompleted returns false when day not in completedDays', () {
      final p = _makeProgress(completedDays: [1, 2]);
      expect(p.isDayCompleted(3), isFalse);
    });
  });

  group('DevotionalEntry.fromJson', () {
    final baseJson = {
      'id':                  'entry-001',
      'series_id':           'series-id',
      'day_number':          1,
      'title':               'Day 1: Walking by Faith',
      'devotional_body':     'Body text here',
      'scripture_reference': 'Hebrews 11:1',
      'scripture_text':      'Faith is...',
      'reflection_question': 'What does faith mean to you?',
      'action_step':         'Read Hebrews 11 today.',
      'prayer_text':         'Lord, increase my faith.',
      'estimated_read_minutes': 8,
      'status':              'published',
      'created_at':          '2026-01-01T00:00:00Z',
      'updated_at':          '2026-01-01T00:00:00Z',
    };

    test('creates from base JSON with English defaults', () {
      final entry = DevotionalEntry.fromJson(baseJson);
      expect(entry.id, 'entry-001');
      expect(entry.title, 'Day 1: Walking by Faith');
      expect(entry.isFallback, isTrue);
      expect(entry.displayedLanguageCode, 'en');
    });

    test('overlays translation when translationJson provided', () {
      final txJson = {
        'language_code':       'ur',
        'title':               'دن 1: ایمان سے چلنا',
        'devotional_body':     'اردو متن یہاں ہے',
        'translation_status':  'published',
      };
      final entry = DevotionalEntry.fromJson(baseJson, translationJson: txJson);
      expect(entry.title, 'دن 1: ایمان سے چلنا');
      expect(entry.devotionalBody, 'اردو متن یہاں ہے');
      expect(entry.isFallback, isFalse);
      expect(entry.displayedLanguageCode, 'ur');
    });

    test('falls back to English fields when translation field is null', () {
      // Translation exists but missing title — should keep base English title
      final txJson = {
        'language_code':       'zu',
        'title':               null,
        'devotional_body':     'Zulu body text',
        'translation_status':  'published',
      };
      final entry = DevotionalEntry.fromJson(baseJson, translationJson: txJson);
      // title falls back to English when tx title is null
      expect(entry.title, 'Day 1: Walking by Faith');
    });

    test('isPublished returns true for published status', () {
      final entry = DevotionalEntry.fromJson(baseJson);
      expect(entry.isPublished, isTrue);
    });

    test('isPublished returns false for draft', () {
      final draftJson = {...baseJson, 'status': 'draft'};
      final entry = DevotionalEntry.fromJson(draftJson);
      expect(entry.isPublished, isFalse);
    });
  });
}
