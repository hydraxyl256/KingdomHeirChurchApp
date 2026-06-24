                        -- ==============================================================================
-- KINGDOM HEIR — GROUPS & COMMUNITY SCHEMA
-- Generated: 2026-06-15
-- ==============================================================================

-- 1. Group Categories
CREATE TABLE public.group_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Groups
CREATE TABLE public.groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category_id UUID REFERENCES public.group_categories(id) ON DELETE SET NULL,
  meeting_time TEXT,
  location TEXT,
  is_private BOOLEAN NOT NULL DEFAULT false,
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Group Members
-- roles: MEMBER, LEADER, ADMIN
-- status: PENDING, ACTIVE, REJECTED, INVITED
CREATE TABLE public.group_members (
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'MEMBER',
  status TEXT NOT NULL DEFAULT 'PENDING',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (group_id, user_id)
);

-- 4. Group Messages (Chat)
CREATE TABLE public.group_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Realtime for group messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.group_messages;

-- 5. Group Announcements
CREATE TABLE public.group_announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Events & Attendance
CREATE TABLE public.group_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  event_date TIMESTAMPTZ NOT NULL,
  location TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.group_attendance (
  event_id UUID NOT NULL REFERENCES public.group_events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'PRESENT', -- PRESENT, ABSENT, EXCUSED
  PRIMARY KEY (event_id, user_id)
);

-- RLS POLICIES --

ALTER TABLE public.group_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for categories" ON public.group_categories FOR SELECT USING (true);

ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for groups" ON public.groups FOR SELECT USING (true);
CREATE POLICY "Admins can manage groups" ON public.groups FOR ALL USING (public.is_admin());

ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for members" ON public.group_members FOR SELECT USING (true);
CREATE POLICY "Users can manage own membership" ON public.group_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own membership" ON public.group_members FOR DELETE USING (auth.uid() = user_id);
-- Leaders can update membership status:
CREATE POLICY "Leaders can update membership" ON public.group_members FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm 
    WHERE gm.group_id = group_members.group_id AND gm.user_id = auth.uid() AND gm.role IN ('LEADER', 'ADMIN')
  )
);

ALTER TABLE public.group_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can read messages" ON public.group_messages FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.group_members WHERE group_id = group_messages.group_id AND user_id = auth.uid() AND status = 'ACTIVE')
);
CREATE POLICY "Members can insert messages" ON public.group_messages FOR INSERT WITH CHECK (
  auth.uid() = user_id AND 
  EXISTS (SELECT 1 FROM public.group_members WHERE group_id = group_messages.group_id AND user_id = auth.uid() AND status = 'ACTIVE')
);

ALTER TABLE public.group_announcements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can read announcements" ON public.group_announcements FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.group_members WHERE group_id = group_announcements.group_id AND user_id = auth.uid() AND status = 'ACTIVE')
);
CREATE POLICY "Leaders can insert announcements" ON public.group_announcements FOR INSERT WITH CHECK (
  auth.uid() = author_id AND 
  EXISTS (SELECT 1 FROM public.group_members WHERE group_id = group_announcements.group_id AND user_id = auth.uid() AND role IN ('LEADER', 'ADMIN'))
);

ALTER TABLE public.group_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can read events" ON public.group_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.group_members WHERE group_id = group_events.group_id AND user_id = auth.uid() AND status = 'ACTIVE')
);
CREATE POLICY "Leaders can manage events" ON public.group_events FOR ALL USING (
  EXISTS (SELECT 1 FROM public.group_members WHERE group_id = group_events.group_id AND user_id = auth.uid() AND role IN ('LEADER', 'ADMIN'))
);

ALTER TABLE public.group_attendance ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can read attendance" ON public.group_attendance FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.group_events e 
    JOIN public.group_members m ON e.group_id = m.group_id 
    WHERE e.id = group_attendance.event_id AND m.user_id = auth.uid() AND m.status = 'ACTIVE'
  )
);
CREATE POLICY "Leaders can manage attendance" ON public.group_attendance FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.group_events e 
    JOIN public.group_members m ON e.group_id = m.group_id 
    WHERE e.id = group_attendance.event_id AND m.user_id = auth.uid() AND m.role IN ('LEADER', 'ADMIN')
  )
);
