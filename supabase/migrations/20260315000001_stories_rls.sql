-- Ensure RLS is enabled on stories (idempotent).
alter table public.stories enable row level security;

-- Drop and re-create the principal delete policy cleanly to avoid conflicts.
drop policy if exists "Principals can delete stories in their school" on public.stories;
drop policy if exists "Principals can update stories in their school" on public.stories;
drop policy if exists "Educators can insert stories" on public.stories;
drop policy if exists "Authenticated users can read stories" on public.stories;

-- SELECT: any authenticated user can read stories.
create policy "Authenticated users can read stories"
  on public.stories
  for select
  using (auth.role() = 'authenticated');

-- INSERT: educators and principals can upload stories.
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

-- UPDATE: uploader can edit their own story; principal can edit any school story.
create policy "Uploader or principal can update story"
  on public.stories
  for update
  using (
    uploader_id = auth.uid()
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = stories.school_id
    )
  )
  with check (
    uploader_id = auth.uid()
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.role = 'principal'
        and p.school_id = stories.school_id
    )
  );

-- DELETE: only principals can delete stories in their school.
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
