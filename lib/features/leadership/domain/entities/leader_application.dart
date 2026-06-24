import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, underReview, approved, denied, infoRequested }

class LeaderApplication extends Equatable {
  const LeaderApplication({
    required this.id,
    required this.userId,
    required this.status,
    required this.submittedAt,
    // Personal Info
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.cityState, // Testimony
    required this.conversionStory,
    required this.yearsFollowingChrist,
    required this.currentWalk,
    required this.areasOfGrowth, // Spiritual Practices
    required this.bibleReadingFrequency,
    required this.prayerFrequency,
    required this.churchAttendanceFrequency,
    required this.currentlyServing, // Character
    required this.honoringChrist,
    required this.willingToSubmit,
    required this.hasUnresolvedConflict,
    required this.involvedInReproach,
    required this.hasCriminalConviction, // Leadership Readiness
    required this.whyBecomeLeader,
    required this.previousLeadershipAreas, // Commitments
    required this.agreedToCommitments,
    this.reviewedAt,
    this.reviewedBy,
    this.churchAffiliation,
    this.pastorName,
    this.pastorContact,
    this.servingDescription,
    this.conflictExplanation,
    this.reproachExplanation,
    this.convictionExplanation,
    this.previousLeadershipDescription,
  });

  final String id;
  final String userId;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String cityState;
  final String? churchAffiliation;
  final String? pastorName;
  final String? pastorContact;

  final String conversionStory;
  final String yearsFollowingChrist;
  final String currentWalk;
  final String areasOfGrowth;

  final String bibleReadingFrequency;
  final String prayerFrequency;
  final String churchAttendanceFrequency;
  final bool currentlyServing;
  final String? servingDescription;

  final bool honoringChrist;
  final bool willingToSubmit;
  final bool hasUnresolvedConflict;
  final String? conflictExplanation;
  final bool involvedInReproach;
  final String? reproachExplanation;
  final bool hasCriminalConviction;
  final String? convictionExplanation;

  final String whyBecomeLeader;
  final List<String> previousLeadershipAreas;
  final String? previousLeadershipDescription;

  final bool agreedToCommitments;

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        submittedAt,
        fullName,
      ];
}
