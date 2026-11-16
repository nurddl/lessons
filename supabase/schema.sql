-- Выполните этот скрипт в Supabase: SQL Editor -> New query -> Run
create table if not exists public.tutor_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.tutor_data enable row level security;

-- Каждый пользователь видит и меняет только свою строку
create policy "own select" on public.tutor_data for select using (auth.uid() = user_id);
create policy "own insert" on public.tutor_data for insert with check (auth.uid() = user_id);
create policy "own update" on public.tutor_data for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own delete" on public.tutor_data for delete using (auth.uid() = user_id);
