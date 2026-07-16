create extension if not exists pgcrypto;

create table if not exists public.academic_students (
  id uuid primary key default gen_random_uuid(),
  dni text not null unique,
  first_name text not null,
  last_name text not null,
  career_id text not null check (career_id in ('artes_visuales', 'musica')),
  cohort_year integer,
  current_year integer check (current_year between 1 and 4),
  division text,
  is_new_student boolean not null default true,
  is_repeating boolean not null default false,
  enrollment_status text not null default 'active'
    check (enrollment_status in ('active', 'inactive', 'graduated', 'left')),
  initial_password text not null default 'Correlativas.2026',
  must_change_password boolean not null default true,
  notes text,
  created_by_device_id text,
  updated_by_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists academic_students_career_idx
  on public.academic_students (career_id);

create index if not exists academic_students_name_idx
  on public.academic_students (last_name, first_name);

create table if not exists public.academic_student_subjects (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academic_students(id) on delete cascade,
  career_id text not null check (career_id in ('artes_visuales', 'musica')),
  subject_id text not null,
  subject_name text not null,
  subject_year integer,
  status text not null check (
    status in ('cursando', 'regular', 'aprobada', 'no_regularizada')
  ),
  source_period text check (
    source_period in ('febrero', 'extraordinaria', 'julio', 'diciembre', 'cursada', 'ajuste')
  ),
  source_date date,
  notes text,
  updated_by_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, subject_id)
);

create index if not exists academic_student_subjects_student_idx
  on public.academic_student_subjects (student_id);

create index if not exists academic_student_subjects_status_idx
  on public.academic_student_subjects (status);

create table if not exists public.academic_student_history (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academic_students(id) on delete cascade,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  admin_device_id text,
  created_at timestamptz not null default now()
);

create or replace function public.set_academic_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_academic_students_updated_at
  on public.academic_students;

create trigger trg_academic_students_updated_at
before update on public.academic_students
for each row
execute function public.set_academic_updated_at();

drop trigger if exists trg_academic_student_subjects_updated_at
  on public.academic_student_subjects;

create trigger trg_academic_student_subjects_updated_at
before update on public.academic_student_subjects
for each row
execute function public.set_academic_updated_at();

alter table public.academic_students enable row level security;
alter table public.academic_student_subjects enable row level security;
alter table public.academic_student_history enable row level security;

drop policy if exists "academic_students_no_direct_access"
  on public.academic_students;
drop policy if exists "academic_student_subjects_no_direct_access"
  on public.academic_student_subjects;
drop policy if exists "academic_student_history_no_direct_access"
  on public.academic_student_history;

create policy "academic_students_no_direct_access"
on public.academic_students
for all
to anon, authenticated
using (false)
with check (false);

create policy "academic_student_subjects_no_direct_access"
on public.academic_student_subjects
for all
to anon, authenticated
using (false)
with check (false);

create policy "academic_student_history_no_direct_access"
on public.academic_student_history
for all
to anon, authenticated
using (false)
with check (false);
