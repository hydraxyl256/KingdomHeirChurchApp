-- ==============================================================================
-- KINGDOM HEIR — V2 ARCHITECTURE REDESIGN
-- Generated: 2026-06-17
-- Focus: Live Platform, Journey Progress, Journaling, Analytics, & Dashboard
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. UTILITY TYPES
-- ------------------------------------------------------------------------------
CREATE TYPE live_service_status AS ENUM ('scheduled', 'live', 'ended', 'archived');
CREATE TYPE chat_message_status AS ENUM ('active', 'flagged', 'hidden', 'deleted');
CREATE TYPE achievement_type AS ENUM ('streak', 'reading', 'prayer', 'giving', 'community');

-- ------------------------------------------------------------------------------
-- 2. LIVE PLATFORM DOMAIN
-- ------------------------------------------------------------------------------
CREATE TABLE public.live_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  speaker_name TEXT,
  thumbnail_url TEXT,
  stream_url TEXT,
  status live_service_status NOT NULL DEFAULT 'scheduled',
  scheduled_start_at TIMESTAMPTZ NOT NULL,
  actual_start_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  viewer_count INTEGER NOT NULL DEFAULT 0,
  is_chat_enabled BOOLEAN NOT NULL DEFAULT true,
  is_slow_mode BOOLEAN NOT NULL DEFAULT false,
  slow_mode_delay_seconds INTEGER NOT NULL DEFAULT 10,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER live_services_updated_at
  BEFORE UPDATE ON public.live_services
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.live_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  live_service_id UUID NOT NULL REFERENCES public.live_services(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  status chat_message_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER live_chat_messages_updated_at
  BEFORE UPDATE ON public.live_chat_messages
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.live_chat_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES public.live_chat_messages(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(message_id, reporter_id)
);

CREATE TABLE public.sermon_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  live_service_id UUID REFERENCES public.live_services(id) ON DELETE SET NULL,
  sermon_id UUID REFERENCES public.sermons(id) ON DELETE SET NULL,
  body TEXT NOT NULL,
  scripture_refs JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (live_service_id IS NOT NULL OR sermon_id IS NOT NULL)
);

CREATE TRIGGER sermon_notes_updated_at
  BEFORE UPDATE ON public.sermon_notes
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.sermon_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  timestamp_seconds INTEGER,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, sermon_id, timestamp_seconds)
);

-- ------------------------------------------------------------------------------
-- 3. JOURNEY & PROGRESS DOMAIN
-- ------------------------------------------------------------------------------
CREATE TABLE public.daily_streaks (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  last_activity_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER daily_streaks_updated_at
  BEFORE UPDATE ON public.daily_streaks
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  type achievement_type NOT NULL,
  icon_url TEXT,
  target_value INTEGER NOT NULL,
  points INTEGER NOT NULL DEFAULT 10,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.achievement_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES public.user_achievements(id) ON DELETE CASCADE,
  current_value INTEGER NOT NULL DEFAULT 0,
  is_unlocked BOOLEAN NOT NULL DEFAULT false,
  unlocked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

CREATE TRIGGER achievement_progress_updated_at
  BEFORE UPDATE ON public.achievement_progress
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.watch_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  watched_seconds INTEGER NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  last_watched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, sermon_id)
);

CREATE TABLE public.continue_watching (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  last_sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  position_seconds INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.reading_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  duration_days INTEGER NOT NULL,
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.reading_plan_days (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES public.reading_plans(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL,
  title TEXT,
  scripture_refs JSONB NOT NULL DEFAULT '[]'::jsonb,
  devotional_text TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(plan_id, day_number)
);

CREATE TABLE public.reading_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES public.reading_plans(id) ON DELETE CASCADE,
  current_day INTEGER NOT NULL DEFAULT 1,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, plan_id)
);

CREATE TRIGGER reading_progress_updated_at
  BEFORE UPDATE ON public.reading_progress
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ------------------------------------------------------------------------------
-- 4. JOURNALING & PRAYER DOMAIN (EXTENSIONS)
-- ------------------------------------------------------------------------------
CREATE TABLE public.reflection_journals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'My Journal',
  theme_color TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

CREATE TRIGGER reflection_journals_updated_at
  BEFORE UPDATE ON public.reflection_journals
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_id UUID NOT NULL REFERENCES public.reflection_journals(id) ON DELETE CASCADE,
  title TEXT,
  body TEXT NOT NULL,
  scripture_ref TEXT,
  mood TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER journal_entries_updated_at
  BEFORE UPDATE ON public.journal_entries
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.journal_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(entry_id, tag)
);

CREATE TABLE public.prayer_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prayer_request_id UUID NOT NULL REFERENCES public.prayer_requests(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  is_leader_response BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER prayer_responses_updated_at
  BEFORE UPDATE ON public.prayer_responses
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.prayer_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  prayer_request_id UUID NOT NULL REFERENCES public.prayer_requests(id) ON DELETE CASCADE,
  prayed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- 5. SYSTEM, CONFIGURATION & DASHBOARD DOMAIN
-- ------------------------------------------------------------------------------
CREATE TABLE public.user_preferences (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  theme TEXT NOT NULL DEFAULT 'system',
  font_size TEXT NOT NULL DEFAULT 'medium',
  language TEXT NOT NULL DEFAULT 'en',
  bible_version TEXT NOT NULL DEFAULT 'KJV',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER user_preferences_updated_at
  BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  push_enabled BOOLEAN NOT NULL DEFAULT true,
  email_enabled BOOLEAN NOT NULL DEFAULT true,
  types_enabled JSONB NOT NULL DEFAULT '["general", "event", "prayer", "sermon", "giving"]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER notification_preferences_updated_at
  BEFORE UPDATE ON public.notification_preferences
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE public.home_dashboard_state (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  widget_order JSONB NOT NULL DEFAULT '[]'::jsonb,
  hidden_widgets JSONB NOT NULL DEFAULT '[]'::jsonb,
  greeting_name TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  event_name TEXT NOT NULL,
  event_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  platform TEXT NOT NULL,
  app_version TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- 6. INDEXES FOR HIGH PERFORMANCE
-- ------------------------------------------------------------------------------
CREATE INDEX idx_live_services_status ON public.live_services(status);
CREATE INDEX idx_live_chat_live_service ON public.live_chat_messages(live_service_id);
CREATE INDEX idx_live_chat_created_at ON public.live_chat_messages(created_at DESC);
CREATE INDEX idx_sermon_notes_user ON public.sermon_notes(user_id);
CREATE INDEX idx_watch_history_user ON public.watch_history(user_id, last_watched_at DESC);
CREATE INDEX idx_reading_progress_user ON public.reading_progress(user_id);
CREATE INDEX idx_journal_entries_journal ON public.journal_entries(journal_id, created_at DESC);
CREATE INDEX idx_analytics_events_name ON public.analytics_events(event_name);
CREATE INDEX idx_analytics_events_created_at ON public.analytics_events(created_at);
CREATE INDEX idx_prayer_responses_request ON public.prayer_responses(prayer_request_id);

-- ------------------------------------------------------------------------------
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
ALTER TABLE public.live_services ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for live services" ON public.live_services FOR SELECT USING (true);

ALTER TABLE public.live_chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for active live chat messages" ON public.live_chat_messages FOR SELECT USING (status = 'active');
CREATE POLICY "Users can insert own live chat messages" ON public.live_chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own live chat messages" ON public.live_chat_messages FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can moderate chat" ON public.live_chat_messages FOR UPDATE USING (public.is_admin());

ALTER TABLE public.live_chat_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert reports" ON public.live_chat_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

ALTER TABLE public.sermon_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own sermon notes" ON public.sermon_notes FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.sermon_bookmarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own sermon bookmarks" ON public.sermon_bookmarks FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.daily_streaks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own streaks" ON public.daily_streaks FOR SELECT USING (auth.uid() = user_id);

ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for achievements" ON public.user_achievements FOR SELECT USING (true);

ALTER TABLE public.achievement_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own achievement progress" ON public.achievement_progress FOR SELECT USING (auth.uid() = user_id);

ALTER TABLE public.watch_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own watch history" ON public.watch_history FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.continue_watching ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own continue watching" ON public.continue_watching FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.reading_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for active reading plans" ON public.reading_plans FOR SELECT USING (is_active = true);

ALTER TABLE public.reading_plan_days ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for reading plan days" ON public.reading_plan_days FOR SELECT USING (true);

ALTER TABLE public.reading_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own reading progress" ON public.reading_progress FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.reflection_journals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own journals" ON public.reflection_journals FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own journal entries" ON public.journal_entries FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.reflection_journals rj 
    WHERE rj.id = journal_entries.journal_id AND rj.user_id = auth.uid()
  )
);

ALTER TABLE public.journal_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own journal tags" ON public.journal_tags FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.journal_entries je
    JOIN public.reflection_journals rj ON rj.id = je.journal_id
    WHERE je.id = journal_tags.entry_id AND rj.user_id = auth.uid()
  )
);

ALTER TABLE public.prayer_responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for prayer responses" ON public.prayer_responses FOR SELECT USING (true);
CREATE POLICY "Users can insert own prayer responses" ON public.prayer_responses FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.prayer_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own prayer history" ON public.prayer_history FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own preferences" ON public.user_preferences FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own notification preferences" ON public.notification_preferences FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.home_dashboard_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users fully manage own dashboard state" ON public.home_dashboard_state FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert analytics events" ON public.analytics_events FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.uid() IS NULL);

-- ------------------------------------------------------------------------------
-- 8. REALTIME CONFIGURATION
-- ------------------------------------------------------------------------------
alter publication supabase_realtime add table public.live_chat_messages;
alter publication supabase_realtime add table public.live_services;
alter publication supabase_realtime add table public.prayer_responses;

-- ------------------------------------------------------------------------------
-- 9. DATABASE FUNCTIONS & TRIGGERS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_daily_streak(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today DATE := current_date;
  v_streak RECORD;
BEGIN
  SELECT * INTO v_streak FROM public.daily_streaks WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    INSERT INTO public.daily_streaks (user_id, current_streak, longest_streak, last_activity_date)
    VALUES (p_user_id, 1, 1, v_today);
  ELSE
    IF v_streak.last_activity_date = v_today THEN
      RETURN;
    ELSIF v_streak.last_activity_date = v_today - interval '1 day' THEN
      UPDATE public.daily_streaks 
      SET 
        current_streak = current_streak + 1,
        longest_streak = GREATEST(longest_streak, current_streak + 1),
        last_activity_date = v_today,
        updated_at = now()
      WHERE user_id = p_user_id;
    ELSE
      UPDATE public.daily_streaks 
      SET 
        current_streak = 1,
        last_activity_date = v_today,
        updated_at = now()
      WHERE user_id = p_user_id;
    END IF;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.upsert_continue_watching(p_user_id UUID, p_sermon_id UUID, p_position_seconds INTEGER)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.continue_watching (user_id, last_sermon_id, position_seconds, updated_at)
  VALUES (p_user_id, p_sermon_id, p_position_seconds, now())
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    last_sermon_id = EXCLUDED.last_sermon_id,
    position_seconds = EXCLUDED.position_seconds,
    updated_at = now();
END;
$$;

-- ------------------------------------------------------------------------------
-- 10. STORAGE BUCKETS
-- ------------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public) VALUES ('journal_images', 'journal_images', false) ON CONFLICT DO NOTHING;
CREATE POLICY "Users can upload their own journal images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'journal_images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can update their own journal images" ON storage.objects FOR UPDATE USING (bucket_id = 'journal_images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can read their own journal images" ON storage.objects FOR SELECT USING (bucket_id = 'journal_images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete their own journal images" ON storage.objects FOR DELETE USING (bucket_id = 'journal_images' AND auth.uid()::text = (storage.foldername(name))[1]);

INSERT INTO storage.buckets (id, name, public) VALUES ('live_thumbnails', 'live_thumbnails', true) ON CONFLICT DO NOTHING;
-- Policy creation for live thumbnails assumes public.is_admin exists (defined in previous migrations)
CREATE POLICY "Admin write live thumbnails" ON storage.objects FOR ALL USING (bucket_id = 'live_thumbnails' AND public.is_admin());
CREATE POLICY "Public read live thumbnails" ON storage.objects FOR SELECT USING (bucket_id = 'live_thumbnails');
