update public.exam_events
set anio = case
  when career_id = 'historia'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bpractica docente i\b'
    then 1
  when career_id = 'historia'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bdidactica de las ciencias sociales\b'
    then 2
  when career_id = 'historia'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bpractica docente ii\b'
    then 2
  when career_id = 'historia'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bepistemologia de la historia\b'
    then 3
  when career_id = 'historia'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bpractica docente iii\b'
    then 3
  when career_id = 'geografia'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bpractica docente iii\b'
    then 3
  when career_id = 'politica'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bdidactica de las ciencias sociales\b'
    then 2
  when career_id = 'politica'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bpractica docente ii\b'
    then 2
  when career_id = 'politica'
    and instancia = 'coloquio'
    and translate(lower(materia), 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN') ~ '\bpractica docente iii\b'
    then 3
  else anio
end
where instancia = 'coloquio'
  and anio is null;
