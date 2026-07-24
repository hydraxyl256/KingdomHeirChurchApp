// Kingdom Heir — LiveServiceRepository YouTube wiring regression test
//
// Pin down the production bug where
// `LiveServiceRepository.getActiveLiveService()` did not read the
// `youtube_video_id` column from `public.live_services` and so the
// live player permanently showed the `_NoStreamPlaceholder`. The
// `sync-youtube-live` edge function writes the canonical 11-char
// video ID to that column, but the Flutter repository was ignoring
// it. The fix is to surface it as `LiveServiceState.youtubeId`
// (for live + upcoming) and `LiveServiceState.replayYoutubeId`
// (for ended).
//
// We test the row-to-state mappers directly via the
// `@visibleForTesting` static helpers, which is the layer the
// production repository delegates to once the Supabase chain has
// returned a row. The end-to-end chain is exercised manually in
// `test/integration` and on device.

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/live_service/data/repositories/live_service_repository.dart';

void main() {
  group('LiveServiceRepository — youtube_video_id wiring', () {
    test('live row: exposes youtube_video_id as LiveServiceState.youtubeId',
        () {
      final state = LiveServiceRepository.liveRowToState({
        'id': 'svc-1',
        'title': 'Sunday Worship',
        'speaker_name': 'Pastor Ade',
        'stream_url': 'https://youtube.com/watch?v=dQw4w9WgXcQ',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'actual_start_at': '2026-07-23T09:00:00.000Z',
        'viewer_count': 142,
        'youtube_video_id': 'dQw4w9WgXcQ',
        'status': 'live',
      });

      expect(state.isLive, isTrue);
      // The canonical fix: youtube_video_id is exposed as youtubeId.
      expect(state.youtubeId, 'dQw4w9WgXcQ');
      expect(state.serviceTitle, 'Sunday Worship');
      expect(state.speakerName, 'Pastor Ade');
      expect(state.viewerCount, 142);
    });

    test(
        'a live row whose youtube_video_id is null leaves youtubeId null',
        () {
      // Defensive: if the sync edge function hasn't written the
      // column yet, the live player must show the placeholder, not
      // crash.
      final state = LiveServiceRepository.liveRowToState({
        'id': 'svc-2',
        'title': 'Sunday Worship',
        'speaker_name': 'Pastor Ade',
        'stream_url': 'https://youtube.com/watch?v=dQw4w9WgXcQ',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'actual_start_at': '2026-07-23T09:00:00.000Z',
        'viewer_count': 142,
        // youtube_video_id intentionally missing → null.
      });

      expect(state.isLive, isTrue);
      expect(state.youtubeId, isNull);
    });

    test('scheduled row: exposes youtube_video_id as youtubeId', () {
      final state = LiveServiceRepository.upcomingRowToState({
        'id': 'svc-3',
        'title': 'Midweek Service',
        'speaker_name': 'Pastor Funke',
        'scheduled_start_at': '2026-07-25T18:00:00.000Z',
        'thumbnail_url': null,
        'youtube_video_id': 'abcd1234567',
      });

      expect(state.isLive, isFalse);
      expect(state.nextServiceTitle, 'Midweek Service');
      expect(state.youtubeId, 'abcd1234567');
    });

    test('ended row: exposes youtube_video_id as replayYoutubeId', () {
      final state = LiveServiceRepository.endedRowToState({
        'id': 'svc-4',
        'title': 'Sunday Worship Replay',
        'speaker_name': 'Pastor Ade',
        'ended_at': '2026-07-21T11:00:00.000Z',
        'thumbnail_url': null,
        'youtube_video_id': 'replay12345',
      });

      expect(state.isLive, isFalse);
      expect(state.replayYoutubeId, 'replay12345');
    });
  });
}
