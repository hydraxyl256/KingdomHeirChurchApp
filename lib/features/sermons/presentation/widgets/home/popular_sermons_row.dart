// Kingdom Heir — Popular Sermons Row (Sermon Home)
//
// Same visual shape as LatestSermonsRow but ordered by viewCount and
// with a different section header. Reuses the same card.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/latest_sermons_row.dart';

class PopularSermonsRow extends StatelessWidget {
  const PopularSermonsRow({
    required this.sermons,
    super.key,
  });

  final List<Sermon> sermons;

  @override
  Widget build(BuildContext context) {
    if (sermons.isEmpty) return const SizedBox.shrink();
    return LatestSermonsRow(
      sermons: sermons,
      title: 'Most popular',
      subtitle: 'Messages our community is engaging with',
    );
  }
}
