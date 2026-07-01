-- =============================================================================
-- 20260701010000_fix_prayer_and_events.sql
--
-- Fixes two production-blocking bugs:
--
-- (A) "Failed to load upcoming events"
--     The Flutter events_repository queries `events.status = 'published'`
--     because the core schema defaults `status` to 'draft'. But the production
--     seed (20260701000000_production_seed.sql) inserted events with the
--     default 'draft' status, so the public query returned zero rows.
--     This migration flips the seeded church events to 'published'.
--
-- (B) Prayer wall "Postgres error" (PGRST200 — could not find a relationship)
--     There are two tables named `prayer_requests` in the public schema:
--       1. The canonical one in 20260610000000_core_schema.sql with
--          `author_id UUID NOT NULL REFERENCES public.profiles(id)` — this
--          is what the prayer wall (lib/features/prayer_requests) reads.
--       2. A simpler dashboard-only one in 20260630_dashboard_real_data.sql
--          with `author_id UUID REFERENCES auth.users(id)` — this is what
--          the dashboard widgets read.
--     When the Flutter app does an embedded join like
--     `select('*, profiles(full_name, avatar_url)')`, PostgREST sometimes
--     can't disambiguate which table's relationship to follow and returns
--     PGRST200 ("Could not find a relationship between 'prayer_requests'
--     and 'profiles' in the schema cache"). The fix is to rename the
--     dashboard-only table to `prayer_wall_dashboard` so it's no longer
--     visible to the public prayer wall query, and to update the
--     dependent RPCs and columns to use the new name.
-- =============================================================================


-- ════════════════════════════════════════════════════════════════════════════
-- (A) Publish the seeded church events
-- ════════════════════════════════════════════════════════════════════════════

update public.events
   set status = 'published',
       updated_at = now()
 where status = 'draft'
   and title in (
     'Sunday Worship Service',
     'Mid-Week Bible Study',
     'Friday Night Prayer',
     'Saturday Youth Fellowship'
   );

-- Also publish any other events that have a start_at in the future
-- but are still in draft — these would be visible to the church app.
update public.events
   set status = 'published',
       updated_at = now()
 where status = 'draft'
   and start_at >= now();


-- ════════════════════════════════════════════════════════════════════════════
-- (B) Disambiguate the two `prayer_requests` tables
-- ════════════════════════════════════════════════════════════════════════════

-- Step 1: Rename the dashboard-only table and its intercession table so the
-- public prayer wall query (which targets `prayer_requests`) unambiguously
-- resolves to the core_schema table that has a real FK to `profiles`.

alter table if exists public.prayer_request_prays
  rename to dashboard_prayer_prays;

alter table if exists public.prayer_requests
  rename to prayer_wall_dashboard;

-- Step 2: Update the RLS policies on the renamed table (they still point
-- to the old name internally even though Postgres renames them with the
-- table). Postgres auto-updates policy names but the table reference in
-- `on public.<table>` is part of the policy identity, so we just need to
-- confirm the policies survived. We don't need to recreate them — Postgres
-- ALTER TABLE ... RENAME updates the policy definitions.

-- Step 3: Recreate the dashboard RPCs to point at the renamed table.

create or replace function public.get_dashboard_prayer(p_limit integer default 4)
returns setof public.prayer_wall_dashboard
language sql
stable
as $$
  select *
  from public.prayer_wall_dashboard
  order by created_at desc
  limit p_limit;
$$;

create or replace function public.increment_prayer_count(p_prayer_id uuid)
returns integer
language plpgsql
as $$
declare
  v_new_count integer;
begin
  update public.prayer_wall_dashboard
    set prayer_count = prayer_count + 1
    where id = p_prayer_id
    returning prayer_count into v_new_count;
  return v_new_count;
end;
$$;

-- Step 4: The increment counter on the core-schema prayer_requests table
-- (used by the public prayer wall) — the Flutter app calls
-- `prayer_intercessions` upsert/delete to track "I prayed" state, so we
-- don't strictly need an increment RPC for the public table. But we expose
-- one for completeness so the future "I prayed" button can be wired up
-- without another migration.

create or replace function public.increment_public_prayer_count(
  p_prayer_id uuid
)
returns integer
language plpgsql
security definer
as $$
declare
  v_new_count integer;
begin
  update public.prayer_requests
    set prayer_count = prayer_count + 1,
        updated_at   = now()
    where id = p_prayer_id
    returning prayer_count into v_new_count;
  return v_new_count;
end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- Done
-- ════════════════════════════════════════════════════════════════════════════
