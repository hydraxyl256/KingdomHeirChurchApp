// Kingdom Heir — Sermon Thumbnail
//
// Square / 16:9 thumbnail with a gold gradient fallback for sermons
// without a remote image.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';

class SermonThumbnail extends StatelessWidget {
  const SermonThumbnail({
    required this.thumbnailUrl,
    super.key,
    this.title,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
  });

  final String? thumbnailUrl;
  final String? title;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: radius,
        child: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
            ? Image.network(
                thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _Fallback(title: title ?? 'Sermon'),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const _Fallback(),
              )
            : _Fallback(title: title ?? 'Sermon'),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.title = 'Sermon'});
  final String title;

  @override
  Widget build(BuildContext context) {
    final initial = title.isEmpty ? '?' : title.characters.first.toUpperCase();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyAccent, AppColors.goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.warmWhite,
          fontSize: 40,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
