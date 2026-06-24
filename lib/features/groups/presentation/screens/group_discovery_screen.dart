// Kingdom Heir — Group Discovery Screen
//
// The full Discovery experience — search bar, filter chips, grid of
// community cards. Reached from the Community tab's "See all" action
// and from the home hero "Discover" pill.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_filters_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/discovery/discovery_grid.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/discovery/filter_chips_bar.dart';

class GroupDiscoveryScreen extends ConsumerStatefulWidget {
  const GroupDiscoveryScreen({super.key});

  @override
  ConsumerState<GroupDiscoveryScreen> createState() =>
      _GroupDiscoveryScreenState();
}

class _GroupDiscoveryScreenState extends ConsumerState<GroupDiscoveryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Discover communities'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                insets.lg,
                insets.xs,
                insets.lg,
                insets.sm,
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.goldDark,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => ref
                            .read(groupFiltersProvider.notifier)
                            .setSearch(v),
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Search by name, topic, or interest…',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(groupFiltersProvider.notifier).setSearch('');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: FilterChipsBar()),
          const DiscoveryGrid(),
        ],
      ),
    );
  }
}
