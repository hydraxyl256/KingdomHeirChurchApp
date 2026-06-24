// Kingdom Heir — Bottom Inspiration (SECTION 11)
//
// A quiet, reverent card that auto-rotates between 1..N inspirational quotes
// every [rotationInterval]. Each transition is a fade + slight slide-up,
// respecting MediaQuery.disableAnimations. The user can also tap "Next" to
// rotate manually.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

class BottomInspiration extends StatefulWidget {
  const BottomInspiration({
    required this.quotes,
    super.key,
    this.rotationInterval = const Duration(seconds: 12),
  });

  final List<InspirationQuote> quotes;
  final Duration rotationInterval;

  @override
  State<BottomInspiration> createState() => _BottomInspirationState();
}

class _BottomInspirationState extends State<BottomInspiration> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer?.cancel();
    if (widget.quotes.length <= 1) return;
    _timer = Timer.periodic(widget.rotationInterval, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.quotes.length);
    });
  }

  @override
  void didUpdateWidget(covariant BottomInspiration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotationInterval != widget.rotationInterval ||
        oldWidget.quotes != widget.quotes) {
      _scheduleNext();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    setState(() => _index = (_index + 1) % widget.quotes.length);
    _scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    if (widget.quotes.isEmpty) return const SizedBox.shrink();

    final current = widget.quotes[_index];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        insets.lg,
        insets.xl,
        insets.lg,
        insets.huge,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: insets.xl,
          vertical: insets.xxl,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.goldContainer, AppColors.warmWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.format_quote_rounded,
              color: AppColors.goldDark,
              size: 32,
            ),
            SizedBox(height: insets.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey(_index),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.text,
                    textAlign: TextAlign.center,
                    style: AppTypography.quote.copyWith(
                      color: AppColors.navy,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: insets.sm),
                  Text(
                    '— ${current.author}',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.quotes.length > 1) ...[
              SizedBox(height: insets.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.quotes.length, (i) {
                  final isActive = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 18 : 6,
                    height: 6,
                    margin: EdgeInsets.symmetric(horizontal: insets.xxxs),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.goldDark
                          : AppColors.goldDark.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              SizedBox(height: insets.sm),
              TextButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('New inspiration'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.goldDark,
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
