import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';

class DevotionalsScreen extends ConsumerWidget {
  const DevotionalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailyAsync = ref.watch(dailyDevotionalProvider);
    final previousAsync = ref.watch(previousDevotionalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devotionals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () => context.go(RouteNames.journal),
            tooltip: 'My Journal',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Today's feature
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: dailyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (devotional) {
                  if (devotional == null) {
                    return const Center(
                        child: Text('No daily devotional found.'),);
                  }
                  return _TodayDevotionalCard(
                    devotional: devotional,
                  ).animate().fadeIn().slideY(begin: 0.2);
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Previous Devotionals',
                style: theme.textTheme.titleLarge,
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: previousAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),),
              error: (e, st) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              data: (devotionals) {
                if (devotionals.isEmpty) {
                  return const SliverToBoxAdapter(
                      child: Center(child: Text('No previous devotionals.')),);
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _DevotionalListTile(
                      devotional: devotionals[i],
                      delay: Duration(milliseconds: 200 + i * 60),
                    ),
                    childCount: devotionals.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayDevotionalCard extends StatelessWidget {
  const _TodayDevotionalCard({required this.devotional});
  final Devotional devotional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "TODAY'S DEVOTIONAL",
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.title,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            devotional.scriptureRef,
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
            ),
            child: const Text("Read Today's Devotional"),
          ),
        ],
      ),
    );
  }
}

class _DevotionalListTile extends StatelessWidget {
  const _DevotionalListTile({
    required this.devotional,
    required this.delay,
  });
  final Devotional devotional;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          devotional.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
            '${devotional.scriptureRef} · ${devotional.scheduledFor.day}/${devotional.scheduledFor.month}/${devotional.scheduledFor.year}',),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {},
      ),
    ).animate().fadeIn(delay: delay);
  }
}
