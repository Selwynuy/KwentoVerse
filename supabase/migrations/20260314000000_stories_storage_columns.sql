-- Add columns to stories if missing (e.g. table created before these were in schema).
alter table public.stories
  add column if not exists title text,
  add column if not exists summary text,
  add column if not exists author text,
  add column if not exists genre text,
  add column if not exists isbn text,
  add column if not exists publisher text,
  add column if not exists publishing_city text,
  add column if not exists publication_date text,
  add column if not exists cover_storage_path text,
  add column if not exists content_storage_path text,
  add column if not exists school_id uuid references public.schools(id),
  add column if not exists is_copyrighted boolean,
  add column if not exists copyright_licenses text[],
  add column if not exists uploader_id uuid references auth.users(id);
