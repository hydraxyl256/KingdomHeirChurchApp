import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class MinistryAssignmentsScreen extends StatelessWidget {
  const MinistryAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignments = [
      {
        'date': 'Sun Jun 15',
        'role': 'Worship Team - Lead Guitar',
        'time': '8:00 AM – 11:30 AM',
        'location': 'Main Stage',
      },
      {
        'date': 'Wed Jun 18',
        'role': 'Prayer Team',
        'time': '7:00 PM – 8:30 PM',
        'location': 'Prayer Room',
      },
      {
        'date': 'Sun Jun 22',
        'role': 'Worship Team - Lead Guitar',
        'time': '8:00 AM – 11:30 AM',
        'location': 'Main Stage',
      },
    ];

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.ministryAssignments),),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: assignments.length,
        itemBuilder: (context, i) {
          final a = assignments[i];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['date']!,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                        Text(a['role']!, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          '${a['time']} · ${a['location']}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    color: AppColors.success,
                    onPressed: () {},
                    tooltip: AppLocalizations.of(context)!.confirm,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
        },
      ),
    );
  }
}
