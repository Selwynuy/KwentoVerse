-- Add avatar_index to profiles to persist student avatar choice.
alter table public.profiles
  add column if not exists avatar_index smallint;

