// ignore_for_file: one_member_abstracts

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/challenge/domain/models/group_reporting_packet.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return SupabaseChallengeRepository(supabase.Supabase.instance.client);
});

abstract class ChallengeRepository {
  Future<Either<String, void>> submitGroupReport(GroupReportingPacket packet);
}

class SupabaseChallengeRepository implements ChallengeRepository {
  SupabaseChallengeRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, void>> submitGroupReport(
      GroupReportingPacket packet,) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left('You must be logged in to submit a report.');
      }

      final payload = packet.toJson();

      final insertData = {
        'leader_id': user.id,
        'group_name': packet.groupName,
        'country': packet.country,
        'city_region': packet.cityRegion,
        'meeting_type': packet.meetingType,
        'group_start_date': packet.groupStartDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'report_date': packet.reportDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'report_data': payload,
      };

      await _client.from('group_reports').insert(insertData);
      return right(null);
    } catch (e) {
      return left('Failed to submit report: $e');
    }
  }
}
