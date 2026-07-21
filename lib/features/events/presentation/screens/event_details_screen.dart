import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/events/domain/entities/event.dart';
import 'package:kingdom_heir/features/events/presentation/providers/events_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({required this.eventId, super.key});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final upcomingAsync = ref.watch(upcomingEventsProvider);

    // Resolve event from the cache if available. Note: if not found, we should ideally fetch individually.
    final event =
        upcomingAsync.valueOrNull?.where((e) => e.id == eventId).firstOrNull;

    if (upcomingAsync.isLoading && event == null) {
      return const Scaffold(body: Center(child: AppLoadingIndicator()));
    }

    if (event == null) {
      return Scaffold(
        body: Center(
            child:
                Text(AppLocalizations.of(context)!.eventNotFoundOrHasPassed),),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.coverImageUrl != null
                  ? Image.network(event.coverImageUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.tertiary, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.church_rounded,
                          color: Colors.white54,
                          size: 80,
                        ),
                      ),
                    ),
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(event.title,
                    style: const TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: event.isSoldOut
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.isSoldOut ? 'Sold Out' : 'Registration Open',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: event.isSoldOut
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.priceLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSpacing.md),
                  Text(event.title, style: theme.textTheme.headlineSmall)
                      .animate()
                      .fadeIn(delay: 100.ms),

                  const SizedBox(height: AppSpacing.lg),

                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label:
                        DateFormat('EEEE, MMMM d, yyyy').format(event.startsAt),
                  ).animate().fadeIn(delay: 150.ms),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label:
                        '${DateFormat('h:mm a').format(event.startsAt)} – ${DateFormat('h:mm a').format(event.endsAt)}',
                  ).animate().fadeIn(delay: 200.ms),
                  _InfoRow(
                    icon: event.isOnline
                        ? Icons.videocam_rounded
                        : Icons.location_on_rounded,
                    label: event.location,
                  ).animate().fadeIn(delay: 250.ms),

                  if (event.maxAttendees > 0)
                    _InfoRow(
                      icon: Icons.people_rounded,
                      label: '${event.spotsRemaining} spots remaining',
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppSpacing.xl),
                  Text('About This Event', style: theme.textTheme.titleLarge)
                      .animate()
                      .fadeIn(delay: 350.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // RSVP UI
                  _RsvpSection(event: event).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Add to Calendar',
                    onPressed: () {},
                    variant: AppButtonVariant.outlined,
                    icon: Icons.calendar_month_rounded,
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpSection extends ConsumerWidget {
  const _RsvpSection({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutationState = ref.watch(rsvpMutationProvider);

    if (event.userRsvp == RsvpStatus.going) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.success),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success),
                SizedBox(width: AppSpacing.sm),
                Text(
                  "You're going!",
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: mutationState.isLoading
                  ? null
                  : () => ref.read(rsvpMutationProvider.notifier).submitRsvp(
                        eventId: event.id,
                        status: RsvpStatus.notGoing,
                        guestCount: 0,
                      ),
              child: const Text(
                'Cancel Registration',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    return AppButton(
      label: event.isSoldOut ? 'Sold Out' : 'Register for This Event',
      onPressed: event.isSoldOut || mutationState.isLoading
          ? null
          : () => ref.read(rsvpMutationProvider.notifier).submitRsvp(
                eventId: event.id,
                status: RsvpStatus.going,
                guestCount: 1,
              ),
      icon: Icons.how_to_reg_rounded,
      isLoading: mutationState.isLoading,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
