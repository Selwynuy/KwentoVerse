-- Join table: which educators/principals belong to which school.
create table if not exists public.school_educators (
  school_id uuid not null references public.schools(id) on delete cascade,
  user_id   uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (school_id, user_id)
);

create index if not exists idx_school_educators_school_id on public.school_educators(school_id);
create index if not exists idx_school_educators_user_id  on public.school_educators(user_id);

alter table public.school_educators enable row level security;

-- Authenticated users can read (needed for co-educator display).
create policy "Authenticated users can read school_educators"
  on public.school_educators for select
  using (auth.role() = 'authenticated');

-- Educators/principals insert themselves on enrollment.
create policy "Educators can enroll themselves"
  on public.school_educators for insert
  with check (auth.uid() = user_id);

-- Principals can remove educators from their school.
create policy "Principals can remove school educators"
  on public.school_educators for delete
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = school_educators.school_id
    )
  );

-- Backfill: add any existing educators/principals who have a school_id in profiles.
insert into public.school_educators (school_id, user_id)
select school_id, id
from public.profiles
where role in ('educator', 'principal')
  and school_id is not null
on conflict do nothing;
