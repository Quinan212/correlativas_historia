begin;

alter table public.exam_events
add column if not exists division text;

update public.exam_events
set
  fecha = '2026-05-15',
  hora = '18:30:00'
where instancia = 'coloquio'
  and career_id = 'historia'
  and anio is not distinct from 2
  and materia = 'Práctica Docente II'
  and division is not distinct from 'A y B';

update public.exam_events
set
  fecha = '2026-05-14',
  hora = '20:30:00',
  docentes = array['CODURI, Emilia', 'Docente nombre']::text[]
where instancia = 'coloquio'
  and career_id = 'historia'
  and anio is not distinct from 2
  and materia = 'Didáctica de las Ciencias Sociales'
  and division is not distinct from 'A';

update public.exam_events
set
  fecha = '2026-05-12',
  hora = '20:00:00',
  docentes = array['BORCHE, Javier', 'Docente nombre']::text[]
where instancia = 'coloquio'
  and career_id = 'historia'
  and anio is not distinct from 2
  and materia = 'Historia de las Ideas II'
  and division is not distinct from 'B';

update public.exam_events
set
  fecha = '2026-05-11',
  hora = '20:00:00'
where instancia = 'coloquio'
  and career_id = 'historia'
  and anio is not distinct from 3
  and materia = 'Práctica Docente III'
  and division is not distinct from 'A y B';

update public.exam_events
set
  fecha = '2026-05-15',
  hora = '18:30:00'
where instancia = 'coloquio'
  and career_id = 'historia'
  and anio is not distinct from 3
  and materia = 'Epistemología de la Historia'
  and division is not distinct from 'A y B';

update public.exam_events
set
  fecha = '2026-05-12',
  hora = '20:00:00'
where instancia = 'coloquio'
  and career_id = 'politica'
  and anio is not distinct from 3
  and materia = 'Práctica Docente II'
  and division is not distinct from 'A y B';

insert into public.exam_events (
  career_id,
  anio,
  division,
  materia,
  instancia,
  fecha,
  hora,
  docentes,
  acta_url
)
select
  'geografia',
  2,
  'A',
  'Sujetos de la Educación Secundaria',
  'coloquio',
  '2026-05-13',
  '20:00:00',
  array['DIAZ, Romina', 'Docente nombre']::text[],
  null
where not exists (
  select 1
  from public.exam_events
  where instancia = 'coloquio'
    and career_id = 'geografia'
    and anio is not distinct from 2
    and materia = 'Sujetos de la Educación Secundaria'
    and division is not distinct from 'A'
);

insert into public.exam_events (
  career_id,
  anio,
  division,
  materia,
  instancia,
  fecha,
  hora,
  docentes,
  acta_url
)
select
  'geografia',
  1,
  'A',
  'Práctica Docente II',
  'coloquio',
  '2026-05-13',
  '20:00:00',
  array['CODURI, Emilia', 'MENONI, Evelyn']::text[],
  null
where not exists (
  select 1
  from public.exam_events
  where instancia = 'coloquio'
    and career_id = 'geografia'
    and anio is not distinct from 1
    and materia = 'Práctica Docente II'
    and division is not distinct from 'A'
);

insert into public.exam_events (
  career_id,
  anio,
  division,
  materia,
  instancia,
  fecha,
  hora,
  docentes,
  acta_url
)
select
  'geografia',
  1,
  'A',
  'Práctica Docente I',
  'coloquio',
  '2026-05-12',
  '20:30:00',
  array['CODURI, Emilia', 'SALUD, Diana']::text[],
  null
where not exists (
  select 1
  from public.exam_events
  where instancia = 'coloquio'
    and career_id = 'geografia'
    and anio is not distinct from 1
    and materia = 'Práctica Docente I'
    and division is not distinct from 'A'
);

insert into public.exam_events (
  career_id,
  anio,
  division,
  materia,
  instancia,
  fecha,
  hora,
  docentes,
  acta_url
)
select
  'geografia',
  4,
  'A',
  'Geotecnología',
  'coloquio',
  '2026-05-13',
  '18:30:00',
  array['CODURI, Emilia']::text[],
  null
where not exists (
  select 1
  from public.exam_events
  where instancia = 'coloquio'
    and career_id = 'geografia'
    and anio is not distinct from 4
    and materia = 'Geotecnología'
    and division is not distinct from 'A'
);

insert into public.exam_events (
  career_id,
  anio,
  division,
  materia,
  instancia,
  fecha,
  hora,
  docentes,
  acta_url
)
select
  'politica',
  3,
  'A',
  'Teoría Sociológica Clásica',
  'coloquio',
  '2026-05-13',
  '18:30:00',
  array['VILLA, Claudio']::text[],
  null
where not exists (
  select 1
  from public.exam_events
  where instancia = 'coloquio'
    and career_id = 'politica'
    and anio is not distinct from 3
    and materia = 'Teoría Sociológica Clásica'
    and division is not distinct from 'A'
);

delete from public.exam_events
where instancia = 'coloquio'
  and career_id = 'historia'
  and anio is not distinct from 1
  and materia = 'Práctica Docente I'
  and division is not distinct from 'A y B';

delete from public.exam_events
where instancia = 'coloquio'
  and career_id = 'geografia'
  and anio is not distinct from 3
  and materia = 'Epistemología de la Geografía'
  and division is not distinct from 'A';

delete from public.exam_events
where instancia = 'coloquio'
  and career_id = 'geografia'
  and anio is not distinct from 3
  and materia = 'Práctica Docente III'
  and division is not distinct from 'A y B';

commit;
