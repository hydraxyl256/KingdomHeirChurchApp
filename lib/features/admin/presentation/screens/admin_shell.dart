import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A simple responsive layout using NavigationRail for desktop/tablet
    // and a bottom navigation bar for mobile.
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final navigationDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: Text('Members'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
        label: Text('Sermons'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.event_outlined),
        selectedIcon: Icon(Icons.event),
        label: Text('Events'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.gavel_outlined),
        selectedIcon: Icon(Icons.gavel),
        label: Text('Moderation'),
      ),
    ];

    int getSelectedIndex() {
      final location = GoRouterState.of(context).uri.toString();
      if (location.startsWith('/admin/members')) return 1;
      if (location.startsWith('/admin/sermons')) return 2;
      if (location.startsWith('/admin/events')) return 3;
      if (location.startsWith('/admin/moderation')) return 4;
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
      }
    }

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kingdom Heir CMS'),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Exit Admin',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kingdom Heir CMS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: getSelectedIndex(),
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Stats',),
          NavigationDestination(
              icon: Icon(Icons.people_outline), label: 'Users',),
          NavigationDestination(
              icon: Icon(Icons.article_outlined), label: 'Content',),
          NavigationDestination(icon: Icon(Icons.gavel_outlined), label: 'Mod'),
        ],
      ),
    );
  }
}
