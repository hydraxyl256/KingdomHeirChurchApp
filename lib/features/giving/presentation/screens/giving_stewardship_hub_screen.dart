import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/giving/presentation/providers/giving_provider.dart';

class GivingStewardshipHubScreen extends ConsumerWidget {
  const GivingStewardshipHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giving & Stewardship'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(RouteNames.givingHistory),
            icon: const Icon(Icons.history_rounded),
            label: const Text('History'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _YearSummaryCard().animate().fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Text('Giving This Year', style: theme.textTheme.titleLarge)
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.md),
            _GivingChart().animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),
            Text('Give Now', style: theme.textTheme.titleLarge)
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: AppSpacing.md),
            _GiveOptions(context: context).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _YearSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(annualSummaryProvider);
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldDark, AppColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Given in $currentYear',
            style: TextStyle(
              color: AppColors.ink.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          summaryAsync.when(
            loading: () =>
                const CircularProgressIndicator(color: AppColors.ink),
            error: (err, _) => const Text('Error loading stats',
                style: TextStyle(color: AppColors.error),),
            data: (total) {
              final currency = ref.watch(currencyProvider);
              return Text(
                '$currency ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Stewardship and Generosity',
            style: TextStyle(
              color: AppColors.ink.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GivingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // In a full implementation, you would use an aggregated monthly breakdown provider.
    // We are mocking the monthly distribution here as placeholder since the schema
    // provides a view for annual aggregates.
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 500,
          barGroups: [
            for (var i = 0; i < 6; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: [50, 200, 180, 420, 190, 240][i].toDouble(),
                    gradient: const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.gold],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 28,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'][v.toInt()],
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _GiveOptions extends StatelessWidget {
  const _GiveOptions({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final options = [
      {
        'label': 'Tithe',
        'icon': Icons.favorite_rounded,
        'color': AppColors.error,
      },
      {
        'label': 'Offering',
        'icon': Icons.volunteer_activism_rounded,
        'color': AppColors.gold,
      },
      {
        'label': 'Missions',
        'icon': Icons.public_rounded,
        'color': AppColors.tertiary,
      },
      {
        'label': 'Building Fund',
        'icon': Icons.church_rounded,
        'color': AppColors.navyAccent,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final o = options[i];
        final color = o['color']! as Color;
        return InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () => context.go(RouteNames.checkout),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(o['icon']! as IconData, color: color, size: 28),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  o['label']! as String,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
