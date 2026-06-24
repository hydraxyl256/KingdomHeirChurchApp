import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_progress.freezed.dart';
part 'challenge_progress.g.dart';

@freezed
class ChallengeProgress with _$ChallengeProgress {
  const factory ChallengeProgress({
    required String userId,
    String? id,
    @Default(1) int currentDay,
    @Default(0) int completedDays,
    @Default(0.0) double percentComplete,
    DateTime? nextGroupMeeting,
    @Default(0.0) double certificateProgress,
    @Default([]) List<int> completedDayNumbers,
    @Default('') String prayerJournal,
    @Default('') String notes,
  }) = _ChallengeProgress;

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) =>
      _$ChallengeProgressFromJson(json);
}
