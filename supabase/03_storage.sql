-- ============================================================
-- TAPAK STORAGE CONFIGURATION
-- Run after 01_schema.sql
-- Configure the place-photos storage bucket
-- ============================================================

-- Create the storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('place-photos', 'place-photos', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload photos
CREATE POLICY "Authenticated users can upload photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'place-photos'
    AND auth.uid() IS NOT NULL
  );

-- Allow public read of all photos in bucket
CREATE POLICY "Public can read place photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'place-photos');

-- Allow editors/admins to delete photos
CREATE POLICY "Editors and admins can delete photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'place-photos'
    AND public.get_my_role() IN ('editor', 'admin')
  );
