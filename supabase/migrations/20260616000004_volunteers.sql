-- ==============================================================================
-- KINGDOM HEIR — VOLUNTEERS SCHEMA
-- Generated: 2026-06-16
-- ==============================================================================

-- 1. Volunteer Opportunities Table
CREATE TABLE public.volunteer_opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  time_description TEXT NOT NULL,
  open_slots INT NOT NULL DEFAULT 1,
  ministry_area TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER volunteer_opportunities_updated_at
  BEFORE UPDATE ON public.volunteer_opportunities
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.volunteer_opportunities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for active volunteer opportunities" ON public.volunteer_opportunities FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage volunteer opportunities" ON public.volunteer_opportunities FOR ALL USING (public.is_admin());

-- 2. Volunteer Applications Table
CREATE TABLE public.volunteer_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  opportunity_id UUID NOT NULL REFERENCES public.volunteer_opportunities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, approved, rejected
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(opportunity_id, user_id)
);

ALTER TABLE public.volunteer_applications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own applications" ON public.volunteer_applications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create applications" ON public.volunteer_applications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can manage applications" ON public.volunteer_applications FOR ALL USING (public.is_admin());

-- Seed Data
INSERT INTO public.volunteer_opportunities (title, time_description, open_slots, ministry_area) VALUES
('Welcome Team', 'Sunday 8:30 AM', 3, 'Guest Services'),
('Media & Tech', 'Sunday 8:00 AM', 1, 'Production'),
('Children''s Ministry', 'Sunday 9:00 AM', 5, 'Kids'),
('Prayer Team', 'After service', 2, 'Prayer');
