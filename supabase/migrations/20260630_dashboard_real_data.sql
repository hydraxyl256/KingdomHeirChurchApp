-- Kingdom Heir — Dashboard Real Data Backend
-- Created: 2026-06-30
--
-- Wires the redesigned Home Dashboard to live Supabase. Adds:
--   • 7 tables (daily_verses, daily_journey_tasks, service_schedules,
--     prayer_requests, prayer_request_prays, community_highlights_user,
--     continue_progress, prayer_streaks)
--   • 11 RPC functions matching the repository's `fetch*` / `toggle*` /
--     `increment*` / `update*` calls
--   • RLS policies so each user only sees their own data + the shared
--     scripture/event rosters
--   • Seed content so the dashboard is non-empty on day 1
--
-- Apply via: supabase db push   OR   paste into Supabase SQL editor.

-- ════════════════════════════════════════════════════════════════════════════
-- 0. Required extensions
-- ════════════════════════════════════════════════════════════════════════════
--
-- We rely on `gen_random_uuid()` (provided by pgcrypto, pre-installed on
-- Supabase via the `extensions` schema which is in `extra_search_path`).
-- We deliberately do NOT enable `uuid-ossp` — its `uuid_generate_v4()`
-- function lives in a non-search-path schema and triggers
-- `function … does not exist (SQLSTATE 42883)` on Supabase, which is
-- the regression this migration's first version hit. All other
-- migrations in this repo (`core_schema`, `sermons_streaming`, etc.)
-- already follow this pattern.

-- ════════════════════════════════════════════════════════════════════════════
-- 1. Daily verses (scripture of the day)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.daily_verses (
  id          uuid primary key default gen_random_uuid(),
  day_date    date unique not null,
  verse_text  text not null,
  reference   text not null,
  translation text not null default 'NIV',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

create index if not exists daily_verses_day_date_idx
  on public.daily_verses (day_date desc)
  where is_active = true;

alter table public.daily_verses enable row level security;

drop policy if exists "daily_verses_read_all" on public.daily_verses;
create policy "daily_verses_read_all"
  on public.daily_verses for select
  using (is_active = true);

drop policy if exists "daily_verses_admin_write" on public.daily_verses;
create policy "daily_verses_admin_write"
  on public.daily_verses for all
  using (auth.jwt() ->> 'role' = 'service_role')
  with check (auth.jwt() ->> 'role' = 'service_role');

-- ════════════════════════════════════════════════════════════════════════════
-- 2. Daily journey tasks (per-user)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.daily_journey_tasks (
  user_id      uuid references auth.users(id) on delete cascade,
  kind         text not null check (kind in (
                 'scripture', 'devotional', 'prayer', 'reflection',
                 'worship', 'journal')),
  day_date     date not null default current_date,
  is_completed boolean not null default false,
  completed_at timestamptz,
  primary key (user_id, kind, day_date)
);

create index if not exists daily_journey_tasks_user_day_idx
  on public.daily_journey_tasks (user_id, day_date desc);

alter table public.daily_journey_tasks enable row level security;

drop policy if exists "journey_tasks_self_read" on public.daily_journey_tasks;
create policy "journey_tasks_self_read"
  on public.daily_journey_tasks for select
  using (auth.uid() = user_id);

drop policy if exists "journey_tasks_self_write" on public.daily_journey_tasks;
create policy "journey_tasks_self_write"
  on public.daily_journey_tasks for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 3. Service schedules (live + upcoming)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.service_schedules (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  host_label     text,
  starts_at      timestamptz not null,
  ends_at        timestamptz,
  is_live        boolean not null default false,
  location_label text,
  stream_url     text,
  is_online      boolean not null default false,
  is_active      boolean not null default true,
  leader_name    text,
  category       text not null default 'other' check (category in (
                   'prayer', 'bible_study', 'youth', 'sunday_service',
                   'outreach', 'choir', 'other')),
  created_at     timestamptz not null default now()
);

create index if not exists service_schedules_active_starts_at_idx
  on public.service_schedules (starts_at)
  where is_active = true;

alter table public.service_schedules enable row level security;

drop policy if exists "service_schedules_read_all" on public.service_schedules;
create policy "service_schedules_read_all"
  on public.service_schedules for select
  using (is_active = true);

drop policy if exists "service_schedules_admin_write" on public.service_schedules;
create policy "service_schedules_admin_write"
  on public.service_schedules for all
  using (auth.jwt() ->> 'role' = 'service_role')
  with check (auth.jwt() ->> 'role' = 'service_role');

-- ════════════════════════════════════════════════════════════════════════════
-- 4. Prayer requests
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.prayer_requests (
  id           uuid primary key default gen_random_uuid(),
  author_id    uuid references auth.users(id) on delete set null,
  author_name  text not null,
  preview      text not null,
  prayer_count integer not null default 0,
  is_answered  boolean not null default false,
  created_at   timestamptz not null default now()
);

create index if not exists prayer_requests_recent_idx
  on public.prayer_requests (created_at desc);

alter table public.prayer_requests enable row level security;

drop policy if exists "prayer_requests_read_all" on public.prayer_requests;
create policy "prayer_requests_read_all"
  on public.prayer_requests for select using (true);

drop policy if exists "prayer_requests_auth_write" on public.prayer_requests;
create policy "prayer_requests_auth_write"
  on public.prayer_requests for insert
  with check (auth.uid() = author_id);

create table if not exists public.prayer_request_prays (
  user_id    uuid references auth.users(id) on delete cascade,
  prayer_id  uuid references public.prayer_requests(id) on delete cascade,
  prayed_at  timestamptz not null default now(),
  primary key (user_id, prayer_id)
);

alter table public.prayer_request_prays enable row level security;

drop policy if exists "prayer_prays_self_read" on public.prayer_request_prays;
create policy "prayer_prays_self_read"
  on public.prayer_request_prays for select
  using (auth.uid() = user_id);

drop policy if exists "prayer_prays_self_write" on public.prayer_request_prays;
create policy "prayer_prays_self_write"
  on public.prayer_request_prays for insert
  with check (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 5. Community highlights (per-user)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.community_highlights_user (
  user_id                uuid primary key references auth.users(id) on delete cascade,
  unread_group_messages  integer not null default 0,
  birthday_name          text,
  leader_announcement    text,
  upcoming_group_meeting text,
  updated_at             timestamptz not null default now()
);

alter table public.community_highlights_user enable row level security;

drop policy if exists "community_self_read" on public.community_highlights_user;
create policy "community_self_read"
  on public.community_highlights_user for select
  using (auth.uid() = user_id);

drop policy if exists "community_self_write" on public.community_highlights_user;
create policy "community_self_write"
  on public.community_highlights_user for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 6. Continue progress (in-progress content across kinds)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.continue_progress (
  user_id          uuid references auth.users(id) on delete cascade,
  kind             text not null check (kind in (
                     'sermon', 'biblePlan', 'devotional', 'podcast',
                     'prayerChallenge')),
  content_id       text not null,
  title            text not null,
  subtitle         text,
  thumbnail_url    text,
  duration_label   text,
  progress         numeric(3,2) not null default 0 check (progress between 0 and 1),
  is_downloaded    boolean not null default false,
  last_watched_at  timestamptz not null default now(),
  primary key (user_id, kind, content_id)
);

create index if not exists continue_progress_recent_idx
  on public.continue_progress (user_id, last_watched_at desc);

alter table public.continue_progress enable row level security;

drop policy if exists "continue_progress_self_read" on public.continue_progress;
create policy "continue_progress_self_read"
  on public.continue_progress for select
  using (auth.uid() = user_id);

drop policy if exists "continue_progress_self_write" on public.continue_progress;
create policy "continue_progress_self_write"
  on public.continue_progress for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 7. Prayer streaks
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.prayer_streaks (
  user_id          uuid primary key references auth.users(id) on delete cascade,
  current_streak   integer not null default 0,
  longest_streak   integer not null default 0,
  last_prayed_date date
);

alter table public.prayer_streaks enable row level security;

drop policy if exists "prayer_streaks_self_read" on public.prayer_streaks;
create policy "prayer_streaks_self_read"
  on public.prayer_streaks for select
  using (auth.uid() = user_id);

drop policy if exists "prayer_streaks_self_write" on public.prayer_streaks;
create policy "prayer_streaks_self_write"
  on public.prayer_streaks for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 8. RPCs
-- ════════════════════════════════════════════════════════════════════════════

-- 8.1 Greeting

create or replace function public.get_dashboard_greeting(p_user_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_first_name text;
  v_avatar     text;
  v_streak     integer := 0;
  v_unread     integer := 0;
begin
  select coalesce(
           split_part(coalesce(u.raw_user_meta_data ->> 'full_name', ''), ' ', 1),
           'Friend'
         ),
         u.raw_user_meta_data ->> 'avatar_url'
    into v_first_name, v_avatar
    from auth.users u
    where u.id = p_user_id;

  select coalesce(ps.current_streak, 0)
    into v_streak
    from public.prayer_streaks ps
    where ps.user_id = p_user_id;

  v_unread := 3; -- placeholder until notification infra is wired

  return jsonb_build_object(
    'first_name',           v_first_name,
    'avatar_url',           v_avatar,
    'streak_days',          v_streak,
    'unread_notifications', v_unread
  );
end;
$$;

-- 8.2 Scripture roster (last 5 verses; today first)

create or replace function public.get_dashboard_scripture()
returns setof public.daily_verses
language sql
stable
as $$
  select *
  from public.daily_verses
  where is_active = true
  order by day_date desc
  limit 5;
$$;

-- 8.3 Continue cards

create or replace function public.get_dashboard_continue(
  p_user_id uuid,
  p_limit   integer default 4
)
returns setof public.continue_progress
language sql
stable
as $$
  select *
  from public.continue_progress
  where user_id = p_user_id
    and progress > 0
    and progress < 1
  order by last_watched_at desc
  limit p_limit;
$$;

-- 8.4 Service status

create or replace function public.get_dashboard_service()
returns jsonb
language sql
stable
as $$
  select to_jsonb(s)
  from (
    select *
    from public.service_schedules
    where is_active = true
      and (
        is_live = true
        or (starts_at >= now() and starts_at <= now() + interval '14 days')
      )
    order by is_live desc, starts_at asc
    limit 1
  ) s;
$$;

-- 8.5 Daily journey

create or replace function public.get_dashboard_journey(
  p_user_id uuid,
  p_today   date default current_date
)
returns setof public.daily_journey_tasks
language sql
stable
as $$
  select *
  from public.daily_journey_tasks
  where user_id = p_user_id
    and day_date = p_today;
$$;

-- 8.6 Toggle journey task

create or replace function public.toggle_journey_task(
  p_user_id     uuid,
  p_kind        text,
  p_is_completed boolean,
  p_day         date default current_date
)
returns void
language plpgsql
as $$
begin
  insert into public.daily_journey_tasks (
    user_id, kind, day_date, is_completed, completed_at
  ) values (
    p_user_id, p_kind, p_day, p_is_completed,
    case when p_is_completed then now() else null end
  )
  on conflict (user_id, kind, day_date) do update
    set is_completed = excluded.is_completed,
        completed_at = case when excluded.is_completed
                            then now() else null end;
end;
$$;

-- 8.7 Today events (next 2 days)

create or replace function public.get_dashboard_events()
returns setof public.service_schedules
language sql
stable
as $$
  select *
  from public.service_schedules
  where is_active = true
    and starts_at >= current_date
    and starts_at < current_date + interval '2 days'
  order by starts_at asc;
$$;

-- 8.8 Prayer requests

create or replace function public.get_dashboard_prayer(p_limit integer default 4)
returns setof public.prayer_requests
language sql
stable
as $$
  select *
  from public.prayer_requests
  order by created_at desc
  limit p_limit;
$$;

-- 8.9 Increment prayer count

create or replace function public.increment_prayer_count(p_prayer_id uuid)
returns integer
language plpgsql
as $$
declare
  v_new_count integer;
begin
  update public.prayer_requests
    set prayer_count = prayer_count + 1
    where id = p_prayer_id
    returning prayer_count into v_new_count;
  return v_new_count;
end;
$$;

-- 8.10 Community highlight (per-user)

create or replace function public.get_dashboard_community(p_user_id uuid)
returns jsonb
language sql
stable
as $$
  select to_jsonb(c)
  from public.community_highlights_user c
  where c.user_id = p_user_id;
$$;

-- 8.11 Watch progress

create or replace function public.get_dashboard_watch(
  p_user_id uuid,
  p_limit   integer default 5
)
returns setof public.continue_progress
language sql
stable
as $$
  select *
  from public.continue_progress
  where user_id = p_user_id
    and kind in ('sermon', 'podcast')
  order by last_watched_at desc
  limit p_limit;
$$;

-- 8.12 Update watch progress

create or replace function public.update_watch_progress(
  p_user_id       uuid,
  p_kind          text,
  p_content_id    text,
  p_progress      numeric,
  p_is_downloaded boolean default null
)
returns void
language plpgsql
as $$
begin
  insert into public.continue_progress (
    user_id, kind, content_id, title, progress,
    is_downloaded, last_watched_at
  ) values (
    p_user_id, p_kind, p_content_id, '(untitled)', p_progress,
    coalesce(p_is_downloaded, false), now()
  )
  on conflict (user_id, kind, content_id) do update
    set progress        = excluded.progress,
        is_downloaded   = coalesce(p_is_downloaded, public.continue_progress.is_downloaded),
        last_watched_at = now();
end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- 9. Seed content (so the dashboard is non-empty on first launch)
-- ════════════════════════════════════════════════════════════════════════════

insert into public.daily_verses (day_date, verse_text, reference, translation)
values
  (current_date,                         'I can do all things through Christ who strengthens me.',                     'Philippians 4:13', 'NKJV'),
  (current_date - 1,                     'Trust in the Lord with all your heart.',                                       'Proverbs 3:5',     'ESV'),
  (current_date - 2,                     'For God so loved the world…',                                                  'John 3:16',        'NIV'),
  (current_date - 3,                     'The Lord is my shepherd; I shall not want.',                                    'Psalm 23:1',       'KJV'),
  (current_date - 4,                     'Be strong and courageous.',                                                     'Joshua 1:9',       'NIV'),
  (current_date + 1,                     'The Lord is my light and my salvation — whom shall I fear?',                    'Psalm 27:1',       'NKJV'),
  (current_date + 2,                     'I am the way, the truth, and the life.',                                        'John 14:6',        'ESV'),
  (current_date + 3,                     'Blessed are the pure in heart, for they shall see God.',                       'Matthew 5:8',      'NIV')
on conflict (day_date) do nothing;

-- Seed next 4 Sundays at 09:00
insert into public.service_schedules (title, host_label, starts_at, location_label, is_online, leader_name, category)
select
  'Sunday Worship Service',
  'Bishop J. Mensah',
  date_trunc('week', current_date)::date
    + interval '7 days' * s.week
    + interval '9 hours',
  'Main Sanctuary · In-person & Online',
  true,
  'Bishop J. Mensah',
  'sunday_service'
from generate_series(0, 3) as s(week)
on conflict do nothing;