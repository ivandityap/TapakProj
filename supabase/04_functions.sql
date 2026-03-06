-- ============================================================
-- TAPAK STORED FUNCTIONS
-- Run after 01_schema.sql
-- PostGIS-based radius search with filters
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_places_nearby(
  lat              FLOAT,
  lng              FLOAT,
  radius_meters    INT     DEFAULT 5000,
  pet_type_filter  TEXT    DEFAULT NULL,
  category_filter  TEXT    DEFAULT NULL
)
RETURNS TABLE (
  id              UUID,
  name            TEXT,
  category        place_category,
  address         TEXT,
  location        JSONB,
  phone           TEXT,
  google_maps_url TEXT,
  instagram_url   TEXT,
  website_url     TEXT,
  status          place_status,
  submitted_by    UUID,
  verified_by     UUID,
  verified_at     TIMESTAMPTZ,
  notes           TEXT,
  created_at      TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ,
  avg_rating      NUMERIC,
  review_count    BIGINT,
  cover_photo_path TEXT,
  distance_meters FLOAT,
  pet_policies    JSONB
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.name,
    p.category,
    p.address,
    ST_AsGeoJSON(p.location)::JSONB AS location,
    p.phone,
    p.google_maps_url,
    p.instagram_url,
    p.website_url,
    p.status,
    p.submitted_by,
    p.verified_by,
    p.verified_at,
    p.notes,
    p.created_at,
    p.updated_at,
    ROUND(AVG(r.rating)::NUMERIC, 1)   AS avg_rating,
    COUNT(DISTINCT r.id)               AS review_count,
    MIN(ph.storage_path)               AS cover_photo_path,
    ST_Distance(
      p.location,
      ST_GeogFromText('SRID=4326;POINT(' || lng || ' ' || lat || ')')
    )                                  AS distance_meters,
    COALESCE(
      json_agg(
        DISTINCT jsonb_build_object(
          'id',           pp.id,
          'place_id',     pp.place_id,
          'pet_type',     pp.pet_type,
          'allowed_zone', pp.allowed_zone,
          'conditions',   pp.conditions,
          'created_at',   pp.created_at
        )
      ) FILTER (WHERE pp.id IS NOT NULL),
      '[]'::JSONB
    )                                  AS pet_policies
  FROM public.places p
  LEFT JOIN public.reviews r  ON r.place_id = p.id
  LEFT JOIN public.photos ph  ON ph.place_id = p.id
                              AND ph.is_approved = TRUE
                              AND ph.is_cover = TRUE
  LEFT JOIN public.pet_policies pp ON pp.place_id = p.id
  WHERE
    p.status = 'verified'
    AND ST_DWithin(
      p.location,
      ST_GeogFromText('SRID=4326;POINT(' || lng || ' ' || lat || ')'),
      radius_meters
    )
    AND (
      category_filter IS NULL
      OR p.category::TEXT = category_filter
    )
    AND (
      pet_type_filter IS NULL
      OR EXISTS (
        SELECT 1 FROM public.pet_policies pp2
        WHERE pp2.place_id = p.id
          AND (pp2.pet_type::TEXT = pet_type_filter OR pp2.pet_type::TEXT = 'all')
      )
    )
  GROUP BY p.id
  ORDER BY distance_meters;
END;
$$;
