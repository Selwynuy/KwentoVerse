-- Schools table for student enrollment
create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

-- Add school_id to profiles for student (and educator) school association
alter table public.profiles
  add column if not exists school_id uuid references public.schools(id);

-- RLS: schools - authenticated users can read
alter table public.schools enable row level security;

create policy "Authenticated users can read schools"
  on public.schools for select
  to authenticated
  using (true);

-- RLS: profiles - allow user to update own row (for setting school_id on enroll)
create policy "Users can update own profile for enrollment"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Seed example school (idempotent)
insert into public.schools (name)
select 'GSC SPED Integrated School'
where not exists (select 1 from public.schools where name = 'GSC SPED Integrated School');
