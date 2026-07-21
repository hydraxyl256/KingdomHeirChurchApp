import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/volunteers/presentation/providers/volunteer_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class VolunteerHubScreen extends ConsumerWidget {
  const VolunteerHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final opportunitiesAsync = ref.watch(volunteerOpportunitiesProvider);
    final applicationsAsync = ref.watch(myVolunteerApplicationsProvider);

    // Using dummy stats for impact summary until a stats backend is requested
    final stats = [
      {'label': 'Hours This Month', 'value': '12'},
      {'label': 'Events Served', 'value': '5'},
      {'label': 'Ministry Area', 'value': 'Worship'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.volunteerHub),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteNames.ministryAssignments),
            child: Text(AppLocalizations.of(context)!.mySchedule),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Impact summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Impact',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stats
                        .map(
                          (s) => Column(
                            children: [
                              Text(
                                s['value']!,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                s['label']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: AppSpacing.xl),

            Text('Open Opportunities', style: theme.textTheme.titleLarge)
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.md),

            opportunitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (opportunities) {
                if (opportunities.isEmpty) {
                  return const Center(
                    child: Text(
                      'No volunteer opportunities available right now.',
                    ),
                  );
                }

                return applicationsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (applications) {
                    return Column(
                      children: opportunities.asMap().entries.map((entry) {
                        final i = entry.key;
                        final o = entry.value;

                        final hasApplied = applications
                            .any((app) => app.opportunityId == o.id);
                        final application = hasApplied
                            ? applications
                                .firstWhere((app) => app.opportunityId == o.id)
                            : null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: const Icon(
                                Icons.volunteer_activism_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              o.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${o.timeDescription} · ${o.openSlots} slots open',
                            ),
                            trailing: hasApplied
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: application?.status == 'approved'
                                          ? AppColors.success
                                              .withValues(alpha: 0.1)
                                          : Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      application?.status.toUpperCase() ??
                                          'APPLIED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: application?.status == 'approved'
                                            ? AppColors.success
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                            volunteerApplicationNotifierProvider
                                                .notifier,
                                          )
                                          .apply(o.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 32),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 200 + i * 80),
                            );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
