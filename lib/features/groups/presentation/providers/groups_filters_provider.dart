// Kingdom Heir — Group Filters Provider
//
// Drives the Discovery screen filter chips. Filters are immutable
// records; toggling creates a new copy. The actual filtering happens
// in a derived provider (`filteredDiscoverableGroupsProvider`) so the
// UI never touches the raw group list.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

/// Immutable set of filter facets active on the Discovery screen.
class GroupFilters {
  const GroupFilters({
    this.lifeStages = const {},
    this.meetingTypes = const {},
    this.privacies = const {},
    this.search = '',
  });

  final Set<GroupLifeStage> lifeStages;
  final Set<GroupMeetingType> meetingTypes;
  final Set<GroupPrivacy> privacies;
  final String search;

  bool get isEmpty =>
      lifeStages.isEmpty &&
      meetingTypes.isEmpty &&
      privacies.isEmpty &&
      search.isEmpty;

  int get activeCount =>
      lifeStages.length +
      meetingTypes.length +
      privacies.length +
      (search.isEmpty ? 0 : 1);

  GroupFilters copyWith({
    Set<GroupLifeStage>? lifeStages,
    Set<GroupMeetingType>? meetingTypes,
    Set<GroupPrivacy>? privacies,
    String? search,
  }) {
    return GroupFilters(
      lifeStages: lifeStages ?? this.lifeStages,
      meetingTypes: meetingTypes ?? this.meetingTypes,
      privacies: privacies ?? this.privacies,
      search: search ?? this.search,
    );
  }
}

class GroupFiltersNotifier extends StateNotifier<GroupFilters> {
  GroupFiltersNotifier() : super(const GroupFilters());

  void toggleLifeStage(GroupLifeStage s) {
    final next = {...state.lifeStages};
    next.contains(s) ? next.remove(s) : next.add(s);
    state = state.copyWith(lifeStages: next);
  }

  void toggleMeetingType(GroupMeetingType t) {
    final next = {...state.meetingTypes};
    next.contains(t) ? next.remove(t) : next.add(t);
    state = state.copyWith(meetingTypes: next);
  }

  void togglePrivacy(GroupPrivacy p) {
    final next = {...state.privacies};
    next.contains(p) ? next.remove(p) : next.add(p);
    state = state.copyWith(privacies: next);
  }

  void setSearch(String q) {
    state = state.copyWith(search: q);
  }

  void clear() {
    state = const GroupFilters();
  }
}

final groupFiltersProvider =
    StateNotifierProvider<GroupFiltersNotifier, GroupFilters>(
  (ref) => GroupFiltersNotifier(),
);

/// The filtered slice of `groupsListProvider` — used by Discovery grid.
final filteredDiscoverableGroupsProvider =
    Provider<AsyncValue<List<CommunityGroup>>>((ref) {
  final asyncGroups = ref.watch(discoverableGroupsProvider);
  final filters = ref.watch(groupFiltersProvider);

  return asyncGroups.whenData((groups) {
    final search = filters.search.trim().toLowerCase();
    return groups.where((g) {
      // Privacy filter
      if (filters.privacies.isNotEmpty &&
          !filters.privacies.contains(g.privacy)) {
        return false;
      }
      // Meeting type filter
      if (filters.meetingTypes.isNotEmpty &&
          !filters.meetingTypes.contains(g.meetingType)) {
        return false;
      }
      // Life stage filter
      if (filters.lifeStages.isNotEmpty &&
          !filters.lifeStages.contains(g.lifeStage)) {
        return false;
      }
      // Search
      if (search.isNotEmpty) {
        final hay =
            '${g.name} ${g.description} ${g.categoryName ?? ''}'.toLowerCase();
        if (!hay.contains(search)) return false;
      }
      return true;
    }).toList();
  });
});
