// Kingdom Heir — Mock Groups Seed Data
//
// Used while the backend tables (group_events, group_prayer_requests,
// group_announcements, etc.) are being stood up. Every fixture is
// self-consistent with the domain models so swapping in the real
// repository later requires no UI changes.

import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart'
    show
        CommunityGroup,
        GroupActivity,
        GroupLifeStage,
        GroupMeetingType,
        GroupMission,
        GroupPrivacy;
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';

/// Helper: a DateTime that is "now + offset" — used so the UI always
/// shows fresh relative times ("in 2h", "3d ago") when the app launches.
DateTime _fromNow(Duration d) => DateTime.now().add(d);

class MockGroupsSeed {
  MockGroupsSeed._();

  // ── Seed groups ─────────────────────────────────────────────────────

  static List<CommunityGroup> get groups => [
        _upperRoom,
        _menIron,
        _womenVirtuous,
        _youthArise,
        _couplesKingdom,
        _prayerWatchmen,
        _bibleStudy,
        _missionsOutreach,
        _creativesStudio,
        _healingAndHope,
      ];

  static CommunityGroup get _upperRoom => CommunityGroup(
        id: 'g-upper-room',
        name: 'Upper Room Prayer Cell',
        description:
            'A weekly upper room encounter — Spirit-led prayer and intercession for the nations.',
        categoryId: 'c-prayer',
        categoryName: 'Prayer',
        meetingTime: 'Wednesdays · 7:00 PM',
        location: 'Main Sanctuary',
        isPrivate: false,
        memberCount: 84,
        userRole: 'LEADER',
        userStatus: 'ACTIVE',
        lastMessagePreview: 'Lord, we lift up the nations tonight…',
        lastMessageAt: _fromNow(const Duration(minutes: -8)),
        weeklyActiveMembers: 42,
      );

  static CommunityGroup get _menIron => CommunityGroup(
        id: 'g-men-iron',
        name: 'Men of Iron',
        description:
            'Sharpening one another in Word, brotherhood, and purpose. Monthly retreats + weekly huddles.',
        categoryId: 'c-men',
        categoryName: 'Men',
        meetingTime: 'Saturdays · 6:30 AM',
        location: 'Fellowship Hall',
        isPrivate: false,
        memberCount: 36,
        userRole: 'MEMBER',
        userStatus: 'ACTIVE',
        lifeStage: GroupLifeStage.youngAdult,
        lastMessagePreview: 'Brothers, who is fasting with me this week?',
        lastMessageAt: _fromNow(const Duration(hours: -2)),
        weeklyActiveMembers: 19,
      );

  static CommunityGroup get _womenVirtuous => const CommunityGroup(
        id: 'g-women-virtuous',
        name: 'Women of Virtue',
        description:
            'Walking in Proverbs 31 together — mentoring, Bible study, and authentic friendship.',
        categoryId: 'c-women',
        categoryName: 'Women',
        meetingTime: 'Tuesdays · 10:00 AM',
        location: 'Room 204',
        isPrivate: false,
        memberCount: 64,
        userStatus: 'PENDING',
        weeklyActiveMembers: 28,
      );

  static CommunityGroup get _youthArise => CommunityGroup(
        id: 'g-youth-arise',
        name: 'Arise Youth',
        description:
            'For students 13–18. Friendships, discipleship, and wild times chasing God together.',
        categoryId: 'c-youth',
        categoryName: 'Youth',
        meetingTime: 'Fridays · 6:00 PM',
        location: 'Youth Loft',
        isPrivate: false,
        memberCount: 52,
        meetingType: GroupMeetingType.hybrid,
        lifeStage: GroupLifeStage.youth,
        lastMessagePreview:
            'Game night Friday — bring your bible AND your Wii controller',
        lastMessageAt: _fromNow(const Duration(hours: -20)),
        weeklyActiveMembers: 38,
      );

  static CommunityGroup get _couplesKingdom => const CommunityGroup(
        id: 'g-couples',
        name: 'Kingdom Couples',
        description:
            'Building marriages that reflect Christ. Quarterly date nights + monthly equipping.',
        categoryId: 'c-couples',
        categoryName: 'Couples',
        meetingTime: '2nd Friday · 7:00 PM',
        location: 'The Loft',
        isPrivate: true,
        memberCount: 24,
        privacy: GroupPrivacy.private,
        lifeStage: GroupLifeStage.family,
        weeklyActiveMembers: 14,
      );

  static CommunityGroup get _prayerWatchmen => CommunityGroup(
        id: 'g-watchmen',
        name: 'Watchmen on the Wall',
        description:
            '24/7 prayer chain. Sign up for a slot — the nations are counting on us.',
        categoryId: 'c-prayer',
        categoryName: 'Prayer',
        meetingTime: 'Always',
        location: 'Zoom',
        isPrivate: false,
        memberCount: 128,
        meetingType: GroupMeetingType.online,
        lastMessagePreview: '🕊️ Taking the 3-4 AM slot — anyone joining?',
        lastMessageAt: _fromNow(const Duration(minutes: -22)),
        weeklyActiveMembers: 71,
      );

  static CommunityGroup get _bibleStudy => const CommunityGroup(
        id: 'g-bible-study',
        name: 'Deep Word Bible Study',
        description: 'Verse-by-verse inductive study. Currently in Romans 8.',
        categoryId: 'c-bible',
        categoryName: 'Bible Study',
        meetingTime: 'Thursdays · 7:00 PM',
        location: 'Zoom + Room 101',
        isPrivate: false,
        memberCount: 96,
        meetingType: GroupMeetingType.hybrid,
        weeklyActiveMembers: 47,
      );

  static CommunityGroup get _missionsOutreach => const CommunityGroup(
        id: 'g-missions',
        name: 'Missions & Outreach',
        description: 'Local + international missions. Where do we go next?',
        categoryId: 'c-missions',
        categoryName: 'Missions',
        meetingTime: '1st Sunday · 12:30 PM',
        location: 'Atrium',
        isPrivate: false,
        memberCount: 41,
        weeklyActiveMembers: 18,
      );

  static CommunityGroup get _creativesStudio => const CommunityGroup(
        id: 'g-creatives',
        name: 'Kingdom Creatives Studio',
        description:
            'Worship arts, media, design, and writing. Using gifts to glorify.',
        categoryId: 'c-creatives',
        categoryName: 'Creatives',
        meetingTime: 'Mondays · 6:00 PM',
        location: 'Studio A',
        isPrivate: false,
        memberCount: 33,
        lifeStage: GroupLifeStage.youngAdult,
        weeklyActiveMembers: 21,
      );

  static CommunityGroup get _healingAndHope => const CommunityGroup(
        id: 'g-healing',
        name: 'Healing & Hope',
        description:
            'A safe space for those walking through grief, illness, or recovery.',
        categoryId: 'c-care',
        categoryName: 'Care',
        meetingTime: 'Saturdays · 10:00 AM',
        location: 'Pastoral Office',
        isPrivate: true,
        memberCount: 18,
        privacy: GroupPrivacy.private,
        weeklyActiveMembers: 11,
      );

  // ── Sample members (for any group) ────────────────────────────────

  static List<GroupMember> sampleMembers(String groupId) => [
        GroupMember(
          id: '$groupId-m1',
          userId: 'u-grace',
          displayName: 'Grace Achieng',
          role: GroupRole.leader,
          joinedAt: _fromNow(const Duration(days: -480)),
          lastActiveAt: _fromNow(const Duration(minutes: -3)),
        ),
        GroupMember(
          id: '$groupId-m2',
          userId: 'u-david',
          displayName: 'David Owusu',
          role: GroupRole.admin,
          joinedAt: _fromNow(const Duration(days: -300)),
          lastActiveAt: _fromNow(const Duration(minutes: -15)),
        ),
        GroupMember(
          id: '$groupId-m3',
          userId: 'u-sarah',
          displayName: 'Sarah Nakato',
          role: GroupRole.member,
          joinedAt: _fromNow(const Duration(days: -120)),
          lastActiveAt: _fromNow(const Duration(hours: -2)),
        ),
        GroupMember(
          id: '$groupId-m4',
          userId: 'u-peter',
          displayName: 'Peter Mutiso',
          role: GroupRole.member,
          joinedAt: _fromNow(const Duration(days: -42)),
          lastActiveAt: _fromNow(const Duration(hours: -8)),
        ),
        GroupMember(
          id: '$groupId-m5',
          userId: 'u-ruth',
          displayName: 'Ruth Wanjiku',
          role: GroupRole.member,
          joinedAt: _fromNow(const Duration(days: -28)),
          lastActiveAt: _fromNow(const Duration(days: -1)),
        ),
        GroupMember(
          id: '$groupId-m6',
          userId: 'u-joshua',
          displayName: 'Joshua Kim',
          role: GroupRole.member,
          joinedAt: _fromNow(const Duration(days: -14)),
          lastActiveAt: _fromNow(const Duration(hours: -5)),
        ),
      ];

  // ── Sample events (per group) ─────────────────────────────────────

  static List<GroupEvent> sampleEvents(String groupId) {
    final base = DateTime.now();
    return [
      GroupEvent(
        id: '$groupId-e1',
        groupId: groupId,
        title: 'Weekly Prayer & Intercession',
        description: 'Come hungry. We press in together.',
        startsAt: DateTime(base.year, base.month, base.day + 1, 19),
        endsAt: DateTime(base.year, base.month, base.day + 1, 21),
        location: 'Main Sanctuary',
        meetingType: GroupMeetingType.physical,
        rsvpCount: 23,
      ),
      GroupEvent(
        id: '$groupId-e2',
        groupId: groupId,
        title: 'Bible Study: Romans 8 (Zoom)',
        description: 'Verse-by-verse inductive study. Bring questions.',
        startsAt: DateTime(base.year, base.month, base.day + 3, 19),
        endsAt: DateTime(base.year, base.month, base.day + 3, 20, 30),
        location: 'Zoom',
        meetingType: GroupMeetingType.online,
        rsvpCount: 41,
      ),
      GroupEvent(
        id: '$groupId-e3',
        groupId: groupId,
        title: 'Fellowship Brunch',
        description: 'Coffee, eggs, and stories of grace.',
        startsAt: DateTime(base.year, base.month, base.day + 7, 10),
        endsAt: DateTime(base.year, base.month, base.day + 7, 12),
        location: 'Atrium',
        meetingType: GroupMeetingType.physical,
        rsvpCount: 28,
      ),
      GroupEvent(
        id: '$groupId-e4',
        groupId: groupId,
        title: 'Outreach Saturday',
        description: 'Serving the city — clothes, food, prayer.',
        startsAt: DateTime(base.year, base.month, base.day + 12, 9),
        endsAt: DateTime(base.year, base.month, base.day + 12, 13),
        location: 'Downtown Park',
        meetingType: GroupMeetingType.physical,
        rsvpCount: 17,
      ),
    ];
  }

  // ── Sample prayer requests ────────────────────────────────────────

  static List<GroupPrayerRequest> samplePrayer(String groupId) => [
        GroupPrayerRequest(
          id: '$groupId-p1',
          groupId: groupId,
          authorMemberId: '$groupId-m3',
          authorName: 'Sarah Nakato',
          body:
              'Please pray for my mum — she goes in for surgery next Tuesday. Asking for peace and a full recovery.',
          category: PrayerCategory.healing,
          createdAt: _fromNow(const Duration(hours: -4)),
          prayingCount: 18,
        ),
        GroupPrayerRequest(
          id: '$groupId-p2',
          groupId: groupId,
          authorMemberId: '$groupId-m4',
          authorName: 'Peter Mutiso',
          body:
              'Job interview tomorrow at 9 AM. Praying for favor and clarity in the conversation.',
          category: PrayerCategory.guidance,
          createdAt: _fromNow(const Duration(hours: -10)),
          prayingCount: 12,
        ),
        GroupPrayerRequest(
          id: '$groupId-p3',
          groupId: groupId,
          authorMemberId: '$groupId-m5',
          authorName: 'Ruth Wanjiku',
          body:
              'Thanksgiving — my dad came home from the hospital today! God is faithful 🙏',
          category: PrayerCategory.thanks,
          createdAt: _fromNow(const Duration(days: -1)),
          prayingCount: 27,
          hasTestimony: true,
          isAnswered: true,
        ),
        GroupPrayerRequest(
          id: '$groupId-p4',
          groupId: groupId,
          authorMemberId: '$groupId-m6',
          authorName: 'Joshua Kim',
          body:
              'My marriage is at a breaking point. Praying for restoration and wisdom to lead my family well.',
          category: PrayerCategory.family,
          createdAt: _fromNow(const Duration(days: -2)),
          prayingCount: 31,
        ),
        GroupPrayerRequest(
          id: '$groupId-p5',
          groupId: groupId,
          authorMemberId: '$groupId-m2',
          authorName: 'David Owusu',
          body:
              r'Asking the Lord to provide for our community garden project — we need $2,400 for supplies.',
          category: PrayerCategory.provision,
          createdAt: _fromNow(const Duration(days: -3)),
          prayingCount: 9,
        ),
      ];

  // ── Sample announcements ──────────────────────────────────────────

  static List<GroupAnnouncement> sampleAnnouncements(String groupId) => [
        GroupAnnouncement(
          id: '$groupId-a1',
          groupId: groupId,
          authorMemberId: '$groupId-m1',
          authorName: 'Grace Achieng',
          body:
              '📌 Pinned: Our annual retreat is May 18–20 at Lake Naivasha. Registration opens this Friday — first 40 paid get a free hoodie.',
          createdAt: _fromNow(const Duration(days: -5)),
          pinned: true,
        ),
        GroupAnnouncement(
          id: '$groupId-a2',
          groupId: groupId,
          authorMemberId: '$groupId-m2',
          authorName: 'David Owusu',
          body:
              'Reminder: We are fasting together this Wednesday until 6 PM. No social media that day — we want clean time with the Lord.',
          createdAt: _fromNow(const Duration(days: -2)),
        ),
        GroupAnnouncement(
          id: '$groupId-a3',
          groupId: groupId,
          authorMemberId: '$groupId-m1',
          authorName: 'Grace Achieng',
          body:
              'Welcome our 3 newest members this week 🎉 Say hi when you see them in the chat.',
          createdAt: _fromNow(const Duration(days: -1)),
        ),
      ];

  // ── Sample discussion posts ───────────────────────────────────────

  static List<GroupDiscussionPost> sampleDiscussion(String groupId) => [
        GroupDiscussionPost(
          id: '$groupId-d1',
          groupId: groupId,
          authorMemberId: '$groupId-m2',
          authorName: 'David Owusu',
          body:
              'Spent the morning in Ephesians 3 and the phrase "the breadth and length and depth and height of the love of Christ" wrecked me. How do you sit with the *vastness* of it?',
          createdAt: _fromNow(const Duration(hours: -6)),
          reactionCount: 14,
          commentCount: 7,
        ),
        GroupDiscussionPost(
          id: '$groupId-d2',
          groupId: groupId,
          authorMemberId: '$groupId-m3',
          authorName: 'Sarah Nakato',
          body:
              'Sharing a worship song that has carried me through the week — "Goodness of God" by Jenn Johnson. May it bless you like it blessed me.',
          createdAt: _fromNow(const Duration(hours: -12)),
          reactionCount: 22,
          commentCount: 4,
        ),
        GroupDiscussionPost(
          id: '$groupId-d3',
          groupId: groupId,
          authorMemberId: '$groupId-m5',
          authorName: 'Ruth Wanjiku',
          body:
              'Practical question — what does your daily devotional rhythm look like? Mine has been dry for weeks. Trying to get back to something consistent.',
          createdAt: _fromNow(const Duration(days: -1)),
          reactionCount: 9,
          commentCount: 16,
        ),
        GroupDiscussionPost(
          id: '$groupId-d4',
          groupId: groupId,
          authorMemberId: '$groupId-m4',
          authorName: 'Peter Mutiso',
          body:
              'My small wins thread: finished reading Genesis, hit my water goal 5 days in a row, prayed with a stranger at the bus stop. God is in the details.',
          createdAt: _fromNow(const Duration(days: -2)),
          reactionCount: 31,
          commentCount: 11,
        ),
        GroupDiscussionPost(
          id: '$groupId-d5',
          groupId: groupId,
          authorMemberId: '$groupId-m6',
          authorName: 'Joshua Kim',
          body:
              'A reminder to the men in here — lead your family in prayer this morning. Even 60 seconds. Our wives and kids are watching how we seek God.',
          createdAt: _fromNow(const Duration(days: -3)),
          reactionCount: 47,
          commentCount: 19,
        ),
      ];

  // ── Mission + activity bundles ────────────────────────────────────

  static GroupMission missionFor(String groupId) => GroupMission(
        statement: groups
            .firstWhere(
              (g) => g.id == groupId,
              orElse: () => _upperRoom,
            )
            .description,
        scripture: 'Hebrews 10:24-25',
        meetingCadence: groups
            .firstWhere((g) => g.id == groupId, orElse: () => _upperRoom)
            .meetingTime,
      );

  static GroupActivity activityFor(String groupId) => GroupActivity(
        lastMessageAt: _fromNow(const Duration(minutes: -8)),
        lastMessagePreview: 'Lord, we lift up the nations tonight…',
        lastMessageAuthor: 'Sarah Nakato',
        weeklyActiveMembers: 42,
        newMembersThisWeek: 3,
      );

  static GroupLeaderProfile leaderFor(String groupId) {
    final members = sampleMembers(groupId);
    return GroupLeaderProfile(
      member: members.first,
      bio:
          'Walking with the Lord for 15+ years. Passionate about prayer, mentoring, and seeing this generation awakened.',
      yearsInRole: 4,
      languages: const ['English', 'Swahili'],
      prayerCount: 218,
    );
  }

  // ── Suggested groups: curated subset to show on Home ──────────────

  static List<CommunityGroup> get suggestedGroups => [
        _youthArise,
        _prayerWatchmen,
        _bibleStudy,
        _creativesStudio,
        _missionsOutreach,
      ];
}
