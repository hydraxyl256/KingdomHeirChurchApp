import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A simple responsive layout using NavigationRail for desktop/tablet
    // and a bottom navigation bar for mobile.
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final navigationDestinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: Text(AppLocalizations.of(context)!.dashboard),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: const Icon(Icons.people),
        label: Text(AppLocalizations.of(context)!.members),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.article_outlined),
        selectedIcon: const Icon(Icons.article),
        label: Text(AppLocalizations.of(context)!.sermonsTab),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.event_outlined),
        selectedIcon: const Icon(Icons.event),
        label: Text(AppLocalizations.of(context)!.eventsTab),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.gavel_outlined),
        selectedIcon: const Icon(Icons.gavel),
        label: Text(AppLocalizations.of(context)!.moderation),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.self_improvement_outlined),
        selectedIcon: const Icon(Icons.self_improvement),
        label: Text(AppLocalizations.of(context)!.prayerMod),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.video_library_outlined),
        selectedIcon: const Icon(Icons.video_library),
        label: Text(AppLocalizations.of(context)!.media),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book),
        label: Text(AppLocalizations.of(context)!.devotions),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.build_circle_outlined),
        selectedIcon: const Icon(Icons.build_circle),
        label: Text(AppLocalizations.of(context)!.tools),
      ),
    ];

    int getSelectedIndex() {
      final location = GoRouterState.of(context).uri.toString();
      if (location.startsWith('/admin/members')) return 1;
      if (location.startsWith('/admin/sermons')) return 2;
      if (location.startsWith('/admin/events')) return 3;
      if (location.startsWith('/admin/moderation')) return 4;
      if (location.startsWith('/admin/prayer-moderation')) return 5;
      if (location.startsWith('/admin/media-review')) return 6;
      if (location.startsWith('/admin/devotional-series')) return 7;
      if (location.startsWith('/admin/tools')) return 8;
      return 0; // default to dashboard
    }

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          context.go('/admin');
        case 1:
          context.go('/admin/members');
        case 2:
          context.go('/admin/sermons');
        case 3:
          context.go('/admin/events');
        case 4:
          context.go('/admin/moderation');
        case 5:
          context.go('/admin/prayer-moderation');
        case 6:
          context.go('/admin/media-review');
        case 7:
          context.go('/admin/devotional-series');
        case 8:
          context.go('/admin/tools');
      }
    }

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.kingdomHeirCms),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: AppLocalizations.of(context)!.exitAdmin,
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: getSelectedIndex(),
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: navigationDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // The mobile bar has 4 destinations: Stats, Users, Content, Mod.
    // The 5th desktop entry (Prayer Mod) is reachable from a button
    // on the new AdminPrayerModerationScreen itself or via deep link.
    // We highlight the Mod tab when the user is on either Moderation
    // OR Prayer Moderation to keep the indicator consistent.
    int getSelectedMobileIndex() {
      final location = GoRouterState.of(context).uri.toString();
      if (location.startsWith('/admin/members')) return 1;
      if (location.startsWith('/admin/sermons') ||
          location.startsWith('/admin/media-review') ||
          location.startsWith('/admin/devotional-series')) {
        return 2;
      }
      if (location.startsWith('/admin/moderation') ||
          location.startsWith('/admin/prayer-moderation')) {
        return 3;
      }
      return 0;
    }

    void onMobileSelected(int index) {
      switch (index) {
        case 0:
          context.go('/admin');
        case 1:
          context.go('/admin/members');
        case 2:
          context.go('/admin/sermons');
        case 3:
          context.go('/admin/moderation');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.kingdomHeirCms),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: getSelectedMobileIndex(),
        onDestinationSelected: onMobileSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: 'Content',
          ),
          NavigationDestination(icon: Icon(Icons.gavel_outlined), label: 'Mod'),
        ],
      ),
    );
  }
}
