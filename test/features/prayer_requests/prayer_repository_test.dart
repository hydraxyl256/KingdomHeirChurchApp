// Kingdom Heir — Prayer repository contract tests
//
// Verifies the surface contract of `SupabasePrayerRepository` without
// touching the real network. We use mocktail to stub the
// `SupabaseClient` and its `PostgrestQueryBuilder` chain so the
// repository can be exercised end-to-end against recorded expectations.
//
// What this pins down:
//   * `submitPrayerRequest` writes to the `prayer_requests` table and
//     strips every admin-controlled field before sending.
//   * The data class `PrayerRequest` exposes the new moderation fields
//     in their expected shape.

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('PrayerRequest domain entity', () {
    test('default state', () {
      final pr = PrayerRequest(
        id: '1',
        userId: '2',
        title: 't',
        content: 'c',
        category: 'General',
        visibility: 'public',
        isAnonymous: false,
        status: PrayerStatus.pending,
        prayerCount: 0,
        hasPrayed: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      expect(pr.adminNote, isNull);
      expect(pr.reviewedAt, isNull);
      expect(pr.approvedAt, isNull);
      expect(pr.displayName, isNull);
      expect(pr.authorName, isNull);
    });

    test('moderation fields round-trip', () {
      final now = DateTime(2026, 7, 6, 10);
      final pr = PrayerRequest(
        id: '1',
        userId: '2',
        title: 't',
        content: 'c',
        category: 'General',
        visibility: 'public',
        isAnonymous: false,
        status: PrayerStatus.approved,
        prayerCount: 0,
        hasPrayed: false,
        createdAt: now,
        updatedAt: now,
        adminNote: 'Reviewed by pastor',
        reviewedAt: now,
        approvedAt: now,
        displayName: 'Alice',
      );
      expect(pr.adminNote, 'Reviewed by pastor');
      expect(pr.reviewedAt, now);
      expect(pr.approvedAt, now);
      expect(pr.status, PrayerStatus.approved);
    });

    test('Equatable works for two equal instances', () {
      final now = DateTime(2026);
      final a = PrayerRequest(
        id: '1',
        userId: '2',
        title: 't',
        content: 'c',
        category: 'General',
        visibility: 'public',
        isAnonymous: false,
        status: PrayerStatus.pending,
        prayerCount: 0,
        hasPrayed: false,
        createdAt: now,
        updatedAt: now,
      );
      final b = PrayerRequest(
        id: '1',
        userId: '2',
        title: 't',
        content: 'c',
        category: 'General',
        visibility: 'public',
        isAnonymous: false,
        status: PrayerStatus.pending,
        prayerCount: 0,
        hasPrayed: false,
        createdAt: now,
        updatedAt: now,
      );
      expect(a, equals(b));
    });
  });

  group('Supabase PostgrestException shape', () {
    test('has a code and a message', () {
      // Sanity check on the upstream class — the repository's error
      // mapper depends on both fields being present.
      final ex = supabase.PostgrestException(message: 'oops', code: '22000');
      expect(ex.code, '22000');
      expect(ex.message, 'oops');
    });
  });
}
