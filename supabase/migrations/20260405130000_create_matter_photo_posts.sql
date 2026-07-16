create extension if not exists pgcrypto;
insert into storage.buckets (id, name, public)
values ('matter-community-photos', 'matter-community-photos', true)
on conflict (id) do nothing;
create table if not exists public.matter_photo_posts (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  matter_id text not null,
  career_id text not null,
  image_path text not null,
  image_url text not null,
  caption text,
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists matter_photo_posts_matter_id_idx
  on public.matter_photo_posts (matter_id);
create index if not exists matter_photo_posts_enabled_idx
  on public.matter_photo_posts (enabled);
alter table public.matter_photo_posts enable row level security;
alter table public.matter_photo_posts replica identity full;
drop policy if exists "matter_photo_posts_select_all" on public.matter_photo_posts;
drop policy if exists "matter_photo_posts_insert_all" on public.matter_photo_posts;
drop policy if exists "matter-community-photos public read" on storage.objects;
drop policy if exists "matter-community-photos public insert" on storage.objects;
create policy "matter_photo_posts_select_all"
on public.matter_photo_posts
for select
to anon, authenticated
using (true);
create policy "matter_photo_posts_insert_all"
on public.matter_photo_posts
for insert
to anon, authenticated
with check (true);
create policy "matter-community-photos public read"
on storage.objects
for select
to public
using (bucket_id = 'matter-community-photos');
create policy "matter-community-photos public insert"
on storage.objects
for insert
to anon, authenticated
with check (bucket_id = 'matter-community-photos');
