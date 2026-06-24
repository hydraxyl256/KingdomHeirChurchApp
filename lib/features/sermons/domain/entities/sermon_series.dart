// Kingdom Heir — Sermon Series
//
// A multi-message teaching arc. Used by the Series screen + the
// series-collection rail on Home.

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SermonSeries extends Equatable {
  const SermonSeries({
    required this.id,
    required this.title,
    required this.description,
    required this.pastorName,
    required this.startedOn,
    required this.episodeCount,
    required this.coverGradient,
    required this.scriptureAnchor,
    this.completedCount = 0,
    this.upcomingDate,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String pastorName;
  final DateTime startedOn;
  final int episodeCount;
  final List<Color> coverGradient;
  final String scriptureAnchor;
  final int completedCount;
  final DateTime? upcomingDate;
  final String? coverImageUrl;

  double get progress => episodeCount == 0 ? 0 : completedCount / episodeCount;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        pastorName,
        startedOn,
        episodeCount,
        coverGradient,
        scriptureAnchor,
        completedCount,
        upcomingDate,
        coverImageUrl,
      ];
}
