// Kingdom Heir — Dashboard Floating Prayer FAB
//
// Soft-breathing glowing prayer button that hovers above the dashboard
// content. Replaces the previously-proposed static FAB. The breathing
// animation respects the user's reduced-motion preference (see
// `AppMotion.reduce`) — when on, the button renders static at scale 1.0
// and opacity 1.0.
//
// Tapping navigates to `RouteNames.submitPrayer` (the prayer-request
// submission flow).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';

class FloatingPrayerButton extends StatefulWidget {
  const FloatingPrayerButton({super.key});

  @override
  State<FloatingPrayerButton> createState() => _FloatingPrayerButtonState();
}

class _FloatingPrayerButtonState extends State<FloatingPrayerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _scale = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.55, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'Open prayer request',
      button: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final s = reduceMotion ? 1.0 : _scale.value;
          final g = reduceMotion ? 0.85 : _glow.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer soft halo
              Container(
                width: 84 * s,
                height: 84 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.45 * g),
                      AppColors.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              // FAB body
              Material(
                shape: const CircleBorder(),
                elevation: 8,
                shadowColor: AppColors.gold.withValues(alpha: 0.6),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.push(RouteNames.submitPrayer),
                  child: Ink(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.goldDark, AppColors.gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Iconography.prayer,
                        color: AppColors.ink,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}