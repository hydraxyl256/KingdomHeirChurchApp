-- ==============================================================================
-- KINGDOM HEIR — 90-DAY DEVOTIONAL SERIES SYSTEM
-- Migration: 20260712000001
-- Creates: devotional_series, devotional_entries, devotional_progress
--          + DB functions for progression
-- Note: devotional_translations and devotional_reflections are upgraded by the
--       follow-up migration 20260715000000_devotional_schema_upgrade.sql
--       because those tables already exist in production with an older schema.
-- ==============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. DEVOTIONAL SERIES
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.devotional_series (
  id                          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug                        TEXT        UNIQUE NOT NULL,
  title                       TEXT        NOT NULL,
  subtitle                    TEXT,
  author_name                 TEXT,
  cover_image_url             TEXT,
  description                 TEXT,
  total_days                  INTEGER     NOT NULL CHECK (total_days > 0),
  amazon_purchase_url         TEXT        DEFAULT 'https://www.amazon.com/s?k=james+maddalone&crid=33XGMCSH8QWPF&sprefix=james+maddalone+%2Caps%2C194&ref=nb_sb_noss',
  is_primary_challenge_series BOOLEAN     NOT NULL DEFAULT FALSE,
  status                      TEXT        NOT NULL
                                          CHECK (status IN ('draft','published','archived'))
                                          DEFAULT 'draft',
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'devotional_series_updated_at'
      AND tgrelid = 'public.devotional_series'::regclass
  ) THEN
    CREATE TRIGGER devotional_series_updated_at
      BEFORE UPDATE ON public.devotional_series
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_devotional_series_status  ON public.devotional_series (status);
CREATE INDEX IF NOT EXISTS idx_devotional_series_primary ON public.devotional_series (is_primary_challenge_series)
  WHERE is_primary_challenge_series = TRUE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. DEVOTIONAL ENTRIES (daily content)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.devotional_entries (
  id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  series_id                UUID        NOT NULL REFERENCES public.devotional_series(id) ON DELETE CASCADE,
  day_number               INTEGER     NOT NULL CHECK (day_number >= 1),
  title                    TEXT        NOT NULL,
  scripture_reference      TEXT,
  scripture_text           TEXT,
  devotional_body          TEXT        NOT NULL,
  reflection_question      TEXT,
  action_step              TEXT,
  prayer_text              TEXT,
  estimated_read_minutes   INTEGER,
  status                   TEXT        NOT NULL
                                       CHECK (status IN ('draft','published','archived'))
                                       DEFAULT 'draft',
  created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (series_id, day_number)
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'devotional_entries_updated_at'
      AND tgrelid = 'public.devotional_entries'::regclass
  ) THEN
    CREATE TRIGGER devotional_entries_updated_at
      BEFORE UPDATE ON public.devotional_entries
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_devotional_entries_series_day ON public.devotional_entries (series_id, day_number);
CREATE INDEX IF NOT EXISTS idx_devotional_entries_status      ON public.devotional_entries (status);

-- NOTE: devotional_translations is intentionally NOT created here.
--   It already exists in production with the old schema
--   (devotional_id / body / reflection / prayer).
--   Migration 20260715000000_devotional_schema_upgrade.sql performs
--   an in-place schema upgrade that preserves all existing rows.

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. DEVOTIONAL PROGRESS (per user, per series)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.devotional_progress (
  id                   UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID          NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  series_id            UUID          NOT NULL REFERENCES public.devotional_series(id) ON DELETE CASCADE,
  current_day          INTEGER       NOT NULL DEFAULT 1 CHECK (current_day >= 1),
  highest_unlocked_day INTEGER       NOT NULL DEFAULT 1 CHECK (highest_unlocked_day >= 1),
  completed_days       INTEGER[]     DEFAULT '{}',
  current_streak       INTEGER       NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak       INTEGER       NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
  last_completed_at    TIMESTAMPTZ,
  started_at           TIMESTAMPTZ   NOT NULL DEFAULT now(),
  completed_at         TIMESTAMPTZ,
  updated_at           TIMESTAMPTZ   NOT NULL DEFAULT now(),
  UNIQUE (user_id, series_id)
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'devotional_progress_updated_at'
      AND tgrelid = 'public.devotional_progress'::regclass
  ) THEN
    CREATE TRIGGER devotional_progress_updated_at
      BEFORE UPDATE ON public.devotional_progress
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_devotional_progress_user_series
  ON public.devotional_progress (user_id, series_id);
CREATE INDEX IF NOT EXISTS idx_devotional_progress_user
  ON public.devotional_progress (user_id);

-- NOTE: devotional_reflections is intentionally NOT created here.
--   It already exists in production with the old schema
--   (devotional_id / body, FK to public.devotionals).
--   Migration 20260715000000_devotional_schema_upgrade.sql renames
--   it to devotional_reflections_legacy (preserving data + RLS) and
--   creates the new devotional_reflections with the canonical schema.

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. RLS — DEVOTIONAL SERIES
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.devotional_series ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'devotional_series'
      AND policyname = 'devotional_series_public_read'
  ) THEN
    CREATE POLICY "devotional_series_public_read"
      ON public.devotional_series FOR SELECT
      TO authenticated
      USING (status = 'published');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'devotional_series'
      AND policyname = 'devotional_series_admin_all'
  ) THEN
    CREATE POLICY "devotional_series_admin_all"
      ON public.devotional_series FOR ALL
      TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
  END IF;
END
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. RLS — DEVOTIONAL ENTRIES
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.devotional_entries ENABLE ROW LEVEL SECURITY;

-- Authenticated users can read published entries for published series
-- that they have unlocked (day_number <= highest_unlocked_day)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'devotional_entries'
      AND policyname = 'devotional_entries_user_read'
  ) THEN
    CREATE POLICY "devotional_entries_user_read"
      ON public.devotional_entries FOR SELECT
      TO authenticated
      USING (
        status = 'published'
        AND EXISTS (
          SELECT 1 FROM public.devotional_series ds
          WHERE ds.id = series_id AND ds.status = 'published'
        )
        AND (
          -- User has progress and the day is unlocked
          day_number <= COALESCE(
            (SELECT dp.highest_unlocked_day
             FROM public.devotional_progress dp
             WHERE dp.user_id = auth.uid() AND dp.series_id = devotional_entries.series_id),
            0
          )
          -- OR user is admin
          OR public.is_admin()
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'devotional_entries'
      AND policyname = 'devotional_entries_admin_all'
  ) THEN
    CREATE POLICY "devotional_entries_admin_all"
      ON public.devotional_entries FOR ALL
      TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
  END IF;
END
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 8. RLS — DEVOTIONAL TRANSLATIONS
-- ─────────────────────────────────────────────────────────────────────────────
-- (The table is created/renamed by the upgrade migration. We add RLS here
--  only if the table exists. This block is a no-op if the upgrade migration
--  hasn't run yet, in which case the old RLS policies still apply.)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'devotional_translations'
  ) THEN
    EXECUTE 'ALTER TABLE public.devotional_translations ENABLE ROW LEVEL SECURITY';
  END IF;
END
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 9. RLS — DEVOTIONAL PROGRESS
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.devotional_progress ENABLE ROW LEVEL SECURITY;

-- Users can only read their own progress
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'devotional_progress'
      AND policyname = 'devotional_progress_own_read'
  ) THEN
    CREATE POLICY "devotional_progress_own_read"
      ON public.devotional_progress FOR SELECT
      TO authenticated
      USING (user_id = auth.uid() OR public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'devotional_progress'
      AND policyname = 'devotional_progress_admin_read'
  ) THEN
    -- Admins can view all for analytics
    CREATE POLICY "devotional_progress_admin_read"
      ON public.devotional_progress FOR SELECT
      TO authenticated
      USING (public.is_admin());
  END IF;
END
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 10. RLS — DEVOTIONAL REFLECTIONS
-- ─────────────────────────────────────────────────────────────────────────────
-- (Table created/renamed by the upgrade migration. RLS is added there
--  alongside the new table definition.)

-- ─────────────────────────────────────────────────────────────────────────────
-- 11. DB FUNCTION: initialize_devotional_progress()
--     Called when a user joins the 90-Day Challenge.
--     Idempotent — safe to call multiple times.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.initialize_devotional_progress(
  p_series_id UUID
)
RETURNS public.devotional_progress
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_result  public.devotional_progress;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Verify series is published
  IF NOT EXISTS (
    SELECT 1 FROM public.devotional_series
    WHERE id = p_series_id AND status = 'published'
  ) THEN
    RAISE EXCEPTION 'Series not found or not published';
  END IF;

  -- Upsert: insert if not exists, return existing if already initialized
  INSERT INTO public.devotional_progress (
    user_id, series_id, current_day, highest_unlocked_day,
    completed_days, current_streak, longest_streak, started_at
  )
  VALUES (
    v_user_id, p_series_id, 1, 1, '{}', 0, 0, now()
  )
  ON CONFLICT (user_id, series_id) DO NOTHING;

  SELECT * INTO v_result
  FROM public.devotional_progress
  WHERE user_id = v_user_id AND series_id = p_series_id;

  RETURN v_result;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 12. DB FUNCTION: complete_devotional_day()
--     Marks a day as complete, unlocks next day, recalculates streak.
--     Guards:
--       - User must be authenticated
--       - Day must be published
--       - Day must be <= highest_unlocked_day (cannot skip ahead)
--       - Idempotent: re-completing an already-completed day is a no-op
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.complete_devotional_day(
  p_series_id  UUID,
  p_day_number INTEGER
)
RETURNS public.devotional_progress
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id          UUID := auth.uid();
  v_progress         public.devotional_progress;
  v_total_days       INTEGER;
  v_new_streak       INTEGER;
  v_longest_streak   INTEGER;
  v_last_date        DATE;
  v_today            DATE := (now() AT TIME ZONE 'UTC')::DATE;
  v_already_done     BOOLEAN;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Load current progress (lock row to prevent race conditions)
  SELECT * INTO v_progress
  FROM public.devotional_progress
  WHERE user_id = v_user_id AND series_id = p_series_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Progress not initialized. Call initialize_devotional_progress first.';
  END IF;

  -- Validate the day exists and is published
  IF NOT EXISTS (
    SELECT 1 FROM public.devotional_entries
    WHERE series_id = p_series_id
      AND day_number = p_day_number
      AND status = 'published'
  ) THEN
    RAISE EXCEPTION 'Day % not found or not published', p_day_number;
  END IF;

  -- Guard: cannot complete a future (locked) day
  IF p_day_number > v_progress.highest_unlocked_day THEN
    RAISE EXCEPTION 'Day % is not yet unlocked. Complete day % first.',
      p_day_number, v_progress.highest_unlocked_day;
  END IF;

  -- Idempotency: if already completed, return current state
  v_already_done := p_day_number = ANY(v_progress.completed_days);
  IF v_already_done THEN
    RETURN v_progress;
  END IF;

  -- Get total days for the series
  SELECT total_days INTO v_total_days
  FROM public.devotional_series WHERE id = p_series_id;

  -- ── Streak calculation ──────────────────────────────────────────────────
  -- Only increment streak when completing on a new calendar day.
  -- Multiple completions in one day = streak moves at most once.
  v_last_date := (v_progress.last_completed_at AT TIME ZONE 'UTC')::DATE;

  IF v_progress.last_completed_at IS NULL THEN
    -- First ever completion
    v_new_streak := 1;
  ELSIF v_last_date = v_today THEN
    -- Already completed something today — streak stays the same
    v_new_streak := v_progress.current_streak;
  ELSIF v_last_date = v_today - INTERVAL '1 day' THEN
    -- Yesterday — extend streak
    v_new_streak := v_progress.current_streak + 1;
  ELSE
    -- Gap of more than 1 day — reset streak to 1
    v_new_streak := 1;
  END IF;

  v_longest_streak := GREATEST(v_new_streak, v_progress.longest_streak);

  -- ── Update progress row ─────────────────────────────────────────────────
  UPDATE public.devotional_progress SET
    completed_days       = array_append(completed_days, p_day_number),
    highest_unlocked_day = CASE
                             WHEN p_day_number >= highest_unlocked_day
                               THEN LEAST(p_day_number + 1, v_total_days)
                             ELSE highest_unlocked_day
                           END,
    current_day          = CASE
                             WHEN p_day_number >= current_day
                               THEN LEAST(p_day_number + 1, v_total_days)
                             ELSE current_day
                           END,
    current_streak       = v_new_streak,
    longest_streak       = v_longest_streak,
    last_completed_at    = now(),
    completed_at         = CASE
                             WHEN array_length(completed_days, 1) + 1 >= v_total_days
                               THEN now()
                             ELSE completed_at
                           END,
    updated_at           = now()
  WHERE user_id = v_user_id AND series_id = p_series_id
  RETURNING * INTO v_progress;

  RETURN v_progress;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 13. DB FUNCTION: get_devotional_progress()
--     Safe read function — returns null if not yet initialized.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_devotional_progress(
  p_series_id UUID
)
RETURNS public.devotional_progress
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result public.devotional_progress;
BEGIN
  SELECT * INTO v_result
  FROM public.devotional_progress
  WHERE user_id = auth.uid() AND series_id = p_series_id;

  RETURN v_result; -- NULL if not found
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 14. ADMIN ANALYTICS VIEW
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.devotional_progress_analytics AS
SELECT
  ds.title                                        AS series_title,
  ds.total_days,
  COUNT(dp.user_id)                               AS total_participants,
  COUNT(dp.completed_at)                          AS total_completions,
  ROUND(AVG(array_length(dp.completed_days, 1)))  AS avg_days_completed,
  MAX(dp.current_streak)                          AS highest_current_streak,
  MAX(dp.longest_streak)                          AS highest_ever_streak
FROM public.devotional_series ds
LEFT JOIN public.devotional_progress dp ON dp.series_id = ds.id
GROUP BY ds.id, ds.title, ds.total_days;
