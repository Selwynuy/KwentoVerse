-- Quiz/evaluation results: one row per attempt. Latest per (user, story) used for progress.
-- stage_scores: jsonb array e.g. [{"stage":"Activity","correct":3,"total":3}, ...]

create table if not exists public.quiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  story_id uuid not null references public.stories(id) on delete cascade,
  total_correct int not null check (total_correct >= 0),
  total_questions int not null check (total_questions > 0),
  stage_scores jsonb not null default '[]'::jsonb,
  attempted_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

comment on column public.quiz_results.stage_scores is 'Array of {stage: string, correct: int, total: int}';

create index if not exists idx_quiz_results_user_id on public.quiz_results(user_id);
create index if not exists idx_quiz_results_story_id on public.quiz_results(story_id);
create index if not exists idx_quiz_results_user_attempted on public.quiz_results(user_id, attempted_at desc);

alter table public.quiz_results enable row level security;

create policy "Users can read own quiz results"
  on public.quiz_results for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own quiz result"
  on public.quiz_results for insert
  to authenticated
  with check (auth.uid() = user_id);

-- No update/delete policy: we keep history; latest per story is chosen in app.
