// Kingdom Heir — Prayer request model unit tests
//
// Covers the JSON parser's handling of:
//   * the new status lifecycle (pending / approved / rejected)
//   * the legacy status values still present in the database
//   * the new moderation columns (admin_note, reviewed_by/at, approved_at)
//   * the display_name synthesized by the public view
//   * the toInsertJson contract: only the four member-controlled
//     fields are sent; status and all admin fields are omitted
//     (the trigger + RPCs own those).

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

void main() {
  group('PrayerRequestModel.fromJson', () {
    test('parses an approved non-anonymous row from the public view', () {
      final model = PrayerRequestModel.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'user_id': '22222222-2222-2222-2222-222222222222',
        'title': 'Healing for my aunt',
        'content': 'Please pray for healing.',
        'category': 'Healing',
        'visibility': 'public',
        'is_anonymous': false,
        'status': 'approved',
        'display_name': 'Jane Doe',
        'prayer_count': 7,
        'approved_at': '2026-07-06T12:00:00Z',
        'created_at': '2026-07-05T10:00:00Z',
        'updated_at': '2026-07-06T12:00:00Z',
      });

      expect(model.title, 'Healing for my aunt');
      expect(model.visibility, 'public');
      expect(model.status, 'approved');
      expect(model.displayName, 'Jane Doe');
      expect(model.prayerCount, 7);
      expect(model.approvedAt, isNotNull);
    });

    test('parses an anonymous approved row — display_name is "Anonymous"', () {
      final model = PrayerRequestModel.fromJson({
        'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'user_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'title': 'Anonymous request',
        'content': 'Please pray.',
        'category': 'General',
        'visibility': 'public',
        'is_anonymous': true,
        'status': 'approved',
        'display_name': 'Anonymous',
        'prayer_count': 0,
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      });

      expect(model.isAnonymous, isTrue);
      expect(model.displayName, 'Anonymous');
    });

    test('falls back to is_public when visibility is absent', () {
      final legacyPublic = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_public': true,
        'is_anonymous': false,
        'status': 'approved',
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      });
      final legacyPrivate = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_public': false,
        'is_anonymous': false,
        'status': 'pending',
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      });
      expect(legacyPublic.visibility, 'public');
      expect(legacyPrivate.visibility, 'private');
    });

    test('handles both prayer_count and pray_count column names', () {
      final fromNewColumn = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': false,
        'status': 'pending',
        'prayer_count': 5,
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      });
      final fromLegacyColumn = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': false,
        'status': 'pending',
        'pray_count': 12,
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      });
      expect(fromNewColumn.prayerCount, 5);
      expect(fromLegacyColumn.prayerCount, 12);
    });

    test('parses new moderation columns when present', () {
      final model = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': false,
        'status': 'rejected',
        'admin_note': 'Please resubmit with more context.',
        'reviewed_by': '99999999-9999-9999-9999-999999999999',
        'reviewed_at': '2026-07-06T11:00:00Z',
        'created_at': '2026-07-05T10:00:00Z',
        'updated_at': '2026-07-06T11:00:00Z',
      });

      expect(model.adminNote, 'Please resubmit with more context.');
      expect(model.reviewedBy, isNotNull);
      expect(model.reviewedAt, isNotNull);
      expect(model.approvedAt, isNull);
    });

    test('updated_at absent falls back to created_at', () {
      final model = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': false,
        'status': 'pending',
        'created_at': '2026-07-06T08:00:00Z',
      });
      expect(model.updatedAt, model.createdAt);
    });
  });

  group('PrayerRequestModel.toEntity status mapping', () {
    PrayerStatus parse(String s) => PrayerRequestModel.fromJson({
          'id': '1',
          'user_id': '2',
          'title': 't',
          'content': 'c',
          'category': 'General',
          'is_anonymous': false,
          'status': s,
          'created_at': '2026-07-06T08:00:00Z',
          'updated_at': '2026-07-06T08:00:00Z',
        }).toEntity().status;

    test('new status values map to the right enum', () {
      expect(parse('pending'), PrayerStatus.pending);
      expect(parse('approved'), PrayerStatus.approved);
      expect(parse('rejected'), PrayerStatus.rejected);
    });

    test('legacy status values still parse', () {
      expect(parse('active'), PrayerStatus.approved);
      expect(parse('archived'), PrayerStatus.rejected);
      expect(parse('answered'), PrayerStatus.approved);
    });
  });

  group('PrayerRequestModel.toEntity identity', () {
    test('anonymous row: authorName is nulled, displayName is "Anonymous"', () {
      final entity = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': true,
        'status': 'approved',
        'display_name': 'Anonymous',
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      }).toEntity();

      expect(entity.authorName, isNull);
      expect(entity.authorAvatarUrl, isNull);
      expect(entity.displayName, 'Anonymous');
    });

    test('non-anonymous row: displayName from view, falls back to authorName', () {
      final fromView = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': false,
        'status': 'approved',
        'display_name': 'View Name',
        'profiles': {'full_name': 'Join Name', 'avatar_url': 'a.png'},
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      }).toEntity();
      expect(fromView.displayName, 'View Name');
      expect(fromView.authorName, 'Join Name');

      final noDisplay = PrayerRequestModel.fromJson({
        'id': '1',
        'user_id': '2',
        'title': 't',
        'content': 'c',
        'category': 'General',
        'is_anonymous': false,
        'status': 'pending',
        'profiles': {'full_name': 'Join Name'},
        'created_at': '2026-07-06T08:00:00Z',
        'updated_at': '2026-07-06T08:00:00Z',
      }).toEntity();
      expect(noDisplay.displayName, 'Join Name');
    });
  });

  group('PrayerRequestModel.toInsertJson', () {
    test('sends only the four member-controlled fields', () {
      final model = PrayerRequestModel(
        id: 'will-be-overwritten',
        userId: 'will-be-overwritten',
        title: 'My request',
        content: 'Please pray for my family.',
        category: 'General',
        visibility: 'public',
        isAnonymous: false,
        status: 'pending',
        prayerCount: 0,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        adminNote: 'should never reach the wire',
        reviewedBy: 'should never reach the wire',
      );

      final json = model.toInsertJson();

      expect(json.keys.toSet(), {
        'title',
        'content',
        'category',
        'visibility',
        'is_anonymous',
      });
      expect(json.containsKey('admin_note'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('reviewed_by'), isFalse);
      expect(json.containsKey('approved_at'), isFalse);
      expect(json.containsKey('requester_name'), isFalse);
    });
  });
}
