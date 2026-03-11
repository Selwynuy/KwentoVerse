-- Ensure profiles.school_id exists AND has a proper FK to schools(id).
-- This is required for PostgREST relationship discovery (embedded selects).

-- Column (idempotent)
alter table public.profiles
  add column if not exists school_id uuid;

-- FK (idempotent via DO block)
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_school_id_fkey'
  ) then
    alter table public.profiles
      add constraint profiles_school_id_fkey
      foreign key (school_id)
      references public.schools(id)
      on delete set null;
  end if;
end $$;

