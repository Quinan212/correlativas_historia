create extension if not exists pgcrypto;

create table if not exists public.matter_navigation_events (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  event_type text not null,
  surface text not null default 'detail_modal',
  career_id text not null,
  matter_id text not null,
  matter_name text not null,
  source_career_id text,
  source_matter_id text,
  source_matter_name text,
  created_at timestamptz not null default now()
);

create index if not exists matter_navigation_events_device_id_idx
  on public.matter_navigation_events (device_id);

create index if not exists matter_navigation_events_matter_id_idx
  on public.matter_navigation_events (matter_id);

create index if not exists matter_navigation_events_career_id_idx
  on public.matter_navigation_events (career_id);

create index if not exists matter_navigation_events_created_at_idx
  on public.matter_navigation_events (created_at desc);

alter table public.matter_navigation_events enable row level security;
alter table public.matter_navigation_events replica identity full;

drop policy if exists "matter_navigation_events_select_all" on public.matter_navigation_events;
drop policy if exists "matter_navigation_events_insert_all" on public.matter_navigation_events;

create policy "matter_navigation_events_select_all"
on public.matter_navigation_events
for select
to anon, authenticated
using (true);

create policy "matter_navigation_events_insert_all"
on public.matter_navigation_events
for insert
to anon, authenticated
with check (true);
