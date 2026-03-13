-- ── Archived flag on stories ─────────────────────────────────────────────────
alter table public.stories
  add column if not exists is_archived boolean not null default false;

-- Students only see non-archived stories (filter enforced in app queries).
-- Educators and principals can see all stories for their school.

-- ── Revoked flag on profiles ──────────────────────────────────────────────────
alter table public.profiles
  add column if not exists is_revoked boolean not null default false;

-- ── RLS: principals can archive/delete stories in their school ────────────────
-- Principals share the educator shell and their school_id is stored in profiles.

create policy "Principals can update stories in their school"
  on public.stories
  for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = stories.school_id
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = stories.school_id
    )
  );

create policy "Principals can delete stories in their school"
  on public.stories
  for delete
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = stories.school_id
    )
  );

-- ── RLS: principals can revoke/restore educators in their school ──────────────
create policy "Principals can update educator profiles in their school"
  on public.profiles
  for update
  using (
    -- The principal updates someone else's profile in the same school
    auth.uid() != id
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = profiles.school_id
    )
  )
  with check (
    auth.uid() != id
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = profiles.school_id
    )
  );

-- ── Educators can insert their own stories ────────────────────────────────────
-- (Allows uploader to insert if no prior insert policy exists.)
create policy "Educators can insert stories"
  on public.stories
  for insert
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role in ('educator', 'principal')
    )
  );

-- ── Authenticated users can read all non-archived stories in their school ─────
-- App-side filtering handles archived visibility per role;
-- RLS allows reading all stories for authenticated users.
create policy "Authenticated users can read stories"
  on public.stories
  for select
  using (auth.role() = 'authenticated');
