create extension if not exists pgcrypto;

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  push_token text not null unique,
  platform text not null default 'android',
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  unique (device_id, push_token)
);

create index if not exists device_push_tokens_device_id_idx
  on public.device_push_tokens (device_id);

create index if not exists device_push_tokens_enabled_idx
  on public.device_push_tokens (enabled);

alter table public.device_push_tokens enable row level security;
alter table public.device_push_tokens replica identity full;

drop policy if exists "device_push_tokens_select_all" on public.device_push_tokens;
drop policy if exists "device_push_tokens_insert_all" on public.device_push_tokens;
drop policy if exists "device_push_tokens_update_all" on public.device_push_tokens;

create policy "device_push_tokens_select_all"
on public.device_push_tokens
for select
to anon, authenticated
using (true);

create policy "device_push_tokens_insert_all"
on public.device_push_tokens
for insert
to anon, authenticated
with check (true);

create policy "device_push_tokens_update_all"
on public.device_push_tokens
for update
to anon, authenticated
using (true)
with check (true);
