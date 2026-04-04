create table if not exists public.device_profiles (
  device_id text primary key,
  device_label text not null default '',
  reference_name text,
  public_mode text not null default 'anonymous',
  public_alias text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint device_profiles_public_mode_check
    check (public_mode in ('anonymous', 'alias'))
);

alter table public.device_profiles enable row level security;
alter table public.device_profiles replica identity full;

drop policy if exists "device_profiles_select_all" on public.device_profiles;
drop policy if exists "device_profiles_insert_all" on public.device_profiles;
drop policy if exists "device_profiles_update_all" on public.device_profiles;

create policy "device_profiles_select_all"
on public.device_profiles
for select
to anon, authenticated
using (true);

create policy "device_profiles_insert_all"
on public.device_profiles
for insert
to anon, authenticated
with check (true);

create policy "device_profiles_update_all"
on public.device_profiles
for update
to anon, authenticated
using (true)
with check (true);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'device_profiles'
  ) then
    alter publication supabase_realtime add table public.device_profiles;
  end if;
end $$;

insert into public.device_profiles (
  device_id,
  device_label,
  public_mode,
  created_at,
  updated_at
)
select
  ids.device_id,
  case
    when ids.device_id like 'emu_%' then 'Android Emulator ' || replace(substring(ids.device_id from 5), '_', ' ')
    when ids.device_id like 'and_%' then 'Dispositivo Android'
    else 'Dispositivo'
  end as device_label,
  'anonymous' as public_mode,
  now(),
  now()
from (
  select device_id from public.admin_devices
  union
  select device_id from public.verification_requests
  union
  select reviewed_by_device_id as device_id from public.verification_requests where reviewed_by_device_id is not null
  union
  select device_id from public.device_subject_permissions
  union
  select granted_by_device_id as device_id from public.device_subject_permissions where granted_by_device_id is not null
  union
  select device_id from public.matter_reviews
  union
  select device_id from public.teacher_reviews
) as ids
where ids.device_id is not null
  and trim(ids.device_id) <> ''
on conflict (device_id) do update
set device_label = case
  when coalesce(public.device_profiles.device_label, '') = '' then excluded.device_label
  else public.device_profiles.device_label
end;

