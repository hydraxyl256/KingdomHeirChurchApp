// Kingdom Heir — Sermon Library Filters
//
// Filter state for the Sermon Library screen. Mirrors the pattern used
// in the Community Groups filters provider.

import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:kingdom_heir/features/sermons/data/mock/reflection_prompts.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

enum SermonDateRange {
  thisWeek,
  thisMonth,
  thisYear,
  allTime,
}

extension SermonDateRangeX on SermonDateRange {
  String get label => switch (this) {
        SermonDateRange.thisWeek => 'This week',
        SermonDateRange.thisMonth => 'This month',
        SermonDateRange.thisYear => 'This year',
        SermonDateRange.allTime => 'All time',
      };
}

class SermonLibraryFilters {
  const SermonLibraryFilters({
    this.topic,
    this.speakerName,
    this.seriesName,
    this.scriptureBook,
    this.ministry,
    this.dateRange,
    this.favoritesOnly = false,
    this.downloadsOnly = false,
    this.audioOnly = false,
    this.videoOnly = false,
  });

  final String? topic;
  final String? speakerName;
  final String? seriesName;
  final String? scriptureBook;
  final String? ministry;
  final SermonDateRange? dateRange;
  final bool favoritesOnly;
  final bool downloadsOnly;
  final bool audioOnly;
  final bool videoOnly;

  bool get isActive =>
      topic != null ||
      speakerName != null ||
      seriesName != null ||
      scriptureBook != null ||
      ministry != null ||
      dateRange != null ||
      favoritesOnly ||
      downloadsOnly ||
      audioOnly ||
      videoOnly;

  int get activeCount {
    var c = 0;
    if (topic != null) c++;
    if (speakerName != null) c++;
    if (seriesName != null) c++;
    if (scriptureBook != null) c++;
    if (ministry != null) c++;
    if (dateRange != null) c++;
    if (favoritesOnly) c++;
    if (downloadsOnly) c++;
    if (audioOnly) c++;
    if (videoOnly) c++;
    return c;
  }

  SermonLibraryFilters copyWith({
    String? topic,
    String? speakerName,
    String? seriesName,
    String? scriptureBook,
    String? ministry,
    SermonDateRange? dateRange,
    bool? favoritesOnly,
    bool? downloadsOnly,
    bool? audioOnly,
    bool? videoOnly,
    bool clearTopic = false,
    bool clearDateRange = false,
  }) =>
      SermonLibraryFilters(
        topic: clearTopic ? null : (topic ?? this.topic),
        speakerName: speakerName ?? this.speakerName,
        seriesName: seriesName ?? this.seriesName,
        scriptureBook: scriptureBook ?? this.scriptureBook,
        ministry: ministry ?? this.ministry,
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
        downloadsOnly: downloadsOnly ?? this.downloadsOnly,
        audioOnly: audioOnly ?? this.audioOnly,
        videoOnly: videoOnly ?? this.videoOnly,
      );

  static const empty = SermonLibraryFilters();
}

final sermonLibraryFiltersProvider =
    StateProvider<SermonLibraryFilters>((ref) => SermonLibraryFilters.empty);

/// All topics known to the seed. Drives the topic-chips bar.
final availableTopicsProvider = Provider<List<String>>((ref) {
  final base = ref.watch(sermonsListProvider);
  final fromData = <String>{};
  
  if (base.hasValue && base.value != null) {
    for (final s in base.value!) {
      fromData.addAll(s.topics);
    }
  }

  final combined = <String>[
    ...ReflectionPrompts.topics,
    ...fromData.where((t) => !ReflectionPrompts.topics.contains(t)),
  ];
  return combined;
});

/// All ministries known to the seed.
final availableMinistriesProvider = Provider<List<String>>((ref) {
  final base = ref.watch(sermonsListProvider);
  final out = <String>{};
  if (base.hasValue && base.value != null) {
    for (final s in base.value!) {
      if (s.ministry != null) out.add(s.ministry!);
    }
  }
  return out.toList()..sort();
});

/// All speakers dynamically derived from production data.
final availableSpeakersProvider = Provider<List<String>>((ref) {
  final base = ref.watch(sermonsListProvider);
  final out = <String>{};
  if (base.hasValue && base.value != null) {
    for (final s in base.value!) {
      if (s.speakerName.isNotEmpty) out.add(s.speakerName);
    }
  }
  return out.toList()..sort();
});

/// All series dynamically derived from production data.
final availableSeriesProvider = Provider<List<String>>((ref) {
  final base = ref.watch(sermonsListProvider);
  final out = <String>{};
  if (base.hasValue && base.value != null) {
    for (final s in base.value!) {
      if (s.seriesName.isNotEmpty) out.add(s.seriesName);
    }
  }
  return out.toList()..sort();
});

/// Filtered + searched sermon list for the Library screen.
final filteredLibrarySermonsProvider =
    Provider<AsyncValue<List<Sermon>>>((ref) {
  final base = ref.watch(sermonsListProvider);
  final filters = ref.watch(sermonLibraryFiltersProvider);
  final query = ref.watch(sermonSearchQueryProvider).toLowerCase();

  return base.whenData((sermons) {
    var result = List<Sermon>.from(sermons);

    if (query.isNotEmpty) {
      result = result.where((s) {
        return s.title.toLowerCase().contains(query) ||
            s.speakerName.toLowerCase().contains(query) ||
            s.seriesName.toLowerCase().contains(query) ||
            s.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    if (filters.topic != null) {
      result = result.where((s) => s.topics.contains(filters.topic)).toList();
    }
    if (filters.speakerName != null) {
      result =
          result.where((s) => s.speakerName == filters.speakerName).toList();
    }
    if (filters.seriesName != null) {
      result = result.where((s) => s.seriesName == filters.seriesName).toList();
    }
    if (filters.ministry != null) {
      result = result.where((s) => s.ministry == filters.ministry).toList();
    }
    if (filters.favoritesOnly) {
      result = result.where((s) => s.isFavorited).toList();
    }
    if (filters.downloadsOnly) {
      result = result.where((s) => s.isDownloaded).toList();
    }
    if (filters.audioOnly) {
      result = result.where((s) => s.hasAudio && !s.hasVideo).toList();
    }
    if (filters.videoOnly) {
      result = result.where((s) => s.hasVideo).toList();
    }
    if (filters.dateRange != null) {
      final now = DateTime.now();
      final cutoff = switch (filters.dateRange!) {
        SermonDateRange.thisWeek => now.subtract(const Duration(days: 7)),
        SermonDateRange.thisMonth => now.subtract(const Duration(days: 30)),
        SermonDateRange.thisYear => now.subtract(const Duration(days: 365)),
        SermonDateRange.allTime => DateTime(1970),
      };
      result = result.where((s) => s.publishedAt.isAfter(cutoff)).toList();
    }

    return result;
  });
});
