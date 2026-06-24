-- ==============================================================================
-- KINGDOM HEIR — SERMONS & STREAMING SCHEMA
-- Generated: 2026-06-15
-- ==============================================================================

-- 1. Sermon Speakers (If not exists, create it or alter existing)
CREATE TABLE IF NOT EXISTS public.sermon_speakers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  role TEXT,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Alter Sermons Table (Adding new fields for Live and Streaming)
-- We'll assume the basic table exists, but we add missing fields.
ALTER TABLE public.sermons 
ADD COLUMN IF NOT EXISTS speaker_id UUID REFERENCES public.sermon_speakers(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS is_live BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS youtube_id TEXT,
ADD COLUMN IF NOT EXISTS hls_stream_url TEXT;

-- 3. Watch History
CREATE TABLE public.sermon_watch_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  position_seconds INTEGER NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, sermon_id)
);

CREATE TRIGGER sermon_watch_history_updated_at
  BEFORE UPDATE ON public.sermon_watch_history
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 4. Playlists
CREATE TABLE public.sermon_playlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.sermon_playlist_items (
  playlist_id UUID NOT NULL REFERENCES public.sermon_playlists(id) ON DELETE CASCADE,
  sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (playlist_id, sermon_id)
);

-- 5. RLS Policies
ALTER TABLE public.sermon_speakers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for speakers" ON public.sermon_speakers FOR SELECT USING (true);
CREATE POLICY "Admin write for speakers" ON public.sermon_speakers FOR ALL USING (public.is_admin());

ALTER TABLE public.sermon_watch_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own watch history" ON public.sermon_watch_history FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.sermon_playlists ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own playlists" ON public.sermon_playlists FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.sermon_playlist_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own playlist items" ON public.sermon_playlist_items FOR ALL USING (
  auth.uid() IN (SELECT user_id FROM public.sermon_playlists WHERE id = playlist_id)
);
