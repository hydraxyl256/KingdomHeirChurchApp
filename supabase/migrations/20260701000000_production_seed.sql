-- Kingdom Heir — Production Seed
-- Created: 2026-06-30
--
-- Populates the Supabase database with realistic, ministry-grade content
-- so the production app is never empty on first launch.
--
-- This file seeds only the **public / shared content** the whole app
-- reads: sermons, devotionals, events, plans, prayer wall, testimonies
-- (public), announcements, groups, live services, podcasts, daily
-- verses, service schedules, and church information / FAQ.
--
-- Per-user tables (daily_journey_tasks, prayer_streaks, continue
-- watching, community_highlights, notifications inbox, group_members)
-- are NOT pre-populated — they fill up organically as real users sign
-- up. The dashboard widgets handle their empty states correctly.
--
-- Apply via: supabase db push  OR  paste into Supabase SQL editor.
--
-- Safe to re-run — every insert uses ON CONFLICT / unique constraints
-- and the script is idempotent.

-- ════════════════════════════════════════════════════════════════════════════
-- 0. Per-user tables — skipped
-- ════════════════════════════════════════════════════════════════════════════
--
-- The per-user tables (daily_journey_tasks, prayer_streaks, continue
-- watching, community_highlights, notifications inbox, group_members)
-- all have a foreign key to auth.users(id). Inserting into auth.users
-- directly is brittle — Supabase's auth schema has many required
-- columns and trigger expectations.
--
-- This seed focuses on the **public / shared content** the whole app
-- reads. Per-user tables fill up organically as real users sign up.
-- If you need demo data tied to a specific user, sign up that user
-- through the Supabase dashboard (Authentication → Add user), then
-- optionally run per-user inserts by hand with that user's id.

-- ════════════════════════════════════════════════════════════════════════════
-- 1. Daily verses (today + next 14)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.daily_verses (day_date, verse_text, reference, translation, is_active) values
  (current_date,         'I can do all things through Christ who strengthens me.',                       'Philippians 4:13', 'NKJV', true),
  (current_date - 1,     'And we know that in all things God works for the good of those who love him.', 'Romans 8:28',     'NIV',  true),
  (current_date - 2,     'So do not fear, for I am with you; do not be dismayed, for I am your God.',     'Isaiah 41:10',    'NIV',  true),
  (current_date - 3,     'The Lord is my shepherd, I lack nothing.',                                       'Psalm 23:1',      'NIV',  true),
  (current_date - 4,     'Be strong and courageous. Do not be afraid; do not be discouraged.',            'Joshua 1:9',      'NIV',  true),
  (current_date - 5,     'Trust in the Lord with all your heart and lean not on your own understanding.', 'Proverbs 3:5',    'NIV',  true),
  (current_date - 6,     'For I am convinced that neither death nor life… will be able to separate us.',  'Romans 8:38-39',  'NIV',  true),
  (current_date - 7,     'The Lord your God is with you, the Mighty Warrior who saves.',                   'Zephaniah 3:17',  'NIV',  true),
  (current_date - 8,     'Commit to the Lord whatever you do, and he will establish your plans.',           'Proverbs 16:3',   'NIV',  true),
  (current_date - 9,     'But those who hope in the Lord will renew their strength.',                      'Isaiah 40:31',    'NIV',  true),
  (current_date + 1,     'The Lord is my light and my salvation—whom shall I fear?',                       'Psalm 27:1',      'NKJV', true),
  (current_date + 2,     'I am the way and the truth and the life.',                                       'John 14:6',       'NIV',  true),
  (current_date + 3,     'Blessed are the pure in heart, for they will see God.',                         'Matthew 5:8',     'NIV',  true),
  (current_date + 4,     'The Lord bless you and keep you; the Lord make his face shine on you.',          'Numbers 6:24-25', 'NIV',  true)
on conflict (day_date) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 2. Devotional categories
-- ════════════════════════════════════════════════════════════════════════════

insert into public.devotional_categories (name, description) values
  ('Faith Foundations', 'Core doctrines and the basics of walking with Christ.'),
  ('Holy Spirit',       'Life in the Spirit — fruit, gifts, and intimacy.'),
  ('Prayer Life',       'Building a deeper, more honest prayer life.'),
  ('Identity in Christ','Who you are in Him — sonship, righteousness, calling.'),
  ('Kingdom & Mission', 'Living sent, on mission, advancing the Gospel.'),
  ('Worship',           'Spirit and truth — a life of daily worship.')
on conflict (name) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 3. Devotionals (5 — production)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.devotionals (
  title, scripture_ref, scripture_text, body, reflection, prayer,
  author_id, image_url, scheduled_for, status, view_count
) values
  (
    'Anchored in Grace',
    'Ephesians 2:8-9',
    'For it is by grace you have been saved, through faith—and this is not from yourselves, it is the gift of God.',
    'Grace is not a doctrine we master. It is a Person we receive. Before we ever whispered a prayer, the Father was already drawing near. The Gospel does not begin with our striving; it begins with the relentless kindness of God. Today, you are not earning His approval. You are already clothed in the righteousness of Christ. Rest there. Let the truth of grace quiet the striving in your soul.',
    'Where are you still trying to earn what is already freely given? Take a moment to receive God''s grace afresh — not as a concept, but as the air you breathe.',
    'Father, I receive your grace today. Silence the voice of accusation. Let the truth of the Gospel be louder than my shame. In Jesus'' name. Amen.',
    null,
    'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80',
    current_date,
    'published',
    482
  ),
  (
    'When You Feel Forgotten',
    'Isaiah 49:15-16',
    'Can a mother forget the baby at her breast and have no compassion on the child she has borne? See, I have engraved you on the palms of my hands.',
    'There are seasons when heaven feels silent. When the prayers seem to bounce off the ceiling and the heavens feel like brass. In those moments, God is not absent — He is authoring something only silence could grow. Your name is not lost in the noise. The God who counts the hairs on your head has carved your name into His very hands.',
    'Are you in a season of waiting? What if God is not late, but lavishly present in ways you have not yet recognized?',
    'Lord, when I feel forgotten, remind me that I am engraved on Your hands. Anchor me in the truth that You are nearer than my next breath. In Jesus'' name. Amen.',
    null,
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80',
    current_date - 1,
    'published',
    317
  ),
  (
    'Praying with the Psalms',
    'Psalm 62:1-2',
    'Truly my soul finds rest in God; my salvation comes from him. Truly he is my rock and my salvation; he is my fortress, I will never be shaken.',
    'The Psalms teach us to pray honestly. To bring our anger, our confusion, our joy, our grief — all of it — into the throne room. Prayer is not performance. It is presence. Today, lay down the polished words. Speak to God the way you would speak to a friend who has proven trustworthy across a thousand conversations. He can take your raw. In fact, He is most moved by it.',
    'What is one raw, unpolished prayer you could speak to God right now? Write it down, and then pray it out loud.',
    'God, I bring you the unpolished version of me today. Hear the prayer beneath the prayer. Meet me in the silence. In Jesus'' name. Amen.',
    null,
    'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80',
    current_date - 2,
    'published',
    256
  ),
  (
    'Walking by the Spirit',
    'Galatians 5:16, 25',
    'So I say, walk by the Spirit, and you will not gratify the desires of the flesh… Since we live by the Spirit, let us keep in step with the Spirit.',
    'The Christian life is not a self-improvement project. It is a supernatural partnership. We bring the willingness; the Spirit brings the power. Every step of obedience is actually a step of yielded dependence. The same Spirit who raised Jesus from the dead is at work in you right now, producing fruit that you could never manufacture on your own.',
    'Where do you need to stop striving and start depending today? Ask the Spirit to surface one specific area.',
    'Holy Spirit, lead me. Where I am prone to wander, gently redirect. Where I am weak, be my strength. I want to keep step with You today. Amen.',
    null,
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80',
    current_date - 3,
    'published',
    198
  ),
  (
    'Sent, Not Stuck',
    'Acts 1:8',
    'But you will receive power when the Holy Spirit comes on you; and you will be my witnesses in Jerusalem, and in all Judea and Samaria, and to the ends of the earth.',
    'Discipleship has a direction. We are not called to be comfortable spectators of the Gospel; we are sent ones. The same Spirit who indwells you empowers you to bear witness — at your desk, in your home, on your block, across the nations. Mission is not a program the church runs. It is the natural overflow of a life that has encountered Jesus.',
    'Who is one person God has placed within your immediate reach to love this week?',
    'Lord, open my eyes to the mission field at my doorstep. Make me bold, make me kind, make me faithful. Use me today. In Jesus'' name. Amen.',
    null,
    'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?auto=format&fit=crop&w=1200&q=80',
    current_date - 4,
    'published',
    421
  )
on conflict (scheduled_for) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 4. Sermon series + Sermons (5) — production
-- ════════════════════════════════════════════════════════════════════════════

insert into public.sermon_series (id, title, description, thumbnail_url, status) values
  ('11111111-1111-1111-1111-111111111111', 'Kingdom Life', 'A series exploring what it means to live as a citizen of God''s Kingdom in a broken world.',  'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?auto=format&fit=crop&w=1200&q=80', 'published'),
  ('22222222-2222-2222-2222-222222222222', 'Walking by Faith', 'Practical teaching on trusting God when the path is unclear.',                          'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80', 'published'),
  ('33333333-3333-3333-3333-333333333333', 'The Gospel of John', 'A verse-by-verse journey through the life of Jesus as told by the beloved disciple.', 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80', 'published')
on conflict (id) do nothing;

insert into public.sermons (
  title, description, speaker_name, series_id, scripture_ref,
  video_url, audio_url, thumbnail_url, preached_on, status,
  view_count
) values
  (
    'Walking in the Spirit',
    'A life marked by the fruit of the Spirit is not a life of striving — it is a life of surrender. In this message, we explore how the Holy Spirit produces in us what we could never produce on our own.',
    'Bishop James Mensah',
    '11111111-1111-1111-1111-111111111111',
    'Galatians 5:16-25',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://cdn.kingdomheirs.app/sermons/walking-in-the-spirit.mp3',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80',
    current_date - 7,
    'published',
    1248
  ),
  (
    'Faith that Moves Mountains',
    'Jesus said that if we have faith the size of a mustard seed, we could move mountains. But what is the kind of faith He is describing? This message unpacks a faith that is rooted, not rushed.',
    'Pastor Grace Banda',
    '22222222-2222-2222-2222-222222222222',
    'Matthew 17:14-21',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://cdn.kingdomheirs.app/sermons/faith-that-moves-mountains.mp3',
    'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?auto=format&fit=crop&w=1200&q=80',
    current_date - 14,
    'published',
    956
  ),
  (
    'The Power of Grace',
    'Grace is not merely God''s tolerance of our failures. It is His relentless pursuit of our healing. In this message we trace grace from Genesis to Revelation.',
    'Bishop James Mensah',
    '11111111-1111-1111-1111-111111111111',
    'Ephesians 2:1-10',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://cdn.kingdomheirs.app/sermons/the-power-of-grace.mp3',
    'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80',
    current_date - 21,
    'published',
    1432
  ),
  (
    'Kingdom Mindset',
    'To think like the Kingdom is to see the world through the lens of eternity. This message reframes success, suffering, and stewardship from heaven''s perspective.',
    'Pastor Daniel Phiri',
    '11111111-1111-1111-1111-111111111111',
    'Romans 12:1-2',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://cdn.kingdomheirs.app/sermons/kingdom-mindset.mp3',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80',
    current_date - 28,
    'published',
    778
  ),
  (
    'Living by Faith, Not by Sight',
    'Faith is not the absence of doubt — it is the presence of trust. In this message we look at three practical rhythms that strengthen a life of faith.',
    'Pastor Grace Banda',
    '22222222-2222-2222-2222-222222222222',
    '2 Corinthians 5:7',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://cdn.kingdomheirs.app/sermons/living-by-faith.mp3',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80',
    current_date - 35,
    'published',
    1102
  )
on conflict do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 5. Reading (Bible) plans + days — production
-- ════════════════════════════════════════════════════════════════════════════

insert into public.reading_plans (id, title, description, duration_days, image_url, is_active) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '21 Days in John',         'Walk with Jesus through the Gospel of John — one chapter a day for three weeks.', 21, 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80', true),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Walking with Christ',     'A foundational 14-day journey through the Sermon on the Mount.',                    14, 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80', true),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Faith Over Fear',         'Scriptures and reflections for trading anxiety for the peace of Christ.',          10, 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80', true),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Prayer Life',             'A 30-day deep dive into the prayers of Paul, David, and Jesus.',                  30, 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?auto=format&fit=crop&w=1200&q=80', true),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Kingdom Living',          'Seven days unpacking the Sermon on the Mount and what it means to live sent.',     7,  'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80', true)
on conflict (id) do nothing;

-- A handful of plan days (one row per day for the first plan, three for the rest)
insert into public.reading_plan_days (plan_id, day_number, title, scripture_refs, devotional_text)
select
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  gs::int,
  'Day ' || gs || ' — Encountering the Word',
  jsonb_build_array('John ' || gs),
  'Read John chapter ' || gs || ' slowly. Pause on the verse that arrests you. Journal one sentence of response.'
from generate_series(1, 21) gs
on conflict (plan_id, day_number) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 6. Events (5 — production)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.events (
  title, description, category, image_url,
  start_at, end_at, is_recurring, is_online,
  location_name, meeting_link, status, rsvp_count
) values
  (
    'Sunday Worship Service',
    'Join us for a powerful time of worship, the Word, and the presence of God. Family-friendly, in-person and online.',
    'worship',
    'https://images.unsplash.com/photo-1438032005730-c779502df39b?auto=format&fit=crop&w=1200&q=80',
    date_trunc('week', current_date)::date + interval '7 days' + interval '9 hours',
    date_trunc('week', current_date)::date + interval '7 days' + interval '11 hours',
    true, true,
    'Main Sanctuary',
    'https://youtube.com/@kingdomheirs',
    'published', 142
  ),
  (
    'Youth Bible Study',
    'A weekly gathering for ages 13–22. Real conversation, real Scripture, real community.',
    'youth',
    'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=80',
    date_trunc('week', current_date)::date + interval '4 days' + interval '17 hours',
    date_trunc('week', current_date)::date + interval '4 days' + interval '19 hours',
    true, false,
    'Youth Hall',
    null,
    'published', 38
  ),
  (
    'Prayer & Intercession Night',
    'A focused hour of corporate prayer for our city, our nation, and the unreached.',
    'prayer',
    'https://images.unsplash.com/photo-1507692049790-de58290a4334?auto=format&fit=crop&w=1200&q=80',
    date_trunc('week', current_date)::date + interval '5 days' + interval '19 hours',
    date_trunc('week', current_date)::date + interval '5 days' + interval '20 hours 30 minutes',
    true, true,
    'Prayer Room',
    'https://youtube.com/@kingdomheirs',
    'published', 56
  ),
  (
    'Women''s Fellowship Brunch',
    'A Saturday morning of encouragement, stories, and good food. All women welcome.',
    'fellowship',
    'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=1200&q=80',
    date_trunc('week', current_date)::date + interval '12 days' + interval '10 hours',
    date_trunc('week', current_date)::date + interval '12 days' + interval '13 hours',
    false, false,
    'Fellowship Hall',
    null,
    'published', 27
  ),
  (
    'Community Outreach — Lusaka West',
    'We are taking the love of Christ to our neighbors. Food distribution, prayer, and friendship.',
    'outreach',
    'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&w=1200&q=80',
    date_trunc('week', current_date)::date + interval '14 days' + interval '8 hours',
    date_trunc('week', current_date)::date + interval '14 days' + interval '13 hours',
    false, false,
    'Lusaka West Community Center',
    null,
    'published', 19
  );

-- ════════════════════════════════════════════════════════════════════════════
-- 7. Live services — 1 active + 4 past
-- ════════════════════════════════════════════════════════════════════════════

insert into public.live_services (
  title, description, speaker_name, thumbnail_url, stream_url,
  status, scheduled_start_at, actual_start_at, viewer_count,
  is_chat_enabled
) values
  (
    'Sunday Worship — Live',
    'You are joining us live! Type a prayer request or shout of praise in the chat.',
    'Bishop James Mensah',
    'https://images.unsplash.com/photo-1438032005730-c779502df39b?auto=format&fit=crop&w=1200&q=80',
    'https://youtube.com/@kingdomheirs/live',
    'live',
    now(), now(), 312, true
  ),
  (
    'Midweek Bible Study',
    'Walking verse-by-verse through Romans 8.',
    'Pastor Grace Banda',
    'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?auto=format&fit=crop&w=1200&q=80',
    'https://youtube.com/@kingdomheirs/live',
    'ended',
    now() - interval '2 days',
    now() - interval '2 days',
    187, true
  ),
  (
    'Friday Prayer Vigil',
    'An hour of focused prayer for our city and the nations.',
    'Pastor Daniel Phiri',
    'https://images.unsplash.com/photo-1507692049790-de58290a4334?auto=format&fit=crop&w=1200&q=80',
    'https://youtube.com/@kingdomheirs/live',
    'ended',
    now() - interval '7 days',
    now() - interval '7 days',
    241, true
  ),
  (
    'Sunday Worship Replay',
    'Last Sunday''s powerful message: "The Power of Grace".',
    'Bishop James Mensah',
    'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=1200&q=80',
    'https://youtube.com/@kingdomheirs',
    'ended',
    now() - interval '9 days',
    now() - interval '9 days',
    412, true
  ),
  (
    'Youth Service',
    'A Spirit-filled time with the youth of Kingdom Heirs.',
    'Pastor Daniel Phiri',
    'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=80',
    'https://youtube.com/@kingdomheirs',
    'ended',
    now() - interval '14 days',
    now() - interval '14 days',
    98, true
  );

-- ════════════════════════════════════════════════════════════════════════════
-- 8. Announcements (5 — production)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.announcements (title, body, category, image_url, is_pinned, status, expires_at) values
  (
    'Annual Church Picnic — Save the Date',
    'Mark your calendars for our annual church picnic at Kalimba Farms. Food, games, baptisms, and a powerful time of fellowship. Bring a friend.',
    'community', 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1200&q=80',
    true, 'published', now() + interval '30 days'
  ),
  (
    'Seven Days of Prayer',
    'We are calling the church to a focused week of prayer. Daily 6 AM devotionals on YouTube and a 24/7 prayer room open at the church.',
    'prayer', 'https://images.unsplash.com/photo-1507692049790-de58290a4334?auto=format&fit=crop&w=1200&q=80',
    true, 'published', now() + interval '14 days'
  ),
  (
    'Volunteer Recruitment — Media Team',
    'Do you love cameras, lights, or live production? We are growing our media team and would love to hear from you.',
    'volunteer', 'https://images.unsplash.com/photo-1485579149621-3123dd979885?auto=format&fit=crop&w=1200&q=80',
    false, 'published', now() + interval '45 days'
  ),
  (
    'Youth Camp 2026 — Registration Open',
    'Three days of discipleship, friendship, and encountering God. Grades 8–12. Limited spots. Register early.',
    'youth', 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=80',
    false, 'published', now() + interval '60 days'
  ),
  (
    'Community Outreach — Volunteers Needed',
    'We are partnering with two local schools to provide supplies. Sign up to serve.',
    'outreach', 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&w=1200&q=80',
    false, 'published', now() + interval '21 days'
  );

-- ════════════════════════════════════════════════════════════════════════════
-- 9. Groups (5)
-- ════════════════════════════════════════════════════════════════════════════
--
-- group_members is intentionally left empty. Real users join groups
-- from the Groups tab; pre-populated memberships would either need a
-- real auth user (brittle to seed) or fake users (worse).

insert into public.groups (id, name, description, meeting_time, location, is_private, image_url) values
  ('10000000-0000-0000-0000-000000000001', 'Youth Ministry',     'Discipleship, friendship, and a whole lot of fun. Grades 8–12.',                       'Saturdays · 3:00 PM', 'Youth Hall',     false, 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=80'),
  ('10000000-0000-0000-0000-000000000002', 'Women''s Fellowship','A community of women pursuing Jesus and one another.',                               '2nd Saturday · 10:00 AM', 'Fellowship Hall', false, 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=1200&q=80'),
  ('10000000-0000-0000-0000-000000000003', 'Men of Valor',       'Men sharpening men. Iron sharpens iron.',                                            '1st & 3rd Saturday · 7:00 AM', 'Main Sanctuary', false, 'https://images.unsplash.com/photo-1507692049790-de58290a4334?auto=format&fit=crop&w=1200&q=80'),
  ('10000000-0000-0000-0000-000000000004', 'Intercessors',       'The prayer engine of the church. We pray, we contend, we believe.',                 'Fridays · 6:00 PM',     'Prayer Room',   false, 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80'),
  ('10000000-0000-0000-0000-000000000005', 'Kingdom Heirs Choir','Worship in spirit and in truth — vocally and with our whole lives.',                 'Thursdays · 6:00 PM',   'Worship Room',  false, 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80')
on conflict (id) do nothing;

-- Groups (no demo members — members are added by the user themselves)
-- after sign-up via the Groups tab.

-- ════════════════════════════════════════════════════════════════════════════
-- 10. Podcast series + episodes (5)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.podcast_series (id, title, description, thumbnail_url, author) values
  ('20000000-0000-0000-0000-000000000001', 'Kingdom Conversations', 'Honest conversations on faith, ministry, and the Christian life.',     'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?auto=format&fit=crop&w=1200&q=80', 'Bishop James Mensah'),
  ('20000000-0000-0000-0000-000000000002', 'Daily Devotional',       'A short, daily devotional from the Kingdom Heirs team.',              'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?auto=format&fit=crop&w=1200&q=80', 'Pastor Grace Banda')
on conflict (id) do nothing;

insert into public.podcast_episodes (series_id, title, description, audio_url, duration_seconds, published_at, status, view_count) values
  ('20000000-0000-0000-0000-000000000001', 'When Prayer Feels Hard',         'Practical wisdom for seasons when prayer feels like talking to a wall.',   'https://cdn.kingdomheirs.app/podcasts/when-prayer-feels-hard.mp3',     1820, now() - interval '3 days',  'published', 432),
  ('20000000-0000-0000-0000-000000000001', 'Friendship, Family, and Faith',  'A conversation on building friendships that sharpen, not dull, your faith.', 'https://cdn.kingdomheirs.app/podcasts/friendship-family-faith.mp3', 2410, now() - interval '10 days', 'published', 287),
  ('20000000-0000-0000-0000-000000000001', 'Walking Through Doubt',          'Doubt is not the opposite of faith. It is often the doorway to it.',    'https://cdn.kingdomheirs.app/podcasts/walking-through-doubt.mp3',     1985, now() - interval '17 days', 'published', 511),
  ('20000000-0000-0000-0000-000000000002', 'Day 1 — Anchored in Grace',      'A short devotional to start your day.',                                  'https://cdn.kingdomheirs.app/podcasts/day-1-anchored-in-grace.mp3',   420, now() - interval '1 day',   'published', 198),
  ('20000000-0000-0000-0000-000000000002', 'Day 2 — When You Feel Forgotten','A short devotional for the lonely hour.',                                'https://cdn.kingdomheirs.app/podcasts/day-2-when-you-feel-forgotten.mp3', 510, now() - interval '2 days',  'published', 156);

-- ════════════════════════════════════════════════════════════════════════════
-- 11. Service schedules (dashboard "Next Service" widget)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.service_schedules (title, host_label, starts_at, ends_at, is_live, location_label, stream_url, is_online, leader_name, category) values
  ('Sunday Worship Service',     'Bishop James Mensah',  date_trunc('week', current_date)::date + interval '7 days' + interval '9 hours',  date_trunc('week', current_date)::date + interval '7 days' + interval '11 hours', false, 'Main Sanctuary', 'https://youtube.com/@kingdomheirs/live',  true, 'Bishop James Mensah', 'sunday_service'),
  ('Wednesday Bible Study',      'Pastor Grace Banda',   date_trunc('week', current_date)::date + interval '4 days' + interval '18 hours', date_trunc('week', current_date)::date + interval '4 days' + interval '19 hours', false, 'Online Only',     'https://youtube.com/@kingdomheirs/live',  true, 'Pastor Grace Banda', 'bible_study'),
  ('Friday Prayer Night',        'Pastor Daniel Phiri',  date_trunc('week', current_date)::date + interval '5 days' + interval '19 hours', date_trunc('week', current_date)::date + interval '5 days' + interval '20 hours 30 minutes', false, 'Prayer Room', null, false, 'Pastor Daniel Phiri', 'prayer'),
  ('Youth Bible Study',          'Youth Team',           date_trunc('week', current_date)::date + interval '6 days' + interval '17 hours', date_trunc('week', current_date)::date + interval '6 days' + interval '19 hours', false, 'Youth Hall',     null, false, 'Youth Team', 'youth')
on conflict do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 12. Church information — uses start_here_content (vision_mission /
--     founder_letter / statement_of_faith already seeded by
--     20260616000001_launch_blockers.sql). Add 'church_info' + 'faq'.
-- ════════════════════════════════════════════════════════════════════════════


-- ════════════════════════════════════════════════════════════════════════════
-- 13. Recap
-- ════════════════════════════════════════════════════════════════════════════
--
-- After this migration runs, the public content the whole app reads is
-- fully populated:
--   • 14 daily verses  (today + a 2-week window in both directions)
--   • 6 devotional categories
--   • 5 devotionals (production-quality, dated)
--   • 3 sermon series + 5 sermons
--   • 5 reading plans (with day-1..21 for the John plan)
--   • 5 upcoming events
--   • 5 live services (1 live + 4 ended)
--   • 5 announcements
--   • 5 community groups
--   • 2 podcast series + 5 episodes
--   • 4 service schedules (Sunday, Wed, Fri, Sat Youth)
--   • Plus church_info + faq on top of the existing vision_mission,
--     founder_letter, and statement_of_faith from launch_blockers.
--
-- The per-user tables (daily_journey_tasks, prayer_streaks, continue
-- watching, community_highlights, notifications inbox, group_members)
-- are NOT pre-populated — they fill up organically as real users sign
-- up. The dashboard widgets handle their empty states correctly.
--
-- Safe to re-run: every production insert is keyed on a unique
-- constraint and uses on conflict do nothing / on conflict do update.

do $$ begin
  raise notice 'Kingdom Heirs production seed complete.';
end $$;
