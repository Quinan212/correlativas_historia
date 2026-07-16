alter table public.device_registry
drop constraint if exists device_registry_device_kind_check;

alter table public.device_registry
add constraint device_registry_device_kind_check
check (device_kind in ('real', 'demo', 'emulator', 'tester'));

with demo_devices as (
  select *
  from (
    values
      ('demo_99000001', 'Sofia', 'Alvarez', 'artes_visuales', 'A'),
      ('demo_99000002', 'Luna', 'Benitez', 'artes_visuales', 'B'),
      ('demo_99000003', 'Camila', 'Castro', 'artes_visuales', 'A'),
      ('demo_99000004', 'Valentina', 'Dominguez', 'artes_visuales', 'B'),
      ('demo_99000005', 'Julia', 'Escobar', 'artes_visuales', 'A'),
      ('demo_99000006', 'Martina', 'Ferreyra', 'artes_visuales', 'C'),
      ('demo_99000007', 'Ariana', 'Gomez', 'artes_visuales', 'A'),
      ('demo_99000008', 'Mara', 'Herrera', 'artes_visuales', 'B'),
      ('demo_99000009', 'Lucia', 'Ibarra', 'artes_visuales', 'D'),
      ('demo_99000010', 'Noelia', 'Juarez', 'artes_visuales', 'A'),
      ('demo_99000011', 'Agustina', 'Ledesma', 'artes_visuales', 'C'),
      ('demo_99000012', 'Rocio', 'Mendez', 'artes_visuales', 'B'),
      ('demo_99000013', 'Micaela', 'Navarro', 'artes_visuales', 'A'),
      ('demo_99000014', 'Bianca', 'Ortega', 'artes_visuales', 'D'),
      ('demo_99000015', 'Antonella', 'Paredes', 'artes_visuales', 'A'),
      ('demo_99000016', 'Florencia', 'Quiroga', 'artes_visuales', 'C'),
      ('demo_99000017', 'Emilia', 'Ramos', 'artes_visuales', 'B'),
      ('demo_99000018', 'Milagros', 'Suarez', 'artes_visuales', 'D'),
      ('demo_99000019', 'Abril', 'Torres', 'artes_visuales', 'A'),
      ('demo_99000020', 'Ana', 'Vega', 'artes_visuales', 'B'),
      ('demo_99000021', 'Bruno', 'Acuña', 'musica', 'A'),
      ('demo_99000022', 'Tomas', 'Bustos', 'musica', 'B'),
      ('demo_99000023', 'Franco', 'Caceres', 'musica', 'A'),
      ('demo_99000024', 'Ivo', 'Diaz', 'musica', 'B'),
      ('demo_99000025', 'Joaquin', 'Echenique', 'musica', 'A'),
      ('demo_99000026', 'Kevin', 'Figueroa', 'musica', 'C'),
      ('demo_99000027', 'Leonel', 'Garcia', 'musica', 'B'),
      ('demo_99000028', 'Mateo', 'Hidalgo', 'musica', 'A'),
      ('demo_99000029', 'Nicolas', 'Iriarte', 'musica', 'D'),
      ('demo_99000030', 'Pablo', 'Jofre', 'musica', 'B'),
      ('demo_99000031', 'Ramiro', 'Klein', 'musica', 'C'),
      ('demo_99000032', 'Santino', 'Lopez', 'musica', 'A'),
      ('demo_99000033', 'Thiago', 'Molina', 'musica', 'B'),
      ('demo_99000034', 'Ulises', 'Nunez', 'musica', 'D'),
      ('demo_99000035', 'Violeta', 'Ocampo', 'musica', 'C'),
      ('demo_99000036', 'Yanina', 'Paz', 'musica', 'A'),
      ('demo_99000037', 'Zoe', 'Quiros', 'musica', 'B'),
      ('demo_99000038', 'Elian', 'Roldan', 'musica', 'D'),
      ('demo_99000039', 'Gaspar', 'Sosa', 'musica', 'A'),
      ('demo_99000040', 'Hector', 'Tapia', 'musica', 'C')
  ) as t(device_id, first_name, last_name, career_id, division)
),
ordered_devices as (
  select
    device_id,
    first_name,
    last_name,
    career_id,
    division,
    row_number() over (order by device_id) as ordinal
  from demo_devices
),
upserted_devices as (
  insert into public.device_registry (
    device_id,
    device_kind,
    lifecycle_status,
    label,
    notes,
    last_active_at
  )
  select
    device_id,
    'demo',
    'active',
    'Demo - ' || first_name || ' ' || last_name,
    'Cuenta demo de presentacion',
    now() - (ordinal || ' minutes')::interval
  from ordered_devices
  on conflict (device_id) do update
  set
    device_kind = excluded.device_kind,
    lifecycle_status = excluded.lifecycle_status,
    label = excluded.label,
    notes = excluded.notes,
    last_active_at = excluded.last_active_at
  returning device_id
),
seeded_matter as (
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
    d.device_id,
    x.event_type,
    x.surface,
    d.career_id,
    x.matter_id,
    x.matter_name,
    x.source_career_id,
    x.source_matter_id,
    x.source_matter_name,
    now() - ((d.ordinal * 4 + x.offset_minutes) || ' minutes')::interval
  from ordered_devices d
  cross join (
    values
      ('view', 'detail_modal', 'lenguaje_visual_i', 'Lenguaje Visual I', null::text, null::text, null::text, 1),
      ('search', 'search_bar', 'lenguaje_visual_i', 'Lenguaje Visual I', null::text, null::text, null::text, 2),
      ('view', 'detail_modal', 'taller_produccion_i', 'Taller de Produccion I', null::text, null::text, null::text, 3)
  ) as x(event_type, surface, matter_id, matter_name, source_career_id, source_matter_id, source_matter_name, offset_minutes)
),
seeded_exam as (
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
    d.device_id,
    x.event_type,
    x.surface,
    d.career_id,
    x.matter_name,
    x.tab_id,
    x.tab_label,
    d.division,
    case d.division
      when 'A' then '1° A'
      when 'B' then '1° B'
      when 'C' then '1° C'
      when 'D' then '1° D'
      else d.division
    end,
    x.source_career_id,
    x.source_tab_id,
    x.source_tab_label,
    x.source_division_id,
    x.source_division_label,
    now() - ((d.ordinal * 5 + x.offset_minutes) || ' minutes')::interval
  from ordered_devices d
  cross join (
    values
      ('view', 'sheet', 'Lenguaje Visual I', 'mesa_final', 'Mesa final', null::text, null::text, null::text, null::text, null::text, 1),
      ('search', 'sheet', 'Lenguaje Visual I', 'busqueda', 'Busqueda', null::text, null::text, null::text, null::text, null::text, 2),
      ('view', 'sheet', 'Instrumento I', 'coloquio', 'Coloquio', null::text, null::text, null::text, null::text, null::text, 3)
  ) as x(event_type, surface, matter_name, tab_id, tab_label, source_career_id, source_tab_id, source_tab_label, source_division_id, source_division_label, offset_minutes)
)
select 1;
