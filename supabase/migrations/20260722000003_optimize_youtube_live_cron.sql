-- ==============================================================================
-- OPTIMIZE YOUTUBE LIVE SYNC SCHEDULING
-- ==============================================================================

-- 1. Ensure required extensions exist
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;

-- 2. Clear old schedule
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-youtube-live-every-10-min') THEN
    PERFORM cron.unschedule('sync-youtube-live-every-10-min');
  END IF;
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-youtube-live-weekdays') THEN
    PERFORM cron.unschedule('sync-youtube-live-weekdays');
  END IF;
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-youtube-live-sunday') THEN
    PERFORM cron.unschedule('sync-youtube-live-sunday');
  END IF;
END $$;

-- 3. Schedule the optimized sync jobs
-- 
-- Weekdays (Mon-Sat): Every 12 hours
SELECT cron.schedule(
  'sync-youtube-live-weekdays',
  '0 */12 * * 1-6',
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

-- Sundays: Every 1 hour
SELECT cron.schedule(
  'sync-youtube-live-sunday',
  '0 * * * 0',
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
