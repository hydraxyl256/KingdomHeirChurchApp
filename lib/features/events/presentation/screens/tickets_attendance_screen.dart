import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class TicketsAttendanceScreen extends StatelessWidget {
  const TicketsAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tickets = [
      {
        'event': 'Sunday Worship Service',
        'date': 'Jun 15, 2026',
        'code': 'KH-4521',
        'status': 'Active',
      },
      {
        'event': 'Young Adults Night',
        'date': 'Jun 20, 2026',
        'code': 'KH-4388',
        'status': 'Active',
      },
      {
        'event': 'Easter Service 2026',
        'date': 'Apr 5, 2026',
        'code': 'KH-3101',
        'status': 'Used',
      },
      {
        'event': 'Christmas Carol Night',
        'date': 'Dec 24, 2025',
        'code': 'KH-2234',
        'status': 'Used',
      },
    ];

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.ticketsAttendance)),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: tickets.length,
        itemBuilder: (context, i) {
          final t = tickets[i];
          final isActive = t['status'] == 'Active';
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['event']!,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(t['date']!, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.textDisabled.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t['status']!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isActive
                                ? AppColors.success
                                : AppColors.textDisabled,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isActive) ...[
                    const Divider(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket Code',
                              style: theme.textTheme.labelSmall,
                            ),
                            Text(
                              t['code']!,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
        },
      ),
    );
  }
}
