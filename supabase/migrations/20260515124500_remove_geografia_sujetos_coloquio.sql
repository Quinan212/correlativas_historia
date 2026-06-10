begin;

delete from public.exam_events
where instancia = 'coloquio'
  and career_id = 'geografia'
  and anio is not distinct from 2
  and materia = 'Sujetos de la Educación Secundaria'
  and division is not distinct from 'A';

commit;
