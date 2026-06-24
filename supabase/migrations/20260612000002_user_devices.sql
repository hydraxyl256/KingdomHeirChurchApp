-- ==============================================================================
-- KINGDOM HEIR — USER DEVICES SCHEMA FOR FCM NOTIFICATIONS
-- Creates a table to store FCM tokens allowing multi-device targeted notifications
-- ==============================================================================

CREATE TABLE public.user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL, -- 'android', 'ios', 'web'
  device_model TEXT,
  last_active_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, fcm_token)
);

ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own device tokens
CREATE POLICY "Users can insert own device tokens" 
ON public.user_devices FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can read their own tokens
CREATE POLICY "Users can read own device tokens" 
ON public.user_devices FOR SELECT 
USING (auth.uid() = user_id);

-- Policy: Users can update their own tokens
CREATE POLICY "Users can update own device tokens" 
ON public.user_devices FOR UPDATE 
USING (auth.uid() = user_id);

-- Policy: Users can delete their own tokens (e.g., on logout)
CREATE POLICY "Users can delete own device tokens" 
ON public.user_devices FOR DELETE 
USING (auth.uid() = user_id);

-- Policy: Admins can view all devices (for targeted broadcast tools in CMS)
CREATE POLICY "Admins can read all device tokens" 
ON public.user_devices FOR SELECT 
USING (public.is_admin());

-- Utility to automatically update last_active_at
CREATE OR REPLACE FUNCTION public.handle_device_active()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.last_active_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER user_devices_active_at
  BEFORE UPDATE ON public.user_devices
  FOR EACH ROW EXECUTE FUNCTION public.handle_device_active();
