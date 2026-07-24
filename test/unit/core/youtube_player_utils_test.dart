// Kingdom Heir — YouTube ID normaliser regression test
//
// Pin down the production bug where `sermon.youtubeId` could arrive
// as:
//
//   • a full https://www.youtube.com/watch?v=… URL
//   • a https://youtu.be/… short URL
//   • a https://www.youtube.com/embed/… embed URL
//   • a https://www.youtube.com/live/… live URL
//   • a https://www.youtube.com/shorts/… short URL
//   • a https://m.youtube.com/… or https://music.youtube.com/… mobile URL
//   • a playlist-only URL (https://www.youtube.com/playlist?list=…)
//   • a garbage string
//
// Passing any of these (except the bare ID) to
// `YoutubePlayerController.fromVideoId` produced the production
// "Video unavailable — error 152-4" because the value is not a valid
// 11-character video ID. The fix is to normalise once at the
// boundary between data and player.

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/utils/youtube_player_utils.dart';

void main() {
  group('normaliseYouTubeId — bare IDs', () {
    test('accepts a canonical 11-char ID', () {
      const id = 'dQw4w9WgXcQ';
      final result = normaliseYouTubeId(id);
      expect(result.isValid, isTrue);
      expect(result.videoId, id);
      expect(result.isPlaylistOnly, isFalse);
    });

    test('accepts an ID with the allowed charset (A-Z, a-z, 0-9, _, -)',
        () {
      final result = normaliseYouTubeId('aZ09_-aZ09_');
      expect(result.isValid, isTrue);
      expect(result.videoId, 'aZ09_-aZ09_');
    });
  });

  group('normaliseYouTubeId — watch?v= URLs', () {
    test('extracts v= from a full youtube.com/watch URL', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts v= from a mobile m.youtube.com URL', () {
      final result = normaliseYouTubeId(
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts v= from a music.youtube.com URL', () {
      final result = normaliseYouTubeId(
        'https://music.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts v= when paired with a list= param', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=PLabcdef',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });
  });

  group('normaliseYouTubeId — path-style URLs', () {
    test('extracts the ID from a youtu.be/<id> short URL', () {
      final result = normaliseYouTubeId('https://youtu.be/dQw4w9WgXcQ');
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts the ID from an /embed/<id> URL', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/embed/dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts the ID from a /live/<id> URL (the production '
        'live-service shape)', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/live/dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts the ID from a /shorts/<id> URL', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/shorts/dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('extracts the ID from a /v/<id> URL', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/v/dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });
  });

  group('normaliseYouTubeId — scheme-less input', () {
    test('parses a scheme-less youtube.com URL (user pasted raw)', () {
      final result = normaliseYouTubeId(
        'youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });

    test('trims surrounding whitespace', () {
      final result = normaliseYouTubeId('  dQw4w9WgXcQ\n');
      expect(result.isValid, isTrue);
      expect(result.videoId, 'dQw4w9WgXcQ');
    });
  });

  group('normaliseYouTubeId — playlist-only URLs', () {
    test('rejects a youtube.com/playlist?list=… with no v= param', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/playlist?list=PL1234567890abcdef',
      );
      expect(result.isValid, isFalse);
      expect(result.isPlaylistOnly, isTrue);
      expect(result.error, YouTubeIdError.playlistOnly);
      expect(result.rawPlaylistId, 'PL1234567890abcdef');
    });

    test('rejects a watch URL that has only a list= (no v=)', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/watch?list=PL1234567890abcdef',
      );
      expect(result.isValid, isFalse);
      expect(result.isPlaylistOnly, isTrue);
    });
  });

  group('normaliseYouTubeId — invalid inputs', () {
    test('rejects an empty string', () {
      final result = normaliseYouTubeId('');
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.empty);
    });

    test('rejects a null input', () {
      final result = normaliseYouTubeId(null);
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.empty);
    });

    test('rejects a whitespace-only input', () {
      final result = normaliseYouTubeId('   ');
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.empty);
    });

    test('rejects a non-YouTube URL', () {
      final result = normaliseYouTubeId('https://example.com/watch?v=abc');
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.notYouTube);
    });

    test('rejects a 12-char "ID" (too long for canonical YouTube ID)',
        () {
      final result = normaliseYouTubeId('dQw4w9WgXcQa');
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.invalid);
    });

    test('rejects an 11-char string with an invalid char (bang)', () {
      final result = normaliseYouTubeId('dQw4w9WgXc!');
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.invalid);
    });

    test('rejects a /watch URL whose v= is not 11 chars', () {
      final result = normaliseYouTubeId(
        'https://www.youtube.com/watch?v=short',
      );
      expect(result.isValid, isFalse);
      expect(result.error, YouTubeIdError.invalid);
    });
  });

  group('youTubeWatchUri / youTubeAppUri', () {
    test('youTubeWatchUri returns a canonical watch URL', () {
      final uri = youTubeWatchUri('dQw4w9WgXcQ');
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.youtube.com');
      expect(uri.path, '/watch');
      expect(uri.queryParameters['v'], 'dQw4w9WgXcQ');
    });

    test('youTubeAppUri returns a youtu.be short URL', () {
      final uri = youTubeAppUri('dQw4w9WgXcQ');
      expect(uri.scheme, 'https');
      expect(uri.host, 'youtu.be');
      expect(uri.path, '/dQw4w9WgXcQ');
    });
  });
}
