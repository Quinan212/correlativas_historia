create or replace function public.set_exam_events_anio_if_missing()
returns trigger
language plpgsql
as $$
declare
  norm_materia text;
begin
  if new.anio is not null then
    return new;
  end if;

  norm_materia := translate(
    lower(coalesce(new.materia, '')),
    'áéíóúüñÁÉÍÓÚÜÑ',
    'aeiouunAEIOUUN'
  );

  if new.career_id = 'historia' and new.instancia = 'coloquio' then
    if norm_materia ~ '\bpractica docente i\b' then
      new.anio := 1;
    elsif norm_materia ~ '\bdidactica de las ciencias sociales\b' then
      new.anio := 2;
    elsif norm_materia ~ '\bpractica docente ii\b' then
      new.anio := 2;
    elsif norm_materia ~ '\bepistemologia de la historia\b' then
      new.anio := 3;
    elsif norm_materia ~ '\bpractica docente iii\b' then
      new.anio := 3;
    end if;
  elsif new.career_id = 'geografia' and new.instancia = 'coloquio' then
    if norm_materia ~ '\bpractica docente iii\b' then
      new.anio := 3;
    end if;
  elsif new.career_id = 'politica' and new.instancia = 'coloquio' then
    if norm_materia ~ '\bdidactica de las ciencias sociales\b' then
      new.anio := 2;
    elsif norm_materia ~ '\bpractica docente ii\b' then
      new.anio := 2;
    elsif norm_materia ~ '\bpractica docente iii\b' then
      new.anio := 3;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_exam_events_anio_if_missing on public.exam_events;

create trigger trg_exam_events_anio_if_missing
before insert or update on public.exam_events
for each row
execute function public.set_exam_events_anio_if_missing();
