// Kingdom Heirs — Vision & Mission content model.
//
// Static, curated copy that drives the immersive Vision & Mission screen.
// Decoupled from any single repository so the screen can be exercised in
// isolation (previews, tests, loading/error states).

import 'package:flutter/material.dart';

/// Vision & Mission copy bundle. Loaded by VisionMissionContentRepository.
class VisionMissionContent {
  const VisionMissionContent({
    required this.headline,
    required this.subheadline,
    required this.heroLine1,
    required this.heroLine2,
    required this.visionStatement,
    required this.visionSupporting,
    required this.missionPillars,
    required this.impact,
    required this.coreValues,
    required this.futureTimeline,
  });

  /// Top eyebrow for the hero ("01 — VISION & MISSION").
  final String headline;

  /// Subheadline beneath the headline.
  final String subheadline;

  /// First line of the hero display heading.
  final String heroLine1;

  /// Second line of the hero display heading.
  final String heroLine2;

  /// Single-sentence vision statement (movement framing).
  final String visionStatement;

  /// Supporting line under the vision statement.
  final String visionSupporting;

  /// Five mission pillars.
  final List<MissionPillar> missionPillars;

  /// Kingdom impact stats.
  final List<ImpactStat> impact;

  /// Six core values.
  final List<CoreValue> coreValues;

  /// Four-phase future roadmap.
  final List<FuturePhase> futureTimeline;

  /// Default, hand-curated content used by the screen until the repository
  /// resolves. Kept here (instead of inlined in widgets) so it's swappable
  /// for a CMS / Supabase-driven source without changing the UI.
  static const VisionMissionContent defaults = VisionMissionContent(
    headline: 'Building Kingdom Leaders.\nTransforming Generations.',
    subheadline:
        'Raising believers who influence families, communities, nations and '
        'generations for Christ.',
    heroLine1: 'Building Kingdom Leaders',
    heroLine2: 'Transforming Generations',
    visionStatement:
        'To see a global generation of Christ-shaped leaders who carry '
        'the presence of God into every sphere of society.',
    visionSupporting:
        'A movement, not a moment. A kingdom, not a programme.',
    missionPillars: [
      MissionPillar(
        index: '01',
        title: 'Spiritual Growth',
        body:
            'Cultivating intimacy with God through prayer, the Word, and '
            'the Holy Spirit.',
        icon: Icons.auto_awesome_rounded,
      ),
      MissionPillar(
        index: '02',
        title: 'Discipleship',
        body:
            'Walking alongside new believers until they become mature, '
            'reproducing disciples of Christ.',
        icon: Icons.school_rounded,
      ),
      MissionPillar(
        index: '03',
        title: 'Leadership Development',
        body:
            'Equipping leaders with biblical wisdom, character, and skill '
            'to serve the Church and the world.',
        icon: Icons.workspace_premium_rounded,
      ),
      MissionPillar(
        index: '04',
        title: 'Community Transformation',
        body:
            'Serving our cities through mercy, justice, and tangible acts '
            'of love that restore dignity.',
        icon: Icons.diversity_3_rounded,
      ),
      MissionPillar(
        index: '05',
        title: 'Global Impact',
        body:
            'Carrying the gospel across borders, planting churches, and '
            'reaching the unreached.',
        icon: Icons.public_rounded,
      ),
    ],
    impact: [
      ImpactStat(
        label: 'Members Reached',
        value: 12480,
        suffix: '+',
        icon: Icons.people_alt_rounded,
      ),
      ImpactStat(
        label: 'Prayers Answered',
        value: 3210,
        suffix: '',
        icon: Icons.local_fire_department_rounded,
      ),
      ImpactStat(
        label: 'Lives Transformed',
        value: 8450,
        suffix: '',
        icon: Icons.favorite_rounded,
      ),
      ImpactStat(
        label: 'Communities Impacted',
        value: 168,
        suffix: '',
        icon: Icons.location_city_rounded,
      ),
      ImpactStat(
        label: 'Nations Reached',
        value: 42,
        suffix: '',
        icon: Icons.public_rounded,
      ),
    ],
    coreValues: [
      CoreValue(
        title: 'Faith',
        body: 'Trust in God as the foundation of every step we take.',
        icon: Icons.spa_rounded,
      ),
      CoreValue(
        title: 'Excellence',
        body: 'Honouring God with the highest quality of our craft.',
        icon: Icons.auto_awesome_rounded,
      ),
      CoreValue(
        title: 'Integrity',
        body: 'Walking in honesty, even when no one is watching.',
        icon: Icons.verified_rounded,
      ),
      CoreValue(
        title: 'Service',
        body: 'Leading by laying our lives down for others.',
        icon: Icons.volunteer_activism_rounded,
      ),
      CoreValue(
        title: 'Leadership',
        body: 'Raising sons and daughters who shape culture for Christ.',
        icon: Icons.workspace_premium_rounded,
      ),
      CoreValue(
        title: 'Community',
        body: 'We were never meant to walk this journey alone.',
        icon: Icons.diversity_3_rounded,
      ),
    ],
    futureTimeline: [
      FuturePhase(
        phase: 'TODAY',
        title: 'Deepening the Core',
        body:
            'Strengthening prayer, discipleship, and leadership pipelines '
            'within our local church.',
      ),
      FuturePhase(
        phase: 'NEXT',
        title: 'The Next Generation',
        body:
            'Launching a dedicated youth and family ministry across every '
            'Kingdom Heirs expression.',
      ),
      FuturePhase(
        phase: 'EXPAND',
        title: 'Future Expansion',
        body:
            'Planting churches across new cities and training centres for '
            'pastoral leadership.',
      ),
      FuturePhase(
        phase: 'GLOBAL',
        title: 'Global Influence',
        body:
            'Carrying our message and our missionaries to every continent, '
            'every tongue, every nation.',
      ),
    ],
  );
}

class MissionPillar {
  const MissionPillar({
    required this.index,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String index;
  final String title;
  final String body;
  final IconData icon;
}

class ImpactStat {
  const ImpactStat({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  final String label;
  final num value;
  final String suffix;
  final IconData icon;
}

class CoreValue {
  const CoreValue({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

class FuturePhase {
  const FuturePhase({
    required this.phase,
    required this.title,
    required this.body,
  });

  final String phase;
  final String title;
  final String body;
}
