update public.academic_students
set current_year = 1
where current_year is null;

alter table public.academic_students
  alter column current_year set default 1,
  alter column current_year set not null;
