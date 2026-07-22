-- ==============================================================================
-- AUTOMATED YOUTUBE LIVE SYNC SCHEDULING
-- ==============================================================================

-- 1. Ensure required extensions exist
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;

-- 2. Clear any existing schedule
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-youtube-live-every-10-min') THEN
    PERFORM cron.unschedule('sync-youtube-live-every-10-min');
  END IF;
END $$;

-- 3. Schedule the sync job
-- 
-- IMPORTANT:
-- This job expects two secrets in Supabase Vault:
-- 1. 'sync_internal_secret' -> A dedicated secret for internal invocation
-- 2. 'sync_live_edge_function_url' -> The full URL to the edge function (sync-youtube-live)
SELECT cron.schedule(
  'sync-youtube-live-every-10-min',
  '*/10 * * * *',
  $$
    WITH token_secret AS (
      SELECT secret FROM vault.decrypted_secrets WHERE name = 'sync_internal_secret' LIMIT 1
    ),
    url_secret AS (
      SELECT secret FROM vault.decrypted_secrets WHERE name = 'sync_live_edge_function_url' LIMIT 1
    )
    SELECT net.http_post(
      url:=(SELECT secret FROM url_secret),
      headers:=jsonb_build_object(
        'Authorization', 'Bearer ' || (SELECT secret FROM token_secret),
        'Content-Type', 'application/json'
      )
    );
  $$
);
