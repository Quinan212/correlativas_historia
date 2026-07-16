alter table public.exam_events
add column if not exists acta_url text;

update public.exam_events
set acta_url = 'https://docs.google.com/spreadsheets/d/1VkdQFZomqug24ZoTJvclOvuEwFXMS9rw/edit?rtpof=true&pli=1&gid=590331576#gid=590331576'
where career_id = 'historia'
  and translate(
    lower(materia),
    'áéíóúüñÁÉÍÓÚÜÑ',
    'aeiouunAEIOUUN'
  ) = 'psicologia educacional';
