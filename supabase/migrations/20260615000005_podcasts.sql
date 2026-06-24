-- ==============================================================================
-- KINGDOM HEIR — PODCASTS SCHEMA
-- Generated: 2026-06-15
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Podcast Series
-- ------------------------------------------------------------------------------
CREATE TABLE public.podcast_series (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  author TEXT NOT NULL,
  status publish_status NOT NULL DEFAULT 'published',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.podcast_series ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for podcast series" ON public.podcast_series FOR SELECT USING (true);
CREATE POLICY "Admin write for podcast series" ON public.podcast_series FOR ALL USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 2. Podcast Episodes
-- ------------------------------------------------------------------------------
CREATE TABLE public.podcast_episodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  series_id UUID NOT NULL REFERENCES public.podcast_series(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  audio_url TEXT NOT NULL,
  duration_seconds INTEGER,
  published_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status publish_status NOT NULL DEFAULT 'published',
  view_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_podcast_episodes_series ON public.podcast_episodes(series_id);
CREATE INDEX idx_podcast_episodes_published ON public.podcast_episodes(published_at DESC);
ALTER TABLE public.podcast_episodes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read for podcast episodes" ON public.podcast_episodes FOR SELECT USING (status = 'published');
CREATE POLICY "Admin write for podcast episodes" ON public.podcast_episodes FOR ALL USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 3. Podcast Subscriptions
-- ------------------------------------------------------------------------------
CREATE TABLE public.podcast_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  series_id UUID NOT NULL REFERENCES public.podcast_series(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, series_id)
);

CREATE INDEX idx_podcast_subs_user ON public.podcast_subscriptions(user_id);
ALTER TABLE public.podcast_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own subs" ON public.podcast_subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own subs" ON public.podcast_subscriptions FOR ALL USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 4. Podcast Playback Positions
-- ------------------------------------------------------------------------------
CREATE TABLE public.podcast_playback_positions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  episode_id UUID NOT NULL REFERENCES public.podcast_episodes(id) ON DELETE CASCADE,
  position_seconds INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, episode_id)
);

CREATE TRIGGER podcast_playback_updated_at
  BEFORE UPDATE ON public.podcast_playback_positions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_podcast_playback_user ON public.podcast_playback_positions(user_id);
ALTER TABLE public.podcast_playback_positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own playback" ON public.podcast_playback_positions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own playback" ON public.podcast_playback_positions FOR ALL USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 5. Podcast Downloads
-- ------------------------------------------------------------------------------
CREATE TABLE public.podcast_downloads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  episode_id UUID NOT NULL REFERENCES public.podcast_episodes(id) ON DELETE CASCADE,
  local_file_path TEXT NOT NULL,
  downloaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, episode_id)
);

CREATE INDEX idx_podcast_downloads_user ON public.podcast_downloads(user_id);
ALTER TABLE public.podcast_downloads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own downloads" ON public.podcast_downloads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own downloads" ON public.podcast_downloads FOR ALL USING (auth.uid() = user_id);
