-- ==============================================================================
-- KINGDOM HEIR — NEWS & NOTIFICATIONS SCHEMA
-- Generated: 2026-06-15
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. News Categories
-- ------------------------------------------------------------------------------
CREATE TABLE public.news_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.news_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for news categories" ON public.news_categories FOR SELECT USING (true);
CREATE POLICY "Admin write for news categories" ON public.news_categories FOR ALL USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 2. News Articles
-- ------------------------------------------------------------------------------
CREATE TABLE public.news_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES public.news_categories(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  preview TEXT NOT NULL,
  image_url TEXT,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  published_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status publish_status NOT NULL DEFAULT 'published',
  view_count INTEGER NOT NULL DEFAULT 0,
  share_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_news_articles_category ON public.news_articles(category_id);
CREATE INDEX idx_news_articles_published ON public.news_articles(published_at DESC);
ALTER TABLE public.news_articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read for news articles" ON public.news_articles FOR SELECT USING (status = 'published');
CREATE POLICY "Admin write for news articles" ON public.news_articles FOR ALL USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 3. FCM Tokens (Push Notifications)
-- ------------------------------------------------------------------------------
CREATE TABLE public.user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_type TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, fcm_token)
);

CREATE TRIGGER user_fcm_tokens_updated_at
  BEFORE UPDATE ON public.user_fcm_tokens
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_user_fcm_tokens_user ON public.user_fcm_tokens(user_id);
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own tokens" ON public.user_fcm_tokens FOR ALL USING (auth.uid() = user_id);
