import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_reporting_packet.freezed.dart';
part 'group_reporting_packet.g.dart';

@freezed
class GroupReportingPacket with _$GroupReportingPacket {
  const factory GroupReportingPacket({
    String? id,
    @Default('') String groupName,
    @Default('') String leaderName,
    @Default('') String country,
    @Default('') String cityRegion,
    @Default('') String meetingType,
    DateTime? groupStartDate,
    DateTime? reportDate,

    // Section 2
    @Default(0) int participantsRegistered,
    @Default(0) int participantsActive,
    @Default(0) int participantsCompleted,
    @Default(0) int participantsAttendedFourPlus,
    @Default(0) int participantsQualifiedCertificate,
    @Default(0) int participantsQualifiedCommissioning,

    // Section 3
    @Default(0) int spiritualGrowthCount,
    @Default(0) int consistentPrayerCount,
    @Default(0) int dailyBibleCount,
    @Default(0) int reconciledRelationshipsCount,
    @Default(0) int activeLocalChurchCount,
    @Default(0) int servingOthersCount,

    // Section 4
    @Default(0) int sharedTestimonyCount,
    @Default(0) int sharedGospelCount,
    @Default(0) int prayedOutsideGroupCount,
    @Default(0) int outreachParticipationCount,
    @Default(0) int professionsOfFaithCount,
    @Default(0) int baptismsCount,

    // Section 5
    @Default(0) int leadershipPotentialCount,
    @Default([]) List<String> potentialFutureLeaders,
    @Default(0) int interestLeadingFutureGroupCount,
    @Default(0) int interestVesselSchoolCount,

    // Section 6
    @Default('') String significantTestimony,
    @Default(false) bool contactForFeature,
    @Default(false) bool photoPermission,
    @Default(false) bool videoPermission,

    // Section 7
    @Default(0) int futureGroupsExpected,
    @Default(0) int futureLeadersExpected,
    DateTime? expectedLaunchDate,
    @Default(0) int projectedFutureParticipants,

    // Section 8
    @Default(false) bool completedReportingRequirements,
    @Default(false) bool faithfullyFacilitated,
    @Default(false) bool identifiedFutureLeaders,
    @Default(false) bool wouldLikeToLeadAnotherGroup,
    @Default(false) bool wouldLikeAdditionalCoaching,
    @Default('') String supportAreas,
    @Default(false) bool finalAffirmation,
  }) = _GroupReportingPacket;

  factory GroupReportingPacket.fromJson(Map<String, dynamic> json) =>
      _$GroupReportingPacketFromJson(json);
}
