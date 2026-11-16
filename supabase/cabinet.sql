-- Кабинет родителя: выполните в Supabase -> SQL Editor -> New query -> Run
-- Снимок данных одного ученика, доступный по секретной ссылке без входа.
create table if not exists public.cabinets (
  token      text primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  student_id text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.cabinets enable row level security;

-- Репетитор управляет только своими ссылками
create policy "cab own all" on public.cabinets
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Читать по токену может любой, но только одну запись и только зная токен
create or replace function public.get_cabinet(p_token text)
returns jsonb
language sql
security definer
set search_path = public
stable
as $$
  select data from public.cabinets where token = p_token
$$;

revoke all on function public.get_cabinet(text) from public;
grant execute on function public.get_cabinet(text) to anon, authenticated;
