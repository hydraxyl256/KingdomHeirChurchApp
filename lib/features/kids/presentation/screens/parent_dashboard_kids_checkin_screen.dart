import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/kids/presentation/providers/kids_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class ParentDashboardKidsCheckinScreen extends ConsumerWidget {
  const ParentDashboardKidsCheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionAsync = ref.watch(activeKidsSessionProvider);
    final kidsAsync = ref.watch(myKidsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.kidsCheckin)),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (session) {
          if (session == null) {
            return Center(
              child: Text(
                  AppLocalizations.of(context)!.noActiveKidsSessionsRightNow,),
            );
          }

          final checkinsAsync = ref.watch(myCheckinsProvider(session.id));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current session info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tertiary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.child_care_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${session.sessionDate.day}/${session.sessionDate.month}/${session.sessionDate.year} · ${session.startTime}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const Text(
                              'Session is Active',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: AppSpacing.xl),

                Text('My Children', style: theme.textTheme.titleLarge)
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: AppSpacing.md),

                kidsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (kids) {
                    if (kids.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'You have not registered any children yet. Please contact an admin to register your kids.',
                          ),
                        ),
                      );
                    }

                    return checkinsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (checkins) {
                        // Extract a safety code if any child is checked in
                        final activeCheckins =
                            checkins.where((c) => c.isCheckedIn).toList();
                        final safetyCode = activeCheckins.isNotEmpty
                            ? activeCheckins.first.safetyCode
                            : null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...kids.asMap().entries.map((entry) {
                              final i = entry.key;
                              final child = entry.value;

                              // Find checkin state
                              final checkinRec = checkins
                                  .where(
                                    (c) => c.kidId == child.id && c.isCheckedIn,
                                  )
                                  .firstOrNull;
                              final isCheckedIn = checkinRec != null;

                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.tertiary
                                            .withValues(alpha: 0.15),
                                        radius: 28,
                                        child: Text(
                                          child.firstName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.tertiary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              child.fullName,
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                            Text(
                                              'Age ${child.age} · ${child.gradeClass}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  isCheckedIn
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons
                                                          .radio_button_unchecked_rounded,
                                                  size: 16,
                                                  color: isCheckedIn
                                                      ? AppColors.success
                                                      : AppColors.textDisabled,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isCheckedIn
                                                      ? 'Checked In'
                                                      : 'Not Checked In',
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: isCheckedIn
                                                        ? AppColors.success
                                                        : AppColors
                                                            .textDisabled,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (isCheckedIn) {
                                            ref
                                                .read(
                                                  kidsCheckinNotifierProvider
                                                      .notifier,
                                                )
                                                .checkOut(
                                                  checkinRec.id,
                                                  session.id,
                                                );
                                          } else {
                                            ref
                                                .read(
                                                  kidsCheckinNotifierProvider
                                                      .notifier,
                                                )
                                                .checkIn(child.id, session.id);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCheckedIn
                                              ? AppColors.error
                                              : AppColors.primary,
                                          minimumSize: const Size(90, 36),
                                        ),
                                        child: Text(
                                          isCheckedIn
                                              ? 'Check Out'
                                              : 'Check In',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(
                                    delay:
                                        Duration(milliseconds: 200 + i * 100),
                                  );
                            }),
                            const SizedBox(height: AppSpacing.xl),
                            if (safetyCode != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.security_rounded,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Safety Code: $safetyCode',
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            Text(
                                              'Required for child pick-up today',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
