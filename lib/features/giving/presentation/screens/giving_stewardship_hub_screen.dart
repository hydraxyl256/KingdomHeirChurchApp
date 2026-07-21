import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/features/giving/presentation/providers/giving_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GivingStewardshipHubScreen extends ConsumerWidget {
  const GivingStewardshipHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.givingStewardship),
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
            const _DonateSecurelyCta()
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
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
              color: scheme.onPrimary.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          summaryAsync.when(
            loading: () => CircularProgressIndicator(
              color: scheme.onPrimary,
            ),
            error: (_, __) => Text(
              'Error loading stats',
              style: TextStyle(color: scheme.onPrimary),
            ),
            data: (total) {
              final currency = ref.watch(currencyProvider);
              return Text(
                '$currency ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: scheme.onPrimary,
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
              color: scheme.onPrimary.withValues(alpha: 0.65),
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
    final scheme = Theme.of(context).colorScheme;
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
                    gradient: LinearGradient(
                      colors: [scheme.tertiary, scheme.primary],
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

/// Single premium "Donate Securely" CTA card that explains the
/// redirect-to-hosted-page flow and exposes the primary donation
/// action. Wraps the call in a local `StatefulWidget` so the button
/// shows a spinner while `openDonationPage` is in flight, and so a
/// rapid second tap is visually suppressed in addition to the
/// `_inFlight` guard in the launcher itself.
class _DonateSecurelyCta extends StatefulWidget {
  const _DonateSecurelyCta();

  @override
  State<_DonateSecurelyCta> createState() => _DonateSecurelyCtaState();
}

class _DonateSecurelyCtaState extends State<_DonateSecurelyCta> {
  bool _busy = false;

  Future<void> _onDonate() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await openDonationPage(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onContainer = scheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Donate Securely',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: onContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.open_in_new_rounded,
                          color: scheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your gift supports the work of Kingdom Heirs Foundation.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onContainer.withValues(alpha: 0.75),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'You will be redirected to our secure hosted payment page to '
            'complete your gift. Card and mobile money payments are '
            'processed there — never inside this app.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: onContainer.withValues(alpha: 0.65),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _busy ? null : _onDonate,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                disabledBackgroundColor: scheme.primary.withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              child: _busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          scheme.onPrimary,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, size: 18),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Donate Securely',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Icon(Icons.open_in_new_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
