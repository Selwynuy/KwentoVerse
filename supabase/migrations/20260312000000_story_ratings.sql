-- Story ratings: one rating per user per story.
-- Requires public.stories to exist (e.g. from educator/story management).

create table if not exists public.story_ratings (
  story_id uuid not null references public.stories(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating smallint not null check (rating >= 1 and rating <= 5),
  created_at timestamptz not null default now(),
  primary key (story_id, user_id)
);

-- Index for "my rating" lookups and for computing averages per story
create index if not exists idx_story_ratings_story_id
  on public.story_ratings(story_id);

alter table public.story_ratings enable row level security;

create policy "Users can read own ratings"
  on public.story_ratings for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own rating"
  on public.story_ratings for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own rating"
  on public.story_ratings for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Optional: cache average on stories for fast display
alter table public.stories
  add column if not exists average_rating numeric(3,2);

-- Trigger: keep stories.average_rating in sync when story_ratings change
create or replace function public.sync_story_average_rating()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  s_id uuid;
begin
  if tg_op = 'DELETE' then
    s_id := old.story_id;
  else
    s_id := new.story_id;
  end if;
  update public.stories
  set average_rating = (
    select round(avg(rating)::numeric, 2)
    from public.story_ratings
    where story_id = s_id
  )
  where id = s_id;
  return coalesce(new, old);
end;
$$;

drop trigger if exists story_ratings_sync_avg on public.story_ratings;
create trigger story_ratings_sync_avg
  after insert or update or delete on public.story_ratings
  for each row execute function public.sync_story_average_rating();

-- Backfill existing stories with current average (optional)
update public.stories s
set average_rating = (
  select round(avg(r.rating)::numeric, 2)
  from public.story_ratings r
  where r.story_id = s.id
)
where exists (select 1 from public.story_ratings r where r.story_id = s.id);
