-- ==============================================================================
-- Add remaining localized RPC functions & Translation Workflow
-- ==============================================================================

-- Add status column to existing translation tables for the workflow: draft -> review -> approved -> published
ALTER TABLE public.sermon_translations ADD COLUMN IF NOT EXISTS translation_status VARCHAR DEFAULT 'draft';
ALTER TABLE public.devotional_translations ADD COLUMN IF NOT EXISTS translation_status VARCHAR DEFAULT 'draft';
ALTER TABLE public.event_translations ADD COLUMN IF NOT EXISTS translation_status VARCHAR DEFAULT 'draft';
ALTER TABLE public.announcement_translations ADD COLUMN IF NOT EXISTS translation_status VARCHAR DEFAULT 'draft';
ALTER TABLE public.testimony_translations ADD COLUMN IF NOT EXISTS translation_status VARCHAR DEFAULT 'draft';

CREATE OR REPLACE FUNCTION public.get_devotionals_localized(p_lang VARCHAR DEFAULT 'en')
RETURNS TABLE (
  id UUID,
  title TEXT,
  scripture_text TEXT,
  body TEXT,
  reflection TEXT,
  prayer TEXT,
  scheduled_for DATE,
  status publish_status,
  created_at TIMESTAMPTZ,
  language_code VARCHAR
) LANGUAGE sql STABLE AS $$
  SELECT 
    d.id,
    COALESCE(t.title, d.title) as title,
    COALESCE(t.scripture_text, d.scripture_text) as scripture_text,
    COALESCE(t.devotional_body, d.body) as body,
    COALESCE(t.reflection_question, d.reflection) as reflection,
    COALESCE(t.prayer_text, d.prayer) as prayer,
    d.scheduled_for,
    d.status,
    d.created_at,
    COALESCE(t.language_code, 'en') as language_code
  FROM public.devotionals d
  LEFT JOIN public.devotional_translations t 
    ON d.id = t.devotional_entry_id AND t.language_code = p_lang
  WHERE d.status = 'published'
  ORDER BY d.scheduled_for DESC;
$$;

CREATE OR REPLACE FUNCTION public.get_events_localized(p_lang VARCHAR DEFAULT 'en')
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  category TEXT,
  image_url TEXT,
  start_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  is_recurring BOOLEAN,
  is_online BOOLEAN,
  location_name TEXT,
  meeting_link TEXT,
  created_by UUID,
  status publish_status,
  rsvp_count INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  language_code VARCHAR
) LANGUAGE sql STABLE AS $$
  SELECT 
    e.id,
    COALESCE(t.title, e.title) as title,
    COALESCE(t.description, e.description) as description,
    e.category,
    e.image_url,
    e.start_at,
    e.end_at,
    e.is_recurring,
    e.is_online,
    e.location_name,
    e.meeting_link,
    e.created_by,
    e.status,
    e.rsvp_count,
    e.created_at,
    e.updated_at,
    COALESCE(t.language_code, 'en') as language_code
  FROM public.events e
  LEFT JOIN public.event_translations t 
    ON e.id = t.event_id AND t.language_code = p_lang
  ORDER BY e.start_at ASC;
$$;

CREATE OR REPLACE FUNCTION public.get_announcements_localized(p_lang VARCHAR DEFAULT 'en')
RETURNS TABLE (
  id UUID,
  title TEXT,
  body TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ,
  language_code VARCHAR
) LANGUAGE sql STABLE AS $$
  SELECT 
    a.id,
    COALESCE(t.title, a.title) as title,
    COALESCE(t.body, a.body) as body,
    a.image_url,
    a.created_at,
    COALESCE(t.language_code, 'en') as language_code
  FROM public.announcements a
  LEFT JOIN public.announcement_translations t 
    ON a.id = t.announcement_id AND t.language_code = p_lang
  ORDER BY a.created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.get_testimonies_localized(p_lang VARCHAR DEFAULT 'en')
RETURNS TABLE (
  id UUID,
  title TEXT,
  body TEXT,
  author_id UUID,
  status VARCHAR,
  created_at TIMESTAMPTZ,
  author_name TEXT,
  author_avatar_url TEXT,
  language_code VARCHAR
) LANGUAGE sql STABLE AS $$
  SELECT 
    test.id,
    COALESCE(t.title, test.title) as title,
    COALESCE(t.body, test.body) as body,
    test.author_id,
    test.status::VARCHAR as status,
    test.created_at,
    p.full_name as author_name,
    p.avatar_url as author_avatar_url,
    COALESCE(t.language_code, 'en') as language_code
  FROM public.testimonies test
  LEFT JOIN public.testimony_translations t 
    ON test.id = t.testimony_id AND t.language_code = p_lang
  LEFT JOIN public.profiles p
    ON test.author_id = p.id
  WHERE test.status = 'published'
  ORDER BY test.created_at DESC;
$$;

-- ==============================================================================
-- News Articles Translations
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.news_article_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id UUID NOT NULL REFERENCES public.news_articles(id) ON DELETE CASCADE,
  language_code VARCHAR(5) NOT NULL,
  title TEXT NOT NULL,
  preview TEXT,
  content TEXT NOT NULL,
  translation_status VARCHAR DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(article_id, language_code)
);

ALTER TABLE public.news_article_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for news translations" ON public.news_article_translations FOR SELECT USING (true);
CREATE POLICY "Admin write for news translations" ON public.news_article_translations FOR ALL USING (public.is_admin());

CREATE OR REPLACE FUNCTION public.get_news_articles_localized(p_lang VARCHAR DEFAULT 'en', p_cat UUID DEFAULT NULL, p_pinned BOOLEAN DEFAULT NULL, p_featured BOOLEAN DEFAULT NULL)
RETURNS TABLE (
  id UUID,
  title TEXT,
  preview TEXT,
  content TEXT,
  category_id UUID,
  image_url TEXT,
  is_featured BOOLEAN,
  is_pinned BOOLEAN,
  published_at TIMESTAMPTZ,
  status publish_status,
  view_count INTEGER,
  share_count INTEGER,
  created_at TIMESTAMPTZ,
  language_code VARCHAR
) LANGUAGE sql STABLE AS $$
  SELECT 
    n.id,
    COALESCE(t.title, n.title) as title,
    COALESCE(t.preview, n.preview) as preview,
    COALESCE(t.content, n.content) as content,
    n.category_id,
    n.image_url,
    n.is_featured,
    n.is_pinned,
    n.published_at,
    n.status,
    n.view_count,
    n.share_count,
    n.created_at,
    COALESCE(t.language_code, 'en') as language_code
  FROM public.news_articles n
  LEFT JOIN public.news_article_translations t 
    ON n.id = t.article_id AND t.language_code = p_lang
  WHERE n.status = 'published'
    AND (p_cat IS NULL OR n.category_id = p_cat)
    AND (p_pinned IS NULL OR n.is_pinned = p_pinned)
    AND (p_featured IS NULL OR n.is_featured = p_featured)
  ORDER BY n.published_at DESC;
$$;
