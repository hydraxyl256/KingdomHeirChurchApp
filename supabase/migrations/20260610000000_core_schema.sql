-- ==============================================================================
-- KINGDOM HEIR — CORE DATABASE SCHEMA
-- Generated: 2026-06-12
-- Note: RLS Policies and Translations are excluded as requested.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Extensions
-- ------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ------------------------------------------------------------------------------
-- 2. Custom Types (Enums)
-- ------------------------------------------------------------------------------
CREATE TYPE user_role AS ENUM (
  'member', 'visitor', 'volunteer', 'group_leader', 'deacon', 'pastor', 'bishop', 'admin'
);

CREATE TYPE publish_status AS ENUM ('draft', 'published', 'archived');

CREATE TYPE rsvp_status AS ENUM ('going', 'maybe', 'not_going', 'attended');

CREATE TYPE giving_fund AS ENUM (
  'tithe', 'offering', 'missions', 'building_fund', 'welfare', 'special'
);

CREATE TYPE payment_method AS ENUM (
  'card', 'bank_transfer', 'mobile_money', 'cash', 'cheque'
);

CREATE TYPE transaction_status AS ENUM (
  'pending', 'completed', 'failed', 'refunded'
);

CREATE TYPE prayer_visibility AS ENUM ('public', 'leaders_only', 'private');
CREATE TYPE prayer_status AS ENUM ('active', 'answered', 'archived');

CREATE TYPE notification_type AS ENUM ('general', 'event', 'prayer', 'sermon', 'giving');

-- ------------------------------------------------------------------------------
-- 3. Utility Functions
-- ------------------------------------------------------------------------------
-- Automatically updates the updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ------------------------------------------------------------------------------
-- 4. Core Tables
-- ------------------------------------------------------------------------------

-- [ PROFILES ]
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'member',
  is_active BOOLEAN NOT NULL DEFAULT true,
  preferences JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- Auto-create profile on auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- [ SERMONS ]
CREATE TABLE public.sermon_series (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  status publish_status NOT NULL DEFAULT 'published',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.sermons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  speaker_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  speaker_name TEXT NOT NULL, 
  series_id UUID REFERENCES public.sermon_series(id) ON DELETE SET NULL,
  scripture_ref TEXT,
  video_url TEXT,
  audio_url TEXT,
  thumbnail_url TEXT,
  preached_on DATE NOT NULL DEFAULT current_date,
  status publish_status NOT NULL DEFAULT 'draft',
  view_count INTEGER NOT NULL DEFAULT 0,
  
  search_vector TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(speaker_name, ''))
  ) STORED,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER sermons_updated_at
  BEFORE UPDATE ON public.sermons
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_sermons_status ON public.sermons(status);
CREATE INDEX idx_sermons_preached_on ON public.sermons(preached_on DESC);
CREATE INDEX idx_sermons_search ON public.sermons USING GIN (search_vector);


-- [ DEVOTIONALS ]
CREATE TABLE public.devotionals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  scripture_ref TEXT NOT NULL,
  scripture_text TEXT NOT NULL,
  body TEXT NOT NULL,
  reflection TEXT,
  prayer TEXT,
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  image_url TEXT,
  scheduled_for DATE UNIQUE,
  status publish_status NOT NULL DEFAULT 'draft',
  view_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER devotionals_updated_at
  BEFORE UPDATE ON public.devotionals
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_devotionals_scheduled_for ON public.devotionals(scheduled_for DESC);


-- [ EVENTS ]
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL DEFAULT 'general',
  image_url TEXT,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ,
  is_recurring BOOLEAN NOT NULL DEFAULT false,
  is_online BOOLEAN NOT NULL DEFAULT false,
  location_name TEXT,
  meeting_link TEXT,
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  status publish_status NOT NULL DEFAULT 'draft',
  rsvp_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER events_updated_at
  BEFORE UPDATE ON public.events
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_events_start_at ON public.events(start_at);
CREATE INDEX idx_events_status ON public.events(status);

CREATE TABLE public.event_rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status rsvp_status NOT NULL DEFAULT 'going',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (event_id, user_id)
);

CREATE TRIGGER event_rsvps_updated_at
  BEFORE UPDATE ON public.event_rsvps
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- [ ANNOUNCEMENTS ]
CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general',
  image_url TEXT,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  target_roles user_role[] DEFAULT '{}',
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  status publish_status NOT NULL DEFAULT 'draft',
  expires_at TIMESTAMPTZ,
  view_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON public.announcements
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_announcements_status ON public.announcements(status);
CREATE INDEX idx_announcements_pinned ON public.announcements(is_pinned) WHERE is_pinned = true;


-- [ PRAYER REQUESTS ]
CREATE TABLE public.prayer_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general',
  visibility prayer_visibility NOT NULL DEFAULT 'public',
  is_anonymous BOOLEAN NOT NULL DEFAULT false,
  status prayer_status NOT NULL DEFAULT 'active',
  answered_note TEXT,
  prayer_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER prayer_requests_updated_at
  BEFORE UPDATE ON public.prayer_requests
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_prayer_status ON public.prayer_requests(status);
CREATE INDEX idx_prayer_visibility ON public.prayer_requests(visibility);

CREATE TABLE public.prayer_intercessions (
  prayer_request_id UUID NOT NULL REFERENCES public.prayer_requests(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  prayed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (prayer_request_id, user_id)
);


-- [ TESTIMONIES ]
CREATE TABLE public.testimonies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general',
  is_anonymous BOOLEAN NOT NULL DEFAULT false,
  status publish_status NOT NULL DEFAULT 'draft',
  like_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER testimonies_updated_at
  BEFORE UPDATE ON public.testimonies
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_testimonies_status ON public.testimonies(status);


-- [ DONATIONS ]
CREATE TABLE public.donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'GHS',
  fund giving_fund NOT NULL DEFAULT 'offering',
  payment_method payment_method NOT NULL,
  status transaction_status NOT NULL DEFAULT 'pending',
  gateway_ref TEXT UNIQUE,
  receipt_number TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER donations_updated_at
  BEFORE UPDATE ON public.donations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_donations_donor_id ON public.donations(donor_id);
CREATE INDEX idx_donations_status ON public.donations(status);
CREATE INDEX idx_donations_created_at ON public.donations(created_at DESC);


-- [ NOTIFICATIONS ]
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type notification_type NOT NULL DEFAULT 'general',
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB, -- Deep linking payload (e.g. {"sermon_id": "123"})
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_unread ON public.notifications(user_id) WHERE is_read = false;
