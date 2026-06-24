import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';

class ParticipantJourneyScreen extends StatefulWidget {
  const ParticipantJourneyScreen({super.key});

  @override
  State<ParticipantJourneyScreen> createState() =>
      _ParticipantJourneyScreenState();
}

class _ParticipantJourneyScreenState extends State<ParticipantJourneyScreen> {
  int currentDay = 12;
  int completedDays = 11;
  double percentComplete = 11 / 90;
  DateTime nextMeeting = DateTime.now().add(const Duration(days: 3));
  double certificateProgress = 11 / 90;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Discipleship Journey'),
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressCard(isDark),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCurrentDayCard(isDark),
                  const SizedBox(height: AppSpacing.xl),
                  _buildActionButtons(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Journey Overview',
                    style: AppTypography.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dayNumber = index + 1;
                final isCompleted = dayNumber <= completedDays;
                final isCurrent = dayNumber == currentDay;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted
                        ? AppColors.success
                        : (isCurrent ? AppColors.gold : AppColors.surfaceLight),
                    child: Icon(
                      isCompleted
                          ? Icons.check_rounded
                          : (isCurrent
                              ? Icons.play_arrow_rounded
                              : Icons.lock_outline_rounded),
                      color:
                          isCompleted || isCurrent ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Day $dayNumber',
                    style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,),
                  ),
                  subtitle: Text('Devotional Reading for Day $dayNumber'),
                  trailing: isCurrent
                      ? AppButton(label: 'Read', height: 32, onPressed: () {})
                      : null,
                );
              },
              childCount: 90,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress',
                  style: AppTypography.textTheme.titleMedium,),
              Text('${(percentComplete * 100).toInt()}%',
                  style: AppTypography.textTheme.titleMedium
                      ?.copyWith(color: AppColors.gold),),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: percentComplete,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('Current Day', currentDay.toString()),
              _buildStatMetric('Completed', '$completedDays / 90'),
              _buildStatMetric(
                  'Certificate', '${(certificateProgress * 100).toInt()}%',),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              const Icon(Icons.event_rounded,
                  color: AppColors.navyAccent, size: 20,),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Next Group Meeting: In 3 Days',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.textTheme.headlineSmall
                ?.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),),
        Text(label,
            style: AppTypography.textTheme.bodySmall
                ?.copyWith(color: Colors.grey),),
      ],
    );
  }

  Widget _buildCurrentDayCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),),
            child: const Text('TODAY',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,),),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Day $currentDay: The Power of Prayer',
              style: AppTypography.textTheme.titleLarge
                  ?.copyWith(color: Colors.white),),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Read Matthew 6:5-15 and reflect on what it means to pray continually...',
            style: TextStyle(color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Start Devotional',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Prayer Journal',
            icon: Icons.book_rounded,
            variant: AppButtonVariant.outlined,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            label: 'My Notes',
            icon: Icons.edit_note_rounded,
            variant: AppButtonVariant.outlined,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
