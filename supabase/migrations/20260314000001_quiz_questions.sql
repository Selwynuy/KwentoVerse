create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories(id) on delete cascade,
  stage text not null check (stage in ('activity', 'abstraction', 'application', 'assessment')),
  prompt text not null,
  options jsonb not null default '[]'::jsonb,
  correct_index int not null default 0,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create index idx_quiz_questions_story_id on public.quiz_questions(story_id);
create index idx_quiz_questions_story_stage on public.quiz_questions(story_id, stage);

-- Educators (uploader) can insert/update/delete their own story's questions.
-- Students can read questions for stories they have access to.
alter table public.quiz_questions enable row level security;

create policy "Educators manage own story questions"
  on public.quiz_questions
  for all
  using (
    exists (
      select 1 from public.stories s
      where s.id = quiz_questions.story_id
        and s.uploader_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.stories s
      where s.id = quiz_questions.story_id
        and s.uploader_id = auth.uid()
    )
  );

create policy "Students read questions"
  on public.quiz_questions
  for select
  using (auth.role() = 'authenticated');
