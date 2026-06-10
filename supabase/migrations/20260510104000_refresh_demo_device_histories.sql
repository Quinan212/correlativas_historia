update public.device_registry
set
  label = 'and_' || substr(md5(device_id), 1, 16),
  notes = null
where device_id like 'demo_%';

do $$
begin
  if to_regclass('public.device_profiles') is not null then
    execute $sql$
      update public.device_profiles
      set
        device_label = 'and_' || substr(md5(device_id), 1, 16),
        public_alias = null,
        reference_name = null
      where device_id like 'demo_%'
    $sql$;
  end if;
end $$;

delete from public.matter_navigation_events
where device_id like 'demo_%';

delete from public.exam_navigation_events
where device_id like 'demo_%';

with demo_devices as (
  select
    'demo_' || lpad((99000000 + gs)::text, 8, '0') as device_id,
    case
      when gs <= 10 then 'historia'
      when gs <= 20 then 'geografia'
      when gs <= 30 then 'politica'
      else 'artes_visuales'
    end as career_id,
    case ((gs - 1) % 4)
      when 0 then 'A'
      when 1 then 'B'
      when 2 then 'C'
      else 'D'
    end as division_id,
    case ((gs - 1) % 4)
      when 0 then '1° A'
      when 1 then '1° B'
      when 2 then '1° C'
      else '1° D'
    end as division_label,
    gs as ordinal
  from generate_series(1, 40) as gs
),
matter_curriculum as (
  select *
  from (
    values
      ('historia', 1, 'pedagogia', 'Pedagogía'),
      ('historia', 2, 'problematica-conocimiento', 'Problemática del Conocimiento Histórico'),
      ('historia', 3, 'procesos-antiguedad', 'Procesos Sociales, Políticos, Económicos y Culturales de la Antigüedad'),
      ('historia', 4, 'historia-ideas-1', 'Historia de las Ideas I'),
      ('historia', 5, 'pueblos-originarios', 'Procesos Sociales, Políticos, Económicos y Culturales de los Pueblos Originarios de América'),
      ('historia', 6, 'didactica-general', 'Didáctica General'),
      ('historia', 7, 'procesos-feudalismo-modernidad', 'Procesos Sociales, Políticos, Económicos y Culturales del Feudalismo y la Modernidad'),
      ('historia', 8, 'procesos-americanos-1', 'Procesos Sociales, Políticos, Económicos y Culturales Americanos I'),
      ('historia', 9, 'historia-ideas-2', 'Historia de las Ideas II'),
      ('historia', 10, 'didactica-ciencias-sociales', 'Didáctica de las Ciencias Sociales'),
      ('historia', 11, 'procesos-contemporaneos-1', 'Procesos Sociales, Políticos, Económicos y Culturales Contemporáneos I'),
      ('historia', 12, 'didactica-historia', 'Didáctica de la Historia'),
      ('historia', 13, 'epistemologia-historia', 'Epistemología de la Historia'),
      ('historia', 14, 'procesos-argentina-1', 'Procesos Sociales, Políticos, Económicos y Culturales de Argentina I'),
      ('historia', 15, 'procesos-americanos-2', 'Procesos Sociales, Políticos, Económicos y Culturales Americanos II'),
      ('historia', 16, 'problematicas-regionales', 'Problemáticas Históricas Regionales y Locales'),
      ('geografia', 1, 'pedagogia', 'Pedagogía'),
      ('geografia', 2, 'oralidad_lectura_escritura_y_tic', 'Oralidad, Lectura, Escritura y TIC'),
      ('geografia', 3, 'naturaleza_y_sociedad_i', 'Naturaleza y Sociedad I'),
      ('geografia', 4, 'paisajes_geograficos_mundiales', 'Paisajes Geográficos Mundiales'),
      ('geografia', 5, 'tecnicas_de_la_representacion_cartografica_i', 'Técnicas de la Representación Cartográfica I'),
      ('geografia', 6, 'espacios_urbanos_y_rurales_en_el_mundo_contemporaneo', 'Espacios Urbanos y Rurales en el Mundo Contemporáneo'),
      ('geografia', 7, 'geografia_de_entre_rios', 'Geografía de Entre Ríos'),
      ('geografia', 8, 'didactica_general', 'Didáctica General'),
      ('geografia', 9, 'organizacion_del_espacio_geografico_americano', 'Organización del Espacio Geográfico Americano'),
      ('geografia', 10, 'sistema_urbano_y_desarrollo_rural_argentino', 'Sistema Urbano y Desarrollo Rural Argentino'),
      ('geografia', 11, 'didactica_de_las_ciencias_sociales', 'Didáctica de las Ciencias Sociales'),
      ('geografia', 12, 'epistemologia_de_la_geografia', 'Epistemología de la Geografía'),
      ('geografia', 13, 'organizacion_del_espacio_geografico_argentino', 'Organización del Espacio Geográfico Argentino'),
      ('geografia', 14, 'geografia_economica', 'Geografía Económica'),
      ('geografia', 15, 'geografia_politica_y_cultural', 'Geografía Política y Cultural'),
      ('geografia', 16, 'geotecnologia', 'Geotecnología'),
      ('politica', 1, 'pedagogia', 'Pedagogía'),
      ('politica', 2, 'corporeidad_juegos_y_lenguajes_artisticos', 'Corporeidad, Juegos y Lenguajes Artísticos'),
      ('politica', 3, 'didactica_general', 'Didáctica general'),
      ('politica', 4, 'oralidad_lectura_escritura_y_tic', 'Oralidad, Lectura, Escritura y TIC'),
      ('politica', 5, 'procesos_historicos_modernos', 'Procesos Históricos Modernos'),
      ('politica', 6, 'problematica_de_la_ciencia_politica_i', 'Problemática de la Ciencia Política I'),
      ('politica', 7, 'economia', 'Economía'),
      ('politica', 8, 'derecho_constitucional', 'Derecho Constitucional'),
      ('politica', 9, 'practica_profesional_docente_i', 'Práctica Profesional Docente I'),
      ('politica', 10, 'psicologia_de_la_educacion', 'Psicología de la educación'),
      ('politica', 11, 'historia_social_politica_argentina_y_latinoamericana', 'Historia social, política argentina y latinoamericana'),
      ('politica', 12, 'teoria_politica_i', 'Teoría Política I'),
      ('politica', 13, 'didactica_de_las_ciencias_sociales', 'Didáctica de las Ciencias Sociales'),
      ('politica', 14, 'teoria_politica_ii', 'Teoría Política II'),
      ('politica', 15, 'derechos_humanos_etica_y_ciudadania', 'Derechos humanos: ética y ciudadanía'),
      ('politica', 16, 'relaciones_internacionales', 'Relaciones Internacionales'),
      ('artes_visuales', 1, 'pedagogia', 'Pedagogía'),
      ('artes_visuales', 2, 'corporeidad_juegos_y_lenguajes_artisticos', 'Corporeidad, juegos y lenguajes artísticos'),
      ('artes_visuales', 3, 'didactica_general', 'Didáctica general'),
      ('artes_visuales', 4, 'oralidad_lectura_escritura_y_tic', 'Oralidad, lectura, escritura y TIC'),
      ('artes_visuales', 5, 'arte-1', 'Arte, Cultura y Sociedad I'),
      ('artes_visuales', 6, 'lenguaje-1', 'Lenguaje Visual I'),
      ('artes_visuales', 7, 'plano-1', 'Producción en el Plano I: Dibujo I - Pintura I'),
      ('artes_visuales', 8, 'espacio-1', 'Producción en el Espacio I: Escultura I - Cerámica I'),
      ('artes_visuales', 9, 'practica-1', 'Práctica Docente I'),
      ('artes_visuales', 10, 'didactica', 'Didáctica General'),
      ('artes_visuales', 11, 'arte-2', 'Arte, Cultura y Sociedad II'),
      ('artes_visuales', 12, 'lenguaje-2', 'Lenguaje Visual II'),
      ('artes_visuales', 13, 'plano-2', 'Producción en el Plano II: Dibujo II - Pintura II'),
      ('artes_visuales', 14, 'espacio-2', 'Producción en el Espacio II: Escultura II - Cerámica II'),
      ('artes_visuales', 15, 'sujetos', 'Sujetos de la Educación'),
      ('artes_visuales', 16, 'practica-2', 'Práctica Docente II'),
      ('artes_visuales', 17, 'arte-3', 'Arte, Cultura y Sociedad III'),
      ('artes_visuales', 18, 'multimedia', 'Producción Multimedial y Digital'),
      ('artes_visuales', 19, 'didactica-artes-1', 'Didáctica de las Artes Visuales I'),
      ('artes_visuales', 20, 'semiotica', 'Semiótica de las Artes Visuales'),
      ('artes_visuales', 21, 'produccion-contemp', 'Producciones Artísticas Contemporáneas'),
      ('artes_visuales', 22, 'didactica-artes-2', 'Didáctica de las Artes Visuales II')
  ) as t(career_id, seq, matter_id, matter_name)
),
matter_curriculum_counts as (
  select career_id, max(seq) as max_seq
  from matter_curriculum
  group by career_id
),
matter_steps as (
  select *
  from (
    values
      (1, 'view', 'detail_modal'),
      (2, 'search', 'search_bar'),
      (3, 'view', 'detail_modal'),
      (4, 'view', 'detail_modal'),
      (5, 'search', 'search_bar'),
      (6, 'view', 'detail_modal'),
      (7, 'view', 'detail_modal'),
      (8, 'search', 'search_bar')
  ) as t(step, event_type, surface)
),
matter_seed as (
  select
    d.device_id,
    s.event_type,
    s.surface,
    d.career_id,
    c.matter_id,
    c.matter_name,
    c.career_id as source_career_id,
    lag(c.matter_id) over (partition by d.device_id order by s.step) as source_matter_id,
    lag(c.matter_name) over (partition by d.device_id order by s.step) as source_matter_name,
    now() - ((d.ordinal * 27 + s.step * 9) || ' minutes')::interval as created_at
  from demo_devices d
  join matter_curriculum_counts cc on cc.career_id = d.career_id
  join matter_steps s on true
  join matter_curriculum c
    on c.career_id = d.career_id
   and c.seq = (((d.ordinal + s.step - 2) % cc.max_seq) + 1)
)
insert into public.matter_navigation_events (
  device_id,
  event_type,
  surface,
  career_id,
  matter_id,
  matter_name,
  source_career_id,
  source_matter_id,
  source_matter_name,
  created_at
)
select
  device_id,
  event_type,
  surface,
  career_id,
  matter_id,
  matter_name,
  source_career_id,
  source_matter_id,
  source_matter_name,
  created_at
from matter_seed;

with demo_devices as (
  select
    'demo_' || lpad((99000000 + gs)::text, 8, '0') as device_id,
    case
      when gs <= 10 then 'historia'
      when gs <= 20 then 'geografia'
      when gs <= 30 then 'politica'
      else 'artes_visuales'
    end as career_id,
    case ((gs - 1) % 4)
      when 0 then 'A'
      when 1 then 'B'
      when 2 then 'C'
      else 'D'
    end as division_id,
    case ((gs - 1) % 4)
      when 0 then '1° A'
      when 1 then '1° B'
      when 2 then '1° C'
      else '1° D'
    end as division_label,
    gs as ordinal
  from generate_series(1, 40) as gs
),
exam_curriculum as (
  select *
  from (
    values
      ('historia', 1, 'pedagogia', 'Pedagogía'),
      ('historia', 2, 'problematica-conocimiento', 'Problemática del Conocimiento Histórico'),
      ('historia', 3, 'procesos-antiguedad', 'Procesos Sociales, Políticos, Económicos y Culturales de la Antigüedad'),
      ('historia', 4, 'historia-ideas-1', 'Historia de las Ideas I'),
      ('historia', 5, 'pueblos-originarios', 'Procesos Sociales, Políticos, Económicos y Culturales de los Pueblos Originarios de América'),
      ('historia', 6, 'didactica-general', 'Didáctica General'),
      ('historia', 7, 'procesos-feudalismo-modernidad', 'Procesos Sociales, Políticos, Económicos y Culturales del Feudalismo y la Modernidad'),
      ('historia', 8, 'procesos-americanos-1', 'Procesos Sociales, Políticos, Económicos y Culturales Americanos I'),
      ('historia', 9, 'historia-ideas-2', 'Historia de las Ideas II'),
      ('historia', 10, 'didactica-ciencias-sociales', 'Didáctica de las Ciencias Sociales'),
      ('historia', 11, 'procesos-contemporaneos-1', 'Procesos Sociales, Políticos, Económicos y Culturales Contemporáneos I'),
      ('historia', 12, 'didactica-historia', 'Didáctica de la Historia'),
      ('historia', 13, 'epistemologia-historia', 'Epistemología de la Historia'),
      ('historia', 14, 'procesos-argentina-1', 'Procesos Sociales, Políticos, Económicos y Culturales de Argentina I'),
      ('historia', 15, 'procesos-americanos-2', 'Procesos Sociales, Políticos, Económicos y Culturales Americanos II'),
      ('historia', 16, 'problematicas-regionales', 'Problemáticas Históricas Regionales y Locales'),
      ('geografia', 1, 'pedagogia', 'Pedagogía'),
      ('geografia', 2, 'oralidad_lectura_escritura_y_tic', 'Oralidad, Lectura, Escritura y TIC'),
      ('geografia', 3, 'naturaleza_y_sociedad_i', 'Naturaleza y Sociedad I'),
      ('geografia', 4, 'paisajes_geograficos_mundiales', 'Paisajes Geográficos Mundiales'),
      ('geografia', 5, 'tecnicas_de_la_representacion_cartografica_i', 'Técnicas de la Representación Cartográfica I'),
      ('geografia', 6, 'espacios_urbanos_y_rurales_en_el_mundo_contemporaneo', 'Espacios Urbanos y Rurales en el Mundo Contemporáneo'),
      ('geografia', 7, 'geografia_de_entre_rios', 'Geografía de Entre Ríos'),
      ('geografia', 8, 'didactica_general', 'Didáctica General'),
      ('geografia', 9, 'organizacion_del_espacio_geografico_americano', 'Organización del Espacio Geográfico Americano'),
      ('geografia', 10, 'sistema_urbano_y_desarrollo_rural_argentino', 'Sistema Urbano y Desarrollo Rural Argentino'),
      ('geografia', 11, 'didactica_de_las_ciencias_sociales', 'Didáctica de las Ciencias Sociales'),
      ('geografia', 12, 'epistemologia_de_la_geografia', 'Epistemología de la Geografía'),
      ('geografia', 13, 'organizacion_del_espacio_geografico_argentino', 'Organización del Espacio Geográfico Argentino'),
      ('geografia', 14, 'geografia_economica', 'Geografía Económica'),
      ('geografia', 15, 'geografia_politica_y_cultural', 'Geografía Política y Cultural'),
      ('geografia', 16, 'geotecnologia', 'Geotecnología'),
      ('politica', 1, 'pedagogia', 'Pedagogía'),
      ('politica', 2, 'corporeidad_juegos_y_lenguajes_artisticos', 'Corporeidad, Juegos y Lenguajes Artísticos'),
      ('politica', 3, 'didactica_general', 'Didáctica general'),
      ('politica', 4, 'oralidad_lectura_escritura_y_tic', 'Oralidad, Lectura, Escritura y TIC'),
      ('politica', 5, 'procesos_historicos_modernos', 'Procesos Históricos Modernos'),
      ('politica', 6, 'problematica_de_la_ciencia_politica_i', 'Problemática de la Ciencia Política I'),
      ('politica', 7, 'economia', 'Economía'),
      ('politica', 8, 'derecho_constitucional', 'Derecho Constitucional'),
      ('politica', 9, 'practica_profesional_docente_i', 'Práctica Profesional Docente I'),
      ('politica', 10, 'psicologia_de_la_educacion', 'Psicología de la educación'),
      ('politica', 11, 'historia_social_politica_argentina_y_latinoamericana', 'Historia social, política argentina y latinoamericana'),
      ('politica', 12, 'teoria_politica_i', 'Teoría Política I'),
      ('politica', 13, 'didactica_de_las_ciencias_sociales', 'Didáctica de las Ciencias Sociales'),
      ('politica', 14, 'teoria_politica_ii', 'Teoría Política II'),
      ('politica', 15, 'derechos_humanos_etica_y_ciudadania', 'Derechos humanos: ética y ciudadanía'),
      ('politica', 16, 'relaciones_internacionales', 'Relaciones Internacionales'),
      ('artes_visuales', 1, 'pedagogia', 'Pedagogía'),
      ('artes_visuales', 2, 'corporeidad_juegos_y_lenguajes_artisticos', 'Corporeidad, juegos y lenguajes artísticos'),
      ('artes_visuales', 3, 'didactica_general', 'Didáctica general'),
      ('artes_visuales', 4, 'oralidad_lectura_escritura_y_tic', 'Oralidad, lectura, escritura y TIC'),
      ('artes_visuales', 5, 'arte-1', 'Arte, Cultura y Sociedad I'),
      ('artes_visuales', 6, 'lenguaje-1', 'Lenguaje Visual I'),
      ('artes_visuales', 7, 'plano-1', 'Producción en el Plano I: Dibujo I - Pintura I'),
      ('artes_visuales', 8, 'espacio-1', 'Producción en el Espacio I: Escultura I - Cerámica I'),
      ('artes_visuales', 9, 'practica-1', 'Práctica Docente I'),
      ('artes_visuales', 10, 'didactica', 'Didáctica General'),
      ('artes_visuales', 11, 'arte-2', 'Arte, Cultura y Sociedad II'),
      ('artes_visuales', 12, 'lenguaje-2', 'Lenguaje Visual II')
  ) as t(career_id, seq, tab_id, tab_label)
),
exam_curriculum_counts as (
  select career_id, max(seq) as max_seq
  from exam_curriculum
  group by career_id
),
exam_steps as (
  select *
  from (
    values
      (1, 'view', 'sheet'),
      (2, 'search', 'sheet'),
      (3, 'view', 'sheet'),
      (4, 'view', 'sheet'),
      (5, 'search', 'sheet'),
      (6, 'view', 'sheet'),
      (7, 'view', 'sheet'),
      (8, 'search', 'sheet')
  ) as t(step, event_type, surface)
),
exam_modes as (
  select *
  from (
    values
      (1, 'mesa_final', 'Mesa final'),
      (2, 'coloquio', 'Coloquio'),
      (3, 'promocion_directa', 'Promoción directa'),
      (4, 'equivalencia', 'Equivalencia'),
      (5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      (6, 'julio', 'Julio'),
      (7, 'diciembre', 'Diciembre'),
      (8, 'febrero', 'Febrero')
  ) as t(step, tab_id, tab_label)
),
exam_seed as (
  select
    d.device_id,
    s.event_type,
    s.surface,
    d.career_id,
    c.tab_label as matter_name,
    m.tab_id,
    m.tab_label,
    d.division_id,
    d.division_label,
    c.career_id as source_career_id,
    lag(m.tab_id) over (partition by d.device_id order by s.step) as source_tab_id,
    lag(m.tab_label) over (partition by d.device_id order by s.step) as source_tab_label,
    d.division_id as source_division_id,
    d.division_label as source_division_label,
    now() - ((d.ordinal * 33 + s.step * 11) || ' minutes')::interval as created_at
  from demo_devices d
  join exam_curriculum_counts cc on cc.career_id = d.career_id
  join exam_steps s on true
  join exam_curriculum c
    on c.career_id = d.career_id
   and c.seq = (((d.ordinal + s.step - 2) % cc.max_seq) + 1)
  join exam_modes m on m.step = s.step
)
insert into public.exam_navigation_events (
  device_id,
  event_type,
  surface,
  career_id,
  matter_name,
  tab_id,
  tab_label,
  division_id,
  division_label,
  source_career_id,
  source_tab_id,
  source_tab_label,
  source_division_id,
  source_division_label,
  created_at
)
select
  device_id,
  event_type,
  surface,
  career_id,
  matter_name,
  tab_id,
  tab_label,
  division_id,
  division_label,
  source_career_id,
  source_tab_id,
  source_tab_label,
  source_division_id,
  source_division_label,
  created_at
from exam_seed;

with latest_activity as (
  select device_id, max(created_at) as last_active_at
  from (
    select device_id, created_at
    from public.matter_navigation_events
    where device_id like 'demo_%'
    union all
    select device_id, created_at
    from public.exam_navigation_events
    where device_id like 'demo_%'
  ) activity
  group by device_id
)
update public.device_registry dr
set last_active_at = latest_activity.last_active_at
from latest_activity
where dr.device_id = latest_activity.device_id;
