create table if not exists public.device_registry (
  device_id text primary key,
  device_kind text not null check (device_kind in ('real', 'emulator')),
  lifecycle_status text not null check (lifecycle_status in ('active', 'legacy')),
  label text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_device_registry_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_device_registry_updated_at on public.device_registry;

create trigger trg_device_registry_updated_at
before update on public.device_registry
for each row
execute function public.set_device_registry_updated_at();

insert into public.device_registry (
  device_id,
  device_kind,
  lifecycle_status,
  label,
  notes
)
values
  (
    'and_61fafad37df69a7e',
    'real',
    'active',
    'Samsung A35 actual',
    'Instalacion vigente del Samsung A35.'
  ),
  (
    'and_2bcd01d6ca700579',
    'real',
    'legacy',
    'Samsung A35 legacy',
    'Instalacion anterior del Samsung A35; hoy ya no deberia usarse.'
  ),
  (
    'and_061f00ea86378e23',
    'real',
    'active',
    'Samsung A13 actual',
    'Instalacion vigente del Samsung A13.'
  ),
  (
    'and_d061b2512bc9a217',
    'real',
    'legacy',
    'Samsung A13 legacy',
    'Instalacion anterior del Samsung A13, previa a la release local nueva.'
  ),
  (
    'emu_flutter_emulator',
    'emulator',
    'active',
    'Emulador principal',
    'Emulador usado para pruebas admin.'
  ),
  (
    'emu_flutter_emulator_2',
    'emulator',
    'active',
    'Emulador secundario',
    'Segundo emulador usado para pruebas.'
  )
on conflict (device_id) do update
set
  device_kind = excluded.device_kind,
  lifecycle_status = excluded.lifecycle_status,
  label = excluded.label,
  notes = excluded.notes;
