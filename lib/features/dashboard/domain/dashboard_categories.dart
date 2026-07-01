// Kingdom Heir — Dashboard Category Enums
//
// Pure-Dart value types that pair each timeline item (Daily Journey task,
// Church Today event) with a brand-tinted color + Phosphor icon for the
// redesigned premium timelines. Kept separate from `home_dashboard_models.dart`
// to avoid touching its existing equality / hashCode semantics.

import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Daily Journey — SpiritualTaskKind → color + icon
// ─────────────────────────────────────────────────────────────────────────────

/// Color palette for the 6 daily-journey task kinds. Tuned to feel
/// spiritual, not synthetic — each sits in the brand-aligned range.
@immutable
class JourneyCategoryStyle {
  const JourneyCategoryStyle({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;
}

abstract final class JourneyCategory {
  static const _prayer = JourneyCategoryStyle(
    color: Color(0xFFD4AF37), // gold
    icon: Iconography.taskPrayer,
    label: 'Prayer',
  );
  static const _reading = JourneyCategoryStyle(
    color: Color(0xFF1E40AF), // navy blue
    icon: Iconography.taskReading,
    label: 'Reading',
  );
  static const _reflection = JourneyCategoryStyle(
    color: Color(0xFF7C3AED), // purple
    icon: Iconography.taskReflection,
    label: 'Reflection',
  );
  static const _devotional = JourneyCategoryStyle(
    color: Color(0xFF0EA5E9), // teal
    icon: Iconography.taskDevotional,
    label: 'Devotional',
  );
  static const _worship = JourneyCategoryStyle(
    color: Color(0xFFF97316), // coral
    icon: Iconography.taskWorship,
    label: 'Worship',
  );
  static const _journal = JourneyCategoryStyle(
    color: Color(0xFFE11D48), // rose
    icon: Iconography.taskJournal,
    label: 'Journal',
  );

  /// Style for a given `SpiritualTaskKind`.
  ///
  /// The compiler will warn if a new kind is added without a style entry,
  /// which is exactly the affordance we want — designers should always
  /// pick a color for a new task category.
  static JourneyCategoryStyle forKind(SpiritualTaskKind kind) {
    switch (kind) {
      case SpiritualTaskKind.scripture:
        return _reading;
      case SpiritualTaskKind.devotional:
        return _devotional;
      case SpiritualTaskKind.prayer:
        return _prayer;
      case SpiritualTaskKind.reflection:
        return _reflection;
      case SpiritualTaskKind.worship:
        return _worship;
      case SpiritualTaskKind.journal:
        return _journal;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Church Today — TodayEventCategory → color + label
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class EventCategoryStyle {
  const EventCategoryStyle({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;
}

abstract final class EventCategory {
  static const _prayer = EventCategoryStyle(
    color: Color(0xFF7C3AED),
    label: 'Prayer',
  );
  static const _bibleStudy = EventCategoryStyle(
    color: Color(0xFF1E40AF),
    label: 'Bible Study',
  );
  static const _youth = EventCategoryStyle(
    color: Color(0xFF0EA5E9),
    label: 'Youth',
  );
  static const _sundayService = EventCategoryStyle(
    color: Color(0xFFD4AF37),
    label: 'Sunday Service',
  );
  static const _outreach = EventCategoryStyle(
    color: Color(0xFF16A34A),
    label: 'Outreach',
  );
  static const _choir = EventCategoryStyle(
    color: Color(0xFFDC2626),
    label: 'Choir',
  );
  static const _other = EventCategoryStyle(
    color: Color(0xFF94A3B8),
    label: 'Event',
  );

  static EventCategoryStyle forCategory(TodayEventCategory category) {
    switch (category) {
      case TodayEventCategory.prayer:
        return _prayer;
      case TodayEventCategory.bibleStudy:
        return _bibleStudy;
      case TodayEventCategory.youth:
        return _youth;
      case TodayEventCategory.sundayService:
        return _sundayService;
      case TodayEventCategory.outreach:
        return _outreach;
      case TodayEventCategory.choir:
        return _choir;
      case TodayEventCategory.other:
        return _other;
    }
  }
}
