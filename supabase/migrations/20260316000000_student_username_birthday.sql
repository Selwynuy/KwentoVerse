-- Student auth: username (unique) and birthday on profiles.
-- Only students use username; educators leave it null.

alter table public.profiles
  add column if not exists username text;

alter table public.profiles
  add column if not exists birthday date;

create unique index if not exists profiles_username_key
  on public.profiles (username)
  where username is not null;
