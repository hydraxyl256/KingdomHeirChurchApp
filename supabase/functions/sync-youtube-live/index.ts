import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ─── YouTube API Types & Helpers ──────────────────────────────────────────────

interface YouTubeSearchResult {
  id: { videoId: string };
  snippet: {
    title: string;
    description: string;
    publishedAt: string;
    thumbnails: {
      high?: { url: string };
      medium?: { url: string };
      default?: { url: string };
    };
  };
}

const YT_BASE = 'https://www.googleapis.com/youtube/v3';

async function fetchLiveStreams(
  apiKey: string,
  channelId: string,
  eventType: 'live' | 'upcoming'
): Promise<YouTubeSearchResult[]> {
  const params = new URLSearchParams({
    part: 'snippet',
    channelId,
    type: 'video',
    eventType,
    key: apiKey,
    maxResults: '25',
  });
  
  const res = await fetch(`${YT_BASE}/search?${params}`);
  if (!res.ok) throw new Error(`search API ${res.status}: ${await res.text()}`);
  const data = await res.json();
  return data.items ?? [];
}

function bestThumbnail(thumbnails: YouTubeSearchResult['snippet']['thumbnails']): string | null {
  return thumbnails?.high?.url ?? thumbnails?.medium?.url ?? thumbnails?.default?.url ?? null;
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

  const supabase = createClient(supabaseUrl, serviceKey);
  const userClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY')!);

  // ── Auth check ──────────────────────────────────────────────────────────────
  const authHeader = req.headers.get('Authorization');
  const syncInternalSecret = Deno.env.get('SYNC_INTERNAL_SECRET');
  
  const isInternalCron = !!(authHeader && syncInternalSecret && authHeader === `Bearer ${syncInternalSecret}`);

  if (!isInternalCron) {
    try {
      await verifyAdmin(userClient, authHeader);
    } catch (e) {
      return new Response(
        JSON.stringify({ error: (e as Error).message }),
        { status: 403, headers: { 'Content-Type': 'application/json' } }
      );
    }
  }

  console.log(JSON.stringify({
    event: "youtube_live_sync_started",
    timestamp: new Date().toISOString()
  }));

  try {
    const liveStreams = await fetchLiveStreams(apiKey, channelId, 'live');
    const upcomingStreams = await fetchLiveStreams(apiKey, channelId, 'upcoming');
    
    const allFoundStreams = [...liveStreams, ...upcomingStreams];

    console.log(JSON.stringify({
      event: "youtube_live_found",
      live_count: liveStreams.length,
      upcoming_count: upcomingStreams.length,
      total: allFoundStreams.length
    }));

    let videosUpserted = 0;
    const activeYoutubeIds: string[] = [];

    // 1. Process Live Streams
    for (const video of liveStreams) {
      const videoId = video.id.videoId;
      if (!videoId) continue;
      
      activeYoutubeIds.push(videoId);
      
      const payload = {
        youtube_video_id: videoId,
        title: video.snippet.title ?? 'Live Stream',
        description: video.snippet.description ?? null,
        thumbnail_url: bestThumbnail(video.snippet.thumbnails),
        stream_url: `https://youtube.com/watch?v=${videoId}`,
        status: 'live',
        actual_start_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      const { error } = await supabase
        .from('live_services')
        .upsert(payload, { onConflict: 'youtube_video_id' });
        
      if (!error) videosUpserted++;
    }

    // 2. Process Upcoming Streams
    for (const video of upcomingStreams) {
      const videoId = video.id.videoId;
      if (!videoId) continue;
      
      activeYoutubeIds.push(videoId);
      
      const payload = {
        youtube_video_id: videoId,
        title: video.snippet.title ?? 'Upcoming Stream',
        description: video.snippet.description ?? null,
        thumbnail_url: bestThumbnail(video.snippet.thumbnails),
        stream_url: `https://youtube.com/watch?v=${videoId}`,
        status: 'scheduled',
        scheduled_start_at: video.snippet.publishedAt ?? new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };

      const { error } = await supabase
        .from('live_services')
        .upsert(payload, { onConflict: 'youtube_video_id' });
        
      if (!error) videosUpserted++;
    }

    // 3. Reconciliation
    let streamsEnded = 0;
    const { data: dbActiveServices } = await supabase
      .from('live_services')
      .select('id, youtube_video_id')
      .in('status', ['live', 'scheduled']);

    if (dbActiveServices) {
      const dbActiveIds = dbActiveServices
        .map(s => s.youtube_video_id)
        .filter(Boolean) as string[];

      const orphanedIds = dbActiveIds.filter(id => !activeYoutubeIds.includes(id));

      if (orphanedIds.length > 0) {
        const { error: endErr } = await supabase
          .from('live_services')
          .update({
            status: 'ended',
            ended_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .in('youtube_video_id', orphanedIds);

        if (!endErr) streamsEnded = orphanedIds.length;
      }
    }

    const durationMs = Date.now() - startedAt.getTime();
    
    console.log(JSON.stringify({
      event: "youtube_live_sync_completed",
      videos_upserted: videosUpserted,
      streams_ended: streamsEnded,
      duration_ms: durationMs,
      timestamp: new Date().toISOString()
    }));

    return new Response(
      JSON.stringify({
        success: true,
        upserted: videosUpserted,
        ended: streamsEnded,
        duration_ms: durationMs
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    const message = (err as Error).message ?? 'Unknown error';
    const durationMs = Date.now() - startedAt.getTime();

    console.log(JSON.stringify({
      event: "youtube_live_sync_failed",
      error: message,
      duration_ms: durationMs,
      timestamp: new Date().toISOString()
    }));

    return new Response(
      JSON.stringify({ success: false, error: message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
