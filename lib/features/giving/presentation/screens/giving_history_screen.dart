import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/giving/presentation/providers/giving_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GivingHistoryScreen extends ConsumerWidget {
  const GivingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(givingHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.givingHistory),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            label: Text(AppLocalizations.of(context)!.export),
          ),
        ],
      ),
      body: Column(
        children: [
          // Recurring plans banner
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.repeat_rounded, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recurring Giving Active',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Manage your scheduled donations.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context)!.manage),
                ),
              ],
            ),
          ).animate().fadeIn(),

          Expanded(
            child: historyAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (err, stack) =>
                  Center(child: Text('Error loading history: $err')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'No giving history yet',
                    description: 'Your generous donations will appear here.',
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = transactions[i];
                    final isPending = t.status == 'pending';
                    final isFailed =
                        t.status == 'failed' || t.status == 'cancelled';

                    final iconColor = isPending
                        ? AppColors.tertiary
                        : isFailed
                            ? AppColors.error
                            : AppColors.success;

                    final icon = isPending
                        ? Icons.hourglass_empty_rounded
                        : isFailed
                            ? Icons.error_outline_rounded
                            : Icons.check_rounded;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.12),
                        child: Icon(icon, color: iconColor),
                      ),
                      title: Text(t.fund.toUpperCase()),
                      subtitle: Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(t.createdAt),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GH₵ ${t.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isFailed
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5)
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration:
                                  isFailed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (t.status != 'completed')
                            Text(
                              t.status.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
