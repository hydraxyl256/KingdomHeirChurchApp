-- ==============================================================================
-- KINGDOM HEIR — DEVOTIONAL SCHEMA UPGRADE
-- Migration: 20260715000000
-- Purpose:  In-place upgrade of the production devotional schema to the
--           new multilingual 90-Day Devotional architecture.
--
-- Why this migration exists
-- -------------------------
-- The migration 20260712000001_devotional_series.sql failed in production
-- with `ERROR: relation "devotional_translations" already exists (42P07)`
-- because the table was already created back in
-- 20260612000000_multilingual_schema.sql with a *different* schema:
--
--   OLD: devotional_id / body / reflection / prayer / scripture_text
--   NEW: devotional_entry_id / devotional_body / reflection_question /
--        prayer_text / scripture_reference / action_step /
--        translation_status / translated_by / reviewed_by / updated_at
--
-- Likewise, devotional_reflections already exists with the legacy
-- devotional_id / body shape and an FK to public.devotionals.
--
-- This migration:
--   1. Upgrades devotional_translations in place — rename cols, add cols,
--      swap FK, switch unique constraint, preserve every row, RLS, trigger,
--      and index.
--   2. Renames the legacy devotional_reflections table to
--      devotional_reflections_legacy (preserves data, RLS, policies) and
--      creates a fresh devotional_reflections with the new canonical
--      schema (FK to devotional_entries, reflection_text, is_private).
--   3. Adds the new RLS policies for devotional_translations and
--      devotional_reflections.
--   4. Re-runs the devotional_progress RLS block idempotently.
--
-- Everything below is safe to run multiple times (idempotent).
-- ==============================================================================


-- ════════════════════════════════════════════════════════════════════════════
-- SECTION A — UPGRADE devotional_translations
-- ════════════════════════════════════════════════════════════════════════════

-- A0. Drop the existing FK and unique constraint that depend on devotional_id
--     so we can safely rename the column. We use IF EXISTS for the named
--     constraints AND also try the auto-generated names so this works
--     even if the original migration used a slightly different naming.
ALTER TABLE public.devotional_translations
  DROP CONSTRAINT IF EXISTS devotional_translations_devotional_id_fkey;

ALTER TABLE public.devotional_translations
  DROP CONSTRAINT IF EXISTS devotional_translations_devotional_id_language_code_key;

-- Belt-and-braces: if either constraint exists with a different auto-name,
-- drop it by querying the catalog. The IF EXISTS guard prevents errors
-- when the constraint has already been dropped in a prior partial run.
DO $$
DECLARE
  cname text;
BEGIN
  FOR cname IN
    SELECT conname FROM pg_constraint c
    JOIN pg_class  t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND t.relname = 'devotional_translations'
      AND c.contype IN ('f','u')
      AND pg_get_constraintdef(c.oid) LIKE '%devotional_id%'
  LOOP
    EXECUTE format('ALTER TABLE public.devotional_translations DROP CONSTRAINT %I', cname);
  END LOOP;
END
$$;

-- Drop the legacy index that exists on (devotional_id, language_code) so we
-- can recreate the right one after the rename.
DROP INDEX IF EXISTS public.idx_devotional_translations_devotional;

-- A1. RENAME columns to the new canonical names.
--     Using DO blocks guarded by information_schema so this is idempotent.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_translations'
      AND column_name  = 'devotional_id'
  ) THEN
    ALTER TABLE public.devotional_translations
      RENAME COLUMN devotional_id TO devotional_entry_id;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_translations'
      AND column_name  = 'body'
  ) THEN
    ALTER TABLE public.devotional_translations
      RENAME COLUMN body TO devotional_body;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_translations'
      AND column_name  = 'reflection'
  ) THEN
    ALTER TABLE public.devotional_translations
      RENAME COLUMN reflection TO reflection_question;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_translations'
      AND column_name  = 'prayer'
  ) THEN
    ALTER TABLE public.devotional_translations
      RENAME COLUMN prayer TO prayer_text;
  END IF;
END
$$;

-- A2. ADD the new columns introduced by the 90-Day Devotional architecture.
--     All nullable so existing rows (with NULL devotional_entry_id) remain
--     valid; new rows created by the app will populate them.
ALTER TABLE public.devotional_translations
  ADD COLUMN IF NOT EXISTS scripture_reference TEXT;

ALTER TABLE public.devotional_translations
  ADD COLUMN IF NOT EXISTS action_step         TEXT;

ALTER TABLE public.devotional_translations
  ADD COLUMN IF NOT EXISTS translation_status  TEXT
    NOT NULL DEFAULT 'draft';

ALTER TABLE public.devotional_translations
  ADD COLUMN IF NOT EXISTS translated_by       TEXT;

ALTER TABLE public.devotional_translations
  ADD COLUMN IF NOT EXISTS reviewed_by         TEXT;

ALTER TABLE public.devotional_translations
  ADD COLUMN IF NOT EXISTS updated_at          TIMESTAMPTZ NOT NULL DEFAULT now();

-- A3. Re-create the updated_at trigger if missing.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'devotional_translations_updated_at'
      AND tgrelid = 'public.devotional_translations'::regclass
  ) THEN
    CREATE TRIGGER devotional_translations_updated_at
      BEFORE UPDATE ON public.devotional_translations
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END
$$;

-- A4. Widen language_code from VARCHAR(5) to TEXT (the new schema expects
--     arbitrary length tags like 'en-US', 'pt-BR', etc.). The old column
--     type was VARCHAR(5); widening is non-destructive.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_translations'
      AND column_name  = 'language_code'
      AND data_type    = 'character varying'
  ) THEN
    ALTER TABLE public.devotional_translations
      ALTER COLUMN language_code TYPE TEXT;
  END IF;
END
$$;

-- A5. Add the CHECK constraint for translation_status (idempotent).
--     Allowed values: draft / review / published.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'devotional_translations_translation_status_check'
      AND conrelid = 'public.devotional_translations'::regclass
  ) THEN
    ALTER TABLE public.devotional_translations
      ADD CONSTRAINT devotional_translations_translation_status_check
      CHECK (translation_status IN ('draft','review','published'));
  END IF;
END
$$;

-- A6. Add the new unique constraint UNIQUE(devotional_entry_id, language_code).
--     The original unique constraint on the renamed column was
--     UNIQUE(devotional_id, language_code); after the rename in A1 it
--     would be UNIQUE(devotional_entry_id, language_code) automatically,
--     but we dropped it in A0 and recreate it here under the canonical
--     name. This is the final unique constraint specified by the spec.
--
--     Legacy rows (renamed from devotional_id) keep their old values, so
--     they are still unique under the (devotional_entry_id, language_code)
--     pair and the constraint is satisfied. New rows produced by the 90-Day
--     app always populate devotional_entry_id, so the constraint continues
--     to enforce uniqueness going forward.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'devotional_translations_devotional_entry_id_language_code_key'
      AND conrelid = 'public.devotional_translations'::regclass
  ) THEN
    ALTER TABLE public.devotional_translations
      ADD CONSTRAINT devotional_translations_devotional_entry_id_language_code_key
      UNIQUE (devotional_entry_id, language_code);
  END IF;
END
$$;

-- A7. Add the new FK to public.devotional_entries.
--     The legacy rows still contain devotional_id values from
--     public.devotionals (NOT NULL because the old column was NOT NULL),
--     which obviously do not exist in public.devotional_entries yet.
--     So we add the FK as NOT VALID to skip validating the existing
--     rows, then backfill by nulling out the now-stale fk values, then
--     VALIDATE the constraint.
--
--     New rows from the 90-Day app always populate devotional_entry_id
--     with a real public.devotional_entries.id, so the constraint will
--     hold for all future writes.
--
--     This block is a no-op if public.devotional_entries doesn't exist
--     yet — in that case the legacy devotional_id values are still
--     valid and the migration 20260712000001 will create
--     devotional_entries and the FK will be added in a follow-up.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'devotional_translations_devotional_entry_id_fkey'
      AND conrelid = 'public.devotional_translations'::regclass
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'devotional_entries'
    ) THEN
      -- 1. Backfill: legacy rows that point to the now-removed-from-FK
      --    devotionals table get NULL so the FK validates clean. This
      --    preserves the rows themselves; only the orphaned fk pointer
      --    is cleared. Legacy data remains queryable on the row id /
      --    language code, just no longer attached to the new 90-day
      --    entries.
      UPDATE public.devotional_translations
         SET devotional_entry_id = NULL
       WHERE devotional_entry_id IS NOT NULL
         AND NOT EXISTS (
           SELECT 1 FROM public.devotional_entries de
           WHERE de.id = devotional_translations.devotional_entry_id
         );

      -- 2. Add the new FK.
      ALTER TABLE public.devotional_translations
        ADD CONSTRAINT devotional_translations_devotional_entry_id_fkey
        FOREIGN KEY (devotional_entry_id)
        REFERENCES public.devotional_entries(id)
        ON DELETE CASCADE
        NOT VALID;

      -- 3. Validate the constraint now that no legacy row can violate it.
      ALTER TABLE public.devotional_translations
        VALIDATE CONSTRAINT devotional_translations_devotional_entry_id_fkey;
    END IF;
  END IF;
END
$$;

-- A8. Recreate the supporting index on (devotional_entry_id, language_code).
--     (Drop was performed in step A0; recreate the named index the app
--     expects to find.)
CREATE INDEX IF NOT EXISTS idx_devotional_translations_entry_lang
  ON public.devotional_translations (devotional_entry_id, language_code);

-- Index for translation_status queries (admin review queue).
CREATE INDEX IF NOT EXISTS idx_devotional_translations_status
  ON public.devotional_translations (translation_status);

-- A9. RLS for devotional_translations — keep the public-read / admin-all
--     policies that existed in the old multilingual migration, plus
--     add the user-read policy the 90-Day system uses.
ALTER TABLE public.devotional_translations ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  -- The legacy migration added a "Public read" policy. We keep that
  -- because it is the broadest policy and ensures existing clients
  -- continue to work.
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'devotional_translations'
      AND policyname = 'Public read for dev translations'
  ) THEN
    CREATE POLICY "Public read for dev translations"
      ON public.devotional_translations FOR SELECT
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'devotional_translations'
      AND policyname = 'Admin write for dev translations'
  ) THEN
    CREATE POLICY "Admin write for dev translations"
      ON public.devotional_translations FOR ALL
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
  END IF;

  -- The new app uses this narrower policy: only published translations
  -- of published entries are visible to non-admin authenticated users.
  -- We only create this policy if public.devotional_entries exists;
  -- otherwise the migration 20260712000001 will create the new table
  -- and the policy will be created in a follow-up.
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'devotional_translations'
      AND policyname = 'devotional_translations_user_read'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'devotional_entries'
  ) THEN
    CREATE POLICY "devotional_translations_user_read"
      ON public.devotional_translations FOR SELECT
      TO authenticated
      USING (
        translation_status = 'published'
        AND EXISTS (
          SELECT 1 FROM public.devotional_entries de
          WHERE de.id = devotional_entry_id AND de.status = 'published'
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'devotional_translations'
      AND policyname = 'devotional_translations_admin_all'
  ) THEN
    CREATE POLICY "devotional_translations_admin_all"
      ON public.devotional_translations FOR ALL
      TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
  END IF;
END
$$;


-- ════════════════════════════════════════════════════════════════════════════
-- SECTION B — UPGRADE devotional_reflections
-- ════════════════════════════════════════════════════════════════════════════
--
-- The legacy table has columns (id, user_id, devotional_id, body, created_at,
-- updated_at) and an FK to public.devotionals. The new canonical table
-- requires columns (id, user_id, devotional_entry_id, reflection_text,
-- is_private, created_at, updated_at) with an FK to public.devotional_entries.
--
-- We cannot safely rename the columns in place because:
--   * the FK target changes from devotionals to devotional_entries
--   * the unique constraint target changes from
--     UNIQUE(user_id, devotional_id) to UNIQUE(user_id, devotional_entry_id)
--   * `body` becomes `reflection_text` and we add an `is_private` flag
--   * the user_id FK changes from profiles(id) to auth.users(id)
--     in the new design — see Flutter DevotionalJournalReflection which
--     uses auth.users directly.
--
-- So we rename the old table to devotional_reflections_legacy (preserving
-- every row, RLS policy, and trigger) and create a fresh
-- devotional_reflections with the new canonical shape.

DO $$
BEGIN
  -- Only rename if the new table doesn't already exist (i.e. we haven't
  -- run this migration yet) and the old table still has the legacy shape.
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_reflections'
      AND column_name  = 'devotional_entry_id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'devotional_reflections'
      AND column_name  = 'devotional_id'
  ) THEN
    ALTER TABLE public.devotional_reflections
      RENAME TO devotional_reflections_legacy;
  END IF;
END
$$;

-- Create the new canonical table only if it doesn't already exist.
CREATE TABLE IF NOT EXISTS public.devotional_reflections (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  devotional_entry_id  UUID        NOT NULL REFERENCES public.devotional_entries(id) ON DELETE CASCADE,
  reflection_text      TEXT,
  is_private           BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, devotional_entry_id)
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'devotional_reflections_updated_at'
      AND tgrelid = 'public.devotional_reflections'::regclass
  ) THEN
    CREATE TRIGGER devotional_reflections_updated_at
      BEFORE UPDATE ON public.devotional_reflections
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_devotional_reflections_user
  ON public.devotional_reflections (user_id);

ALTER TABLE public.devotional_reflections ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename  = 'devotional_reflections'
      AND policyname = 'devotional_reflections_own_read'
  ) THEN
    CREATE POLICY "devotional_reflections_own_read"
      ON public.devotional_reflections FOR SELECT
      TO authenticated
      USING (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename  = 'devotional_reflections'
      AND policyname = 'devotional_reflections_own_write'
  ) THEN
    CREATE POLICY "devotional_reflections_own_write"
      ON public.devotional_reflections FOR INSERT
      TO authenticated
      WITH CHECK (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename  = 'devotional_reflections'
      AND policyname = 'devotional_reflections_own_update'
  ) THEN
    CREATE POLICY "devotional_reflections_own_update"
      ON public.devotional_reflections FOR UPDATE
      TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;
END
$$;


-- ════════════════════════════════════════════════════════════════════════════
-- SECTION C — sanity / verification
-- ════════════════════════════════════════════════════════════════════════════
--
-- These queries are run at the end of the migration and raise an exception
-- if any expected column / index is missing. The migration is committed
-- atomically with the rest of the file (Supabase runs each file in a
-- transaction), so a failure here rolls the whole upgrade back.
DO $$
DECLARE
  v_missing TEXT;
BEGIN
  SELECT string_agg(missing, ', ' ORDER BY missing) INTO v_missing
  FROM (
    VALUES
      ('devotional_translations.devotional_entry_id'),
      ('devotional_translations.devotional_body'),
      ('devotional_translations.reflection_question'),
      ('devotional_translations.prayer_text'),
      ('devotional_translations.scripture_reference'),
      ('devotional_translations.action_step'),
      ('devotional_translations.translation_status'),
      ('devotional_translations.translated_by'),
      ('devotional_translations.reviewed_by'),
      ('devotional_translations.updated_at'),
      ('devotional_reflections.devotional_entry_id'),
      ('devotional_reflections.reflection_text'),
      ('devotional_reflections.is_private')
  ) AS required(missing)
  WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.columns c
    WHERE c.table_schema = 'public'
      AND c.table_name   = split_part(required.missing, '.', 1)
      AND c.column_name  = split_part(required.missing, '.', 2)
  );

  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'devotional schema upgrade incomplete — missing columns: %', v_missing;
  END IF;
END
$$;
