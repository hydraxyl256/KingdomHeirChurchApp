-- ==============================================================================
-- KINGDOM HEIR — DEVOTIONALS FEATURES
-- Generated: 2026-06-15
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Devotional Categories
-- ------------------------------------------------------------------------------
CREATE TABLE public.devotional_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.devotional_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for devotional categories" ON public.devotional_categories FOR SELECT USING (true);
CREATE POLICY "Admin write for devotional categories" ON public.devotional_categories FOR ALL USING (public.is_admin());

CREATE TABLE public.devotional_category_mapping (
  devotional_id UUID NOT NULL REFERENCES public.devotionals(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.devotional_categories(id) ON DELETE CASCADE,
  PRIMARY KEY (devotional_id, category_id)
);

ALTER TABLE public.devotional_category_mapping ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for devotional categories mapping" ON public.devotional_category_mapping FOR SELECT USING (true);
CREATE POLICY "Admin write for devotional categories mapping" ON public.devotional_category_mapping FOR ALL USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 2. Devotional Likes
-- ------------------------------------------------------------------------------
CREATE TABLE public.devotional_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  devotional_id UUID NOT NULL REFERENCES public.devotionals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(devotional_id, user_id)
);

CREATE INDEX idx_devotional_likes_user ON public.devotional_likes(user_id);
ALTER TABLE public.devotional_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read for devotional likes" ON public.devotional_likes FOR SELECT USING (true);
CREATE POLICY "Users can insert own likes" ON public.devotional_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON public.devotional_likes FOR DELETE USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 3. Devotional Comments
-- ------------------------------------------------------------------------------
CREATE TABLE public.devotional_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  devotional_id UUID NOT NULL REFERENCES public.devotionals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER devotional_comments_updated_at
  BEFORE UPDATE ON public.devotional_comments
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_devotional_comments_devotional ON public.devotional_comments(devotional_id);
ALTER TABLE public.devotional_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read for devotional comments" ON public.devotional_comments FOR SELECT USING (true);
CREATE POLICY "Users can insert own comments" ON public.devotional_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comments" ON public.devotional_comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.devotional_comments FOR DELETE USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 4. Devotional Bookmarks
-- ------------------------------------------------------------------------------
CREATE TABLE public.devotional_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  devotional_id UUID NOT NULL REFERENCES public.devotionals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(devotional_id, user_id)
);

CREATE INDEX idx_devotional_bookmarks_user ON public.devotional_bookmarks(user_id);
ALTER TABLE public.devotional_bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bookmarks" ON public.devotional_bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own bookmarks" ON public.devotional_bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own bookmarks" ON public.devotional_bookmarks FOR DELETE USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 5. Devotional Reflections
-- ------------------------------------------------------------------------------
CREATE TABLE public.devotional_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  devotional_id UUID REFERENCES public.devotionals(id) ON DELETE SET NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER devotional_reflections_updated_at
  BEFORE UPDATE ON public.devotional_reflections
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_devotional_reflections_user ON public.devotional_reflections(user_id);
ALTER TABLE public.devotional_reflections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reflections" ON public.devotional_reflections FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reflections" ON public.devotional_reflections FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reflections" ON public.devotional_reflections FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reflections" ON public.devotional_reflections FOR DELETE USING (auth.uid() = user_id);
