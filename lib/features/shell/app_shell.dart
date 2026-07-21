import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/responsive_layout.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/global_sermon_mini_player.dart';

// ─── Navigation Model ─────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    // ignore: unused_element_parameter
    this.badge,
    this.isMore = false,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  /// Optional badge count (null = no badge).
  final int? badge;

  /// Whether this tab opens the "More" overlay instead of navigating.
  final bool isMore;
}

const _navItems = [
  _NavItem(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    route: RouteNames.dashboard,
  ),
  _NavItem(
    label: 'Bible',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    route: RouteNames.bible,
  ),
  _NavItem(
    label: 'Community',
    icon: Icons.groups_2_outlined,
    activeIcon: Icons.groups_2_rounded,
    route: RouteNames.groups,
  ),
  _NavItem(
    label: 'Media',
    icon: Icons.play_circle_outline_rounded,
    activeIcon: Icons.play_circle_rounded,
    route: RouteNames.sermons,
  ),
  _NavItem(
    label: 'More',
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    route: RouteNames.more,
    isMore: true,
  ),
];

// ─── App Shell ────────────────────────────────────────────────────────────────

/// Shell widget providing bottom navigation bar (mobile) or
/// navigation rail (tablet / desktop) via [ResponsiveLayout].
///
/// Architecture (hard requirement from design):
///   MaterialApp.router
///     ↓
///   ShellRoute
///     ↓
///   Scaffold
///        body: full-screen child
///        bottomNavigationBar: NavigationBar(...)
///
/// Nothing wraps the Scaffold except MaterialApp / ShellRoute.
/// The body is NOT a Column around the child — it is the child, full screen.
/// The global mini-player is overlaid above the nav bar via [Stack]
/// inside the body so it never distorts Scaffold layout.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Check primary nav tabs first (index 0‒3), excluding the More tab.
    for (var i = 0; i < _navItems.length - 1; i++) {
      if (location.startsWith(_navItems[i].route)) return i;
    }

    // Any remaining /home/* route belongs under "More" (last tab).
    if (location.startsWith('/home/')) return _navItems.length - 1;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return ResponsiveLayout(
      compact: _CompactShell(currentIndex: currentIndex, child: child),
      medium:
          _RailShell(currentIndex: currentIndex, extended: false, child: child),
      expanded:
          _RailShell(currentIndex: currentIndex, extended: true, child: child),
    );
  }
}

// ─── Compact (Mobile) Shell ────────────────────────────────────────────────────

/// Mobile (compact) variant.
///
/// Scaffold layout:
///   body:               child (fills remaining height, full width)
///   bottomNavigationBar: edge-to-edge nav bar with SafeArea bottom inset
///
/// The global sermon mini-player is overlaid using [Stack] above the
/// bottom of the body (not as a Column sibling) so the Scaffold's
/// intrinsic sizing is never disturbed.
class _CompactShell extends StatelessWidget {
  const _CompactShell({required this.child, required this.currentIndex});

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Body fills the entire remaining height; the mini-player is
      // stacked above the bottom of the body via Positioned.
      body: Stack(
        children: [
          Positioned.fill(child: child),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlobalSermonMiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        isDark: isDark,
        currentIndex: currentIndex,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.isDark, required this.currentIndex});

  final bool isDark;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyMid : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navBarHeight,
          child: Row(
            children: _navItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = i == currentIndex;

              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    if (item.isMore) {
                      context.go(RouteNames.more);
                    } else {
                      context.go(item.route);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? AppColors.goldLight : AppColors.gold;
    final unselectedColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.gold.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 24,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.textTheme.labelSmall!.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rail (Tablet / Desktop) Shell ────────────────────────────────────────────

class _RailShell extends StatelessWidget {
  const _RailShell({
    required this.child,
    required this.currentIndex,
    required this.extended,
  });

  final Widget child;
  final int currentIndex;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? AppColors.navyMid : AppColors.white,
              border: Border(
                right: BorderSide(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationRail(
              selectedIndex: currentIndex,
              extended: extended,
              onDestinationSelected: (i) {
                final item = _navItems[i];
                if (item.isMore) {
                  context.go(RouteNames.more);
                } else {
                  context.go(item.route);
                }
              },
              // Logo header
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: extended
                    ? Row(
                        children: [
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.goldDark, AppColors.gold],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(
                              Icons.church_rounded,
                              color: AppColors.ink,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Kingdom Heir',
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              color:
                                  isDark ? AppColors.warmWhite : AppColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldDark, AppColors.gold],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(
                          Icons.church_rounded,
                          color: AppColors.ink,
                          size: 20,
                        ),
                      ),
              ),
              destinations: _navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: child),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GlobalSermonMiniPlayer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
