import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/testimonies/data/repositories/testimony_repository.dart';
import 'package:kingdom_heir/features/testimonies/domain/entities/testimony.dart';
import 'package:kingdom_heir/features/testimonies/presentation/providers/testimony_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

// Mock data removed.

const _categories = [
  'All',
  'Healing',
  'Provision',
  'Salvation',
  'Deliverance',
  'Relationships',
  'Business',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class TestimoniesScreen extends ConsumerStatefulWidget {
  const TestimoniesScreen({super.key});

  @override
  ConsumerState<TestimoniesScreen> createState() => _TestimoniesScreenState();
}

class _TestimoniesScreenState extends ConsumerState<TestimoniesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedCategory = 0;
  final Map<String, ({bool liked, bool amen})> _reactions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testimoniesAsync = ref.watch(testimoniesFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.testimonies),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Community'),
            Tab(text: 'My Testimonies'),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => context.go(RouteNames.submitTestimony),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(AppLocalizations.of(context)!.scriptureShare),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              minimumSize: const Size(0, 36),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Community tab ───────────────────────────────────────────
          Column(
            children: [
              // Category filter
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => FilterChip(
                    label: Text(_categories[i]),
                    selected: _selectedCategory == i,
                    onSelected: (val) {
                      ref.read(testimonyCategoryFilterProvider.notifier).state =
                          _categories[i];
                      setState(() => _selectedCategory = i);
                    },
                    selectedColor: AppColors.gold.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.goldDark,
                    side: BorderSide(
                      color: _selectedCategory == i
                          ? AppColors.gold
                          : Theme.of(context).dividerColor,
                    ),
                    labelStyle: AppTypography.textTheme.labelSmall?.copyWith(
                      fontWeight: _selectedCategory == i
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: _selectedCategory == i ? AppColors.goldDark : null,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: testimoniesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text('Error: $err')),
                  data: (filtered) {
                    if (filtered.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.volunteer_activism_rounded,
                        title: 'No testimonies yet',
                        description: 'Be the first to share what God has done.',
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.massive,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final t = filtered[i];
                        final r = _reactions[t.id];
                        return _TestimonyCard(
                          item: t,
                          isLiked: r?.liked ?? t.isLiked,
                          onLike: () {
                            // Optimistic update locally
                            setState(() {
                              final cur = _reactions[t.id] ??
                                  (liked: t.isLiked, amen: false);
                              _reactions[t.id] =
                                  (liked: !cur.liked, amen: cur.amen);
                            });
                            // Call repo
                            ref.read(testimonyRepositoryProvider).toggleLike(
                                t.id,
                                isLiking: !(r?.liked ?? t.isLiked),);
                          },
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: i * 80),
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // ── My testimonies tab ──────────────────────────────────────
          const AppEmptyState(
            icon: Icons.volunteer_activism_outlined,
            title: 'No testimonies yet',
            description:
                'Tap "Share" to tell the church what God has done in your life.',
          ),
        ],
      ),
    );
  }
}

// ─── Testimony Card ───────────────────────────────────────────────────────────

class _TestimonyCard extends StatelessWidget {
  const _TestimonyCard({
    required this.item,
    required this.isLiked,
    required this.onLike,
  });

  final Testimony item;
  final bool isLiked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured top bar by category
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.gold, // Default category color
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author + category
                Row(
                  children: [
                    AppAvatar(
                      name: item.displayName,
                      size: AppSpacing.avatarSm,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.displayName,
                            style:
                                AppTypography.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            timeago.format(item.createdAt),
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        item.category,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Quote mark + title
                Row(
                  children: [
                    Text(
                      '\u201c',
                      style: AppTypography.quote.copyWith(
                        color: AppColors.gold,
                        fontSize: 40,
                        height: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  item.body,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    height: 1.7,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.xs),

                // Reactions
                Row(
                  children: [
                    _ReactionBtn(
                      icon: Icons.favorite_rounded,
                      outlinedIcon: Icons.favorite_border_rounded,
                      label:
                          '${item.likeCount + (isLiked && !item.isLiked ? 1 : 0)}',
                      isActive: isLiked,
                      activeColor: AppColors.error,
                      onTap: onLike,
                    ),
                    const Spacer(),
                    _ReactionBtn(
                      icon: Icons.chat_bubble_rounded,
                      outlinedIcon: Icons.chat_bubble_outline_rounded,
                      label: '${item.commentCount}',
                      isActive: false,
                      activeColor: AppColors.tertiary,
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ReactionBtn(
                      icon: Icons.share_rounded,
                      outlinedIcon: Icons.share_outlined,
                      label: 'Share',
                      isActive: false,
                      activeColor: AppColors.navyAccent,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionBtn extends StatelessWidget {
  const _ReactionBtn({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? activeColor
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : outlinedIcon,
              size: AppSpacing.iconSm,
              color: color,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Local data model removed as we are now using the live Supabase domain entity
