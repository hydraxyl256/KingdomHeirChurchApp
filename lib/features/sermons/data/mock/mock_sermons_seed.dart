// Kingdom Heir — Sermon Mock Seed
//
// Fixture data so the redesigned Sermon platform renders end-to-end
// without a backend. Mirrors the pattern used in
// `lib/features/groups/data/mock/mock_groups_seed.dart`.

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_continue_item.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_note.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_prayer_response.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_reflection.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_speaker.dart';

class MockSermonSeed {
  const MockSermonSeed._();

  // ─── Series ──────────────────────────────────────────────────────────
  static const String seriesIdUpperRoom = 'series-upper-room';
  static const String seriesIdKingdom = 'series-kingdom-identity';
  static const String seriesIdGenerals = 'series-generals-table';
  static const String seriesIdRuach = 'series-ruach-breath';
  static const String seriesIdWhole = 'series-whole-heart';
  static const String seriesIdFathers = 'series-fathers-house';

  // ─── Speaker IDs ─────────────────────────────────────────────────────
  static const String speakerIdDaniel = 'speaker-daniel-okafor';
  static const String speakerIdSarah = 'speaker-sarah-adeyemi';
  static const String speakerIdJames = 'speaker-james-mensah';
  static const String speakerIdGrace = 'speaker-grace-ibrahim';
  static const String speakerIdMichael = 'speaker-michael-tan';

  // ─── Sermon IDs (24 total) ───────────────────────────────────────────
  static const String sermonId1 = 'sermon-1';
  static const String sermonId2 = 'sermon-2';
  static const String sermonId3 = 'sermon-3';
  static const String sermonId4 = 'sermon-4';
  static const String sermonId5 = 'sermon-5';
  static const String sermonId6 = 'sermon-6';
  static const String sermonId7 = 'sermon-7';
  static const String sermonId8 = 'sermon-8';
  static const String sermonId9 = 'sermon-9';
  static const String sermonId10 = 'sermon-10';
  static const String sermonId11 = 'sermon-11';
  static const String sermonId12 = 'sermon-12';
  static const String sermonId13 = 'sermon-13';
  static const String sermonId14 = 'sermon-14';
  static const String sermonId15 = 'sermon-15';
  static const String sermonId16 = 'sermon-16';
  static const String sermonId17 = 'sermon-17';
  static const String sermonId18 = 'sermon-18';
  static const String sermonId19 = 'sermon-19';
  static const String sermonId20 = 'sermon-20';
  static const String sermonId21 = 'sermon-21';
  static const String sermonId22 = 'sermon-22';
  static const String sermonId23 = 'sermon-23';
  static const String sermonId24 = 'sermon-24';

  // Featured + Live
  static const String featuredSermonId = sermonId1;
  static const String liveSermonId = sermonId2;

  /// All 24 sermons, ordered most-recent first.
  static final List<Sermon> allSermons = <Sermon>[
    _sermon(
      id: sermonId1,
      title: 'The Upper Room: A Table Set for the Broken',
      speaker: 'Pastor Daniel Okafor',
      seriesId: seriesIdUpperRoom,
      seriesName: 'The Upper Room',
      topics: const ['Grace', 'Healing', 'Faith'],
      ministry: 'Congregational',
      daysAgo: 2,
      duration: 3220,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Luke', chapter: 22, verse: 14),
      ],
      desc:
          'A study of the Last Supper as a portrait of grace — the disciples who would betray, deny, and flee, and a Savior who washed their feet anyway. How do we extend that same grace to ourselves and the people sitting across from us this week?',
      isFeatured: true,
      viewCount: 12400,
    ),
    _sermon(
      id: sermonId2,
      title: 'Sunday Service — January 19 (Live)',
      speaker: 'Pastor Daniel Okafor',
      seriesId: '',
      seriesName: 'Sunday Services',
      topics: const ['Faith', 'Hope'],
      ministry: 'Worship',
      daysAgo: 0,
      duration: 4500,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Psalm', chapter: 95, verse: 6),
      ],
      desc:
          'Our weekly congregational gathering — worship, word, and prayer. Join us in person or stream live below.',
      isLive: true,
      viewCount: 820,
    ),
    _sermon(
      id: sermonId3,
      title: 'Generals of the Faith: Hall of Names',
      speaker: 'Pastor Daniel Okafor',
      seriesId: seriesIdGenerals,
      seriesName: 'Generals of the Faith',
      topics: const ['Faith', 'Leadership'],
      ministry: 'Discipleship',
      daysAgo: 7,
      duration: 2950,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Hebrews', chapter: 11, verse: 1),
        SermonScriptureRef(book: 'Hebrews', chapter: 11, verse: 32),
      ],
      desc:
          'Hebrews 11 is not a list of perfect people — it is a record of imperfect people who trusted a perfect God. A look at what made them extraordinary and how the same faith is available to us.',
      viewCount: 8450,
    ),
    _sermon(
      id: sermonId4,
      title: 'The Breath of God: Receiving the Ruach',
      speaker: 'Pastor Sarah Adeyemi',
      seriesId: seriesIdRuach,
      seriesName: 'The Breath of God',
      topics: const ['Prayer', 'Identity'],
      ministry: 'Spiritual Formation',
      daysAgo: 14,
      duration: 2640,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'John', chapter: 20, verse: 22),
        SermonScriptureRef(book: 'Acts', chapter: 2, verse: 1, endVerse: 4),
      ],
      desc:
          'The same breath that hovered over the waters in Genesis 1 is the breath Jesus exhaled onto His disciples in John 20. What would it look like to stop striving and start receiving?',
      viewCount: 6920,
    ),
    _sermon(
      id: sermonId5,
      title: 'A Whole Heart: Healing the Split Self',
      speaker: 'Pastor Sarah Adeyemi',
      seriesId: seriesIdWhole,
      seriesName: 'A Whole Heart',
      topics: const ['Healing', 'Identity'],
      ministry: 'Counseling',
      daysAgo: 21,
      duration: 2880,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Psalm', chapter: 86, verse: 11),
      ],
      desc:
          'We all live with a private self and a public self — but the gospel invites us into integrity. A practical message on closing the gap between who we are and who we pretend to be.',
      viewCount: 5380,
    ),
    _sermon(
      id: sermonId6,
      title: "The Father's House: Welcome Home",
      speaker: 'Pastor James Mensah',
      seriesId: seriesIdFathers,
      seriesName: "The Father's House",
      topics: const ['Family', 'Grace'],
      ministry: 'Family',
      daysAgo: 28,
      duration: 3120,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Luke', chapter: 15, verse: 11, endVerse: 32),
      ],
      desc:
          'The parable of the prodigal son is really a parable about a generous father. Whether you have been the one who left, the one who stayed, or the one still waiting — this message is for you.',
      viewCount: 7100,
    ),
    _sermon(
      id: sermonId7,
      title: 'Kingdom Identity: Who You Are in Christ',
      speaker: 'Pastor Daniel Okafor',
      seriesId: seriesIdKingdom,
      seriesName: 'Kingdom Identity',
      topics: const ['Identity', 'Hope'],
      ministry: 'Discipleship',
      daysAgo: 35,
      duration: 2780,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: '2 Corinthians', chapter: 5, verse: 17),
      ],
      desc:
          'You are not who you were. You are not who the world says you are. You are a new creation — seated with Christ, hidden in God, defined by love.',
      viewCount: 9100,
    ),
    _sermon(
      id: sermonId8,
      title: 'Praying the Scriptures: A Practical Guide',
      speaker: 'Pastor Sarah Adeyemi',
      seriesId: seriesIdRuach,
      seriesName: 'The Breath of God',
      topics: const ['Prayer'],
      ministry: 'Spiritual Formation',
      daysAgo: 42,
      duration: 2400,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Psalm', chapter: 119, verse: 105),
      ],
      desc:
          'When you do not know what to pray, the Bible does. A walk through the Psalms as a prayer book, with practical patterns for turning any passage into conversation with God.',
      viewCount: 4820,
    ),
    _sermon(
      id: sermonId9,
      title: 'Walking Through the Valley',
      speaker: 'Pastor Grace Ibrahim',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Hope', 'Healing'],
      ministry: 'Pastoral Care',
      daysAgo: 49,
      duration: 2520,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Psalm', chapter: 23, verse: 4),
      ],
      desc:
          'A pastoral message for those walking through a season of grief, loss, or prolonged difficulty. God is not absent in the valley — He is closer than the air you breathe.',
      viewCount: 6250,
    ),
    _sermon(
      id: sermonId10,
      title: 'The God Who Provides',
      speaker: 'Pastor Daniel Okafor',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Provision', 'Faith'],
      ministry: 'Congregational',
      daysAgo: 56,
      duration: 2700,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Genesis', chapter: 22, verse: 14),
      ],
      desc:
          'Jehovah Jireh — the Lord will provide. A study of provision in the Old Testament and the surprising places God shows up for His people.',
      viewCount: 4800,
    ),
    _sermon(
      id: sermonId11,
      title: 'Mothers of the Faith: Deborah, Ruth, and Mary',
      speaker: 'Pastor Grace Ibrahim',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Family', 'Leadership'],
      ministry: "Women's Ministry",
      daysAgo: 63,
      duration: 2950,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Judges', chapter: 4, verse: 4),
        SermonScriptureRef(book: 'Ruth', chapter: 1, verse: 16),
      ],
      desc:
          "A Mother's Day message honoring three women who shaped the story of redemption — and a call to every woman in the room to see the leadership God has entrusted to her.",
      viewCount: 5100,
    ),
    _sermon(
      id: sermonId12,
      title: 'A House of Prayer for All Nations',
      speaker: 'Pastor James Mensah',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Prayer', 'Identity'],
      ministry: 'Missions',
      daysAgo: 70,
      duration: 2640,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Isaiah', chapter: 56, verse: 7),
      ],
      desc:
          'What does it look like for the church to be a house of prayer for the nations — not just a house of programs? A message on intercession and global vision.',
      viewCount: 3900,
    ),
    _sermon(
      id: sermonId13,
      title: 'Generals of the Faith: Hall of Names, Part 2',
      speaker: 'Pastor Daniel Okafor',
      seriesId: seriesIdGenerals,
      seriesName: 'Generals of the Faith',
      topics: const ['Faith', 'Leadership'],
      ministry: 'Discipleship',
      daysAgo: 77,
      duration: 2880,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(
            book: 'Hebrews', chapter: 11, verse: 33, endVerse: 40,),
      ],
      desc:
          'Part 2 of the Hall of Names — faith that conquered kingdoms, shut the mouths of lions, and quenched the fury of the flames.',
      viewCount: 4200,
    ),
    _sermon(
      id: sermonId14,
      title: 'Identity: I Am Loved',
      speaker: 'Pastor Sarah Adeyemi',
      seriesId: seriesIdKingdom,
      seriesName: 'Kingdom Identity',
      topics: const ['Identity', 'Grace'],
      ministry: 'Spiritual Formation',
      daysAgo: 84,
      duration: 2520,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: '1 John', chapter: 4, verse: 19),
      ],
      desc:
          'Before you do anything for God, He has done everything for you. A meditative message on the first foundation of identity: you are loved.',
      viewCount: 6300,
    ),
    _sermon(
      id: sermonId15,
      title: 'Healing for the Wounded Heart',
      speaker: 'Pastor Grace Ibrahim',
      seriesId: seriesIdWhole,
      seriesName: 'A Whole Heart',
      topics: const ['Healing'],
      ministry: 'Counseling',
      daysAgo: 91,
      duration: 2700,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Psalm', chapter: 147, verse: 3),
      ],
      desc:
          'He is close to the brokenhearted. A gentle, pastoral message on what real healing looks like — for those who have carried wounds too long in silence.',
      viewCount: 4900,
    ),
    _sermon(
      id: sermonId16,
      title: "The Father's House: A House for Everyone",
      speaker: 'Pastor James Mensah',
      seriesId: seriesIdFathers,
      seriesName: "The Father's House",
      topics: const ['Family', 'Grace'],
      ministry: 'Family',
      daysAgo: 98,
      duration: 2580,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Luke', chapter: 15, verse: 25, endVerse: 32),
      ],
      desc:
          "Part 2 of The Father's House — the older brother's heart and the surprising grace that calls him home too.",
      viewCount: 3700,
    ),
    _sermon(
      id: sermonId17,
      title: 'Hope in the Dark',
      speaker: 'Pastor Michael Tan',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Hope', 'Faith'],
      ministry: 'Youth',
      daysAgo: 105,
      duration: 2400,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Romans', chapter: 8, verse: 28),
      ],
      desc:
          'A youth service message on holding onto hope when circumstances are not changing. God is working all things together — even the things you cannot see.',
      viewCount: 3200,
    ),
    _sermon(
      id: sermonId18,
      title: 'Faith That Endures',
      speaker: 'Pastor Michael Tan',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Faith', 'Leadership'],
      ministry: 'Youth',
      daysAgo: 112,
      duration: 2280,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'James', chapter: 1, verse: 2, endVerse: 4),
      ],
      desc:
          'Count it all joy. A message for students and young adults on the kind of faith that does not collapse under pressure.',
      viewCount: 2800,
    ),
    _sermon(
      id: sermonId19,
      title: 'The Breath of God: A New Creation',
      speaker: 'Pastor Sarah Adeyemi',
      seriesId: seriesIdRuach,
      seriesName: 'The Breath of God',
      topics: const ['Identity', 'Prayer'],
      ministry: 'Spiritual Formation',
      daysAgo: 119,
      duration: 2640,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(
            book: 'Ezekiel', chapter: 37, verse: 1, endVerse: 14,),
      ],
      desc:
          'The valley of dry bones — what happens when the breath of God comes into a place of death. Resurrection is not just an event; it is a way of life.',
      viewCount: 4600,
    ),
    _sermon(
      id: sermonId20,
      title: 'Kingdom Identity: Sent Out',
      speaker: 'Pastor Daniel Okafor',
      seriesId: seriesIdKingdom,
      seriesName: 'Kingdom Identity',
      topics: const ['Identity', 'Leadership'],
      ministry: 'Missions',
      daysAgo: 126,
      duration: 2520,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(
            book: 'Matthew', chapter: 28, verse: 19, endVerse: 20,),
      ],
      desc:
          'You are not just saved for heaven — you are sent out to represent the Kingdom on earth. A message on the missionary identity of every believer.',
      viewCount: 4100,
    ),
    _sermon(
      id: sermonId21,
      title: 'Generals of the Faith: Hall of Names, Part 3',
      speaker: 'Pastor Daniel Okafor',
      seriesId: seriesIdGenerals,
      seriesName: 'Generals of the Faith',
      topics: const ['Faith', 'Leadership'],
      ministry: 'Discipleship',
      daysAgo: 133,
      duration: 2820,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(
            book: 'Hebrews', chapter: 11, verse: 35, endVerse: 38,),
      ],
      desc:
          'Part 3 — faith that refused to be rescued, choosing to be mistreated with the people of God. A sobering and encouraging call to costly obedience.',
      viewCount: 3300,
    ),
    _sermon(
      id: sermonId22,
      title: 'A Whole Heart: When Forgiveness Feels Impossible',
      speaker: 'Pastor Sarah Adeyemi',
      seriesId: seriesIdWhole,
      seriesName: 'A Whole Heart',
      topics: const ['Healing', 'Grace'],
      ministry: 'Counseling',
      daysAgo: 140,
      duration: 2580,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(
            book: 'Matthew', chapter: 18, verse: 21, endVerse: 22,),
      ],
      desc:
          'A compassionate, honest message for anyone who has been told to forgive but does not know how. Forgiveness is a process, not a moment — and grace meets you in the middle of it.',
      viewCount: 5500,
    ),
    _sermon(
      id: sermonId23,
      title: "The Father's House: The Waiting Father",
      speaker: 'Pastor James Mensah',
      seriesId: seriesIdFathers,
      seriesName: "The Father's House",
      topics: const ['Family', 'Hope'],
      ministry: 'Family',
      daysAgo: 147,
      duration: 2700,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(book: 'Luke', chapter: 15, verse: 20, endVerse: 24),
      ],
      desc:
          'A message for those still waiting on a prodigal to come home. The father saw him while he was still a long way off. The father has been watching for you too.',
      viewCount: 4400,
    ),
    _sermon(
      id: sermonId24,
      title: 'Generosity and the Heart of God',
      speaker: 'Pastor Daniel Okafor',
      seriesId: '',
      seriesName: 'Standalone',
      topics: const ['Provision', 'Grace'],
      ministry: 'Stewardship',
      daysAgo: 154,
      duration: 2640,
      video: true,
      audio: true,
      scripture: const [
        SermonScriptureRef(
            book: '2 Corinthians', chapter: 9, verse: 6, endVerse: 8,),
      ],
      desc:
          'God loves a cheerful giver — and the cheerful part matters. A refreshing message on generosity that flows from grace, not guilt.',
      viewCount: 3500,
    ),
  ];

  /// All series. The episode counts are inferred from [allSermons];
  /// the static [allSeriesDefs] below carries the metadata.
  static List<SermonSeries> get allSeries {
    final out = <SermonSeries>[];
    for (final def in allSeriesDefs) {
      final count = allSermons.where((s) => s.seriesName == def.title).length;
      out.add(
        SermonSeries(
          id: def.id,
          title: def.title,
          description: def.description,
          pastorName: def.pastorName,
          startedOn: def.startedOn,
          episodeCount: count == 0 ? def.episodeCount : count,
          coverGradient: def.coverGradient,
          scriptureAnchor: def.scriptureAnchor,
          completedCount: def.completedCount,
          upcomingDate: def.upcomingDate,
        ),
      );
    }
    return out;
  }

  static final List<SermonSeries> allSeriesDefs = <SermonSeries>[
    SermonSeries(
      id: seriesIdUpperRoom,
      title: 'The Upper Room',
      description:
          "A Lenten series walking through the events of Jesus' final days — the table, the garden, the cross, the empty tomb.",
      pastorName: 'Pastor Daniel Okafor',
      startedOn: DateTime.now().subtract(const Duration(days: 14)),
      episodeCount: 4,
      coverGradient: const [AppColors.goldDark, AppColors.navy],
      scriptureAnchor: 'Luke 22:14',
      completedCount: 1,
    ),
    SermonSeries(
      id: seriesIdKingdom,
      title: 'Kingdom Identity',
      description:
          'Who you are in Christ is the foundation of everything else. A four-part series on identity, belonging, and purpose.',
      pastorName: 'Pastor Daniel Okafor',
      startedOn: DateTime.now().subtract(const Duration(days: 90)),
      episodeCount: 4,
      coverGradient: const [
        AppColors.navy,
        AppColors.navyAccent,
        AppColors.goldDark,
      ],
      scriptureAnchor: '2 Corinthians 5:17',
      completedCount: 2,
    ),
    SermonSeries(
      id: seriesIdGenerals,
      title: 'Generals of the Faith',
      description:
          'A multi-part walk through Hebrews 11 — the men and women whose faith defined their generation, and what we can learn from them.',
      pastorName: 'Pastor Daniel Okafor',
      startedOn: DateTime.now().subtract(const Duration(days: 140)),
      episodeCount: 3,
      coverGradient: const [AppColors.gold, AppColors.goldDark],
      scriptureAnchor: 'Hebrews 11:1',
      completedCount: 1,
    ),
    SermonSeries(
      id: seriesIdRuach,
      title: 'The Breath of God',
      description:
          'A study of the Holy Spirit as the Ruach — the breath, wind, and life of God breathed into His people.',
      pastorName: 'Pastor Sarah Adeyemi',
      startedOn: DateTime.now().subtract(const Duration(days: 60)),
      episodeCount: 3,
      coverGradient: const [AppColors.navyAccent, AppColors.gold],
      scriptureAnchor: 'John 20:22',
      completedCount: 2,
    ),
    SermonSeries(
      id: seriesIdWhole,
      title: 'A Whole Heart',
      description:
          'A pastoral series on healing the split self — bringing private and public into integrity, and walking in wholeness.',
      pastorName: 'Pastor Sarah Adeyemi',
      startedOn: DateTime.now().subtract(const Duration(days: 100)),
      episodeCount: 3,
      coverGradient: const [
        AppColors.goldLight,
        AppColors.gold,
        AppColors.goldDark,
      ],
      scriptureAnchor: 'Psalm 86:11',
      completedCount: 1,
    ),
    SermonSeries(
      id: seriesIdFathers,
      title: "The Father's House",
      description:
          'A three-week journey through the parable of the prodigal son — and the grace of the father that meets each character where they are.',
      pastorName: 'Pastor James Mensah',
      startedOn: DateTime.now().subtract(const Duration(days: 110)),
      episodeCount: 3,
      coverGradient: const [AppColors.navy, AppColors.goldDark, AppColors.gold],
      scriptureAnchor: 'Luke 15:11-32',
      completedCount: 1,
      upcomingDate: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  static const List<SermonSpeaker> allSpeakers = <SermonSpeaker>[
    SermonSpeaker(
      id: speakerIdDaniel,
      name: 'Pastor Daniel Okafor',
      role: 'Lead Pastor',
      bio:
          'Daniel planted Kingdom Heir Church in 2014 with a vision to see a multi-ethnic, Scripture-saturated community of disciples. He holds an M.Div from Fuller Theological Seminary and has been married to Grace for 18 years.',
      sermonCount: 124,
      languages: ['English', 'Igbo'],
      yearsInMinistry: 22,
    ),
    SermonSpeaker(
      id: speakerIdSarah,
      name: 'Pastor Sarah Adeyemi',
      role: 'Teaching Pastor',
      bio:
          'Sarah leads our spiritual formation ministry and teaches the Sunday Bible hour. She is passionate about prayer, spiritual disciplines, and seeing people walk in the wholeness Jesus purchased for them.',
      sermonCount: 86,
      languages: ['English', 'Yoruba'],
      yearsInMinistry: 14,
    ),
    SermonSpeaker(
      id: speakerIdJames,
      name: 'Pastor James Mensah',
      role: 'Family & Discipleship Pastor',
      bio:
          "James oversees our family ministry, small groups, and the discipleship pipeline. He is a gifted teacher with a pastor's heart for families and the next generation.",
      sermonCount: 62,
      languages: ['English', 'Twi'],
      yearsInMinistry: 11,
    ),
    SermonSpeaker(
      id: speakerIdGrace,
      name: 'Pastor Grace Ibrahim',
      role: 'Worship & Pastoral Care Pastor',
      bio:
          "Grace leads our worship ministry and oversees pastoral care, counseling, and women's ministry. She is a trained counselor and brings a gentle, hopeful voice to difficult seasons.",
      sermonCount: 54,
      languages: ['English', 'Hausa'],
      yearsInMinistry: 9,
    ),
    SermonSpeaker(
      id: speakerIdMichael,
      name: 'Pastor Michael Tan',
      role: 'Youth Pastor',
      bio:
          'Michael leads our youth ministry and reaches students across the city with a gospel that is both uncompromising and compelling. He is a graduate of our internship program.',
      sermonCount: 38,
      languages: ['English', 'Mandarin'],
      yearsInMinistry: 6,
    ),
  ];

  /// Continue Watching — 4 in-progress items.
  static final List<SermonContinueItem> seedContinueWatching =
      <SermonContinueItem>[
    SermonContinueItem(
      sermon: allSermons[0], // Upper Room
      positionSeconds: 1620, // ~27 min in
      totalSeconds: allSermons[0].durationSeconds,
      lastWatchedAt: DateTime.now().subtract(const Duration(hours: 4)),
      isCompleted: false,
    ),
    SermonContinueItem(
      sermon: allSermons[3], // Breath of God
      positionSeconds: 980,
      totalSeconds: allSermons[3].durationSeconds,
      lastWatchedAt: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: false,
    ),
    SermonContinueItem(
      sermon: allSermons[5], // Father's House
      positionSeconds: 2200,
      totalSeconds: allSermons[5].durationSeconds,
      lastWatchedAt: DateTime.now().subtract(const Duration(days: 3)),
      isCompleted: false,
    ),
    SermonContinueItem(
      sermon: allSermons[6], // Kingdom Identity
      positionSeconds: 2100,
      totalSeconds: allSermons[6].durationSeconds,
      lastWatchedAt: DateTime.now().subtract(const Duration(days: 5)),
      isCompleted: false,
    ),
  ];

  /// Pre-existing downloads (audio).
  static final List<SermonDownload> seedDownloads = <SermonDownload>[
    SermonDownload(
      sermonId: allSermons[3].id,
      localPath: '/storage/emulated/0/KingdomHeir/sermon-4.m4a',
      downloadedAt: DateTime.now().subtract(const Duration(days: 2)),
      sizeBytes: 24500000,
      completed: true,
    ),
    SermonDownload(
      sermonId: allSermons[6].id,
      localPath: '/storage/emulated/0/KingdomHeir/sermon-7.m4a',
      downloadedAt: DateTime.now().subtract(const Duration(days: 5)),
      sizeBytes: 21800000,
      completed: true,
    ),
    SermonDownload(
      sermonId: allSermons[8].id,
      localPath: '/storage/emulated/0/KingdomHeir/sermon-9.m4a',
      downloadedAt: DateTime.now().subtract(const Duration(days: 12)),
      sizeBytes: 20100000,
      completed: true,
    ),
  ];

  /// Pre-existing notes.
  static final List<SermonNote> seedNotes = <SermonNote>[
    SermonNote(
      id: 'note-1',
      sermonId: sermonId1,
      body:
          '"A table set for the broken" — the disciples were not qualified. None of us are. Grace is not a reward for the worthy; it is a gift for the unworthy.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      timestampSeconds: 240,
    ),
    SermonNote(
      id: 'note-2',
      sermonId: sermonId1,
      body:
          'Application: Who is the "modern Judas" I have been resenting? Where is God asking me to wash feet this week?',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      timestampSeconds: 1840,
    ),
    SermonNote(
      id: 'note-3',
      sermonId: sermonId4,
      body:
          'Ruach = breath, wind, Spirit. The same breath that hovered over the waters is the breath Jesus exhaled on the disciples. We are not waiting for the Spirit — He is already breathing in us.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      timestampSeconds: 360,
    ),
    SermonNote(
      id: 'note-4',
      sermonId: sermonId5,
      body:
          'Integrity = closing the gap between private and public. The gospel calls us into the same person in every room.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SermonNote(
      id: 'note-5',
      sermonId: sermonId6,
      body:
          'The father saw him while he was still a long way off. God has been watching. He is not waiting to forgive you — He has already run to you.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SermonNote(
      id: 'note-6',
      sermonId: sermonId7,
      body:
          '"You are a new creation." Past tense. The old has gone; the new is here. I am not in process — I am in Christ.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    SermonNote(
      id: 'note-7',
      sermonId: sermonId8,
      body:
          'Turn the Psalm into prayer. I tried it this morning with Psalm 23 and it changed my hour. New rhythm.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    SermonNote(
      id: 'note-8',
      sermonId: sermonId9,
      body:
          'God is not absent in the valley — He is closer than the air. I needed to hear this. Bringing it back to grief group tonight.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    SermonNote(
      id: 'note-9',
      sermonId: sermonId14,
      body:
          'Identity first, then obedience. I have been trying to obey my way into identity. Reverse the order.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    SermonNote(
      id: 'note-10',
      sermonId: sermonId22,
      body:
          'Forgiveness is a process, not a moment. I have been trying to forgive "right now" and failing. There is grace for the journey.',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  /// Pre-existing reflection answers.
  static final List<SermonReflection> seedReflections = <SermonReflection>[
    SermonReflection(
      id: 'refl-1',
      sermonId: sermonId1,
      question: 'What is God asking you to trust Him for this week?',
      answer:
          'Trusting Him with a difficult conversation I have been postponing with my brother. Praying for the courage to initiate this week.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    SermonReflection(
      id: 'refl-2',
      sermonId: sermonId1,
      question: 'Where have you seen His faithfulness recently?',
      answer:
          'A friend unexpectedly showed up at the door with groceries during a hard week. The kindness of the Body. God is not absent.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SermonReflection(
      id: 'refl-3',
      sermonId: sermonId4,
      question: 'What is the deepest cry of your heart in this season?',
      answer:
          "To learn to hear the Shepherd's voice. I have been anxious and rushing. I want to slow down and discern.",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SermonReflection(
      id: 'refl-4',
      sermonId: sermonId5,
      question: 'How does God see you — apart from what you do?',
      answer:
          'As His. Just His. Not what I produce. Not how I look. Just held.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SermonReflection(
      id: 'refl-5',
      sermonId: sermonId7,
      question:
          'What truth about your identity in Christ needs repeating today?',
      answer:
          'I am not what happened to me. I am what God says about me. The cross rewrote my story.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    SermonReflection(
      id: 'refl-6',
      sermonId: sermonId22,
      question: 'What would it look like to live as if you are fully loved?',
      answer:
          "To stop performing. To stop earning. To rest in the Father's smile. Starting tonight — sitting in silence before bed.",
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  /// Pre-existing prayer response (single per sermon).
  static final List<SermonPrayerResponse> seedPrayerResponses =
      <SermonPrayerResponse>[
    SermonPrayerResponse(
      id: 'pray-1',
      sermonId: sermonId1,
      body:
          "Lord, I bring the people I have been resenting. Wash my heart the way You washed the disciples' feet. Make me gentle with the difficult people in my life this week. In Jesus' name.",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isPrivate: true,
    ),
  ];

  /// Helper — look up a sermon by id. Returns null if not found.
  static Sermon? findSermon(String id) {
    for (final s in allSermons) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Helper — find sermons by series name.
  static List<Sermon> sermonsBySeries(String seriesName) =>
      allSermons.where((s) => s.seriesName == seriesName).toList();

  /// Helper — find sermons by speaker.
  static List<Sermon> sermonsBySpeaker(String speakerName) =>
      allSermons.where((s) => s.speakerName == speakerName).toList();

  /// Helper — find sermons by topic.
  static List<Sermon> sermonsByTopic(String topic) =>
      allSermons.where((s) => s.topics.contains(topic)).toList();

  // ─── Internal builder ────────────────────────────────────────────────
  static Sermon _sermon({
    required String id,
    required String title,
    required String speaker,
    required String seriesId,
    required String seriesName,
    required List<String> topics,
    required int daysAgo,
    required int duration,
    required bool video,
    required bool audio,
    String? ministry,
    List<SermonScriptureRef> scripture = const [],
    String desc = '',
    bool isFeatured = false,
    bool isLive = false,
    int viewCount = 0,
  }) {
    final publishedAt = DateTime.now().subtract(Duration(days: daysAgo));
    final type = (video && audio)
        ? SermonMediaType.both
        : video
            ? SermonMediaType.video
            : SermonMediaType.audio;
    return Sermon(
      id: id,
      title: title,
      speakerName: speaker,
      seriesName: seriesName,
      publishedAt: publishedAt,
      durationSeconds: duration,
      mediaType: type,
      videoUrl: video ? 'https://example.com/$id/video.mp4' : null,
      audioUrl: audio ? 'https://example.com/$id/audio.m4a' : null,
      thumbnailUrl: 'https://example.com/$id/thumb.jpg',
      scriptureReference: scripture.isEmpty ? null : scripture.first.label,
      description: desc,
      isLive: isLive,
      youtubeId: video ? 'dQw4w9WgXcQ' : null,
      viewCount: viewCount,
      tags: topics,
      scriptures: scripture,
      topics: topics,
      ministry: ministry,
      trendingScore: isFeatured ? 1000 : (viewCount ~/ 50) + topics.length * 20,
      updatedAt: publishedAt,
    );
  }
}
