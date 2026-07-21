// Kingdom Heir — Sermon Continue Watching Screen
//
// Netflix-style resume screen. List of in-progress sermons with progress
// bars + Resume buttons. Empty state nudges the user to start a sermon.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_continue_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/continue_watching/continue_card.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermons_empty_state.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class SermonContinueScreen extends ConsumerWidget {
  const SermonContinueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(continueWatchingListProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.continueWatching),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: listAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return SermonsEmptyState(
              icon: Icons.play_circle_outline_rounded,
              title: 'Nothing to resume',
              description:
                  "Start a sermon and we'll track your progress so you can pick up where you left off.",
              actionLabel: 'Browse library',
              onAction: () => context.push('/home/sermons/library'),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    '${list.length} sermon${list.length == 1 ? '' : 's'} in progress',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => ContinueCard(item: list[i]),
                    childCount: list.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(continueWatchingListProvider),
        ),
      ),
    );
  }
}
