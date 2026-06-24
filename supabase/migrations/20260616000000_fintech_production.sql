-- ==============================================================================
-- KINGDOM HEIR — FINTECH & PAYMENTS SCHEMA
-- Generated: 2026-06-16
-- ==============================================================================

-- 1. Updates to Donations Table
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS fee_covered BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS fee_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS net_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS gateway TEXT; -- 'paystack', 'flutterwave'
ALTER TABLE public.donations ADD COLUMN IF NOT EXISTS authorization_url TEXT; -- Used temporarily for frontend redirect

-- 2. Webhook Audit Logs
CREATE TABLE IF NOT EXISTS public.payment_webhooks_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gateway TEXT NOT NULL,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  gateway_ref TEXT,
  processed BOOLEAN NOT NULL DEFAULT false,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS for Webhook Logs (Backend Only)
ALTER TABLE public.payment_webhooks_log ENABLE ROW LEVEL SECURITY;
-- No public policies, only service_role (edge functions) can insert/select

-- 3. Gateway Recurring Mandates
CREATE TABLE IF NOT EXISTS public.recurring_mandates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  gateway TEXT NOT NULL,
  plan_code TEXT NOT NULL, -- The Gateway's plan ID
  subscription_code TEXT NOT NULL, -- The specific user's subscription ID
  amount NUMERIC(12, 2) NOT NULL,
  fund TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active', -- active, cancelled
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.recurring_mandates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own mandates" ON public.recurring_mandates FOR SELECT USING (auth.uid() = donor_id);
CREATE POLICY "Admins can view all mandates" ON public.recurring_mandates FOR SELECT USING (public.is_admin());
