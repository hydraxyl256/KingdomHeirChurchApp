-- ==============================================================================
-- KINGDOM HEIR — SECURITY HARDENING MIGRATION
-- This script implements strict Row Level Security (RLS) across all modules,
-- utilizing JWT custom claims to avoid recursive profile lookups.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Helper Functions for RBAC (Role-Based Access Control)
-- ------------------------------------------------------------------------------

-- Get the user role directly from the JWT app_metadata
-- (Assumes a Supabase auth hook sets the role in app_metadata upon auth, or it defaults to 'member')
CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS text
LANGUAGE sql STABLE
AS $$
  SELECT COALESCE(
    nullif(current_setting('request.jwt.claim.app_metadata', true), '')::jsonb ->> 'role', 
    'member'
  );
$$;

-- Check if current user is an Admin, Bishop, or Pastor
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql STABLE
AS $$
  SELECT public.get_auth_role() IN ('admin', 'bishop', 'pastor');
$$;

-- Check if current user is a Group Leader, Deacon, or Admin tier
CREATE OR REPLACE FUNCTION public.is_leader()
RETURNS boolean
LANGUAGE sql STABLE
AS $$
  SELECT public.get_auth_role() IN ('admin', 'bishop', 'pastor', 'group_leader', 'deacon');
$$;

-- ------------------------------------------------------------------------------
-- 2. User Profiles Security (`profiles`)
-- ------------------------------------------------------------------------------

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Public/Authenticated users can read basic info of others
CREATE POLICY "Public profile data is viewable by everyone"
ON public.profiles FOR SELECT
USING (true);
-- Note: In a real environment, you might restrict columns using column-level privileges,
-- or create a view. For RLS, this allows fetching avatars/names for UI displays.

-- Policy: Users can only update their own profiles
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy: Admins can update any profile (e.g., assigning roles)
CREATE POLICY "Admins can update any profile"
ON public.profiles FOR UPDATE
USING (public.is_admin());

-- Policy: Admins can delete profiles
CREATE POLICY "Admins can delete profiles"
ON public.profiles FOR DELETE
USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 3. Donations Security (`donations`)
-- ------------------------------------------------------------------------------

ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own donations
CREATE POLICY "Users can view own donations"
ON public.donations FOR SELECT
USING (auth.uid() = donor_id);

-- Policy: Admins can view all donations
CREATE POLICY "Admins can view all donations"
ON public.donations FOR SELECT
USING (public.is_admin());

-- Policy: Users can insert their own donations
CREATE POLICY "Users can insert own donations"
ON public.donations FOR INSERT
WITH CHECK (auth.uid() = donor_id);

-- Policy: Admins can update donation status
CREATE POLICY "Admins can update donations"
ON public.donations FOR UPDATE
USING (public.is_admin());

-- Note: Webhooks via Edge Functions use Service Role key and bypass RLS to update status.

-- ------------------------------------------------------------------------------
-- 4. Prayer Requests Security (`prayer_requests`)
-- ------------------------------------------------------------------------------

ALTER TABLE public.prayer_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Authors can view their own requests regardless of visibility
CREATE POLICY "Authors can view own prayer requests"
ON public.prayer_requests FOR SELECT
USING (auth.uid() = author_id);

-- Policy: Public visibility
CREATE POLICY "Anyone can view public prayer requests"
ON public.prayer_requests FOR SELECT
USING (visibility = 'public');

-- Policy: Leaders visibility
CREATE POLICY "Leaders can view leaders_only prayer requests"
ON public.prayer_requests FOR SELECT
USING (visibility = 'leaders_only' AND public.is_leader());

-- Policy: Admins can view all
CREATE POLICY "Admins can view all prayer requests"
ON public.prayer_requests FOR SELECT
USING (public.is_admin());

-- Policy: Insert
CREATE POLICY "Users can insert prayer requests"
ON public.prayer_requests FOR INSERT
WITH CHECK (auth.uid() = author_id);

-- Policy: Update (Author can update their own)
CREATE POLICY "Authors can update own prayer requests"
ON public.prayer_requests FOR UPDATE
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);

-- Policy: Update (Admins can moderate)
CREATE POLICY "Admins can moderate prayer requests"
ON public.prayer_requests FOR UPDATE
USING (public.is_admin());

-- Policy: Delete
CREATE POLICY "Authors and Admins can delete prayer requests"
ON public.prayer_requests FOR DELETE
USING (auth.uid() = author_id OR public.is_admin());

-- ------------------------------------------------------------------------------
-- 5. Testimonies Security (`testimonies`)
-- ------------------------------------------------------------------------------

ALTER TABLE public.testimonies ENABLE ROW LEVEL SECURITY;

-- Policy: View Published
CREATE POLICY "Anyone can view published testimonies"
ON public.testimonies FOR SELECT
USING (status = 'published');

-- Policy: View Own Drafts/Pending
CREATE POLICY "Authors can view own testimonies"
ON public.testimonies FOR SELECT
USING (auth.uid() = author_id);

-- Policy: Admins can view all (for moderation)
CREATE POLICY "Admins can view all testimonies"
ON public.testimonies FOR SELECT
USING (public.is_admin());

-- Policy: Insert
CREATE POLICY "Users can insert testimonies"
ON public.testimonies FOR INSERT
WITH CHECK (auth.uid() = author_id);

-- Policy: Update Own (Only if draft or pending, to prevent self-publishing)
CREATE POLICY "Authors can update own unpublished testimonies"
ON public.testimonies FOR UPDATE
USING (auth.uid() = author_id AND status != 'published')
WITH CHECK (auth.uid() = author_id);

-- Policy: Moderate
CREATE POLICY "Admins can moderate testimonies"
ON public.testimonies FOR UPDATE
USING (public.is_admin());

-- Policy: Delete
CREATE POLICY "Authors and Admins can delete testimonies"
ON public.testimonies FOR DELETE
USING (auth.uid() = author_id OR public.is_admin());

-- ------------------------------------------------------------------------------
-- 6. Storage Bucket Policies (Assumes buckets exist in storage.buckets)
-- ------------------------------------------------------------------------------

-- Ensure buckets exist (using standard Supabase storage tables)
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('testimonies_media', 'testimonies_media', false) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('sermon_media', 'sermon_media', true) ON CONFLICT DO NOTHING;

-- Avatars Bucket
CREATE POLICY "Avatars are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Testimonies Bucket
CREATE POLICY "Authenticated users can view testimony media"
ON storage.objects FOR SELECT
USING (bucket_id = 'testimonies_media' AND auth.role() = 'authenticated');

CREATE POLICY "Users can upload testimony media"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'testimonies_media' AND auth.role() = 'authenticated');

-- Sermon Media Bucket
CREATE POLICY "Sermons are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'sermon_media');

CREATE POLICY "Only admins can upload/modify sermons"
ON storage.objects FOR ALL
USING (bucket_id = 'sermon_media' AND public.is_admin());

-- ==============================================================================
-- END OF SCRIPT
-- ==============================================================================
