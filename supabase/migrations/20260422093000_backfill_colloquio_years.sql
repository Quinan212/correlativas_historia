update public.exam_events
set anio = 1
where career_id = 'historia'
  and instancia = 'coloquio'
  and materia like '%Docente I%';

update public.exam_events
set anio = 2
where career_id = 'historia'
  and instancia = 'coloquio'
  and materia like '%Ciencias Sociales%';

update public.exam_events
set anio = 2
where career_id = 'historia'
  and instancia = 'coloquio'
  and materia like '%Docente II%';

update public.exam_events
set anio = 3
where career_id = 'historia'
  and instancia = 'coloquio'
  and materia like '%Epistemolog%Historia%';

update public.exam_events
set anio = 3
where career_id = 'historia'
  and instancia = 'coloquio'
  and materia like '%Docente III%';

update public.exam_events
set anio = 3
where career_id = 'geografia'
  and instancia = 'coloquio'
  and materia like '%Docente III%';

update public.exam_events
set anio = 2
where career_id = 'politica'
  and instancia = 'coloquio'
  and materia like '%Docente II%';

update public.exam_events
set anio = 2
where career_id = 'politica'
  and instancia = 'coloquio'
  and materia like '%Ciencias Sociales%';

update public.exam_events
set anio = 3
where career_id = 'politica'
  and instancia = 'coloquio'
  and materia like '%Docente III%';
