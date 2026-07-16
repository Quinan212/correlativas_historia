create extension if not exists pgcrypto;

create table if not exists public.matter_reviews (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  matter_id text not null,
  career_id text not null,
  rating int not null check (rating between 1 and 5),
  tags text[] not null default '{}',
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (device_id, matter_id)
);

create table if not exists public.teacher_reviews (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  teacher_id text not null,
  matter_id text not null,
  career_id text not null,
  general_rating int not null check (general_rating between 1 and 5),
  explica_rating int not null default 0 check (explica_rating between 0 and 5),
  claridad_rating int not null default 0 check (claridad_rating between 0 and 5),
  exigencia_rating int not null default 0 check (exigencia_rating between 0 and 5),
  trato_rating int not null default 0 check (trato_rating between 0 and 5),
  organizacion_rating int not null default 0 check (organizacion_rating between 0 and 5),
  recomendacion_rating int not null default 0 check (recomendacion_rating between 0 and 5),
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (device_id, teacher_id, matter_id)
);

alter table public.matter_reviews replica identity full;
alter table public.teacher_reviews replica identity full;

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'matter_reviews'
  ) then
    alter publication supabase_realtime add table public.matter_reviews;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'teacher_reviews'
  ) then
    alter publication supabase_realtime add table public.teacher_reviews;
  end if;
end $$;

alter table public.matter_reviews enable row level security;
alter table public.teacher_reviews enable row level security;

drop policy if exists "matter_reviews_select_all" on public.matter_reviews;
drop policy if exists "matter_reviews_insert_all" on public.matter_reviews;
drop policy if exists "matter_reviews_update_all" on public.matter_reviews;
drop policy if exists "teacher_reviews_select_all" on public.teacher_reviews;
drop policy if exists "teacher_reviews_insert_all" on public.teacher_reviews;
drop policy if exists "teacher_reviews_update_all" on public.teacher_reviews;

create policy "matter_reviews_select_all"
on public.matter_reviews
for select
to anon, authenticated
using (true);

create policy "matter_reviews_insert_all"
on public.matter_reviews
for insert
to anon, authenticated
with check (true);

create policy "matter_reviews_update_all"
on public.matter_reviews
for update
to anon, authenticated
using (true)
with check (true);

create policy "teacher_reviews_select_all"
on public.teacher_reviews
for select
to anon, authenticated
using (true);

create policy "teacher_reviews_insert_all"
on public.teacher_reviews
for insert
to anon, authenticated
with check (true);

create policy "teacher_reviews_update_all"
on public.teacher_reviews
for update
to anon, authenticated
using (true)
with check (true);
