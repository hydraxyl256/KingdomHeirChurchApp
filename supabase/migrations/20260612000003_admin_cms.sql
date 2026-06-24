-- ==============================================================================
-- KINGDOM HEIR — ADMIN CMS SCHEMA
-- Creates Audit Logs, Dashboard Analytic Views, and Admin RLS Policies.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Audit Logging System
-- ------------------------------------------------------------------------------

CREATE TABLE public.admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  action TEXT NOT NULL,          -- e.g., 'INSERT', 'UPDATE', 'DELETE'
  target_table TEXT NOT NULL,    -- e.g., 'sermons'
  target_id UUID NOT NULL,
  payload JSONB,                 -- The new/changed data
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can read audit logs. No one can mutate them directly via API.
CREATE POLICY "Admins can read audit logs" ON public.admin_audit_logs 
FOR SELECT USING (public.is_admin());

-- Postgres Trigger Function to automatically log admin actions
CREATE OR REPLACE FUNCTION public.log_admin_action()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Only log if the current user is an admin
  IF public.is_admin() THEN
    IF TG_OP = 'DELETE' THEN
      INSERT INTO public.admin_audit_logs (admin_id, action, target_table, target_id, payload)
      VALUES (auth.uid(), TG_OP, TG_TABLE_NAME, OLD.id, row_to_json(OLD)::jsonb);
      RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      INSERT INTO public.admin_audit_logs (admin_id, action, target_table, target_id, payload)
      VALUES (auth.uid(), TG_OP, TG_TABLE_NAME, NEW.id, row_to_json(NEW)::jsonb);
      RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
      INSERT INTO public.admin_audit_logs (admin_id, action, target_table, target_id, payload)
      VALUES (auth.uid(), TG_OP, TG_TABLE_NAME, NEW.id, row_to_json(NEW)::jsonb);
      RETURN NEW;
    END IF;
  END IF;
  
  IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$;

-- Attach Audit Triggers to core tables
CREATE TRIGGER audit_sermons_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.sermons
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_action();

CREATE TRIGGER audit_events_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.events
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_action();

CREATE TRIGGER audit_devotionals_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.devotionals
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_action();

CREATE TRIGGER audit_announcements_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.announcements
  FOR EACH ROW EXECUTE FUNCTION public.log_admin_action();


-- ------------------------------------------------------------------------------
-- 2. Admin Dashboard Views
-- ------------------------------------------------------------------------------

-- View to power the Flutter Web Admin Dashboard Analytics screen
CREATE OR REPLACE VIEW public.view_admin_dashboard_stats AS
SELECT
  (SELECT count(*) FROM public.profiles) AS total_users,
  (SELECT count(*) FROM public.profiles WHERE created_at > now() - interval '30 days') AS new_users_30d,
  
  (SELECT count(*) FROM public.donations WHERE status = 'completed') AS total_donations,
  (SELECT COALESCE(sum(amount), 0) FROM public.donations WHERE status = 'completed' AND created_at > now() - interval '30 days') AS monthly_donation_revenue,
  
  (SELECT count(*) FROM public.prayer_requests WHERE status = 'active') AS active_prayer_requests,
  (SELECT count(*) FROM public.testimonies WHERE status = 'pending' OR status = 'draft') AS unmoderated_testimonies,
  
  (SELECT count(*) FROM public.events WHERE start_at > now()) AS upcoming_events,
  (SELECT count(*) FROM public.sermons WHERE status = 'published') AS published_sermons
;

-- ------------------------------------------------------------------------------
-- 3. Admin RLS Policies (Core Tables)
-- Note: Assuming the core tables created in 20260610000000_core_schema.sql 
-- have RLS enabled (we enabled it in the security_hardening migration).
-- ------------------------------------------------------------------------------

CREATE POLICY "Admins have full access to sermons" ON public.sermons FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to series" ON public.sermon_series FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to devotionals" ON public.devotionals FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to events" ON public.events FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to announcements" ON public.announcements FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to prayer_requests" ON public.prayer_requests FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to testimonies" ON public.testimonies FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to donations" ON public.donations FOR ALL USING (public.is_admin());
CREATE POLICY "Admins have full access to profiles" ON public.profiles FOR ALL USING (public.is_admin());
