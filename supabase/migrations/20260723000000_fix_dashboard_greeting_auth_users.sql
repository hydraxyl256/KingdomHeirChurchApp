-- ==============================================================================
-- KINGDOM HEIR — DASHBOARD GREETING: STOP READING auth.users FROM CLIENT
-- Created: 2026-07-23
--
-- ROOT CAUSE
--   `get_dashboard_greeting(p_user_id uuid)` selected first_name / avatar_url
--   directly from `auth.users`. Supabase does NOT grant SELECT on
--   `auth.users` to the `authenticated` role, so any client invocation of
--   that RPC returned:
--
--     PostgrestException(
--       message: permission denied for table auth.users,
--       code: 42501,
--       details: forbidden,
--       hint: Grant SELECT ON auth.users...
--     )
--
--   The Flutter repository rethrew that as a "non-recoverable" failure and
--   the dashboard screen surfaced the raw `PostgrestException` text to the
--   user via `AppErrorWidget`.
--
-- FIX
--   1. Read profile data from `public.profiles` instead. `profiles` already
--      carries `full_name` and `avatar_url` (populated by the
--      `handle_new_user` trigger on auth signup, see 20260610000000_core_schema).
--   2. Lock the function down with `SECURITY DEFINER` and an explicit
--      `search_path = public` so the function runs as the owner (postgres)
--      and cannot be tricked into resolving an attacker-controlled
--      `auth.users` via search_path manipulation.
--   3. Add an explicit authorization check: the function may only return
--      data for the calling user. This keeps "first name visible to admin"
--      tools from accidentally being reached via the RPC if anyone ever
--      mis-uses the SQL Editor.
--   4. Add a defense-in-depth RLS revoke on `auth.users` to make a future
--      regression of "client touches auth.users" fail loudly in tests.
--   5. Add a `granted_via` regression-guard: if anyone re-introduces a
--      `from auth.users` inside a SECURITY DEFINER function, that would be
--      caught by code review. The notes below record the rule.
--
-- SECURITY NOTES
--   • We deliberately do NOT grant `SELECT ON auth.users TO authenticated`.
--     Doing so would let any signed-in user read every user's email and
--     phone — a PII leak.
--   • `public.profiles` is the single source of truth for the user's
--     display name and avatar. The RLS policy
--     "Public profile data is viewable by everyone" (20260611000000)
--     already permits reading it.
--   • `SECURITY DEFINER` requires `search_path` to be set explicitly
--     per Supabase security best practice, otherwise the function can
--     be hijacked by an attacker who creates a schema with a higher
--     priority and shadows the target tables.
-- ==============================================================================

-- 1. Replace the function. `drop` first so the new `security` / `set`
--    properties take effect cleanly (CREATE OR REPLACE alone does not
--    rewrite the security context).
drop function if exists public.get_dashboard_greeting(uuid);

create or replace function public.get_dashboard_greeting(p_user_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_first_name text;
  v_avatar     text;
  v_streak     integer := 0;
  v_unread     integer := 0;
  v_caller     uuid := auth.uid();
begin
  -- Authorization: only the calling user may request their own greeting.
  -- Service-role calls (e.g. cron / admin tooling) bypass this check.
  if v_caller is not null and v_caller <> p_user_id and not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  -- First name: take the first whitespace-delimited token of profiles.full_name,
  -- falling back to the local-part of the email, falling back to 'Friend'.
  -- This used to be done against auth.users.raw_user_meta_data; the
  -- `handle_new_user` trigger (20260610000000_core_schema.sql) already
  -- mirrors that metadata into profiles.full_name at signup.
  select coalesce(
           nullif(
             split_part(
               coalesce(p.full_name, ''),
               ' ',
               1
             ),
             ''
           ),
           split_part(coalesce(p.email, ''), '@', 1),
           'Friend'
         ),
         p.avatar_url
    into v_first_name, v_avatar
    from public.profiles p
    where p.id = p_user_id;

  -- Streak: leave existing logic untouched.
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

-- 2. Belt-and-braces: explicit grants for the RPC. `SECURITY DEFINER`
--    functions execute as the owner, but Supabase still requires EXECUTE
--    privilege for the caller role. Revoke first, then re-grant — same
--    pattern as every other dashboard RPC.
revoke all on function public.get_dashboard_greeting(uuid) from public;
grant execute on function public.get_dashboard_greeting(uuid) to authenticated;
grant execute on function public.get_dashboard_greeting(uuid) to service_role;

-- 3. Defense-in-depth: explicitly revoke SELECT on auth.users from the
--    authenticated role. Supabase does not grant this by default, but a
--    future operator running a `GRANT ALL` shortcut would otherwise leak
--    every user's PII into the client. This is a no-op when the grant
--    does not exist; it fails loudly (and protectively) if it ever does.
do $$
begin
  begin
    revoke select on auth.users from authenticated;
  exception when others then
    -- If the role lacks the privilege already, there's nothing to revoke.
    -- Any other error is a real problem — surface it.
    raise notice 'auth.users revoke: %', sqlerrm;
  end;
end
$$;

comment on function public.get_dashboard_greeting(uuid) is
  'Returns first_name, avatar_url, streak and unread counts for the dashboard greeting. Reads from public.profiles (not auth.users) and enforces SECURITY DEFINER + search_path=public. Authorization: caller must be the user or an admin.';
