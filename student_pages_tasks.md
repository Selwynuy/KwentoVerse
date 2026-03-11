## Student Pages – Task Breakdown

This file maps each **student-facing page** to the PRD and breaks it into concrete tasks.

Legend:
- **PRD Routes** → Section 8 Routing
- **PRD Epics** → Section 12 Epics (C, D, E, F, G, H, etc.)

---

## 1. Student Navigation & Shell

- **Related routes**: `/student/home`, `/student/library`, `/student/search`, `/student/profile`
- **PRD routes**: Student shell (Section 8)
- **PRD epics**: A4 (routing skeleton), H3 (student progress screens)

**Tasks**
- [x] Bottom nav items wired to `/student/library`, `/student/home`, `/student/search`
- [x] Hamburger menu links to `/student/profile`, `/student/progress` (notifications can be added later if needed)
- [x] Hamburger menu opened state: top section with avatar, name, level, and progress bar (placeholder; real progress/levels to be wired in H1–H3)
- [x] Hook shell into `authControllerProvider` for logout and basic profile display (name, level, avatar)
- [x] Match student shell and navbar to design (KwentoVerse title, progress bar, badge placeholder, orange/cream theme)

---

## 2. Student Home Page (My School)

- **Route**: `/student/home`
- **PRD routes**: Student home
- **PRD epics**: C1–C3 (story library/details), D2–D3 (position/completion), H1–H3 (points/levels/badges)

**Scope (design-aligned)**
- School card (school name, placeholder)
- Educator section with horizontal list and "See More"
- School Library search bar
- Book grid (placeholder)

**Tasks**
- [x] School card with icon and placeholder school name (e.g. GSC SPED Integrated School)
- [x] Educator section: "See More →" + horizontal scroll of educator avatars and names (placeholder)
- [x] School Library heading + search bar (placeholder; non-functional for now)
- [x] Book grid with cover placeholders and titles (placeholder data)
- [ ] Wire school name from enrollment/school data
- [ ] Wire educators from API; wire "See More" and search to real flows
- [ ] Wire book grid to school-scoped stories

---

## 3. Story Library Page

- **Route**: `/student/library`
- **PRD routes**: Story Library
- **PRD epics**: C1 (stories API + caching), C2 (library UI), C3 (story details)

**Scope (design-aligned)**
- Home / Notifications segment; Home tab: Current readings (horizontal), Exercises (vertical + "See More"); Notifications tab: placeholder list (Today / Earlier)

**Tasks**
- [x] Home / Notifications segment control on Library route (orange/cream theme)
- [x] Current readings: horizontal list of orange cards (cover placeholder, title, author, progress) with placeholder data
- [x] Exercises: section with "See More →" and vertical list of same-style cards (placeholder data)
- [x] Notifications tab: placeholder (Today / Earlier sections with sample notification items)
- [ ] Fetch school-scoped stories (`stories` + `story_access` with `school_id`)
- [ ] Implement paginated list with status chip (not started / in progress / completed)
- [ ] Add search by title (local filter first; later server-backed)
- [ ] Add optional filters (difficulty, category/tags)
- [ ] Wire story tap → `/student/story/:id`
- [ ] Cache story list for offline reopen (Hive/Isar or Supabase cache strategy)

---

## 3a. Student Search Page

- **Route**: `/student/search`
- **PRD routes**: Search (student)
- **PRD epics**: C1–C2 (library/search)

**Tasks**
- [x] Search bar with placeholder "Search for books" (UI only; no backend yet)
- [x] 2-column book grid with cover placeholders and titles (placeholder data)
- [ ] Wire search to story API / local filter
- [ ] Wire grid to real story list

---

## 4. Story Details Page

- **Route**: `/student/story/:id`
- **PRD routes**: Story details
- **PRD epics**: C3 (story details), D3 (completion CTA), G5 (evaluation access)

**Scope from you**
- Story cover
- Description
- Difficulty
- Start reading button

**Tasks**
- [ ] Load story metadata by `:id` (title, summary, cover, difficulty, estimated length)
- [ ] Show reading status and last progress (e.g., “Continue from paragraph X”)
- [ ] Primary CTA: “Start Reading” or “Continue Reading” → `/student/reader/:id`
- [ ] Secondary CTA: “View Evaluation” only when `is_enabled_for_evaluation = true` and completion met
- [ ] Handle archived/disabled story with friendly error UI

---

## 5. Reader Page

- **Route**: `/student/reader/:id`
- **PRD routes**: Reader
- **PRD epics**: D1–D3 (reader), E1–E3 (TTS), F1–F3 (dictionary)

**Scope from you**
- Story text
- TTS button
- Tap word → dictionary
- Bookmark
- Progress bar

**Tasks**
- [ ] Render `content_text` segmented into paragraphs (D1)
- [ ] Persist reading position (paragraph index + offset) and restore on open (D2)
- [ ] Progress bar based on paragraph index / story length (D3)
- [ ] Integrate TTS toolbar: play/pause/stop, adjustable rate, continuous read (E1–E2)
- [ ] (Should) Long-press sentence read aloud (E3)
- [ ] Word tap detection, token normalization, and dictionary lookup trigger (F1–F2)
- [ ] Bookmark support (per-story, maybe multiple bookmarks later)
- [ ] Trigger “completion” flow near end (explicit “Complete story?” CTA) → evaluation option

---

## 6. Dictionary Popup / Page

- **Invocation**: From Reader word tap
- **PRD routes**: Not separate route in PRD (bottom sheet/popup under Reader)
- **PRD epics**: F1–F3 (dictionary)

**Scope from you**
- word
- meaning
- pronunciation
- example

**Tasks**
- [ ] Design a bottom sheet (or dialog) showing word, meaning, example, and pronunciation if available
- [ ] Normalize tokens: strip punctuation, lowercase, handle hyphenation (F1)
- [ ] Query dictionary source (`dictionary_terms` table or local seed) and cache results (F3)
- [ ] Handle “not found” gracefully with fallback text
- [ ] Track dictionary_opened(word) + cache_hit events (Section 9 analytics)

---

## 7. Evaluation Page (Question Flow)

- **Route**: `/student/evaluation/:storyId/:type`
- **PRD routes**: Evaluation per stage (Activity/Abstraction/Application/Assessment)
- **PRD epics**: G1–G6 (evaluation engine)

**Scope from you**
- Activity questions
- Abstraction
- Application
- Assessment

**Tasks**
- [ ] Support `:type` values = `activity`, `abstraction`, `application`, `assessment`
- [ ] Load questions for given `storyId` + stage and enforce counts (3/1/1/10) from schema (G1, G3)
- [ ] MCQ UI component with A–D choices, next/previous navigation (G2)
- [ ] Persist answers per question locally and/or server-side as you go (G4)
- [ ] Respect `is_enabled_for_evaluation` at story/school level (G5)
- [ ] Optional gating: only allow later stages when previous stage completed (G6)
- [ ] On completion, compute per-stage score and total score and navigate to result page

---

## 8. Evaluation Result Page

- **Route**: (Can be subroute or same page state, e.g. `/student/evaluation/:storyId/result`)
- **PRD routes**: Not explicit; implied in evaluations + progress epics
- **PRD epics**: G4 (submission + scoring), H1–H3 (points/badges), H4 (reward moment – “should”)

**Scope from you**
- Score
- correct answers
- points earned
- retry button

**Tasks**
- [ ] Show per-stage scores + total score from persisted evaluation result
- [ ] Summarize correct/incorrect counts and optionally show question breakdown
- [ ] Show points earned from this evaluation and updated total points (H1)
- [ ] Trigger badge/level unlock check and show reward modal/animation if unlocked (H2–H4)
- [ ] “Retry” button wired according to retry policy (open PRD decision: unlimited vs cooldown etc.)
- [ ] CTA back to progress page or library

---

## 9. Progress Page

- **Route**: `/student/progress`
- **PRD routes**: Student progress
- **PRD epics**: H1–H3 (progress + gamification), H4 (reward modal), C1/C3 (story completion info)

**Scope from you**
- stories completed
- reading streak
- total points
- average score

**Tasks**
- [ ] Fetch aggregate metrics: total points, completed stories count, average evaluation scores
- [ ] Show reading streak (days with at least one read event) if tracked (H2 “should”)
- [ ] List recent stories with score summaries
- [ ] Link into detailed evaluation history per story if available
- [ ] Surface unlocked badges/levels and link to Badges page

---

## 10. Badges Page

- **Route**: `/student/badges`
- **PRD routes**: Badges
- **PRD epics**: H2–H4 (levels + badges)

**Scope from you**
- unlocked badges
- locked badges
- level progression

**Tasks**
- [ ] Display grid/list of all badge definitions, highlighting unlocked vs locked
- [ ] Show current level, next level threshold, and progress bar
- [ ] Show unlock dates or short description for each unlocked badge
- [ ] Integrate with progress/events so that each badge only unlocks once per level (H2)
- [ ] Optionally link back to stories or actions that help unlock remaining badges

---

## 11. Student Profile Page

- **Route**: `/student/profile`
- **PRD routes**: Student profile
- **PRD epics**: H3 (progress screens), B4 (school association), onboarding/avatar selection

**Scope from you**
- avatar
- name
- school
- reading stats

**Tasks**
- [x] Show avatar with ability to change (improved modal; persists to Supabase `profiles.avatar_index`)
- [x] Fetch and display `userId` from Supabase auth (copy-to-clipboard)
- [x] Display name from `profiles.full_name` (fallback to "Student")
- [x] Display associated school name (via `profiles.school_id` → `schools`)
- [ ] Light reading stats summary: total stories read, time read, average score
- [ ] Entry points to account management (change password, etc. – can be deferred to separate flows)

---

## 12. Settings Page (Student-Focused)

- **Route**: `/settings` (global, but you listed student-specific settings)
- **PRD routes**: Settings
- **PRD epics**: E1 (TTS controls), A3 (theming), L4 (performance checks – indirectly)

**Scope from you**
- TTS speed
- theme
- logout

**Tasks**
- [ ] TTS speed slider hooked to persisted user preference and used in Reader’s TTS engine
- [ ] Theme toggle (light/dark or font-size scaling) integrated with app theme system
- [ ] Logout action wired to `authControllerProvider.notifier.logout()` and redirects to `/login`
- [ ] Optional: language/accessibility settings (bigger text, dyslexia-friendly font)

---

## 13. Enrollment Page (after avatar)

- **Route**: `/student/enroll`
- **PRD routes**: Not explicit; fits onboarding after avatar
- **PRD epics**: B4 (school association), onboarding after avatar

**Scope**
- "You are not enrolled yet" / "My School" card
- Search bar (no dropdown) and list of schools below
- Select school from list; Enroll button enabled when selected
- On Enroll: save enrollment (Supabase), show "Student is enrolled" modal, then redirect to `/student/home`

**Tasks**
- [x] Enrollment page: "You are not enrolled yet" / "My School" card
- [x] Search bar (no dropdown) and list of schools below
- [x] Select school from list; Enroll button enabled when selected
- [x] On Enroll: save enrollment (Supabase), show "Student is enrolled" modal, then redirect to `/student/home`
- [x] If already enrolled, redirect from `/student/enroll` to `/student/home`

---

## 14. Avatar Selection Page (Extra Onboarding)

- **Route**: `/student/avatar-select`
- **PRD routes**: Not explicit; fits onboarding/profile refinement
- **PRD epics**: B1 (auth/onboarding), H3 (profile/progress UX)

**Scope (current implementation)**
- Avatar grid selection
- “Let’s Go” button → `/student/enroll`

**Tasks**
- [x] Persist chosen avatar to student profile (Supabase `profiles.avatar_index`)
- [ ] Use avatar in `StudentShell`/`StudentNavbar` (Profile page already uses it)
- [ ] Optionally gate first-time users: after login, redirect to avatar selection once

