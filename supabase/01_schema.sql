-- ============================================================
-- TAPAK DATABASE SCHEMA
-- Run this entire file in Supabase SQL Editor
-- Execute in a single transaction for consistency
-- ============================================================

BEGIN;

-- ============================================================
-- STEP 1: Extensions
-- ============================================================
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================
-- STEP 2: Enum Types
-- ============================================================
CREATE TYPE place_status AS ENUM ('pending', 'verified', 'rejected', 'closed');

CREATE TYPE place_category AS ENUM (
  'cafe', 'restaurant', 'mall', 'park', 'hotel', 'store', 'vet', 'grooming', 'other'
);

CREATE TYPE pet_type AS ENUM (
  'cat', 'small_dog', 'large_dog', 'rabbit', 'bird', 'all'
);

CREATE TYPE allowed_zone AS ENUM ('indoor', 'outdoor', 'both');

CREATE TYPE user_role AS ENUM ('contributor', 'editor', 'admin');

-- ============================================================
-- STEP 3: Tables
-- ============================================================

-- profiles: extends auth.users
CREATE TABLE public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT '',
  avatar_url  TEXT,
  role        user_role NOT NULL DEFAULT 'contributor',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- places: core place data
CREATE TABLE public.places (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  category        place_category NOT NULL,
  address         TEXT NOT NULL,
  location        GEOGRAPHY(POINT, 4326) NOT NULL,  -- (longitude, latitude)
  phone           TEXT,
  google_maps_url TEXT,
  instagram_url   TEXT,
  website_url     TEXT,
  status          place_status NOT NULL DEFAULT 'pending',
  submitted_by    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  verified_by     UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  verified_at     TIMESTAMPTZ,
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- pet_policies: per-place pet rules
CREATE TABLE public.pet_policies (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id        UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
  pet_type        pet_type NOT NULL,
  allowed_zone    allowed_zone NOT NULL,
  conditions      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- photos: place photos
CREATE TABLE public.photos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id    UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
  uploaded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  storage_path TEXT NOT NULL,
  is_cover    BOOLEAN NOT NULL DEFAULT FALSE,
  is_approved BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- reviews: user reviews
CREATE TABLE public.reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id    UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  visit_date  DATE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (place_id, user_id)
);

-- favorites: user-saved places
CREATE TABLE public.favorites (
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  place_id    UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, place_id)
);

-- ============================================================
-- STEP 4: Indexes
-- ============================================================
CREATE INDEX idx_places_status ON public.places(status);
CREATE INDEX idx_places_category ON public.places(category);
CREATE INDEX idx_places_location ON public.places USING GIST(location);
CREATE INDEX idx_places_submitted_by ON public.places(submitted_by);
CREATE INDEX idx_pet_policies_place_id ON public.pet_policies(place_id);
CREATE INDEX idx_photos_place_id ON public.photos(place_id);
CREATE INDEX idx_photos_is_approved ON public.photos(is_approved);
CREATE INDEX idx_reviews_place_id ON public.reviews(place_id);
CREATE INDEX idx_reviews_user_id ON public.reviews(user_id);
CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);

-- ============================================================
-- STEP 5: places_summary view
-- ============================================================
CREATE OR REPLACE VIEW public.places_summary AS
SELECT
  p.id,
  p.name,
  p.category,
  p.address,
  p.location,
  p.status,
  p.google_maps_url,
  p.verified_at,
  ROUND(AVG(r.rating)::NUMERIC, 1)  AS avg_rating,
  COUNT(DISTINCT r.id)               AS review_count,
  MIN(ph.storage_path)               AS cover_photo_path
FROM public.places p
LEFT JOIN public.reviews r  ON r.place_id = p.id
LEFT JOIN public.photos ph  ON ph.place_id = p.id AND ph.is_approved = TRUE AND ph.is_cover = TRUE
GROUP BY p.id;

-- ============================================================
-- STEP 6: Enable RLS on all tables
-- ============================================================
ALTER TABLE public.profiles   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.places     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites  ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 7: Helper function (must be before RLS policies)
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- ============================================================
-- STEP 8: RLS Policies
-- ============================================================

-- profiles
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT USING (TRUE);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- places
CREATE POLICY "Verified places are public"
  ON public.places FOR SELECT
  USING (status = 'verified' OR auth.uid() = submitted_by OR get_my_role() IN ('editor', 'admin'));

CREATE POLICY "Authenticated users can submit places"
  ON public.places FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND submitted_by = auth.uid() AND status = 'pending');

CREATE POLICY "Editors and admins can update places"
  ON public.places FOR UPDATE
  USING (get_my_role() IN ('editor', 'admin'));

CREATE POLICY "Admins can delete places"
  ON public.places FOR DELETE
  USING (get_my_role() = 'admin');

-- pet_policies
CREATE POLICY "Pet policies follow place visibility"
  ON public.pet_policies FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.places pl
      WHERE pl.id = pet_policies.place_id
        AND (pl.status = 'verified' OR auth.uid() = pl.submitted_by OR get_my_role() IN ('editor', 'admin'))
    )
  );

CREATE POLICY "Authenticated users can insert pet policies"
  ON public.pet_policies FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Editors and admins can update pet policies"
  ON public.pet_policies FOR UPDATE
  USING (get_my_role() IN ('editor', 'admin'));

CREATE POLICY "Editors and admins can delete pet policies"
  ON public.pet_policies FOR DELETE
  USING (get_my_role() IN ('editor', 'admin'));

-- photos
CREATE POLICY "Approved photos are public"
  ON public.photos FOR SELECT
  USING (is_approved = TRUE OR auth.uid() = uploaded_by OR get_my_role() IN ('editor', 'admin'));

CREATE POLICY "Authenticated users can upload photos"
  ON public.photos FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND uploaded_by = auth.uid());

CREATE POLICY "Editors and admins can approve photos"
  ON public.photos FOR UPDATE
  USING (get_my_role() IN ('editor', 'admin'));

CREATE POLICY "Editors and admins can delete photos"
  ON public.photos FOR DELETE
  USING (get_my_role() IN ('editor', 'admin'));

-- reviews
CREATE POLICY "Reviews are public"
  ON public.reviews FOR SELECT USING (TRUE);

CREATE POLICY "Authenticated users can insert reviews"
  ON public.reviews FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND user_id = auth.uid());

CREATE POLICY "Users can update their own reviews"
  ON public.reviews FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews"
  ON public.reviews FOR DELETE
  USING (auth.uid() = user_id);

-- favorites
CREATE POLICY "Users can view their own favorites"
  ON public.favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own favorites"
  ON public.favorites FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND user_id = auth.uid());

CREATE POLICY "Users can delete their own favorites"
  ON public.favorites FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- STEP 9: handle_new_user trigger (attached to auth.users)
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

COMMIT;
