-- ==============================================================================
-- KINGDOM HEIR — MEDIA CONTENT CATALOG (YouTube Integration)
-- Migration: 20260712000000
-- Creates: media_content, media_sync_runs tables + RLS + triggers
-- ==============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. HELPER: is_admin() — reuses profile.role pattern from existing migrations
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND role IN ('admin','pastor')
  );
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. MEDIA CONTENT TABLE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.media_content (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  youtube_video_id    TEXT        UNIQUE NOT NULL,
  youtube_url         TEXT        NOT NULL,
  content_type        TEXT        NOT NULL
                                  CHECK (content_type IN (
                                    'sermon','podcast','teaching',
                                    'testimony','announcement'
                                  )),
  title               TEXT        NOT NULL,
  description         TEXT,
  thumbnail_url       TEXT,
  speaker_name        TEXT,
  series_name         TEXT,
  duration_seconds    INTEGER,
  published_at        TIMESTAMPTZ,
  tags                TEXT[]      DEFAULT '{}',
  status              TEXT        NOT NULL
                                  CHECK (status IN (
                                    'draft','pending_review',
                                    'published','archived'
                                  ))
                                  DEFAULT 'pending_review',
  is_featured         BOOLEAN     DEFAULT FALSE,
  sort_order          INTEGER     DEFAULT 0,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger: keep updated_at current
CREATE TRIGGER media_content_updated_at
  BEFORE UPDATE ON public.media_content
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Indexes for common query patterns
CREATE INDEX idx_media_content_status          ON public.media_content (status);
CREATE INDEX idx_media_content_content_type    ON public.media_content (content_type);
CREATE INDEX idx_media_content_published_at    ON public.media_content (published_at DESC);
CREATE INDEX idx_media_content_is_featured     ON public.media_content (is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_media_content_youtube_id      ON public.media_content (youtube_video_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. MEDIA SYNC RUNS TABLE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.media_sync_runs (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  started_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at     TIMESTAMPTZ,
  status           TEXT        NOT NULL
                               CHECK (status IN (
                                 'running','completed','failed','partial'
                               )),
  videos_found     INTEGER     DEFAULT 0,
  videos_created   INTEGER     DEFAULT 0,
  videos_updated   INTEGER     DEFAULT 0,
  error_message    TEXT,
  created_by       UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_media_sync_runs_started_at ON public.media_sync_runs (started_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. RLS — MEDIA CONTENT
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.media_content ENABLE ROW LEVEL SECURITY;

-- Public/authenticated read: only published records
CREATE POLICY "media_content_authenticated_read"
  ON public.media_content
  FOR SELECT
  TO authenticated
  USING (status = 'published');

-- Admins can read everything (any status)
CREATE POLICY "media_content_admin_read_all"
  ON public.media_content
  FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- Admins can insert / update / delete
CREATE POLICY "media_content_admin_write"
  ON public.media_content
  FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Service role (Edge Functions) can do anything — bypasses RLS by default in Supabase
-- No explicit policy needed for service_role; it bypasses RLS.

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. RLS — MEDIA SYNC RUNS
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.media_sync_runs ENABLE ROW LEVEL SECURITY;

-- Only admins can read sync run records
CREATE POLICY "media_sync_runs_admin_read"
  ON public.media_sync_runs
  FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- No direct INSERT from clients — only service_role (Edge Function) inserts
-- service_role bypasses RLS; standard users cannot insert

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. HELPER FUNCTION: get_latest_sync_run()
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_latest_sync_run()
RETURNS public.media_sync_runs
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT * FROM public.media_sync_runs
  ORDER BY started_at DESC
  LIMIT 1;
$$;
