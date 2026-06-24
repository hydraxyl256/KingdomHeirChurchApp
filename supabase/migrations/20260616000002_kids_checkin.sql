-- ==============================================================================
-- KINGDOM HEIR — KIDS CHECKIN SCHEMA
-- Generated: 2026-06-16
-- ==============================================================================

-- 1. Kids Table
CREATE TABLE public.kids (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  medical_notes TEXT,
  grade_class TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER kids_updated_at
  BEFORE UPDATE ON public.kids
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.kids ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Parents can view their own kids" ON public.kids FOR SELECT USING (auth.uid() = parent_id);
CREATE POLICY "Parents can insert their own kids" ON public.kids FOR INSERT WITH CHECK (auth.uid() = parent_id);
CREATE POLICY "Parents can update their own kids" ON public.kids FOR UPDATE USING (auth.uid() = parent_id);
CREATE POLICY "Admins can manage all kids" ON public.kids FOR ALL USING (public.is_admin());

-- 2. Kids Sessions
CREATE TABLE public.kids_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  session_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.kids_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for kids sessions" ON public.kids_sessions FOR SELECT USING (true);
CREATE POLICY "Admins can manage kids sessions" ON public.kids_sessions FOR ALL USING (public.is_admin());

-- 3. Kids Checkins
CREATE TABLE public.kids_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kid_id UUID NOT NULL REFERENCES public.kids(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.kids_sessions(id) ON DELETE CASCADE,
  checked_in_by UUID NOT NULL REFERENCES public.profiles(id),
  checked_out_by UUID REFERENCES public.profiles(id),
  safety_code TEXT NOT NULL,
  checked_in_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  checked_out_at TIMESTAMPTZ,
  UNIQUE(kid_id, session_id)
);

ALTER TABLE public.kids_checkins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Parents can view their kids checkins" ON public.kids_checkins FOR SELECT USING (
  kid_id IN (SELECT id FROM public.kids WHERE parent_id = auth.uid())
);
CREATE POLICY "Parents can checkin their kids" ON public.kids_checkins FOR INSERT WITH CHECK (
  checked_in_by = auth.uid() AND kid_id IN (SELECT id FROM public.kids WHERE parent_id = auth.uid())
);
CREATE POLICY "Parents can checkout their kids" ON public.kids_checkins FOR UPDATE USING (
  checked_in_by = auth.uid() AND kid_id IN (SELECT id FROM public.kids WHERE parent_id = auth.uid())
);
CREATE POLICY "Admins can manage checkins" ON public.kids_checkins FOR ALL USING (public.is_admin());

-- Insert a default active session for demo purposes
INSERT INTO public.kids_sessions (name, session_date, start_time, end_time, is_active)
VALUES ('Sunday School - Combined', CURRENT_DATE, '09:00:00', '11:00:00', true);
