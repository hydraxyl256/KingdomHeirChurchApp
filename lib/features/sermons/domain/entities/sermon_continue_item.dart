// Kingdom Heir — Sermon Continue Item
//
// Aggregate: a Sermon + the user's watch progress. Drives the Continue
// Watching row on Home and the Continue Watching screen.

import 'package:equatable/equatable.dart';

import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';

class SermonContinueItem extends Equatable {
  const SermonContinueItem({
    required this.sermon,
    required this.positionSeconds,
    required this.totalSeconds,
    required this.lastWatchedAt,
    required this.isCompleted,
  });

  final Sermon sermon;
  final int positionSeconds;
  final int totalSeconds;
  final DateTime lastWatchedAt;
  final bool isCompleted;

  double get progress => totalSeconds == 0 ? 0 : positionSeconds / totalSeconds;

  int get remainingSeconds {
    final r = totalSeconds - positionSeconds;
    if (r < 0) return 0;
    return r;
  }

  String get remainingLabel {
    final m = remainingSeconds ~/ 60;
    if (m <= 0) return 'Under a min left';
    if (m == 1) return '1 min left';
    return '$m min left';
  }

  @override
  List<Object?> get props =>
      [sermon, positionSeconds, totalSeconds, lastWatchedAt, isCompleted];
}
