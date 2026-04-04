create table if not exists public.admin_devices (
  device_id text primary key,
  label text,
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.admin_devices enable row level security;

drop policy if exists "admin_devices_select_all" on public.admin_devices;

create policy "admin_devices_select_all"
on public.admin_devices
for select
to anon, authenticated
using (true);

-- Ejemplo para habilitar un dispositivo:
-- insert into public.admin_devices (device_id, label)
-- values ('dev_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'emulador admin');
