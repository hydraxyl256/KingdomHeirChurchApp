-- 1. Safely drop if exists to ensure clean recreation without conflicts
DROP TABLE IF EXISTS public.prayer_requests CASCADE;

-- 2. Create the required public.prayer_requests table
CREATE TABLE public.prayer_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  title text,
  content text NOT NULL CHECK (trim(content) <> ''),
  category text,
  is_anonymous boolean NOT NULL DEFAULT false,
  is_public boolean NOT NULL DEFAULT true,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'answered', 'archived')),
  pray_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  CONSTRAINT prayer_category_check CHECK (
    category IS NULL OR 
    category IN ('General', 'Healing', 'Provision', 'Salvation', 'Relationships', 'Deliverance', 'Direction', 'Thanksgiving', 'All', 'general', 'healing', 'family', 'finances', 'guidance', 'thanksgiving', 'other')
  )
);

-- 3. Indexes
CREATE INDEX idx_prayer_requests_created_at ON public.prayer_requests(created_at DESC);
CREATE INDEX idx_prayer_requests_status ON public.prayer_requests(status);
CREATE INDEX idx_prayer_requests_is_public ON public.prayer_requests(is_public);
CREATE INDEX idx_prayer_requests_user_id ON public.prayer_requests(user_id);

-- 4. Re-attach updated_at trigger (using the project's standard function)
CREATE TRIGGER prayer_requests_updated_at
  BEFORE UPDATE ON public.prayer_requests
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 5. Safely handle prayer_responses foreign key to prayer_requests
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prayer_responses' AND column_name = 'prayer_request_id'
  ) THEN
    -- First remove any existing constraints on that column just in case
    ALTER TABLE public.prayer_responses DROP CONSTRAINT IF EXISTS prayer_responses_prayer_request_id_fkey;
    
    -- Now add the correct foreign key
    ALTER TABLE public.prayer_responses 
      ADD CONSTRAINT prayer_responses_prayer_request_id_fkey 
      FOREIGN KEY (prayer_request_id) REFERENCES public.prayer_requests(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Same for prayer_intercessions
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prayer_intercessions' AND column_name = 'prayer_request_id'
  ) THEN
    ALTER TABLE public.prayer_intercessions DROP CONSTRAINT IF EXISTS prayer_intercessions_prayer_request_id_fkey;
    
    ALTER TABLE public.prayer_intercessions 
      ADD CONSTRAINT prayer_intercessions_prayer_request_id_fkey 
      FOREIGN KEY (prayer_request_id) REFERENCES public.prayer_requests(id) ON DELETE CASCADE;
  END IF;
END $$;

-- 6. RLS Policies
ALTER TABLE public.prayer_requests ENABLE ROW LEVEL SECURITY;

-- Policy 1: Anyone authenticated can read only public active prayer requests.
CREATE POLICY "Anyone authenticated can read public active requests" 
ON public.prayer_requests FOR SELECT 
TO authenticated 
USING (is_public = true AND status = 'active');

-- Policy 2: Authenticated users can insert a request only when user_id = auth.uid().
CREATE POLICY "Users can insert their own requests" 
ON public.prayer_requests FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());

-- Policy 3: Authenticated users can update or delete only their own requests.
CREATE POLICY "Users can update their own requests" 
ON public.prayer_requests FOR UPDATE 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own requests" 
ON public.prayer_requests FOR DELETE 
TO authenticated 
USING (user_id = auth.uid());

-- Policy 4: Admin/service-role access must remain possible.
-- (Supabase handles service_role bypassing RLS automatically, but we can explicitly allow admin roles if they exist)
CREATE POLICY "Service role and admins can manage all"
ON public.prayer_requests FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- We also need to allow users to read their OWN private requests! 
CREATE POLICY "Users can read their own private requests"
ON public.prayer_requests FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Ensure prayer_responses RLS doesn't expose private requests
-- (We use DO block since table might not exist in this script natively)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'prayer_responses') THEN
    ALTER TABLE public.prayer_responses ENABLE ROW LEVEL SECURITY;
    
    -- Drop old policies to be safe
    DROP POLICY IF EXISTS "Users can read responses on public active requests" ON public.prayer_responses;
    DROP POLICY IF EXISTS "Users can insert responses as themselves" ON public.prayer_responses;
    DROP POLICY IF EXISTS "Users can update their own responses" ON public.prayer_responses;
    DROP POLICY IF EXISTS "Users can delete their own responses" ON public.prayer_responses;
    
    -- Create safe policies
    EXECUTE '
      CREATE POLICY "Users can read responses on public active requests"
      ON public.prayer_responses FOR SELECT
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM public.prayer_requests pr 
          WHERE pr.id = prayer_responses.prayer_request_id AND pr.is_public = true AND pr.status = ''active''
        )
      )
    ';
    
    EXECUTE '
      CREATE POLICY "Users can insert responses as themselves"
      ON public.prayer_responses FOR INSERT
      TO authenticated
      WITH CHECK (user_id = auth.uid())
    ';
    
    EXECUTE '
      CREATE POLICY "Users can update their own responses"
      ON public.prayer_responses FOR UPDATE
      TO authenticated
      USING (user_id = auth.uid())
    ';
    
    EXECUTE '
      CREATE POLICY "Users can delete their own responses"
      ON public.prayer_responses FOR DELETE
      TO authenticated
      USING (user_id = auth.uid())
    ';
  END IF;
END $$;

-- 7. Seed 5 demo prayer requests if table is empty
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.prayer_requests) THEN
    INSERT INTO public.prayer_requests (title, content, category, is_public, status) VALUES
    ('Strength for the week', 'Praying for strength and guidance at work this week as we face new challenges.', 'General', true, 'active'),
    ('Healing for my aunt', 'Please pray for my aunt who is recovering from a recent surgery. She is in a lot of pain.', 'Healing', true, 'active'),
    ('Job interview', 'I have a final round interview this Thursday. Praying for peace and clarity of mind.', 'Provision', true, 'active'),
    ('Praise report! New baby', 'Thank you Lord for a safe delivery! Our healthy baby girl arrived yesterday.', 'Thanksgiving', true, 'answered'),
    ('Guidance for family move', 'We are considering moving to a new city for work. Praying for clear direction.', 'Direction', true, 'active');
  END IF;
END $$;

-- 8. Add RPC for incrementing pray_count
create or replace function public.increment_prayer_count(p_prayer_id uuid)
returns integer
language plpgsql
security definer
as $$
declare
  v_new_count integer;
begin
  update public.prayer_requests
    set pray_count = pray_count + 1
    where id = p_prayer_id
    returning pray_count into v_new_count;
    
  return v_new_count;
end;
$$;
