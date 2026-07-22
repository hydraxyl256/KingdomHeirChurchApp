-- Update live_services schema for automated YouTube synchronization
-- 1. Add youtube_video_id column
ALTER TABLE public.live_services ADD COLUMN youtube_video_id TEXT UNIQUE;

-- 2. Add index for faster lookups during edge function upserts
CREATE INDEX idx_live_services_youtube_video_id ON public.live_services(youtube_video_id);

-- 3. Delete seeded placeholder live services
DELETE FROM public.live_services;
