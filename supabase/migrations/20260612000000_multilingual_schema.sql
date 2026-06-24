-- ==============================================================================
-- KINGDOM HEIR — MULTILINGUAL ARCHITECTURE MIGRATION
-- Creates dedicated translation tables for strong referential integrity.
-- Supported Languages: en, fr, ur, pt, bem, zu, ss
-- ==============================================================================

-- 1. User Preferences
CREATE TABLE public.user_language_preferences (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  preferred_language VARCHAR(5) NOT NULL DEFAULT 'en',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.user_language_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own language preferences"
ON public.user_language_preferences FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 2. Dedicated Translation Tables

-- Sermons
CREATE TABLE public.sermon_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  language_code VARCHAR(5) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(sermon_id, language_code)
);

ALTER TABLE public.sermon_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for sermon translations" ON public.sermon_translations FOR SELECT USING (true);
CREATE POLICY "Admin write for sermon translations" ON public.sermon_translations FOR ALL USING (public.is_admin());

-- Devotionals
CREATE TABLE public.devotional_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  devotional_id UUID NOT NULL REFERENCES public.devotionals(id) ON DELETE CASCADE,
  language_code VARCHAR(5) NOT NULL,
  title TEXT NOT NULL,
  scripture_text TEXT NOT NULL,
  body TEXT NOT NULL,
  reflection TEXT,
  prayer TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(devotional_id, language_code)
);

ALTER TABLE public.devotional_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for dev translations" ON public.devotional_translations FOR SELECT USING (true);
CREATE POLICY "Admin write for dev translations" ON public.devotional_translations FOR ALL USING (public.is_admin());

-- Events
CREATE TABLE public.event_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  language_code VARCHAR(5) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(event_id, language_code)
);

ALTER TABLE public.event_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for event translations" ON public.event_translations FOR SELECT USING (true);
CREATE POLICY "Admin write for event translations" ON public.event_translations FOR ALL USING (public.is_admin());

-- Announcements
CREATE TABLE public.announcement_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID NOT NULL REFERENCES public.announcements(id) ON DELETE CASCADE,
  language_code VARCHAR(5) NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(announcement_id, language_code)
);

ALTER TABLE public.announcement_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for announcement translations" ON public.announcement_translations FOR SELECT USING (true);
CREATE POLICY "Admin write for announcement translations" ON public.announcement_translations FOR ALL USING (public.is_admin());

-- Testimonies
CREATE TABLE public.testimony_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  testimony_id UUID NOT NULL REFERENCES public.testimonies(id) ON DELETE CASCADE,
  language_code VARCHAR(5) NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(testimony_id, language_code)
);

ALTER TABLE public.testimony_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for testimony translations" ON public.testimony_translations FOR SELECT USING (true);
CREATE POLICY "Admin write for testimony translations" ON public.testimony_translations FOR ALL USING (public.is_admin());

-- ==============================================================================
-- 3. Fallback Helper Functions (RPC)
-- ==============================================================================
-- Example: Fetch Sermons with automatic translation fallback.
-- If the translated row exists, it overlays the English base fields.
-- In Flutter, the repository just calls: rpc('get_sermons_localized', { p_lang: 'fr' })

CREATE OR REPLACE FUNCTION public.get_sermons_localized(p_lang VARCHAR DEFAULT 'en')
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  speaker_name TEXT,
  video_url TEXT,
  audio_url TEXT,
  thumbnail_url TEXT,
  preached_on DATE,
  view_count INTEGER,
  language_code VARCHAR
) LANGUAGE sql STABLE AS $$
  SELECT 
    s.id,
    COALESCE(t.title, s.title) as title,
    COALESCE(t.description, s.description) as description,
    s.speaker_name,
    s.video_url,
    s.audio_url,
    s.thumbnail_url,
    s.preached_on,
    s.view_count,
    COALESCE(t.language_code, 'en') as language_code
  FROM public.sermons s
  LEFT JOIN public.sermon_translations t 
    ON s.id = t.sermon_id AND t.language_code = p_lang
  WHERE s.status = 'published'
  ORDER BY s.preached_on DESC;
$$;
