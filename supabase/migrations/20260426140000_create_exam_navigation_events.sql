create extension if not exists pgcrypto;

create table if not exists public.exam_navigation_events (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  event_type text not null,
  surface text not null default 'sheet',
  career_id text not null,
  matter_name text not null,
  tab_id text not null,
  tab_label text not null,
  division_id text,
  division_label text,
  source_career_id text,
  source_tab_id text,
  source_tab_label text,
  source_division_id text,
  source_division_label text,
  created_at timestamptz not null default now()
);

create index if not exists exam_navigation_events_device_id_idx
  on public.exam_navigation_events (device_id);

create index if not exists exam_navigation_events_career_id_idx
  on public.exam_navigation_events (career_id);

create index if not exists exam_navigation_events_matter_name_idx
  on public.exam_navigation_events (matter_name);

create index if not exists exam_navigation_events_created_at_idx
  on public.exam_navigation_events (created_at desc);

alter table public.exam_navigation_events enable row level security;
alter table public.exam_navigation_events replica identity full;

drop policy if exists "exam_navigation_events_select_all" on public.exam_navigation_events;
drop policy if exists "exam_navigation_events_insert_all" on public.exam_navigation_events;

create policy "exam_navigation_events_select_all"
on public.exam_navigation_events
for select
to anon, authenticated
using (true);

create policy "exam_navigation_events_insert_all"
on public.exam_navigation_events
for insert
to anon, authenticated
with check (true);
