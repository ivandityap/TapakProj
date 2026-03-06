-- ============================================================
-- TAPAK SEED DATA
-- Run after 01_schema.sql
-- Inserts 10 sample verified places in Jakarta
-- NOTE: These are sample places for development/testing only.
-- Coordinates are approximate. Verify actual pet policies before publishing.
-- ============================================================

-- Temporarily bypass RLS for seeding (run as superuser / service_role)
SET LOCAL role = 'service_role';

INSERT INTO public.places (name, category, address, location, phone, google_maps_url, status, notes)
VALUES
  (
    'Anomali Coffee Kemang',
    'cafe',
    'Jl. Kemang Raya No.81, Bangka, Mampang Prapatan, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.8156 -6.2641)'),
    '+62 21 7179 0055',
    'https://maps.google.com/?q=Anomali+Coffee+Kemang',
    'verified',
    'Pet-friendly outdoor seating area. Dogs allowed on terrace.'
  ),
  (
    'Hutan Kota Srengseng',
    'park',
    'Jl. Srengseng, Kembangan, Jakarta Barat',
    ST_GeogFromText('SRID=4326;POINT(106.7617 -6.2112)'),
    NULL,
    'https://maps.google.com/?q=Hutan+Kota+Srengseng',
    'verified',
    'Public urban forest. All pets welcome on leash.'
  ),
  (
    'Taman Menteng',
    'park',
    'Jl. HOS. Cokroaminoto, Menteng, Jakarta Pusat',
    ST_GeogFromText('SRID=4326;POINT(106.8327 -6.2024)'),
    NULL,
    'https://maps.google.com/?q=Taman+Menteng+Jakarta',
    'verified',
    'Well-maintained city park. Pets allowed on leash.'
  ),
  (
    'Drip Coffee Bar',
    'cafe',
    'Jl. Cipete Raya No.13, Cipete, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.8012 -6.2812)'),
    '+62 812 9988 7766',
    'https://maps.google.com/?q=Drip+Coffee+Bar+Cipete',
    'verified',
    'Small dogs allowed at outdoor seating. Cats welcome.'
  ),
  (
    'Hoppity Grooming Studio',
    'grooming',
    'Jl. Warung Buncit Raya No.22, Kalibata, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.8443 -6.2714)'),
    '+62 21 7994 3321',
    'https://maps.google.com/?q=Hoppity+Grooming+Jakarta',
    'verified',
    'Dog and cat grooming. Rabbits on appointment.'
  ),
  (
    'Klinik Hewan Kebayoran',
    'vet',
    'Jl. Panglima Polim V No.45, Kebayoran Baru, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.7957 -6.2499)'),
    '+62 21 7221 8832',
    'https://maps.google.com/?q=Klinik+Hewan+Kebayoran',
    'verified',
    'Full-service veterinary clinic. All pet types accepted.'
  ),
  (
    'The Goods Dept Pet Corner',
    'store',
    'Plaza Indonesia, Jl. M.H. Thamrin No.28-30, Jakarta Pusat',
    ST_GeogFromText('SRID=4326;POINT(106.8228 -6.1935)'),
    '+62 21 3193 8919',
    'https://maps.google.com/?q=The+Goods+Dept+Plaza+Indonesia',
    'verified',
    'Pet-friendly retail store. Small pets in carriers allowed inside mall.'
  ),
  (
    'Nusa Dua Cafe Kemang',
    'cafe',
    'Jl. Kemang Timur No.14, Bangka, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.8221 -6.2698)'),
    '+62 21 7179 6677',
    'https://maps.google.com/?q=Nusa+Dua+Cafe+Kemang',
    'verified',
    'Large outdoor area. Dogs and cats welcome. Water bowls provided.'
  ),
  (
    'The Westin Jakarta',
    'hotel',
    'Jl. H.R. Rasuna Said Kav. C-22A, Kuningan, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.8310 -6.2236)'),
    '+62 21 5090 3888',
    'https://maps.google.com/?q=The+Westin+Jakarta',
    'verified',
    'Pet-friendly hotel. Dogs up to 20kg allowed. Pet amenities available. Fee applies.'
  ),
  (
    'Pasar Santa',
    'mall',
    'Jl. Wolter Monginsidi No.99, Kebayoran Baru, Jakarta Selatan',
    ST_GeogFromText('SRID=4326;POINT(106.7968 -6.2418)'),
    NULL,
    'https://maps.google.com/?q=Pasar+Santa+Jakarta',
    'verified',
    'Hipster market. Pet-friendly common areas. Small pets on leash allowed.'
  );

-- Insert pet policies for each place
-- Anomali Coffee Kemang (index 1)
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'small_dog', 'outdoor', 'Must be on leash at all times'
FROM public.places WHERE name = 'Anomali Coffee Kemang';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'large_dog', 'outdoor', 'Must be on leash. Max 2 dogs per table'
FROM public.places WHERE name = 'Anomali Coffee Kemang';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'cat', 'outdoor', 'Must be in carrier or on harness'
FROM public.places WHERE name = 'Anomali Coffee Kemang';

-- Hutan Kota Srengseng (park)
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'all', 'outdoor', 'All pets welcome on leash'
FROM public.places WHERE name = 'Hutan Kota Srengseng';

-- Taman Menteng (park)
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'all', 'outdoor', 'Pets must be on leash'
FROM public.places WHERE name = 'Taman Menteng';

-- Drip Coffee Bar
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'small_dog', 'outdoor', 'Small dogs under 10kg only'
FROM public.places WHERE name = 'Drip Coffee Bar';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'cat', 'both', 'Cats in carrier allowed inside'
FROM public.places WHERE name = 'Drip Coffee Bar';

-- Hoppity Grooming Studio
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'small_dog', 'indoor', 'Grooming appointment required'
FROM public.places WHERE name = 'Hoppity Grooming Studio';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'cat', 'indoor', 'Cat-only grooming slots available'
FROM public.places WHERE name = 'Hoppity Grooming Studio';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'rabbit', 'indoor', 'By appointment only'
FROM public.places WHERE name = 'Hoppity Grooming Studio';

-- Klinik Hewan Kebayoran
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'all', 'indoor', 'All pets accepted. Carrier or leash required'
FROM public.places WHERE name = 'Klinik Hewan Kebayoran';

-- The Goods Dept Pet Corner
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'cat', 'indoor', 'Must be in carrier'
FROM public.places WHERE name = 'The Goods Dept Pet Corner';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'small_dog', 'indoor', 'Small dogs in carrier only'
FROM public.places WHERE name = 'The Goods Dept Pet Corner';

-- Nusa Dua Cafe Kemang
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'all', 'outdoor', 'All pets welcome at outdoor tables. Water bowls provided'
FROM public.places WHERE name = 'Nusa Dua Cafe Kemang';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'cat', 'indoor', 'Cats in carrier allowed inside'
FROM public.places WHERE name = 'Nusa Dua Cafe Kemang';

-- The Westin Jakarta
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'small_dog', 'indoor', 'Under 10kg. Rp 250,000/night pet fee'
FROM public.places WHERE name = 'The Westin Jakarta';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'large_dog', 'indoor', 'Up to 20kg. Rp 500,000/night pet fee. Prior approval required'
FROM public.places WHERE name = 'The Westin Jakarta';

-- Pasar Santa
INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'small_dog', 'both', 'On leash. Not allowed in food stalls'
FROM public.places WHERE name = 'Pasar Santa';

INSERT INTO public.pet_policies (place_id, pet_type, allowed_zone, conditions)
SELECT id, 'cat', 'both', 'On harness or in carrier'
FROM public.places WHERE name = 'Pasar Santa';
