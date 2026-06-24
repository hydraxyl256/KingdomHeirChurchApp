-- ==============================================================================
-- KINGDOM HEIR — BIBLE PERSISTENCE
-- Generated: 2026-06-15
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Bible Bookmarks
-- ------------------------------------------------------------------------------
CREATE TABLE public.bible_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  bible_version_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  chapter_id TEXT NOT NULL,
  verse_id TEXT NOT NULL,
  reference_text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_bible_bookmarks_user_id ON public.bible_bookmarks(user_id);
ALTER TABLE public.bible_bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bookmarks" ON public.bible_bookmarks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bookmarks" ON public.bible_bookmarks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks" ON public.bible_bookmarks
  FOR DELETE USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 2. Bible Highlights
-- ------------------------------------------------------------------------------
CREATE TABLE public.bible_highlights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  bible_version_id TEXT NOT NULL,
  verse_id TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, bible_version_id, verse_id)
);

CREATE INDEX idx_bible_highlights_user_id ON public.bible_highlights(user_id);
ALTER TABLE public.bible_highlights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own highlights" ON public.bible_highlights
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own highlights" ON public.bible_highlights
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own highlights" ON public.bible_highlights
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own highlights" ON public.bible_highlights
  FOR DELETE USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 3. Bible Reading History
-- ------------------------------------------------------------------------------
CREATE TABLE public.bible_reading_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  bible_version_id TEXT NOT NULL,
  chapter_id TEXT NOT NULL,
  last_read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  progress_percent INT NOT NULL DEFAULT 0,
  UNIQUE(user_id, bible_version_id, chapter_id)
);

CREATE INDEX idx_bible_reading_history_user_id ON public.bible_reading_history(user_id);
ALTER TABLE public.bible_reading_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reading history" ON public.bible_reading_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reading history" ON public.bible_reading_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reading history" ON public.bible_reading_history
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reading history" ON public.bible_reading_history
  FOR DELETE USING (auth.uid() = user_id);
