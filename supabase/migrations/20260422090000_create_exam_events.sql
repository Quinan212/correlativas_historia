create extension if not exists pgcrypto;

create table if not exists public.exam_events (
  id uuid primary key default gen_random_uuid(),
  career_id text not null,
  anio integer,
  fecha date,
  hora time,
  materia text not null,
  instancia text not null check (instancia in ('llamado_1', 'llamado_2', 'coloquio')),
  docentes text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists exam_events_instancia_idx
  on public.exam_events (instancia);

create index if not exists exam_events_career_id_idx
  on public.exam_events (career_id);

create index if not exists exam_events_fecha_idx
  on public.exam_events (fecha);

create or replace function public.set_exam_events_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_exam_events_updated_at on public.exam_events;

create trigger trg_exam_events_updated_at
before update on public.exam_events
for each row
execute function public.set_exam_events_updated_at();

alter table public.exam_events enable row level security;

drop policy if exists "exam_events_select_all" on public.exam_events;

create policy "exam_events_select_all"
on public.exam_events
for select
to anon, authenticated
using (true);
