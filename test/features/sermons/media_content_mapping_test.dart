// Kingdom Heir — Sermon.fromMediaContent() Mapping Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';

void main() {
  group('Sermon.fromMediaContent()', () {
    final baseRow = {
      'id':               'abc-123',
      'youtube_video_id': 'dQw4w9WgXcQ',
      'youtube_url':      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'content_type':     'sermon',
      'title':            'Walking by Faith',
      'description':      'A powerful message on faith.',
      'thumbnail_url':    'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      'speaker_name':     'Pastor James',
      'series_name':      'Faith Series',
      'duration_seconds': 3600,
      'published_at':     '2026-06-01T10:00:00Z',
      'tags':             ['faith', 'grace'],
      'is_featured':      true,
      'status':           'published',
      'updated_at':       '2026-06-02T08:00:00Z',
    };

    test('maps id correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.id, 'abc-123');
    });

    test('maps youtube_video_id to youtubeId', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.youtubeId, 'dQw4w9WgXcQ');
    });

    test('maps youtube_url to videoUrl', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.videoUrl, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    });

    test('maps title correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.title, 'Walking by Faith');
    });

    test('maps speaker_name correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.speakerName, 'Pastor James');
    });

    test('maps series_name correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.seriesName, 'Faith Series');
    });

    test('maps duration_seconds correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.durationSeconds, 3600);
    });

    test('maps thumbnail_url correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.thumbnailUrl,
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',);
    });

    test('maps mediaType as video', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.mediaType, SermonMediaType.video);
    });

    test('maps is_featured=true to trendingScore=100', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.trendingScore, 100);
    });

    test('maps is_featured=false to trendingScore=0', () {
      final row = {...baseRow, 'is_featured': false};
      final sermon = Sermon.fromMediaContent(row);
      expect(sermon.trendingScore, 0);
    });

    test('maps tags correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.tags, ['faith', 'grace']);
    });

    test('falls back speaker_name to Kingdom Heirs when null', () {
      final row = {...baseRow, 'speaker_name': null};
      final sermon = Sermon.fromMediaContent(row);
      expect(sermon.speakerName, 'Kingdom Heirs');
    });

    test('falls back series_name to General when null', () {
      final row = {...baseRow, 'series_name': null};
      final sermon = Sermon.fromMediaContent(row);
      expect(sermon.seriesName, 'General');
    });

    test('hasVideo is true', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.hasVideo, isTrue);
    });

    test('published_at parses correctly', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.publishedAt, DateTime.parse('2026-06-01T10:00:00Z'));
    });

    test('audioUrl is null (YouTube-only)', () {
      final sermon = Sermon.fromMediaContent(baseRow);
      expect(sermon.audioUrl, isNull);
    });
  });
}
