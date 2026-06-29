// Kingdom Heir — Announcements Carousel + After-Live Section
//
// Two widgets in one file for efficient import:
//   AnnouncementsCarousel — auto-advancing PageView with dot indicator
//   AfterLiveSection — complete post-service engagement hub

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

// ─── Helper Classes ──────────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.onTap,
  });
  final LiveAnnouncement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.dividerLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image / icon
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppSpacing.radiusXl),
                ),
                child: announcement.imageUrl != null
                    ? Image.network(
                        announcement.imageUrl!,
                        width: 110,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _AnnouncementImageFallback(),
                      )
                    : const _AnnouncementImageFallback(),
              ),

              // Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (announcement.badgeLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            announcement.badgeLabel!,
                            style:
                                AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        announcement.title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement.description,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDisabled,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementImageFallback extends StatelessWidget {
  const _AnnouncementImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      color: AppColors.navy.withValues(alpha: 0.06),
      child: const Center(
        child: Icon(
          Icons.campaign_rounded,
          color: AppColors.navy,
          size: 32,
        ),
      ),
    );
  }
}

class _AnnouncementDetailSheet extends StatelessWidget {
  const _AnnouncementDetailSheet({required this.announcement});
  final LiveAnnouncement announcement;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: ctrl,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (announcement.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Image.network(
                    announcement.imageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              if (announcement.imageUrl != null)
                const SizedBox(height: AppSpacing.xl),
              Text(
                announcement.title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                announcement.description,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.7,
                ),
              ),
              if (announcement.ctaLabel != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: AppSpacing.buttonHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.gold],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Center(
                      child: Text(
                        announcement.ctaLabel!,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.dividerLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),
    );
  }
}

// ─── After-Live Card ──────────────────────────────────────────────────────────

class _AfterLiveCard extends StatelessWidget {
  const _AfterLiveCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.dividerLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Upcoming Service Tile ────────────────────────────────────────────────────

class _UpcomingServiceTile extends StatelessWidget {
  const _UpcomingServiceTile({required this.service});
  final UpcomingService service;

  @override
  Widget build(BuildContext context) {
    final day = _dayLabel(service.scheduledAt);
    final time = _timeLabel(service.scheduledAt);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.brLg,
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Row(
          children: [
            // Date pill
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    time,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.title,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.speaker != null)
                    Text(
                      service.speaker!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (service.location != null)
                    Text(
                      service.location!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.add_alert_outlined,
              color: AppColors.textDisabled,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday]}\n${dt.day}';
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }
}

// ─── Sermon Thumb Fallback ────────────────────────────────────────────────────

class _SermonThumbFallback extends StatelessWidget {
  const _SermonThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      color: AppColors.navy.withValues(alpha: 0.08),
      child: const Icon(
        Icons.play_circle_outline_rounded,
        color: AppColors.navy,
        size: 32,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANNOUNCEMENTS CAROUSEL
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementsCarousel extends ConsumerStatefulWidget {
  const AnnouncementsCarousel({super.key});

  @override
  ConsumerState<AnnouncementsCarousel> createState() =>
      _AnnouncementsCarouselState();
}

class _AnnouncementsCarouselState
    extends ConsumerState<AnnouncementsCarousel> {
  final _pageCtrl = PageController();
  int _current = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      final count = ref.read(liveAnnouncementsProvider).valueOrNull?.length ?? 0;
      if (count == 0) return;
      final next = (_current + 1) % count;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(liveAnnouncementsProvider);

    return announcementsAsync.when(
      loading: () => const _CarouselSkeleton(),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        color: AppColors.errorContainer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Could not load announcements.',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => ref.refresh(liveAnnouncementsProvider),
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
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_rounded,
                    size: 16,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Announcements',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: items.length,
                itemBuilder: (_, i) => _AnnouncementCard(
                  announcement: items[i],
                  onTap: () => _showDetail(context, items[i]),
                ),
              ),
            ),

            // Dot indicator
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _current ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _current
                          ? AppColors.navy
                          : AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetail(BuildContext context, LiveAnnouncement ann) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnnouncementDetailSheet(announcement: ann),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AFTER-LIVE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class AfterLiveSection extends ConsumerWidget {
  const AfterLiveSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(liveServiceStateProvider).when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load live service status.',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
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
      data: (state) {
        if (state.isLive) return const SizedBox.shrink();

        final latestAsync = ref.watch(latestSermonsProvider);
        final upcomingAsync = ref.watch(upcomingServicesProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Text(
                'Continue Your Worship',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Today's devotional card ───────────────────────────────────────
            _AfterLiveCard(
              icon: Icons.auto_stories_rounded,
              iconColor: AppColors.goldDark,
              title: "Today's Devotional",
              subtitle: 'Continue your daily spiritual journey',
              onTap: () => unawaited(context.push('/home/devotionals')),
            ).animate().fadeIn(delay: 80.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0, delay: 80.ms),

            _AfterLiveCard(
              icon: Icons.menu_book_rounded,
              iconColor: AppColors.navy,
              title: 'Bible Reading Plan',
              subtitle: 'Continue where you left off',
              onTap: () {},
            ).animate().fadeIn(delay: 160.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0, delay: 160.ms),

            _AfterLiveCard(
              icon: Icons.groups_rounded,
              iconColor: const Color(0xFF059669),
              title: 'Community Groups',
              subtitle: 'Connect with your group this week',
              onTap: () => unawaited(context.push('/home/community')),
            ).animate().fadeIn(delay: 240.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0, delay: 240.ms),

            // ── Related sermons ───────────────────────────────────────────────
            latestAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load recent messages.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.refresh(latestSermonsProvider),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(AppColors.gold),
                        foregroundColor: WidgetStateProperty.all(AppColors.ink),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
              data: (sermons) {
                if (sermons.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Text(
                        'Recent Messages',
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: sermons.take(6).length,
                        itemBuilder: (_, i) {
                          final sermon = sermons[i];
                          return GestureDetector(
                            onTap: () => unawaited(
                              context.push('/home/sermons/${sermon.id}'),
                            ),
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(
                                right: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusXl,
                                ),
                                color: Colors.white,
                                border: Border.all(color: AppColors.dividerLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(
                                        AppSpacing.radiusXl,
                                      ),
                                    ),
                                    child: sermon.thumbnailUrl != null
                                        ? Image.network(
                                            sermon.thumbnailUrl!,
                                            height: 90,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const _SermonThumbFallback(),
                                          )
                                        : const _SermonThumbFallback(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sermon.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.textTheme.labelSmall
                                              ?.copyWith(
                                                color: AppColors.navy,
                                                fontWeight: FontWeight.w700,
                                                height: 1.3,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          sermon.speakerName,
                                          style:
                                              AppTypography.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.textDisabled,
                                                fontSize: 10,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(
                                  delay: Duration(milliseconds: i * 60),
                                )
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.06, end: 0),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            // ── Upcoming services ─────────────────────────────────────────────
            upcomingAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load upcoming services.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.refresh(upcomingServicesProvider),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(AppColors.gold),
                        foregroundColor: WidgetStateProperty.all(AppColors.ink),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
              data: (services) {
                if (services.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Text(
                        'Upcoming Services',
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...services.take(3).map(
                          (s) => _UpcomingServiceTile(service: s)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.04, end: 0),
                        ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        );
      },
    );
  }
}
