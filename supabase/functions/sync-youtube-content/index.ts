// Kingdom Heir — sync-youtube-content Edge Function
// Fetches the official channel's uploads from YouTube Data API v3,
// upserts into media_content, writes a sync run record.
//
// Invoke: POST /functions/v1/sync-youtube-content
// Requires: Authorization: Bearer <admin-user-jwt>
//
// Secrets required (set via: supabase secrets set KEY=value):
//   YOUTUBE_API_KEY      — YouTube Data API v3 key
//   YOUTUBE_CHANNEL_ID   — UCxxxxxx channel ID

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ─── Types ────────────────────────────────────────────────────────────────────

interface YouTubePlaylistItem {
  snippet: {
    title: string;
    description: string;
    publishedAt: string;
    thumbnails: {
      maxres?: { url: string };
      high?: { url: string };
      medium?: { url: string };
      default?: { url: string };
    };
    resourceId: { videoId: string };
  };
}

interface YouTubeVideoDetail {
  id: string;
  snippet: {
    title: string;
    description: string;
    publishedAt: string;
    thumbnails: {
      maxres?: { url: string };
      high?: { url: string };
      medium?: { url: string };
    };
    privacyStatus?: string;
  };
  contentDetails: {
    duration: string;
    privacyStatus?: string; // sometimes nested here in status
  };
  status?: {
    privacyStatus: string;
  };
}

interface SyncSummary {
  status: 'completed' | 'failed' | 'partial';
  videosFound: number;
  videosCreated: number;
  videosUpdated: number;
  errorMessage?: string;
  durationMs: number;
}

// ─── ISO 8601 Duration Parser ─────────────────────────────────────────────────

/**
 * Parses an ISO 8601 duration string (e.g. "PT1H30M45S") into total seconds.
 * Handles days, hours, minutes, seconds. Returns 0 on parse failure.
 */
export function parseIso8601Duration(iso: string): number {
  if (!iso || !iso.startsWith('P')) return 0;
  const match = iso.match(
    /P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/
  );
  if (!match) return 0;
  const days    = parseInt(match[1] ?? '0', 10);
  const hours   = parseInt(match[2] ?? '0', 10);
  const minutes = parseInt(match[3] ?? '0', 10);
  const seconds = parseInt(match[4] ?? '0', 10);
  return days * 86400 + hours * 3600 + minutes * 60 + seconds;
}

// ─── Best thumbnail helper ────────────────────────────────────────────────────

function bestThumbnail(thumbnails: YouTubeVideoDetail['snippet']['thumbnails']): string | null {
  return thumbnails?.maxres?.url
    ?? thumbnails?.high?.url
    ?? thumbnails?.medium?.url
    ?? null;
}

// ─── YouTube API helpers ──────────────────────────────────────────────────────

const YT_BASE = 'https://www.googleapis.com/youtube/v3';

async function fetchUploadsPlaylistId(
  apiKey: string,
  channelId: string
): Promise<string> {
  const url = `${YT_BASE}/channels?part=contentDetails&id=${channelId}&key=${apiKey}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`channels API ${res.status}: ${await res.text()}`);
  const data = await res.json();
  const playlistId = data?.items?.[0]?.contentDetails?.relatedPlaylists?.uploads;
  if (!playlistId) throw new Error('Could not retrieve uploads playlist ID');
  return playlistId as string;
}

async function fetchAllPlaylistItems(
  apiKey: string,
  playlistId: string
): Promise<YouTubePlaylistItem[]> {
  const items: YouTubePlaylistItem[] = [];
  let pageToken: string | undefined;

  do {
    const params = new URLSearchParams({
      part: 'snippet',
      playlistId,
      maxResults: '50',
      key: apiKey,
      ...(pageToken ? { pageToken } : {}),
    });
    const res = await fetch(`${YT_BASE}/playlistItems?${params}`);
    if (!res.ok) throw new Error(`playlistItems API ${res.status}: ${await res.text()}`);
    const data = await res.json();
    items.push(...(data.items ?? []));
    pageToken = data.nextPageToken;
  } while (pageToken);

  return items;
}

async function fetchVideoDetails(
  apiKey: string,
  videoIds: string[]
): Promise<YouTubeVideoDetail[]> {
  const details: YouTubeVideoDetail[] = [];
  // YouTube API allows up to 50 IDs per request
  for (let i = 0; i < videoIds.length; i += 50) {
    const chunk = videoIds.slice(i, i + 50);
    const params = new URLSearchParams({
      part: 'snippet,contentDetails,status',
      id: chunk.join(','),
      key: apiKey,
    });
    const res = await fetch(`${YT_BASE}/videos?${params}`);
    if (!res.ok) throw new Error(`videos API ${res.status}: ${await res.text()}`);
    const data = await res.json();
    details.push(...(data.items ?? []));
  }
  return details;
}

// ─── Admin verification ───────────────────────────────────────────────────────

async function verifyAdmin(
  supabase: ReturnType<typeof createClient>,
  authHeader: string | null
): Promise<void> {
  if (!authHeader?.startsWith('Bearer ')) {
    throw new Error('Missing or invalid Authorization header');
  }
  const token = authHeader.slice(7);
  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) throw new Error('Invalid token');

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  if (profileError || !profile) throw new Error('Profile not found');
  if (!['admin', 'super_admin', 'pastor'].includes(profile.role)) {
    throw new Error('Insufficient permissions. Admin role required.');
  }
}

// ─── Main handler ─────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  const startedAt = new Date();

  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
    });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const supabaseUrl  = Deno.env.get('SUPABASE_URL')!;
  const serviceKey   = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const apiKey       = Deno.env.get('YOUTUBE_API_KEY');
  const channelId    = Deno.env.get('YOUTUBE_CHANNEL_ID');

  if (!apiKey || !channelId) {
    return new Response(
      JSON.stringify({ error: 'YOUTUBE_API_KEY and YOUTUBE_CHANNEL_ID secrets are required.' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // Service-role client (bypasses RLS) — used for writes
  const supabase = createClient(supabaseUrl, serviceKey);

  // User-context client — used only for auth verification
  const userClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY')!);

  // ── Auth check ──────────────────────────────────────────────────────────────
  try {
    await verifyAdmin(userClient, req.headers.get('Authorization'));
  } catch (e) {
    return new Response(
      JSON.stringify({ error: (e as Error).message }),
      { status: 403, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // ── Insert initial sync run record ──────────────────────────────────────────
  let syncRunId: string | null = null;
  const { data: runRow } = await supabase
    .from('media_sync_runs')
    .insert({
      status: 'running',
      started_at: startedAt.toISOString(),
    })
    .select('id')
    .single();
  syncRunId = runRow?.id ?? null;

  const summary: SyncSummary = {
    status: 'completed',
    videosFound: 0,
    videosCreated: 0,
    videosUpdated: 0,
    durationMs: 0,
  };

  try {
    // 1. Get uploads playlist ID
    const playlistId = await fetchUploadsPlaylistId(apiKey, channelId);

    // 2. Fetch all playlist items (paginated)
    const playlistItems = await fetchAllPlaylistItems(apiKey, playlistId);
    const videoIds = playlistItems
      .map(item => item?.snippet?.resourceId?.videoId)
      .filter(Boolean) as string[];

    summary.videosFound = videoIds.length;

    if (videoIds.length === 0) {
      throw new Error('No videos found in channel uploads playlist');
    }

    // 3. Fetch full video details (snippet + contentDetails + status)
    const videoDetails = await fetchVideoDetails(apiKey, videoIds);

    // 4. Upsert each video into media_content
    for (const video of videoDetails) {
      // Skip private/unlisted videos
      const privacyStatus = video.status?.privacyStatus ?? video.contentDetails?.privacyStatus;
      if (privacyStatus && privacyStatus !== 'public') continue;

      const videoId = video.id;
      const youtubeUrl = `https://www.youtube.com/watch?v=${videoId}`;
      const thumbnail = bestThumbnail(video.snippet.thumbnails);
      const durationSecs = parseIso8601Duration(video.contentDetails.duration ?? '');
      const publishedAt = video.snippet.publishedAt ?? null;

      // Fields admin manages — preserved via ON CONFLICT DO UPDATE selective merge
      const insertPayload = {
        youtube_video_id: videoId,
        youtube_url:      youtubeUrl,
        title:            video.snippet.title?.trim() ?? 'Untitled',
        description:      video.snippet.description?.trim() ?? null,
        thumbnail_url:    thumbnail,
        duration_seconds: durationSecs > 0 ? durationSecs : null,
        published_at:     publishedAt,
        // New videos start as pending_review; admin-managed fields set defaults
        status:           'pending_review',
        content_type:     'sermon',       // default — admin changes in review queue
        updated_at:       new Date().toISOString(),
      };

      const { data: existing } = await supabase
        .from('media_content')
        .select('id')
        .eq('youtube_video_id', videoId)
        .maybeSingle();

      if (existing) {
        // UPDATE: only sync YouTube-sourced fields; preserve admin-managed fields
        const { error: updateErr } = await supabase
          .from('media_content')
          .update({
            title:            insertPayload.title,
            description:      insertPayload.description,
            thumbnail_url:    insertPayload.thumbnail_url,
            duration_seconds: insertPayload.duration_seconds,
            published_at:     insertPayload.published_at,
            updated_at:       insertPayload.updated_at,
            // youtube_url updated in case it changed (shouldn't, but safe)
            youtube_url:      youtubeUrl,
          })
          .eq('youtube_video_id', videoId);

        if (!updateErr) summary.videosUpdated++;
      } else {
        // INSERT new record as pending_review
        const { error: insertErr } = await supabase
          .from('media_content')
          .insert(insertPayload);

        if (!insertErr) summary.videosCreated++;
      }
    }

    // 5. Finalize sync run
    summary.durationMs = Date.now() - startedAt.getTime();
    if (syncRunId) {
      await supabase.from('media_sync_runs').update({
        status:          'completed',
        completed_at:    new Date().toISOString(),
        videos_found:    summary.videosFound,
        videos_created:  summary.videosCreated,
        videos_updated:  summary.videosUpdated,
      }).eq('id', syncRunId);
    }

    return new Response(
      JSON.stringify({ success: true, summary }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    const message = (err as Error).message ?? 'Unknown error';
    summary.status = 'failed';
    summary.errorMessage = message;
    summary.durationMs = Date.now() - startedAt.getTime();

    if (syncRunId) {
      await supabase.from('media_sync_runs').update({
        status:          'failed',
        completed_at:    new Date().toISOString(),
        videos_found:    summary.videosFound,
        videos_created:  summary.videosCreated,
        videos_updated:  summary.videosUpdated,
        error_message:   message,
      }).eq('id', syncRunId);
    }

    return new Response(
      JSON.stringify({ success: false, summary }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
