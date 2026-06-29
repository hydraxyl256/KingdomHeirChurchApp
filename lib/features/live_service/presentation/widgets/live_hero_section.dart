// Kingdom Heir — Live Hero Section
//
// Premium blurred-background hero that replaces the standard AppBar.
// Shows dynamic LIVE badge with pulse, service info, speaker, and viewer count.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';

class LiveHeroSection extends ConsumerWidget {
  const LiveHeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(liveServiceStateProvider);
    final viewerCount = ref.watch(liveViewerCountProvider).valueOrNull ?? 0;

    return stateAsync.when(
      loading: () => const _HeroSkeleton(),
      error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Live service unavailable',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your connection and try again.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => ref.refresh(liveServiceStateProvider),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.gold),
                      foregroundColor:
                          WidgetStateProperty.all(AppColors.ink),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
      data: (state) => _HeroContent(state: state, viewerCount: viewerCount),
    );
  }
}

// ─── Hero Content ─────────────────────────────────────────────────────────────

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.state, required this.viewerCount});
  final LiveServiceState state;
  final int viewerCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred thumbnail background
          if (state.thumbnailUrl != null)
            Image.network(
              state.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _HeroPlaceholderBg(),
            )
          else
            const _HeroPlaceholderBg(),

          // Blur filter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const ColoredBox(color: Colors.transparent),
          ),

          // Dark gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A1628).withValues(alpha: 0.6),
                  const Color(0xFF0A1628).withValues(alpha: 0.92),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: LIVE badge + viewer count
                  Row(
                    children: [
                      if (state.isLive)
                        _LiveBadge()
                      else
                        _UpcomingBadge(nextAt: state.nextServiceAt),
                      const Spacer(),
                      if (state.isLive && viewerCount > 0)
                        _ViewerCount(count: viewerCount),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const Spacer(),

                  // Service title
                  Text(
                    state.serviceTitle ?? state.nextServiceTitle ?? 'Kingdom Heirs Church',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.08, end: 0, delay: 100.ms),

                  if (state.seriesName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      state.seriesName!,
                      style: AppTypography.scriptureRef.copyWith(
                        color: AppColors.goldLight,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 180.ms, duration: 400.ms),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  // Speaker + started
                  Row(
                    children: [
                      if (state.speakerName != null) ...[
                        const Icon(Icons.person_rounded,
                            color: Colors.white54, size: 13,),
                        const SizedBox(width: 4),
                        Text(
                          state.speakerName!,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      if (state.isLive && state.durationLabel.isNotEmpty) ...[
                        const Icon(Icons.schedule_rounded,
                            color: Colors.white54, size: 13,),
                        const SizedBox(width: 4),
                        Text(
                          state.startedLabel,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  if (state.currentScriptureRef != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '📖 ${state.currentScriptureRef}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LIVE Badge ───────────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingBadge extends StatelessWidget {
  const _UpcomingBadge({this.nextAt});
  final DateTime? nextAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        nextAt != null ? 'UPCOMING' : 'NO SERVICE',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Viewer Count ─────────────────────────────────────────────────────────────

class _ViewerCount extends StatelessWidget {
  const _ViewerCount({required this.count});
  final int count;

  String _format(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_rounded, color: Colors.white54, size: 14),
        const SizedBox(width: 4),
        Text(
          _format(count),
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: const Color(0xFF0A1628),
    );
  }
}

// ─── Placeholder Background ───────────────────────────────────────────────────

class _HeroPlaceholderBg extends StatelessWidget {
  const _HeroPlaceholderBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.church_rounded, color: Colors.white10, size: 80),
      ),
    );
  }
}
