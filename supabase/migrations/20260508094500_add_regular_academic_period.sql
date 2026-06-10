do $$
declare
  constraint_record record;
begin
  for constraint_record in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'academic_student_subjects'
      and c.contype = 'c'
      and pg_get_constraintdef(c.oid) like '%academic_period%'
  loop
    execute format(
      'alter table public.academic_student_subjects drop constraint %I',
      constraint_record.conname
    );
  end loop;

  for constraint_record in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'academic_student_subjects'
      and c.contype = 'c'
      and pg_get_constraintdef(c.oid) like '%source_period%'
  loop
    execute format(
      'alter table public.academic_student_subjects drop constraint %I',
      constraint_record.conname
    );
  end loop;
end $$;

alter table public.academic_student_subjects
  add constraint academic_student_subjects_academic_period_check
  check (
    academic_period is null or academic_period in (
      'febrero',
      'mayo_extraordinaria',
      'julio',
      'diciembre',
      'regular',
      'cursada',
      'tif',
      'equivalencia',
      'ajuste'
    )
  );

alter table public.academic_student_subjects
  add constraint academic_student_subjects_source_period_check
  check (
    source_period is null or source_period in (
      'febrero',
      'mayo_extraordinaria',
      'extraordinaria',
      'julio',
      'diciembre',
      'regular',
      'cursada',
      'tif',
      'equivalencia',
      'ajuste'
    )
  );
