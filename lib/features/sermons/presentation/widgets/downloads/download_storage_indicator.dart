// Kingdom Heir — Download Storage Indicator
//
// Card that shows total downloads + bytes used with a circular ring
// painted by CustomPainter. Anchors the top of the Downloads screen.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

class DownloadStorageIndicator extends StatelessWidget {
  const DownloadStorageIndicator({
    required this.totalBytes,
    required this.downloadCount,
    super.key,
  });

  final int totalBytes;
  final int downloadCount;

  String _humanBytes() {
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(0)} KB';
    }
    if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(totalBytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.goldDark, AppColors.navyAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(
                painter: _StorageRingPainter(
                  progress:
                      0.6, // visual placeholder — ring shows capacity used
                  color: AppColors.warmWhite,
                  trackColor: AppColors.warmWhite.withValues(alpha: 0.25),
                ),
                child: const Center(
                  child: Icon(
                    Icons.cloud_done_rounded,
                    color: AppColors.warmWhite,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$downloadCount downloads',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_humanBytes()} used offline',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageRingPainter extends CustomPainter {
  _StorageRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 4;
    const stroke = 6.0;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StorageRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
