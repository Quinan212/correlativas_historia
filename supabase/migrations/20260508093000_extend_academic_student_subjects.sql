alter table public.academic_student_subjects
  add column if not exists condition_status text not null default 'habilitada'
    check (condition_status in ('habilitada', 'condicional', 'bloqueada')),
  add column if not exists detail_status text
    check (
      detail_status is null or detail_status in (
        'promocion_directa',
        'mesa_final',
        'equivalencia',
        'coloquio_tif',
        'desaprobo',
        'libre',
        'abandono',
        'no_continuo',
        'rechazo_equivalencia'
      )
    ),
  add column if not exists credit_type text
    check (
      credit_type is null or credit_type in (
        'mesa_final',
        'promocion_directa',
        'equivalencia',
        'coloquio_tif'
      )
    ),
  add column if not exists academic_period text
    check (
      academic_period is null or academic_period in (
        'febrero',
        'mayo_extraordinaria',
        'julio',
        'diciembre',
        'cursada',
        'tif',
        'equivalencia',
        'ajuste'
      )
    ),
  add column if not exists grade numeric(4, 2),
  add column if not exists condition_deadline date,
  add column if not exists admin_note text;

create index if not exists academic_student_subjects_condition_idx
  on public.academic_student_subjects (condition_status);

create index if not exists academic_student_subjects_period_idx
  on public.academic_student_subjects (academic_period);
