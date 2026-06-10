alter table public.academic_students
add column if not exists is_demo boolean not null default false;

create index if not exists academic_students_is_demo_idx
  on public.academic_students (is_demo);

alter table public.device_registry
drop constraint if exists device_registry_device_kind_check;

alter table public.device_registry
add constraint device_registry_device_kind_check
check (device_kind in ('real', 'emulator', 'tester'));
