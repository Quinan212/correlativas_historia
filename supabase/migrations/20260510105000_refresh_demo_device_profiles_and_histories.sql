update public.device_registry
set
  label = demo_catalog.device_label,
  notes = null
from (
  select *
  from (
    values
      ('demo_99000001', 'TCL T613P SN-1A7C'),
      ('demo_99000002', 'TCL T613P SN-3D4F'),
      ('demo_99000003', 'TCL T616K SN-5E6A'),
      ('demo_99000004', 'Xiaomi 23049PCD8G SN-7B8C'),
      ('demo_99000005', 'Xiaomi 2201116TG SN-9D1E'),
      ('demo_99000006', 'Xiaomi 22101316G SN-2F3A'),
      ('demo_99000007', 'Xiaomi 23078PND5G SN-4B5D'),
      ('demo_99000008', 'Samsung SM-A145M SN-6C7E'),
      ('demo_99000009', 'Samsung SM-A236M SN-8A9B'),
      ('demo_99000010', 'Samsung SM-A336M SN-0C1D'),
      ('demo_99000011', 'Samsung SM-A546E SN-2E3F'),
      ('demo_99000012', 'Motorola XT2345-3 SN-4A5B'),
      ('demo_99000013', 'Motorola XT2235-1 SN-6D7C'),
      ('demo_99000014', 'Motorola XT2309-2 SN-8E9A'),
      ('demo_99000015', 'Motorola XT2311-4 SN-1B2C'),
      ('demo_99000016', 'Redmi 2201116TG SN-3E4D'),
      ('demo_99000017', 'Redmi 2306EPN60G SN-5A6B'),
      ('demo_99000018', 'Redmi 23076RN8DY SN-7C8D'),
      ('demo_99000019', 'OPPO CPH2483 SN-9E0F'),
      ('demo_99000020', 'OPPO CPH2525 SN-2A4C'),
      ('demo_99000021', 'Nokia TA-1418 SN-4E6F'),
      ('demo_99000022', 'Nokia TA-1448 SN-6A8B'),
      ('demo_99000023', 'Nokia TA-1529 SN-8C0D'),
      ('demo_99000024', 'realme RMX3710 SN-1E3A'),
      ('demo_99000025', 'realme RMX3771 SN-3C5D'),
      ('demo_99000026', 'realme RMX3834 SN-5E7F'),
      ('demo_99000027', 'realme RMX3851 SN-7A9B'),
      ('demo_99000028', 'TCL T606P SN-0D2E'),
      ('demo_99000029', 'TCL T612P SN-2F4A'),
      ('demo_99000030', 'TCL T610P SN-4C6D'),
      ('demo_99000031', 'Xiaomi 23129RAA4G SN-6E8F'),
      ('demo_99000032', 'Xiaomi 22126RN91Y SN-8A0C'),
      ('demo_99000033', 'Samsung SM-A055M SN-1D3E'),
      ('demo_99000034', 'Samsung SM-A146P SN-3F5A'),
      ('demo_99000035', 'Motorola XT2251-1 SN-5C7D'),
      ('demo_99000036', 'Motorola XT2313-2 SN-7E9F'),
      ('demo_99000037', 'OPPO CPH2581 SN-0A2C'),
      ('demo_99000038', 'OPPO CPH2631 SN-2D4E'),
      ('demo_99000039', 'Nokia TA-1538 SN-4F6A'),
      ('demo_99000040', 'realme RMX3999 SN-6C8E')
  ) as t(device_id, device_label)
) as demo_catalog
where public.device_registry.device_id = demo_catalog.device_id
  and public.device_registry.device_id like 'demo_%';

insert into public.device_profiles (
  device_id,
  device_label,
  reference_name,
  public_mode,
  public_alias,
  created_at,
  updated_at
)
select
  demo_catalog.device_id,
  demo_catalog.device_label,
  null,
  'anonymous',
  null,
  now(),
  now()
from (
  select *
  from (
    values
      ('demo_99000001', 'TCL T613P SN-1A7C'),
      ('demo_99000002', 'TCL T613P SN-3D4F'),
      ('demo_99000003', 'TCL T616K SN-5E6A'),
      ('demo_99000004', 'Xiaomi 23049PCD8G SN-7B8C'),
      ('demo_99000005', 'Xiaomi 2201116TG SN-9D1E'),
      ('demo_99000006', 'Xiaomi 22101316G SN-2F3A'),
      ('demo_99000007', 'Xiaomi 23078PND5G SN-4B5D'),
      ('demo_99000008', 'Samsung SM-A145M SN-6C7E'),
      ('demo_99000009', 'Samsung SM-A236M SN-8A9B'),
      ('demo_99000010', 'Samsung SM-A336M SN-0C1D'),
      ('demo_99000011', 'Samsung SM-A546E SN-2E3F'),
      ('demo_99000012', 'Motorola XT2345-3 SN-4A5B'),
      ('demo_99000013', 'Motorola XT2235-1 SN-6D7C'),
      ('demo_99000014', 'Motorola XT2309-2 SN-8E9A'),
      ('demo_99000015', 'Motorola XT2311-4 SN-1B2C'),
      ('demo_99000016', 'Redmi 2201116TG SN-3E4D'),
      ('demo_99000017', 'Redmi 2306EPN60G SN-5A6B'),
      ('demo_99000018', 'Redmi 23076RN8DY SN-7C8D'),
      ('demo_99000019', 'OPPO CPH2483 SN-9E0F'),
      ('demo_99000020', 'OPPO CPH2525 SN-2A4C'),
      ('demo_99000021', 'Nokia TA-1418 SN-4E6F'),
      ('demo_99000022', 'Nokia TA-1448 SN-6A8B'),
      ('demo_99000023', 'Nokia TA-1529 SN-8C0D'),
      ('demo_99000024', 'realme RMX3710 SN-1E3A'),
      ('demo_99000025', 'realme RMX3771 SN-3C5D'),
      ('demo_99000026', 'realme RMX3834 SN-5E7F'),
      ('demo_99000027', 'realme RMX3851 SN-7A9B'),
      ('demo_99000028', 'TCL T606P SN-0D2E'),
      ('demo_99000029', 'TCL T612P SN-2F4A'),
      ('demo_99000030', 'TCL T610P SN-4C6D'),
      ('demo_99000031', 'Xiaomi 23129RAA4G SN-6E8F'),
      ('demo_99000032', 'Xiaomi 22126RN91Y SN-8A0C'),
      ('demo_99000033', 'Samsung SM-A055M SN-1D3E'),
      ('demo_99000034', 'Samsung SM-A146P SN-3F5A'),
      ('demo_99000035', 'Motorola XT2251-1 SN-5C7D'),
      ('demo_99000036', 'Motorola XT2313-2 SN-7E9F'),
      ('demo_99000037', 'OPPO CPH2581 SN-0A2C'),
      ('demo_99000038', 'OPPO CPH2631 SN-2D4E'),
      ('demo_99000039', 'Nokia TA-1538 SN-4F6A'),
      ('demo_99000040', 'realme RMX3999 SN-6C8E')
  ) as t(device_id, device_label)
) as demo_catalog
on conflict (device_id) do update
set
  device_label = excluded.device_label,
  reference_name = excluded.reference_name,
  public_mode = excluded.public_mode,
  public_alias = excluded.public_alias,
  updated_at = excluded.updated_at;

delete from public.matter_navigation_events
where device_id like 'demo_%';

delete from public.exam_navigation_events
where device_id like 'demo_%';

with demo_device_catalog as (
  select *
  from (
    values
      ('demo_99000001', 'TCL T613P SN-1A7C'),
      ('demo_99000002', 'TCL T613P SN-3D4F'),
      ('demo_99000003', 'TCL T616K SN-5E6A'),
      ('demo_99000004', 'Xiaomi 23049PCD8G SN-7B8C'),
      ('demo_99000005', 'Xiaomi 2201116TG SN-9D1E'),
      ('demo_99000006', 'Xiaomi 22101316G SN-2F3A'),
      ('demo_99000007', 'Xiaomi 23078PND5G SN-4B5D'),
      ('demo_99000008', 'Samsung SM-A145M SN-6C7E'),
      ('demo_99000009', 'Samsung SM-A236M SN-8A9B'),
      ('demo_99000010', 'Samsung SM-A336M SN-0C1D'),
      ('demo_99000011', 'Samsung SM-A546E SN-2E3F'),
      ('demo_99000012', 'Motorola XT2345-3 SN-4A5B'),
      ('demo_99000013', 'Motorola XT2235-1 SN-6D7C'),
      ('demo_99000014', 'Motorola XT2309-2 SN-8E9A'),
      ('demo_99000015', 'Motorola XT2311-4 SN-1B2C'),
      ('demo_99000016', 'Redmi 2201116TG SN-3E4D'),
      ('demo_99000017', 'Redmi 2306EPN60G SN-5A6B'),
      ('demo_99000018', 'Redmi 23076RN8DY SN-7C8D'),
      ('demo_99000019', 'OPPO CPH2483 SN-9E0F'),
      ('demo_99000020', 'OPPO CPH2525 SN-2A4C'),
      ('demo_99000021', 'Nokia TA-1418 SN-4E6F'),
      ('demo_99000022', 'Nokia TA-1448 SN-6A8B'),
      ('demo_99000023', 'Nokia TA-1529 SN-8C0D'),
      ('demo_99000024', 'realme RMX3710 SN-1E3A'),
      ('demo_99000025', 'realme RMX3771 SN-3C5D'),
      ('demo_99000026', 'realme RMX3834 SN-5E7F'),
      ('demo_99000027', 'realme RMX3851 SN-7A9B'),
      ('demo_99000028', 'TCL T606P SN-0D2E'),
      ('demo_99000029', 'TCL T612P SN-2F4A'),
      ('demo_99000030', 'TCL T610P SN-4C6D'),
      ('demo_99000031', 'Xiaomi 23129RAA4G SN-6E8F'),
      ('demo_99000032', 'Xiaomi 22126RN91Y SN-8A0C'),
      ('demo_99000033', 'Samsung SM-A055M SN-1D3E'),
      ('demo_99000034', 'Samsung SM-A146P SN-3F5A'),
      ('demo_99000035', 'Motorola XT2251-1 SN-5C7D'),
      ('demo_99000036', 'Motorola XT2313-2 SN-7E9F'),
      ('demo_99000037', 'OPPO CPH2581 SN-0A2C'),
      ('demo_99000038', 'OPPO CPH2631 SN-2D4E'),
      ('demo_99000039', 'Nokia TA-1538 SN-4F6A'),
      ('demo_99000040', 'realme RMX3999 SN-6C8E')
  ) as t(device_id, device_label)
),
demo_devices as (
  select
    device_id,
    device_label,
    case
      when ordinal <= 20 then 'historia'
      when ordinal <= 30 then 'geografia'
      else 'politica'
    end as career_id,
    case ((ordinal - 1) % 4)
      when 0 then 'A'
      when 1 then 'B'
      when 2 then 'C'
      else 'D'
    end as division_id,
    case ((ordinal - 1) % 4)
      when 0 then '1° A'
      when 1 then '1° B'
      when 2 then '1° C'
      else '1° D'
    end as division_label,
    ordinal,
    row_number() over (
      partition by case
        when ordinal <= 20 then 'historia'
        when ordinal <= 30 then 'geografia'
        else 'politica'
      end
      order by ordinal
    ) as career_rank
  from (
    select device_id, device_label, row_number() over (order by device_id) as ordinal
    from demo_device_catalog
  ) numbered
),
matter_library as (
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
      ('politica', 16, 'relaciones_internacionales', 'Relaciones Internacionales')
  ) as t(career_id, seq, matter_id, matter_name)
),
exam_library as (
  select *
  from (
    values
      ('historia', 1, 'mesa_final', 'Mesa final'),
      ('historia', 2, 'coloquio', 'Coloquio'),
      ('historia', 3, 'promocion_directa', 'Promoción directa'),
      ('historia', 4, 'equivalencia', 'Equivalencia'),
      ('historia', 5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      ('historia', 6, 'julio', 'Julio'),
      ('historia', 7, 'diciembre', 'Diciembre'),
      ('historia', 8, 'febrero', 'Febrero'),
      ('geografia', 1, 'mesa_final', 'Mesa final'),
      ('geografia', 2, 'coloquio', 'Coloquio'),
      ('geografia', 3, 'promocion_directa', 'Promoción directa'),
      ('geografia', 4, 'equivalencia', 'Equivalencia'),
      ('geografia', 5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      ('geografia', 6, 'julio', 'Julio'),
      ('geografia', 7, 'diciembre', 'Diciembre'),
      ('geografia', 8, 'febrero', 'Febrero'),
      ('politica', 1, 'mesa_final', 'Mesa final'),
      ('politica', 2, 'coloquio', 'Coloquio'),
      ('politica', 3, 'promocion_directa', 'Promoción directa'),
      ('politica', 4, 'equivalencia', 'Equivalencia'),
      ('politica', 5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      ('politica', 6, 'julio', 'Julio'),
      ('politica', 7, 'diciembre', 'Diciembre'),
      ('politica', 8, 'febrero', 'Febrero')
  ) as t(career_id, seq, tab_id, tab_label)
),
created_windows as (
  select
    date '2026-03-01' as march_start,
    date '2026-04-01' as april_start,
    date '2026-05-01' as may_start,
    current_date as today
),
matter_count_plan as (
  select
    device_id,
    device_label,
    career_id,
    division_id,
    division_label,
    career_rank,
    case
      when career_id = 'historia' and career_rank <= 6 then 18
      when career_id = 'historia' and career_rank <= 13 then 12
      when career_id = 'geografia' and career_rank <= 3 then 16
      when career_id = 'geografia' and career_rank <= 6 then 10
      when career_id = 'politica' and career_rank <= 3 then 16
      when career_id = 'politica' and career_rank <= 6 then 10
      else 6
    end as matter_events,
    case
      when career_id = 'historia' and career_rank <= 6 then 12
      when career_id = 'historia' and career_rank <= 13 then 8
      when career_id = 'geografia' and career_rank <= 3 then 10
      when career_id = 'geografia' and career_rank <= 6 then 7
      when career_id = 'politica' and career_rank <= 3 then 10
      when career_id = 'politica' and career_rank <= 6 then 7
      else 4
    end as exam_events
  from demo_devices
),
matter_seed as (
  select
    p.device_id,
    case
      when s.step % 4 = 0 then 'search'
      else 'view'
    end as event_type,
    case
      when s.step % 4 = 0 then 'search_bar'
      else 'detail_modal'
    end as surface,
    p.career_id,
    m.matter_id,
    m.matter_name,
    lag(m.career_id) over (partition by p.device_id order by s.step) as source_career_id,
    lag(m.matter_id) over (partition by p.device_id order by s.step) as source_matter_id,
    lag(m.matter_name) over (partition by p.device_id order by s.step) as source_matter_name,
    case
      when s.step <= 4 then (select march_start from created_windows) + ((p.career_rank * 2 + s.step) % 18) * interval '1 day'
      when s.step <= 8 then (select april_start from created_windows) + ((p.career_rank * 3 + s.step) % 18) * interval '1 day'
      else (select may_start from created_windows) + ((p.career_rank * 4 + s.step) % 10) * interval '1 day'
    end + ((s.step % 6) * interval '2 hours') as created_at
  from matter_count_plan p
  join lateral generate_series(1, p.matter_events) as s(step) on true
  join matter_library m
    on m.career_id = p.career_id
   and m.seq = (((p.career_rank + s.step - 2) % 16) + 1)
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

with demo_device_catalog as (
  select *
  from (
    values
      ('demo_99000001', 'TCL T613P SN-1A7C'),
      ('demo_99000002', 'TCL T613P SN-3D4F'),
      ('demo_99000003', 'TCL T616K SN-5E6A'),
      ('demo_99000004', 'Xiaomi 23049PCD8G SN-7B8C'),
      ('demo_99000005', 'Xiaomi 2201116TG SN-9D1E'),
      ('demo_99000006', 'Xiaomi 22101316G SN-2F3A'),
      ('demo_99000007', 'Xiaomi 23078PND5G SN-4B5D'),
      ('demo_99000008', 'Samsung SM-A145M SN-6C7E'),
      ('demo_99000009', 'Samsung SM-A236M SN-8A9B'),
      ('demo_99000010', 'Samsung SM-A336M SN-0C1D'),
      ('demo_99000011', 'Samsung SM-A546E SN-2E3F'),
      ('demo_99000012', 'Motorola XT2345-3 SN-4A5B'),
      ('demo_99000013', 'Motorola XT2235-1 SN-6D7C'),
      ('demo_99000014', 'Motorola XT2309-2 SN-8E9A'),
      ('demo_99000015', 'Motorola XT2311-4 SN-1B2C'),
      ('demo_99000016', 'Redmi 2201116TG SN-3E4D'),
      ('demo_99000017', 'Redmi 2306EPN60G SN-5A6B'),
      ('demo_99000018', 'Redmi 23076RN8DY SN-7C8D'),
      ('demo_99000019', 'OPPO CPH2483 SN-9E0F'),
      ('demo_99000020', 'OPPO CPH2525 SN-2A4C'),
      ('demo_99000021', 'Nokia TA-1418 SN-4E6F'),
      ('demo_99000022', 'Nokia TA-1448 SN-6A8B'),
      ('demo_99000023', 'Nokia TA-1529 SN-8C0D'),
      ('demo_99000024', 'realme RMX3710 SN-1E3A'),
      ('demo_99000025', 'realme RMX3771 SN-3C5D'),
      ('demo_99000026', 'realme RMX3834 SN-5E7F'),
      ('demo_99000027', 'realme RMX3851 SN-7A9B'),
      ('demo_99000028', 'TCL T606P SN-0D2E'),
      ('demo_99000029', 'TCL T612P SN-2F4A'),
      ('demo_99000030', 'TCL T610P SN-4C6D'),
      ('demo_99000031', 'Xiaomi 23129RAA4G SN-6E8F'),
      ('demo_99000032', 'Xiaomi 22126RN91Y SN-8A0C'),
      ('demo_99000033', 'Samsung SM-A055M SN-1D3E'),
      ('demo_99000034', 'Samsung SM-A146P SN-3F5A'),
      ('demo_99000035', 'Motorola XT2251-1 SN-5C7D'),
      ('demo_99000036', 'Motorola XT2313-2 SN-7E9F'),
      ('demo_99000037', 'OPPO CPH2581 SN-0A2C'),
      ('demo_99000038', 'OPPO CPH2631 SN-2D4E'),
      ('demo_99000039', 'Nokia TA-1538 SN-4F6A'),
      ('demo_99000040', 'realme RMX3999 SN-6C8E')
  ) as t(device_id, device_label)
),
demo_devices as (
  select
    device_id,
    device_label,
    case
      when ordinal <= 20 then 'historia'
      when ordinal <= 30 then 'geografia'
      else 'politica'
    end as career_id,
    case ((ordinal - 1) % 4)
      when 0 then 'A'
      when 1 then 'B'
      when 2 then 'C'
      else 'D'
    end as division_id,
    case ((ordinal - 1) % 4)
      when 0 then '1° A'
      when 1 then '1° B'
      when 2 then '1° C'
      else '1° D'
    end as division_label,
    ordinal,
    row_number() over (
      partition by case
        when ordinal <= 20 then 'historia'
        when ordinal <= 30 then 'geografia'
        else 'politica'
      end
      order by ordinal
    ) as career_rank
  from (
    select device_id, device_label, row_number() over (order by device_id) as ordinal
    from demo_device_catalog
  ) numbered
),
exam_library as (
  select *
  from (
    values
      ('historia', 1, 'mesa_final', 'Mesa final'),
      ('historia', 2, 'coloquio', 'Coloquio'),
      ('historia', 3, 'promocion_directa', 'Promoción directa'),
      ('historia', 4, 'equivalencia', 'Equivalencia'),
      ('historia', 5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      ('historia', 6, 'julio', 'Julio'),
      ('historia', 7, 'diciembre', 'Diciembre'),
      ('historia', 8, 'febrero', 'Febrero'),
      ('geografia', 1, 'mesa_final', 'Mesa final'),
      ('geografia', 2, 'coloquio', 'Coloquio'),
      ('geografia', 3, 'promocion_directa', 'Promoción directa'),
      ('geografia', 4, 'equivalencia', 'Equivalencia'),
      ('geografia', 5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      ('geografia', 6, 'julio', 'Julio'),
      ('geografia', 7, 'diciembre', 'Diciembre'),
      ('geografia', 8, 'febrero', 'Febrero'),
      ('politica', 1, 'mesa_final', 'Mesa final'),
      ('politica', 2, 'coloquio', 'Coloquio'),
      ('politica', 3, 'promocion_directa', 'Promoción directa'),
      ('politica', 4, 'equivalencia', 'Equivalencia'),
      ('politica', 5, 'mayo_extraordinaria', 'Mayo extraordinaria'),
      ('politica', 6, 'julio', 'Julio'),
      ('politica', 7, 'diciembre', 'Diciembre'),
      ('politica', 8, 'febrero', 'Febrero')
  ) as t(career_id, seq, tab_id, tab_label)
),
created_windows as (
  select
    date '2026-03-01' as march_start,
    date '2026-04-01' as april_start,
    date '2026-05-01' as may_start,
    current_date as today
),
exam_seed as (
  select
    p.device_id,
    case
      when s.step % 4 = 0 then 'search'
      else 'view'
    end as event_type,
    'sheet' as surface,
    p.career_id,
    e.tab_id,
    e.tab_label,
    p.division_id,
    p.division_label,
    lag(e.career_id) over (partition by p.device_id order by s.step) as source_career_id,
    lag(e.tab_id) over (partition by p.device_id order by s.step) as source_tab_id,
    lag(e.tab_label) over (partition by p.device_id order by s.step) as source_tab_label,
    lag(p.division_id) over (partition by p.device_id order by s.step) as source_division_id,
    lag(p.division_label) over (partition by p.device_id order by s.step) as source_division_label,
    case
      when s.step <= 4 then (select march_start from created_windows) + ((p.career_rank * 3 + s.step) % 18) * interval '1 day'
      when s.step <= 8 then (select april_start from created_windows) + ((p.career_rank * 4 + s.step) % 18) * interval '1 day'
      else (select may_start from created_windows) + ((p.career_rank * 5 + s.step) % 10) * interval '1 day'
    end + ((s.step % 8) * interval '3 hours') as created_at
  from (
    select
      device_id,
      device_label,
      career_id,
      division_id,
      division_label,
      career_rank,
      case
        when career_id = 'historia' and career_rank <= 6 then 12
        when career_id = 'historia' and career_rank <= 13 then 8
        when career_id = 'geografia' and career_rank <= 3 then 10
        when career_id = 'geografia' and career_rank <= 6 then 7
        when career_id = 'politica' and career_rank <= 3 then 10
        when career_id = 'politica' and career_rank <= 6 then 7
        else 4
      end as exam_events
    from demo_devices
  ) p
  join lateral generate_series(1, p.exam_events) as s(step) on true
  join exam_library e
    on e.career_id = p.career_id
   and e.seq = (((p.career_rank + s.step - 2) % 8) + 1)
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
  tab_label as matter_name,
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
