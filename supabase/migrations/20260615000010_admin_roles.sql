-- ==============================================================================
-- KINGDOM HEIR — ADMIN & MODERATION SCHEMA
-- Generated: 2026-06-15
-- ==============================================================================

-- 1. Soft Deletes & Roles
-- Assume profiles table exists, adding fields if they don't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'USER'; -- USER, MODERATOR, ADMIN

ALTER TABLE public.groups ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT false;

-- 2. Moderation Workflow (Pre-publish Approval)
-- Default to pending (false) instead of automatically being live
ALTER TABLE public.prayer_requests ADD COLUMN IF NOT EXISTS is_approved BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.testimonies ADD COLUMN IF NOT EXISTS is_approved BOOLEAN NOT NULL DEFAULT false;

-- Add a moderation table for reported content (optional)
CREATE TABLE IF NOT EXISTS public.reported_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type TEXT NOT NULL, -- PRAYER, TESTIMONY, COMMENT
  content_id UUID NOT NULL,
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING, REVIEWED, DISMISSED
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Admin Audit Logs
CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  action TEXT NOT NULL, -- e.g., 'DELETE_USER', 'APPROVE_PRAYER', 'ASSIGN_ROLE'
  target_id TEXT NOT NULL,
  details JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS Policies
ALTER TABLE public.reported_content ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can report content" ON public.reported_content FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Admins can view reports" ON public.reported_content FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins can manage reports" ON public.reported_content FOR ALL USING (public.is_admin());

ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view audit logs" ON public.admin_audit_logs FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins can insert audit logs" ON public.admin_audit_logs FOR INSERT WITH CHECK (public.is_admin());

-- Override public read policies for Prayers and Testimonies to only show approved AND not deleted users
-- (Note: If previous policies exist, these commands might need to replace them or you apply them in the logic layer. 
-- For safety, we will rely on application logic to append `.eq('is_approved', true)` for standard users, 
-- but Admins will fetch without `.eq()` to see pending items.)
