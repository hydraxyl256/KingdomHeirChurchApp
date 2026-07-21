// ignore_for_file: one_member_abstracts

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/leadership/domain/entities/leader_application.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final leadershipRepositoryProvider = Provider<LeadershipRepository>((ref) {
  return SupabaseLeadershipRepository(supabase.Supabase.instance.client);
});

abstract class LeadershipRepository {
  Future<Either<String, void>> submitLeaderApplication(
    LeaderApplication application,
  );
}

class SupabaseLeadershipRepository implements LeadershipRepository {
  SupabaseLeadershipRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, void>> submitLeaderApplication(
    LeaderApplication application,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left('You must be logged in to apply for leadership.');
      }

      final insertData = {
        'user_id': user.id,
        'status': 'pending',
        'personal_info': {
          'fullName': application.fullName,
          'email': application.email,
          'phone': application.phone,
          'country': application.country,
          'cityState': application.cityState,
          'churchAffiliation': application.churchAffiliation,
          'pastorName': application.pastorName,
          'pastorContact': application.pastorContact,
        },
        'testimony': {
          'conversionStory': application.conversionStory,
          'yearsFollowingChrist': application.yearsFollowingChrist,
          'currentWalk': application.currentWalk,
          'areasOfGrowth': application.areasOfGrowth,
        },
        'spiritual_practices': {
          'bibleReadingFrequency': application.bibleReadingFrequency,
          'prayerFrequency': application.prayerFrequency,
          'churchAttendanceFrequency': application.churchAttendanceFrequency,
          'currentlyServing': application.currentlyServing,
          'servingDescription': application.servingDescription,
        },
        'character_reputation': {
          'honoringChrist': application.honoringChrist,
          'willingToSubmit': application.willingToSubmit,
          'hasUnresolvedConflict': application.hasUnresolvedConflict,
          'conflictExplanation': application.conflictExplanation,
          'involvedInReproach': application.involvedInReproach,
          'reproachExplanation': application.reproachExplanation,
          'hasCriminalConviction': application.hasCriminalConviction,
          'convictionExplanation': application.convictionExplanation,
        },
        'leadership_experience': {
          'whyBecomeLeader': application.whyBecomeLeader,
          'previousLeadershipAreas': application.previousLeadershipAreas,
          'previousLeadershipDescription':
              application.previousLeadershipDescription,
        },
        'commitments_agreed': application.agreedToCommitments,
      };

      await _client.from('leader_applications').insert(insertData);
      return right(null);
    } catch (e) {
      return left('Failed to submit application: $e');
    }
  }
}
