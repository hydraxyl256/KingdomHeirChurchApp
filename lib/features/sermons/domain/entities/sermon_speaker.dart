// Kingdom Heir — Sermon Speaker
//
// Bio record for a pastor/teacher. Used by the speaker strip on Details
// and the Speaker browse page.

import 'package:equatable/equatable.dart';

class SermonSpeaker extends Equatable {
  const SermonSpeaker({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.sermonCount,
    this.avatarUrl,
    this.languages = const ['English'],
    this.yearsInMinistry = 0,
  });

  final String id;
  final String name;
  final String role;
  final String bio;
  final int sermonCount;
  final String? avatarUrl;
  final List<String> languages;
  final int yearsInMinistry;

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        bio,
        sermonCount,
        avatarUrl,
        languages,
        yearsInMinistry,
      ];
}
