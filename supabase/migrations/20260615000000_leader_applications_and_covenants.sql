-- ==============================================================================
-- KINGDOM HEIR — LEADER APPLICATIONS & COVENANTS MIGRATION
-- Generated: 2026-06-15
-- Implements the backend logic for Leadership Pipelines
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Custom Types (Enums)
-- ------------------------------------------------------------------------------
CREATE TYPE application_status AS ENUM (
  'pending', 'under_review', 'approved', 'denied', 'info_requested'
);

CREATE TYPE leader_level AS ENUM (
  'participant', 'group_leader', 'trainer', 'regional_leader', 'ministry_partner'
);

-- Note: user_role enum already exists in core_schema and contains 'group_leader'.
-- We will use leader_level to define the specific hierarchy of an approved leader.

-- ------------------------------------------------------------------------------
-- 2. Leader Applications Table
-- ------------------------------------------------------------------------------
CREATE TABLE public.leader_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status application_status NOT NULL DEFAULT 'pending',
  
  -- We use JSONB to handle the large nested form data without excessive columns
  personal_info JSONB NOT NULL DEFAULT '{}'::jsonb,
  testimony JSONB NOT NULL DEFAULT '{}'::jsonb,
  spiritual_practices JSONB NOT NULL DEFAULT '{}'::jsonb,
  character_reputation JSONB NOT NULL DEFAULT '{}'::jsonb,
  leadership_experience JSONB NOT NULL DEFAULT '{}'::jsonb,
  commitments_agreed BOOLEAN NOT NULL DEFAULT false,
  
  assigned_level leader_level,
  reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure updated_at stays accurate
CREATE TRIGGER leader_applications_updated_at
  BEFORE UPDATE ON public.leader_applications
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_leader_apps_user_id ON public.leader_applications(user_id);
CREATE INDEX idx_leader_apps_status ON public.leader_applications(status);

-- ------------------------------------------------------------------------------
-- 3. Covenant Signatures Table
-- ------------------------------------------------------------------------------
CREATE TABLE public.covenant_signatures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  application_id UUID NOT NULL REFERENCES public.leader_applications(id) ON DELETE CASCADE,
  
  signature_text TEXT NOT NULL,
  ip_address TEXT,
  signed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Ensure a user only signs once per approved application
  UNIQUE (user_id, application_id)
);

CREATE INDEX idx_covenant_user_id ON public.covenant_signatures(user_id);

-- ------------------------------------------------------------------------------
-- 4. RLS Policies
-- ------------------------------------------------------------------------------

-- [ LEADER APPLICATIONS SECURITY ]
ALTER TABLE public.leader_applications ENABLE ROW LEVEL SECURITY;

-- Select: Users view their own, Admins view all
CREATE POLICY "Users can view own leader applications"
ON public.leader_applications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all leader applications"
ON public.leader_applications FOR SELECT
USING (public.is_admin());

-- Insert: Users can apply for themselves
CREATE POLICY "Users can insert own leader applications"
ON public.leader_applications FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Update: Users can update their application IF it is not approved or denied
CREATE POLICY "Users can update own pending applications"
ON public.leader_applications FOR UPDATE
USING (auth.uid() = user_id AND status IN ('pending', 'info_requested'))
WITH CHECK (auth.uid() = user_id);

-- Update: Admins can update any application (e.g. approve/deny)
CREATE POLICY "Admins can update any leader application"
ON public.leader_applications FOR UPDATE
USING (public.is_admin());

-- [ COVENANT SIGNATURES SECURITY ]
ALTER TABLE public.covenant_signatures ENABLE ROW LEVEL SECURITY;

-- Select: Users view their own, Admins view all
CREATE POLICY "Users can view own covenant signatures"
ON public.covenant_signatures FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all covenant signatures"
ON public.covenant_signatures FOR SELECT
USING (public.is_admin());

-- Insert: Users can sign their own covenant
CREATE POLICY "Users can insert own covenant signature"
ON public.covenant_signatures FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Update/Delete: Signatures are immutable audit logs.
-- No UPDATE or DELETE policies are created.

-- ------------------------------------------------------------------------------
-- 5. Automation Triggers
-- ------------------------------------------------------------------------------

-- When a covenant is signed, automatically upgrade the user's role to 'group_leader' 
-- if they are just a 'member' or 'visitor', to unlock Leader Toolkit access.
CREATE OR REPLACE FUNCTION public.handle_covenant_signed()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.profiles
  SET 
    role = CASE WHEN role IN ('member', 'visitor') THEN 'group_leader'::user_role ELSE role END,
    updated_at = now()
  WHERE id = NEW.user_id;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_covenant_signed
  AFTER INSERT ON public.covenant_signatures
  FOR EACH ROW EXECUTE FUNCTION public.handle_covenant_signed();

-- ==============================================================================
-- END OF SCRIPT
-- ==============================================================================
