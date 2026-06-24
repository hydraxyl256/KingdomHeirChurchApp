-- ==============================================================================
-- KINGDOM HEIR — REPORTING & CERTIFICATES MIGRATION
-- Generated: 2026-06-15
-- Implements the backend logic for Group Reporting and automated Recognition
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Custom Types (Enums)
-- ------------------------------------------------------------------------------
CREATE TYPE certificate_type AS ENUM (
  'completion', 
  'commissioning', 
  'group_leader', 
  'trainer', 
  'regional_leader'
);

CREATE TYPE badge_type AS ENUM (
  'bronze',    -- 1 Group Led
  'silver',    -- 3 Groups Led
  'gold',      -- 5 Groups Led
  'builder',   -- 10 Groups Led
  'multiplier' -- 25+ Groups Led
);

-- ------------------------------------------------------------------------------
-- 2. Group Reports Table
-- ------------------------------------------------------------------------------
CREATE TABLE public.group_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  leader_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Section 1: Group Info extracted for quick querying
  group_name TEXT NOT NULL,
  country TEXT NOT NULL,
  city_region TEXT NOT NULL,
  meeting_type TEXT NOT NULL,
  group_start_date DATE NOT NULL,
  report_date DATE NOT NULL DEFAULT current_date,
  
  -- The full packet data (Sections 2-8) is stored in JSONB for flexibility
  -- Keys should map to the GroupReportingPacket Dart model
  report_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  status publish_status NOT NULL DEFAULT 'published',
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER group_reports_updated_at
  BEFORE UPDATE ON public.group_reports
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_group_reports_leader_id ON public.group_reports(leader_id);
CREATE INDEX idx_group_reports_country ON public.group_reports(country);

-- ------------------------------------------------------------------------------
-- 3. Certificates & Badges Tables
-- ------------------------------------------------------------------------------
CREATE TABLE public.certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type certificate_type NOT NULL,
  issued_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL, -- Null implies system generated
  issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb, -- Store specific group info or dates here
  
  -- Users should only receive one of each certificate type generally, unless re-certified
  UNIQUE (user_id, type)
);

CREATE INDEX idx_certificates_user_id ON public.certificates(user_id);

CREATE TABLE public.leader_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type badge_type NOT NULL,
  awarded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE (user_id, type)
);

CREATE INDEX idx_leader_badges_user_id ON public.leader_badges(user_id);

-- ------------------------------------------------------------------------------
-- 4. RLS Policies
-- ------------------------------------------------------------------------------

-- [ GROUP REPORTS SECURITY ]
ALTER TABLE public.group_reports ENABLE ROW LEVEL SECURITY;

-- Leaders can view and insert their own reports
CREATE POLICY "Leaders can view own reports" ON public.group_reports FOR SELECT USING (auth.uid() = leader_id);
CREATE POLICY "Leaders can insert own reports" ON public.group_reports FOR INSERT WITH CHECK (auth.uid() = leader_id);

-- Admins can view all reports (for Global Impact Dashboard)
CREATE POLICY "Admins can view all reports" ON public.group_reports FOR SELECT USING (public.is_admin());

-- [ CERTIFICATES SECURITY ]
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own certificates" ON public.certificates FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all certificates" ON public.certificates FOR SELECT USING (public.is_admin());
-- Certificates are inserted by triggers or admins, not directly by users
CREATE POLICY "Admins can insert certificates" ON public.certificates FOR INSERT WITH CHECK (public.is_admin());

-- [ BADGES SECURITY ]
ALTER TABLE public.leader_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own badges" ON public.leader_badges FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all badges" ON public.leader_badges FOR SELECT USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 5. Automation Triggers
-- ------------------------------------------------------------------------------

-- Automatically issues certificates and badges when a leader submits a group report.
CREATE OR REPLACE FUNCTION public.process_group_report()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  total_groups_led INT;
  future_leaders_count INT;
BEGIN
  -- 1. Calculate total groups led by this user
  SELECT count(*) INTO total_groups_led
  FROM public.group_reports
  WHERE leader_id = NEW.leader_id;

  -- 2. Award Badges based on total groups led
  IF total_groups_led >= 1 THEN
    INSERT INTO public.leader_badges (user_id, type) VALUES (NEW.leader_id, 'bronze') ON CONFLICT DO NOTHING;
  END IF;
  IF total_groups_led >= 3 THEN
    INSERT INTO public.leader_badges (user_id, type) VALUES (NEW.leader_id, 'silver') ON CONFLICT DO NOTHING;
  END IF;
  IF total_groups_led >= 5 THEN
    INSERT INTO public.leader_badges (user_id, type) VALUES (NEW.leader_id, 'gold') ON CONFLICT DO NOTHING;
  END IF;
  IF total_groups_led >= 10 THEN
    INSERT INTO public.leader_badges (user_id, type) VALUES (NEW.leader_id, 'builder') ON CONFLICT DO NOTHING;
  END IF;
  IF total_groups_led >= 25 THEN
    INSERT INTO public.leader_badges (user_id, type) VALUES (NEW.leader_id, 'multiplier') ON CONFLICT DO NOTHING;
  END IF;

  -- 3. Issue Group Leader Certificate (if they just completed their first group report)
  IF total_groups_led >= 1 THEN
    INSERT INTO public.certificates (user_id, type, metadata) 
    VALUES (NEW.leader_id, 'group_leader', jsonb_build_object('group_name', NEW.group_name)) 
    ON CONFLICT DO NOTHING;
  END IF;

  -- 4. Evaluate Trainer Certificate
  -- If they have led >= 1 group AND identified future leaders/trainers
  future_leaders_count := (NEW.report_data->>'futureLeadersExpected')::INT;
  IF future_leaders_count IS NULL THEN
    future_leaders_count := 0;
  END IF;

  IF total_groups_led >= 1 AND future_leaders_count > 0 THEN
    INSERT INTO public.certificates (user_id, type, metadata) 
    VALUES (NEW.leader_id, 'trainer', jsonb_build_object('groups_led', total_groups_led, 'future_leaders', future_leaders_count)) 
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_group_report_submitted
  AFTER INSERT ON public.group_reports
  FOR EACH ROW EXECUTE FUNCTION public.process_group_report();

-- ==============================================================================
-- END OF SCRIPT
-- ==============================================================================
