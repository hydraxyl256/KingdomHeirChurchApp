
-- KINGDOM HEIR — ANALYTICS & USER PRESENCE SYSTEM
-- Features: Real-time tracking, DAU/WAU/MAU views, Content Analytics, RLS.

-- 1. USER PRESENCE

CREATE TABLE public.user_presence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  is_online BOOLEAN NOT NULL DEFAULT true,
  last_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
  device_type TEXT,
  platform TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id) -- One presence record per user (can be upserted)
);

CREATE INDEX idx_user_presence_last_seen ON public.user_presence USING btree (last_seen);
CREATE INDEX idx_user_presence_is_online ON public.user_presence USING btree (is_online);


-- 2. APP INSTALLATIONS

CREATE TABLE public.app_installations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  device_id TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL,
  app_version TEXT NOT NULL,
  country TEXT,
  language TEXT,
  installed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_app_installations_platform ON public.app_installations USING btree (platform);
CREATE INDEX idx_app_installations_installed_at ON public.app_installations USING btree (installed_at);


-- 3. CONTENT ANALYTICS

CREATE TABLE public.sermon_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sermon_id UUID NOT NULL REFERENCES public.sermons(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  watch_duration INTEGER NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_sermon_analytics_sermon ON public.sermon_analytics USING btree (sermon_id);
CREATE INDEX idx_sermon_analytics_user ON public.sermon_analytics USING btree (user_id);
-- Composite index for rapid query of user completion
CREATE INDEX idx_sermon_analytics_user_sermon ON public.sermon_analytics USING btree (user_id, sermon_id);


CREATE TABLE public.devotional_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  devotional_id UUID NOT NULL REFERENCES public.devotionals(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  reading_duration INTEGER NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_devotional_analytics_devotional ON public.devotional_analytics USING btree (devotional_id);
CREATE INDEX idx_devotional_analytics_user ON public.devotional_analytics USING btree (user_id);
CREATE INDEX idx_devotional_analytics_user_devo ON public.devotional_analytics USING btree (user_id, devotional_id);


-- 4. ACTIVE USER VIEWS

-- Realtime Online Users (last_seen within 5 minutes AND is_online = true)
CREATE OR REPLACE VIEW public.view_online_users AS
SELECT count(*) AS online_users_count
FROM public.user_presence
WHERE is_online = true AND last_seen >= now() - interval '5 minutes';

-- DAU (Daily Active Users)
CREATE OR REPLACE VIEW public.view_dau AS
SELECT count(*) AS active_today
FROM public.user_presence
WHERE last_seen >= current_date;

-- WAU (Weekly Active Users)
CREATE OR REPLACE VIEW public.view_wau AS
SELECT count(*) AS active_this_week
FROM public.user_presence
WHERE last_seen >= current_date - interval '7 days';

-- MAU (Monthly Active Users)
CREATE OR REPLACE VIEW public.view_mau AS
SELECT count(*) AS active_this_month
FROM public.user_presence
WHERE last_seen >= current_date - interval '30 days';


-- 5. DONATION ANALYTICS VIEW

CREATE OR REPLACE VIEW public.view_donation_analytics AS
SELECT
  (SELECT COALESCE(sum(amount), 0) FROM public.donations WHERE status = 'completed' AND created_at >= current_date) AS donations_today,
  (SELECT COALESCE(sum(amount), 0) FROM public.donations WHERE status = 'completed' AND created_at >= current_date - interval '7 days') AS donations_this_week,
  (SELECT COALESCE(sum(amount), 0) FROM public.donations WHERE status = 'completed' AND created_at >= current_date - interval '30 days') AS donations_this_month,
  (SELECT COALESCE(sum(amount), 0) FROM public.donations WHERE status = 'completed') AS total_revenue,
  (SELECT COALESCE(avg(amount), 0) FROM public.donations WHERE status = 'completed') AS average_donation,
  (
    SELECT fund FROM public.donations 
    WHERE status = 'completed' 
    GROUP BY fund 
    ORDER BY sum(amount) DESC LIMIT 1
  ) AS top_giving_fund
;


-- 6. GEOGRAPHIC & LANGUAGE ANALYTICS

CREATE OR REPLACE VIEW public.view_country_analytics AS
SELECT 
  COALESCE(i.country, 'Unknown') AS country,
  count(DISTINCT p.id) AS users,
  count(DISTINCT CASE WHEN up.is_online = true AND up.last_seen >= now() - interval '5 minutes' THEN up.user_id END) AS online_users
FROM public.profiles p
LEFT JOIN public.app_installations i ON p.id = i.user_id
LEFT JOIN public.user_presence up ON p.id = up.user_id
GROUP BY i.country
ORDER BY users DESC;

CREATE OR REPLACE VIEW public.view_language_analytics AS
SELECT 
  preferred_language,
  count(user_id) AS users_count
FROM public.user_language_preferences
GROUP BY preferred_language
ORDER BY users_count DESC;


-- 7. ROW LEVEL SECURITY
ALTER TABLE public.user_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_installations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sermon_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devotional_analytics ENABLE ROW LEVEL SECURITY;

-- Helper to check if analytics access is granted
CREATE OR REPLACE FUNCTION public.can_view_analytics()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER AS $$
  SELECT (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'pastor', 'bishop');
$$;

-- INSERT: Authenticated users can insert their own presence/analytics
CREATE POLICY "Users can insert own presence" ON public.user_presence FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own presence" ON public.user_presence FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert installations" ON public.app_installations FOR INSERT WITH CHECK (true); -- Anonymous allowed on first launch

CREATE POLICY "Users can insert sermon analytics" ON public.sermon_analytics FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can insert devotional analytics" ON public.devotional_analytics FOR INSERT WITH CHECK (auth.uid() = user_id);

-- SELECT: Only Analytics Roles can read the raw tables
CREATE POLICY "Analytics access for presence" ON public.user_presence FOR SELECT USING (public.can_view_analytics() OR auth.uid() = user_id);
CREATE POLICY "Analytics access for installations" ON public.app_installations FOR SELECT USING (public.can_view_analytics());
CREATE POLICY "Analytics access for sermons" ON public.sermon_analytics FOR SELECT USING (public.can_view_analytics() OR auth.uid() = user_id);
CREATE POLICY "Analytics access for devotionals" ON public.devotional_analytics FOR SELECT USING (public.can_view_analytics() OR auth.uid() = user_id);
