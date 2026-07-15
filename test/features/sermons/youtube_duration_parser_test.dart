// Kingdom Heir — YouTube ISO 8601 Duration Parser Tests

import 'package:flutter_test/flutter_test.dart';

// We can't import the Deno edge function directly, so we replicate
// the same parsing logic here for unit testing the Dart equivalent.
// If you ever port the sync to a Dart worker, update the import below.

/// Parses an ISO 8601 duration string to total seconds.
/// Mirrors the TypeScript parseIso8601Duration in the Edge Function.
int parseIso8601Duration(String iso) {
  if (iso.isEmpty || !iso.startsWith('P')) return 0;
  final match = RegExp(
    r'P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
  ).firstMatch(iso);
  if (match == null) return 0;
  final days    = int.tryParse(match.group(1) ?? '') ?? 0;
  final hours   = int.tryParse(match.group(2) ?? '') ?? 0;
  final minutes = int.tryParse(match.group(3) ?? '') ?? 0;
  final seconds = int.tryParse(match.group(4) ?? '') ?? 0;
  return days * 86400 + hours * 3600 + minutes * 60 + seconds;
}

void main() {
  group('parseIso8601Duration', () {
    test('parses full format PT1H30M45S', () {
      expect(parseIso8601Duration('PT1H30M45S'), 5445);
    });

    test('parses minutes only PT45M', () {
      expect(parseIso8601Duration('PT45M'), 2700);
    });

    test('parses hours only PT1H', () {
      expect(parseIso8601Duration('PT1H'), 3600);
    });

    test('parses seconds only PT30S', () {
      expect(parseIso8601Duration('PT30S'), 30);
    });

    test('parses hours and minutes PT2H15M', () {
      expect(parseIso8601Duration('PT2H15M'), 8100);
    });

    test('parses hours, minutes, seconds PT1H30M45S', () {
      expect(parseIso8601Duration('PT1H30M45S'), 1 * 3600 + 30 * 60 + 45);
    });

    test('parses days P1DT2H', () {
      expect(parseIso8601Duration('P1DT2H'), 86400 + 7200);
    });

    test('returns 0 for empty string', () {
      expect(parseIso8601Duration(''), 0);
    });

    test('returns 0 for malformed string', () {
      expect(parseIso8601Duration('not-a-duration'), 0);
    });

    test('returns 0 for just P with no values', () {
      expect(parseIso8601Duration('PT'), 0);
    });

    test('handles long sermon PT1H25M30S', () {
      expect(parseIso8601Duration('PT1H25M30S'), 3600 + 1530 + 30);
    });

    test('handles short clip PT3M12S', () {
      expect(parseIso8601Duration('PT3M12S'), 192);
    });
  });
}
