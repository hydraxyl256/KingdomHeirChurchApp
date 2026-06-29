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

class _CompactShell extends StatelessWidget {
  const _CompactShell({required this.child, required this.currentIndex});

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const GlobalSermonMiniPlayer(),
        ],
      ),
      bottomNavigationBar: Container(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.navBarHeight,
                ),
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
              );
            },
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

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.gold.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated indicator pill
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withValues(alpha: isDark ? 0.2 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: AppSpacing.iconMd,
                      color: isSelected
                          ? AppColors.gold
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                    if (item.badge != null && item.badge! > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${item.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxs),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.textTheme.labelSmall!.copyWith(
                color: isSelected
                    ? AppColors.gold
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
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
          Container(
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
            child: Column(
              children: [
                Expanded(child: child),
                const GlobalSermonMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
