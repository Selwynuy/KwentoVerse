-- Fix PostgREST embedding: school_educators(user_id) must relate to public.profiles(id)
-- so queries like: select user_id, profiles(full_name) work.

alter table public.school_educators
  drop constraint if exists school_educators_user_id_fkey;

alter table public.school_educators
  add constraint school_educators_user_id_fkey
  foreign key (user_id) references public.profiles(id) on delete cascade;

