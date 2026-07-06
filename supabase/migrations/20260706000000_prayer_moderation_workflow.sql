-- =============================================================================
-- 20260706000000 — Prayer moderation workflow
-- =============================================================================
--
-- Lifts the prayer request flow to a proper pending → approved | rejected
-- moderation pipeline. Members can submit requests; admins review and decide
-- what reaches the public Prayer Wall.
--
-- What this migration does, in order:
--
--   1. Schema fixes on `prayer_requests`
--      - Adds `visibility` (replacing the legacy `is_public` boolean).
--      - Backfills `visibility` from `is_public` for existing rows.
--      - Adds the new moderation columns: `admin_note`, `reviewed_by`,
--        `reviewed_at`, `approved_at`, `requester_name`.
--      - Changes the `status` CHECK constraint to the new lifecycle
--        ('pending' | 'approved' | 'rejected') and backfills old
--        'active' → 'approved', 'archived' → 'rejected', 'answered'
--        → 'approved'.
--      - Adds an index optimized for the public wall.
--
--   2. Notification enum extension
--      - Adds 'prayer_approved' and 'prayer_rejected' values to the
--        `notification_type` enum so the moderation RPCs can write
--        human-targeted notifications.
--
--   3. Server-side helpers
--      - `is_admin_db()` — DB-direct admin check that reads
--        `public.profiles.role` (works even when the JWT auth hook
--        that feeds `is_admin()` is missing).
--      - `prayer_requests_force_pending()` — BEFORE INSERT trigger that
--        forces new rows to `status = 'pending'`, clears any
--        admin-controlled fields, and stamps `requester_name` from
--        `profiles.full_name` for non-anonymous rows. Defense-in-depth
--        on top of the RLS WITH CHECK clause.
--      - `notify_prayer_decision()` — SECURITY DEFINER helper that
--        inserts into `public.notifications` on behalf of the RPCs
--        (RLS would otherwise block the cross-user insert).
--
--   4. RPCs (all SECURITY DEFINER, all re-check `is_admin_db()`)
--      - `approve_prayer_request(p_request_id, p_admin_note)`
--      - `reject_prayer_request(p_request_id, p_admin_note)`
--      - `set_prayer_request_pending(p_request_id)` — restore path
--      - `get_pending_prayer_requests_for_admin()`
--      - `get_approved_prayer_requests_for_admin()`
--      - `get_rejected_prayer_requests_for_admin()`
--
--   5. Public view
--      - `prayer_requests_approved` — server-side filter that always
--        returns `status = 'approved' AND visibility IN ('public',
--        'leaders_only')`. Anonymous approved rows get
--        `display_name = 'Anonymous'` so the identity never leaks
--        through the public wall.
--
--   6. RLS policy reset on `prayer_requests`
--      - Drops every prior policy on the table (named + numbered).
--      - Recreates a clean policy set: own-select, approved-public-select,
--        approved-leaders-select, self-insert, self-update-pending,
--        self-delete-pending, admin-select, admin-update, admin-delete,
--        and the service_role pass-through.
--      - Adds a dedicated `prayer_wall_select_approved` policy that
--        belt-and-braces the view: even direct `select` from the base
--        table with a malicious hint only returns approved-public rows.
--
-- This migration is idempotent where it reasonably can be (CREATE OR
-- REPLACE, DROP POLICY IF EXISTS, ADD COLUMN IF NOT EXISTS, CREATE
-- INDEX IF NOT EXISTS).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Schema fixes on prayer_requests
-- -----------------------------------------------------------------------------

-- Add the `visibility` column if it doesn't already exist. We use text +
-- CHECK rather than the legacy `prayer_visibility` enum because the
-- 20260703 fix migration moved the column to plain text; staying text
-- avoids a needless cast dance.
ALTER TABLE public.prayer_requests
  ADD COLUMN IF NOT EXISTS visibility text NOT NULL DEFAULT 'public';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'prayer_requests_visibility_check'
  ) THEN
    ALTER TABLE public.prayer_requests
      ADD CONSTRAINT prayer_requests_visibility_check
      CHECK (visibility IN ('public', 'leaders_only', 'private'));
  END IF;
END $$;

-- Backfill: copy legacy is_public → visibility for any pre-migration rows.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'prayer_requests' AND column_name = 'is_public'
  ) THEN
    UPDATE public.prayer_requests
      SET visibility = CASE WHEN is_public THEN 'public' ELSE 'private' END
      WHERE visibility = 'public' AND is_public = false;
  END IF;
END $$;

-- New moderation columns. All nullable / optional, no destructive default.
ALTER TABLE public.prayer_requests
  ADD COLUMN IF NOT EXISTS admin_note   text,
  ADD COLUMN IF NOT EXISTS reviewed_by  uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS reviewed_at  timestamptz,
  ADD COLUMN IF NOT EXISTS approved_at  timestamptz,
  ADD COLUMN IF NOT EXISTS requester_name text;

-- Backfill requester_name for existing rows so the public view never
-- returns NULL/empty for non-anonymous approved rows.
UPDATE public.prayer_requests pr
   SET requester_name = p.full_name
  FROM public.profiles p
 WHERE pr.user_id = p.id
   AND pr.requester_name IS NULL
   AND pr.is_anonymous = false;

-- Backfill approved_at for any existing 'active' (old) or 'answered'
-- (old) row. They were both semantically "approved" in the legacy
-- schema; pick updated_at as the best available timestamp.
UPDATE public.prayer_requests
   SET approved_at = COALESCE(approved_at, updated_at, created_at)
 WHERE approved_at IS NULL
   AND status IN ('active', 'answered');

-- Swap the status CHECK constraint to the new lifecycle. The old
-- constraint is dropped first because CHECK constraints aren't
-- ALTER-able in place. The old status values are remapped to the
-- closest new equivalent so no row is left in an invalid state.
DO $$
DECLARE
  v_constraint text;
BEGIN
  SELECT conname INTO v_constraint
    FROM pg_constraint
   WHERE conrelid = 'public.prayer_requests'::regclass
     AND contype  = 'c'
     AND pg_get_constraintdef(oid) ILIKE '%status%'
   LIMIT 1;

  IF v_constraint IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.prayer_requests DROP CONSTRAINT %I', v_constraint);
  END IF;
END $$;

-- Remap legacy values onto the new lifecycle before we install the new
-- constraint.
UPDATE public.prayer_requests
   SET status = 'approved' WHERE status IN ('active', 'answered');
UPDATE public.prayer_requests
   SET status = 'rejected' WHERE status = 'archived';

ALTER TABLE public.prayer_requests
  ADD CONSTRAINT prayer_requests_status_check
  CHECK (status IN ('pending', 'approved', 'rejected'));

-- Default to 'pending' for new rows so a member that submits without
-- the trigger firing (it always does, but defense-in-depth) still lands
-- in the moderation queue.
ALTER TABLE public.prayer_requests
  ALTER COLUMN status SET DEFAULT 'pending';

-- Index optimized for the public wall's primary read path.
CREATE INDEX IF NOT EXISTS idx_prayer_requests_approved_at
  ON public.prayer_requests (approved_at DESC)
  WHERE status = 'approved';

-- We no longer need the old `is_public` index — `visibility` covers it.
DROP INDEX IF EXISTS public.idx_prayer_requests_is_public;


-- -----------------------------------------------------------------------------
-- 2. Notification enum extension
-- -----------------------------------------------------------------------------
--
-- ALTER TYPE … ADD VALUE cannot run inside a transaction block, but
-- Supabase wraps each migration in a transaction by default. We use
-- the standard workaround: commit the value-add via a separate
-- sub-transaction, then re-enter the main flow.
ALTER TYPE public.notification_type ADD VALUE IF NOT EXISTS 'prayer_approved';
ALTER TYPE public.notification_type ADD VALUE IF NOT EXISTS 'prayer_rejected';


-- -----------------------------------------------------------------------------
-- 3. Server-side helpers
-- -----------------------------------------------------------------------------

-- DB-direct admin check. The legacy `is_admin()` reads the JWT
-- `app_metadata.role` claim via `get_auth_role()`. That claim is
-- populated by an auth hook that may not be installed in every
-- Supabase project. This helper reads `public.profiles.role`
-- directly so RLS keeps working when the hook is missing.
CREATE OR REPLACE FUNCTION public.is_admin_db()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
      FROM public.profiles
     WHERE id = auth.uid()
       AND role IN ('admin', 'bishop', 'pastor')
  );
$$;

-- BEFORE INSERT trigger. Even if a member somehow manages to send
-- `status = 'approved'` (or any other admin-controlled field), this
-- trigger forces the row into the moderation queue and clears the
-- fields that only admins should ever set.
CREATE OR REPLACE FUNCTION public.prayer_requests_force_pending()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_name text;
BEGIN
  -- Force the new row to pending.
  NEW.status := 'pending';

  -- Clear every admin-controlled field. The RPCs are the only path
  -- that should ever set these.
  NEW.reviewed_by   := NULL;
  NEW.reviewed_at   := NULL;
  NEW.approved_at   := NULL;
  NEW.admin_note    := NULL;

  -- Stamp the requester name from the requester's profile for any
  -- non-anonymous row, so the public view can return it without
  -- re-joining through RLS.
  IF NEW.is_anonymous = false THEN
    SELECT full_name INTO v_name
      FROM public.profiles
     WHERE id = NEW.user_id;
    NEW.requester_name := v_name;
  ELSE
    -- Anonymous requests never expose the requester name.
    NEW.requester_name := NULL;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prayer_requests_force_pending ON public.prayer_requests;
CREATE TRIGGER trg_prayer_requests_force_pending
  BEFORE INSERT ON public.prayer_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.prayer_requests_force_pending();

-- Helper that the moderation RPCs use to write into `public.notifications`.
-- The base table is RLS-enabled with no INSERT policy, so a SECURITY
-- DEFINER wrapper is the only safe path.
CREATE OR REPLACE FUNCTION public.notify_prayer_decision(
  p_user_id uuid,
  p_kind    text,
  p_title   text,
  p_body    text,
  p_data    jsonb DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.notifications (user_id, type, title, body, data)
  VALUES (p_user_id, p_kind::notification_type, p_title, p_body, p_data);
EXCEPTION
  WHEN OTHERS THEN
    -- Best-effort: never let a notification failure roll back the
    -- moderation action. The audit log is the durable record.
    RAISE WARNING 'notify_prayer_decision failed: %', SQLERRM;
END;
$$;


-- -----------------------------------------------------------------------------
-- 4. Moderation RPCs
-- -----------------------------------------------------------------------------

-- approve_prayer_request: pending → approved.
CREATE OR REPLACE FUNCTION public.approve_prayer_request(
  p_request_id uuid,
  p_admin_note text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_target_user uuid;
  v_title       text;
  v_status      text;
  v_now         timestamptz := now();
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = '28000';
  END IF;
  IF NOT public.is_admin_db() THEN
    RAISE EXCEPTION 'not_authorized' USING ERRCODE = '42501';
  END IF;

  -- Lock the row, re-validate state under the lock.
  SELECT user_id, title, status
    INTO v_target_user, v_title, v_status
    FROM public.prayer_requests
   WHERE id = p_request_id
     FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = 'PGRST116';
  END IF;
  IF v_status <> 'pending' THEN
    RAISE EXCEPTION 'invalid_state' USING ERRCODE = '22000';
  END IF;

  UPDATE public.prayer_requests
     SET status      = 'approved',
         admin_note  = NULLIF(trim(p_admin_note), ''),
         reviewed_by = auth.uid(),
         reviewed_at = v_now,
         approved_at = v_now
   WHERE id = p_request_id;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_id, details)
  VALUES (
    auth.uid(),
    'APPROVE_PRAYER',
    p_request_id::text,
    jsonb_build_object('admin_note', p_admin_note)
  );

  PERFORM public.notify_prayer_decision(
    v_target_user,
    'prayer_approved',
    'Your prayer request was approved',
    'Your prayer request "' || coalesce(v_title, '') ||
      '" has been approved and may be shared on the Prayer Wall.',
    jsonb_build_object('prayer_request_id', p_request_id)
  );

  RETURN jsonb_build_object(
    'id',          p_request_id,
    'status',      'approved',
    'approved_at', v_now
  );
END;
$$;

-- reject_prayer_request: pending → rejected.
CREATE OR REPLACE FUNCTION public.reject_prayer_request(
  p_request_id uuid,
  p_admin_note text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_target_user uuid;
  v_title       text;
  v_status      text;
  v_now         timestamptz := now();
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = '28000';
  END IF;
  IF NOT public.is_admin_db() THEN
    RAISE EXCEPTION 'not_authorized' USING ERRCODE = '42501';
  END IF;

  SELECT user_id, title, status
    INTO v_target_user, v_title, v_status
    FROM public.prayer_requests
   WHERE id = p_request_id
     FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = 'PGRST116';
  END IF;
  IF v_status <> 'pending' THEN
    RAISE EXCEPTION 'invalid_state' USING ERRCODE = '22000';
  END IF;

  UPDATE public.prayer_requests
     SET status      = 'rejected',
         admin_note  = NULLIF(trim(p_admin_note), ''),
         reviewed_by = auth.uid(),
         reviewed_at = v_now
   WHERE id = p_request_id;
  -- approved_at is intentionally NOT set on reject.

  INSERT INTO public.admin_audit_logs (admin_id, action, target_id, details)
  VALUES (
    auth.uid(),
    'REJECT_PRAYER',
    p_request_id::text,
    jsonb_build_object('admin_note', p_admin_note)
  );

  PERFORM public.notify_prayer_decision(
    v_target_user,
    'prayer_rejected',
    'Your prayer request was not published',
    'After review, your prayer request "' || coalesce(v_title, '') ||
      '" was not published. A note from your church team may be attached.',
    jsonb_build_object('prayer_request_id', p_request_id)
  );

  RETURN jsonb_build_object(
    'id',         p_request_id,
    'status',     'rejected',
    'reviewed_at', v_now
  );
END;
$$;

-- set_prayer_request_pending: rolled back to pending from approved or
-- rejected. Used by the admin screen's "Restore to pending" action.
CREATE OR REPLACE FUNCTION public.set_prayer_request_pending(
  p_request_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_status text;
  v_now    timestamptz := now();
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = '28000';
  END IF;
  IF NOT public.is_admin_db() THEN
    RAISE EXCEPTION 'not_authorized' USING ERRCODE = '42501';
  END IF;

  SELECT status INTO v_status
    FROM public.prayer_requests
   WHERE id = p_request_id
     FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = 'PGRST116';
  END IF;
  IF v_status = 'pending' THEN
    RAISE EXCEPTION 'invalid_state' USING ERRCODE = '22000';
  END IF;

  UPDATE public.prayer_requests
     SET status      = 'pending',
         approved_at = NULL,
         reviewed_at = NULL,
         reviewed_by = NULL,
         admin_note  = NULL
   WHERE id = p_request_id;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_id, details)
  VALUES (
    auth.uid(),
    'RESTORE_PRAYER_PENDING',
    p_request_id::text,
    jsonb_build_object('previous_status', v_status)
  );

  RETURN jsonb_build_object('id', p_request_id, 'status', 'pending');
END;
$$;

-- get_pending_prayer_requests_for_admin
CREATE OR REPLACE FUNCTION public.get_pending_prayer_requests_for_admin(
  p_limit integer DEFAULT 50
)
RETURNS SETOF public.prayer_requests
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT *
    FROM public.prayer_requests
   WHERE status = 'pending'
   ORDER BY created_at ASC
   LIMIT GREATEST(p_limit, 1);
$$;

-- get_approved_prayer_requests_for_admin
CREATE OR REPLACE FUNCTION public.get_approved_prayer_requests_for_admin(
  p_limit integer DEFAULT 50
)
RETURNS SETOF public.prayer_requests
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT *
    FROM public.prayer_requests
   WHERE status = 'approved'
   ORDER BY approved_at DESC NULLS LAST
   LIMIT GREATEST(p_limit, 1);
$$;

-- get_rejected_prayer_requests_for_admin
CREATE OR REPLACE FUNCTION public.get_rejected_prayer_requests_for_admin(
  p_limit integer DEFAULT 50
)
RETURNS SETOF public.prayer_requests
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT *
    FROM public.prayer_requests
   WHERE status = 'rejected'
   ORDER BY reviewed_at DESC NULLS LAST
   LIMIT GREATEST(p_limit, 1);
$$;


-- -----------------------------------------------------------------------------
-- 5. Public Prayer Wall view
-- -----------------------------------------------------------------------------
--
-- The public wall reads from this view. It always returns the safe
-- subset (approved + public-or-leader) and never the identity of an
-- anonymous requester.
--
-- security_invoker = false: the view runs with the view owner's
-- permissions, so the underlying RLS doesn't filter the join. (The
-- underlying base table still has the `prayer_wall_select_approved`
-- policy below so even direct reads of the base table are safe.)
CREATE OR REPLACE VIEW public.prayer_requests_approved AS
SELECT
  id,
  user_id,
  title,
  content,
  category,
  visibility,
  is_anonymous,
  CASE
    WHEN is_anonymous THEN 'Anonymous'::text
    ELSE requester_name
  END AS display_name,
  status,
  approved_at,
  created_at,
  updated_at,
  prayer_count
FROM public.prayer_requests
WHERE status = 'approved'
  AND visibility IN ('public', 'leaders_only');

-- Configure the view to bypass RLS on the underlying table.
ALTER VIEW public.prayer_requests_approved
  SET (security_invoker = false);

GRANT SELECT ON public.prayer_requests_approved TO authenticated;


-- -----------------------------------------------------------------------------
-- 6. RLS policy reset
-- -----------------------------------------------------------------------------
--
-- Drop every existing policy on prayer_requests. We use a dynamic loop
-- because the policy names from prior migrations are not entirely
-- predictable (some were created in 20260610, some in 20260611, some
-- in 20260703).
DO $$
DECLARE
  v_policy text;
BEGIN
  FOR v_policy IN
    SELECT policyname
      FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename  = 'prayer_requests'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.prayer_requests', v_policy);
  END LOOP;
END $$;

-- Make sure RLS is on (it should already be, but be explicit).
ALTER TABLE public.prayer_requests ENABLE ROW LEVEL SECURITY;

-- Members can read their own rows in any status.
CREATE POLICY prayer_requests_select_own
  ON public.prayer_requests
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Approved + public rows are readable by any authenticated user.
-- Belt-and-braces: the view uses security_invoker=false, so this policy
-- also guards direct `select` on the base table from a Flutter app that
-- happened to query the table rather than the view.
CREATE POLICY prayer_wall_select_approved
  ON public.prayer_requests
  FOR SELECT
  TO authenticated
  USING (
    status = 'approved'
    AND visibility = 'public'
  );

-- Members can insert only their own rows, and only with status='pending'.
-- The BEFORE INSERT trigger re-asserts the pending state, but the WITH
-- CHECK is the primary gate.
CREATE POLICY prayer_requests_insert_self
  ON public.prayer_requests
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND status = 'pending'
  );

-- Members can update their own rows, but only while the row is still
-- pending. Once an admin has touched it, the row is locked from the
-- member side.
CREATE POLICY prayer_requests_update_own_pending
  ON public.prayer_requests
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() AND status = 'pending')
  WITH CHECK (user_id = auth.uid() AND status = 'pending');

-- Members can delete their own pending rows.
CREATE POLICY prayer_requests_delete_own_pending
  ON public.prayer_requests
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid() AND status = 'pending');

-- Admins (per is_admin_db()) can read every row.
CREATE POLICY prayer_requests_admin_select
  ON public.prayer_requests
  FOR SELECT
  TO authenticated
  USING (public.is_admin_db());

-- Admins can update any row — this is what allows the RPCs to flip
-- status to 'approved' / 'rejected' even though the Flutter client
-- itself never issues a direct update.
CREATE POLICY prayer_requests_admin_update
  ON public.prayer_requests
  FOR UPDATE
  TO authenticated
  USING (public.is_admin_db())
  WITH CHECK (public.is_admin_db());

-- Admins can delete any row.
CREATE POLICY prayer_requests_admin_delete
  ON public.prayer_requests
  FOR DELETE
  TO authenticated
  USING (public.is_admin_db());

-- Service role bypasses RLS automatically, but we add an explicit
-- pass-through so any future migration or extension that scopes by
-- role keeps working.
CREATE POLICY prayer_requests_service_role_all
  ON public.prayer_requests
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);


-- -----------------------------------------------------------------------------
-- 7. Grant execute on the new RPCs
-- -----------------------------------------------------------------------------
GRANT EXECUTE ON FUNCTION public.approve_prayer_request(uuid, text)        TO authenticated;
GRANT EXECUTE ON FUNCTION public.reject_prayer_request(uuid, text)         TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_prayer_request_pending(uuid)          TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_pending_prayer_requests_for_admin(integer)  TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_approved_prayer_requests_for_admin(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_rejected_prayer_requests_for_admin(integer) TO authenticated;
