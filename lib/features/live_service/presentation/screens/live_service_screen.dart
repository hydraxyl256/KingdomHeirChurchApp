// Kingdom Heir — Live Service Screen
//
// Premium digital worship experience orchestrator.
// Architecture: CustomScrollView with SliverList for lazy loading.
// Video is sticky via SliverPersistentHeader after hero scrolls away.
//
// Sections:
//   1. LiveHeroSection      — blurred hero, LIVE badge, service info
//   2. LiveVideoPlayer      — YouTube, 16:9, no layout jump
//   3. LiveStatusBar        — LIVE info / countdown
//   4. LiveQuickActions     — 8 animated pill buttons
//   5. AnnouncementsCarousel — church announcements
//   6. LiveChatPanel        — Supabase Realtime chat (expandable)
//   7. AfterLiveSection     — post-service engagement hub

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/announcements_and_after_live.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/live_chat_panel.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/live_hero_section.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/live_prayer_panel.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/live_status_and_actions.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/live_video_player.dart';

class LiveServiceScreen extends ConsumerStatefulWidget {
  const LiveServiceScreen({super.key});

  @override
  ConsumerState<LiveServiceScreen> createState() => _LiveServiceScreenState();
}

class _LiveServiceScreenState extends ConsumerState<LiveServiceScreen>
    with TickerProviderStateMixin {
  // Chat expand state
  bool _chatExpanded = true;

  // Scroll
  final _scrollController = ScrollController();
  bool _videoSticky = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Hero is 200px — make video sticky after hero scrolls off
    final sticky = _scrollController.offset > 160;
    if (sticky != _videoSticky) {
      setState(() => _videoSticky = sticky);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(liveServiceStateProvider);
    final isLive = stateAsync.valueOrNull?.isLive ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        // No standard AppBar — hero replaces it
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // ── Main scrollable content ─────────────────────────────────
            RefreshIndicator(
              color: AppColors.gold,
              backgroundColor: Colors.white,
              onRefresh: () async {
                ref
                  ..invalidate(liveServiceStateProvider)
                  ..invalidate(liveAnnouncementsProvider)
                  ..invalidate(upcomingServicesProvider);
                await Future<void>.delayed(const Duration(milliseconds: 800));
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // 1. Hero Section (200px)
                  const SliverToBoxAdapter(
                    child: LiveHeroSection(),
                  ),

                  // 2. Video Player (sticky after hero scrolls off)
                  if (_videoSticky)
                    // After hero is gone — player is in sticky header
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _VideoStickyDelegate(),
                    )
                  else
                    // Initially inline below hero
                    const SliverToBoxAdapter(
                      child: LiveVideoPlayer(),
                    ),

                  // 3. Status Bar
                  const SliverToBoxAdapter(
                    child: LiveStatusBar(),
                  ),

                  // 4. Quick Actions
                  const SliverToBoxAdapter(
                    child: LiveQuickActions(),
                  ),

                  // 5. Announcements Carousel
                  const SliverToBoxAdapter(
                    child: AnnouncementsCarousel(),
                  ),

                  // 6. Chat Section
                  SliverToBoxAdapter(
                    child: _ChatSection(
                      expanded: _chatExpanded,
                      onToggle: () =>
                          setState(() => _chatExpanded = !_chatExpanded),
                    ),
                  ),

                  // 7. After-Live Section (only when not live)
                  if (!isLive)
                    const SliverToBoxAdapter(
                      child: AfterLiveSection(),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxxl),
                  ),
                ],
              ),
            ),

            // ── Floating Prayer FAB ─────────────────────────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              right: AppSpacing.xl,
              child: _PrayerFAB()
                  .animate()
                  .scale(
                    begin: Offset.zero,
                    end: const Offset(1, 1),
                    delay: 600.ms,
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(delay: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky Video Header Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _VideoStickyDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => _videoHeight;

  @override
  double get maxExtent => _videoHeight;

  // 16:9 ratio on 360dp screen = 202.5; clamp to 200.
  double get _videoHeight {
    // Evaluated at layout time; fallback safe.
    return 202.5;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const LiveVideoPlayer();
  }

  @override
  bool shouldRebuild(_VideoStickyDelegate old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Expandable Chat Section
// ─────────────────────────────────────────────────────────────────────────────

class _ChatSection extends StatelessWidget {
  const _ChatSection({
    required this.expanded,
    required this.onToggle,
  });
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          top: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expand/collapse header
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_rounded,
                      size: 15, color: AppColors.navy,),
                  const SizedBox(width: 6),
                  Text(
                    'Live Chat',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary, size: 20,),
                  ),
                ],
              ),
            ),
          ),

          // Chat content
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: expanded ? 520 : 0,
              child: expanded ? const LiveChatPanel() : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer FAB
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerFAB extends StatefulWidget {
  @override
  State<_PrayerFAB> createState() => _PrayerFABState();
}

class _PrayerFABState extends State<_PrayerFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseScale,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const LivePrayerPanel(),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldDark, AppColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.self_improvement_rounded,
            color: AppColors.ink,
            size: 26,
          ),
        ),
      ),
    );
  }
}
