import 'package:kingdom_heir/core/config/env.dart';

/// Centralizes the approved YouVersion Bible IDs used by the app.
///
/// The values are configurable through --dart-define so the app no longer
/// relies on a hard-coded Bible ID 1 being available in the licensed account.
class BibleVersionConfig {
  const BibleVersionConfig._();

  static const List<int> defaultPreferredVersionIds = [
    3034,
    12,
    206,
    42,
    2163,
    1207,
    1209,
    2660,
    3427,
    1932,
  ];

  static List<int> preferredVersionIds({List<int>? overrides}) {
    final configured = overrides ?? _parseConfiguredVersionIds();
    if (configured.isEmpty) return List<int>.from(defaultPreferredVersionIds);
    return _deduplicatePositive([...configured, ...defaultPreferredVersionIds]);
  }

  static List<int> _parseConfiguredVersionIds() {
    const configured = Env.biblePreferredVersionIds;
    if (configured.isEmpty) return const [];
    return configured
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map((entry) => int.tryParse(entry) ?? 0)
        .toList();
  }

  static List<int> _deduplicatePositive(Iterable<int> ids) {
    final seen = <int>{};
    return [for (final id in ids) if (id > 0 && seen.add(id)) id];
  }

  static int fallbackVersionId({int? override, List<int>? overrides}) {
    final preferred = preferredVersionIds(overrides: overrides);
    final configuredFallback = override ?? Env.bibleFallbackVersionId;
    if (preferred.contains(configuredFallback)) return configuredFallback;
    return preferred.first;
  }

  static int normalizeVersionId(
    int? requestedVersionId, {
    List<int>? overrides,
    int? fallbackOverride,
  }) {
    if (requestedVersionId != null && requestedVersionId > 0) {
      final preferred = preferredVersionIds(overrides: overrides);
      if (preferred.contains(requestedVersionId)) {
        return requestedVersionId;
      }
    }

    return fallbackVersionId(
      override: fallbackOverride,
      overrides: overrides,
    );
  }

  static List<int> orderedCandidates(
    int requestedVersionId, {
    List<int>? overrides,
    int? fallbackOverride,
  }) {
    final preferred = preferredVersionIds(overrides: overrides);
    final fallback = fallbackVersionId(
      override: fallbackOverride,
      overrides: overrides,
    );
    final requested = preferred.contains(requestedVersionId)
        ? requestedVersionId
        : fallback;

    final seen = <int>{};
    final candidates = <int>[];

    for (final id in [requested, ...preferred]) {
      if (id <= 0 || !seen.add(id)) continue;
      candidates.add(id);
    }

    if (!candidates.contains(fallback)) {
      candidates.add(fallback);
    }

    return candidates;
  }
}
