// Kingdom Heir — Recommended For You Row (Sermon Home)
//
// Horizontal rail tagged "Because you watched [topic]". Reuses the
// LatestSermonsRow card.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/latest_sermons_row.dart';

class RecommendedForYouRow extends StatelessWidget {
  const RecommendedForYouRow({
    required this.sermons,
    super.key,
    this.topic,
  });

  final List<Sermon> sermons;
  final String? topic;

  @override
  Widget build(BuildContext context) {
    if (sermons.isEmpty) return const SizedBox.shrink();
    final subtitle = topic == null
        ? 'Picked for your walk'
        : 'Because you watched messages tagged $topic';
    return LatestSermonsRow(
      sermons: sermons,
      title: 'Recommended for you',
      subtitle: subtitle,
    );
  }
}
