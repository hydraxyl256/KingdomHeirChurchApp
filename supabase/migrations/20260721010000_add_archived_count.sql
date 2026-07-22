-- ==============================================================================
-- ADD NEWLY ARCHIVED COUNT TO SYNC RUNS
-- ==============================================================================
ALTER TABLE public.media_sync_runs
ADD COLUMN IF NOT EXISTS newly_archived_count INTEGER DEFAULT 0;
