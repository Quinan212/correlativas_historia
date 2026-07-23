-- Control remoto de mesas y coloquios desde el panel administrativo existente.
-- Migración aditiva: conserva admin_devices, la política pública de lectura y
-- todas las columnas utilizadas por versiones anteriores de la aplicación.

alter table public.exam_events
  add column if not exists suspendido boolean not null default false,
  add column if not exists estado text,
  add column if not exists titulo_estado text,
  add column if not exists mensaje_estado text,
  add column if not exists fecha_reprogramada date,
  add column if not exists hora_reprogramada time,
  add column if not exists acta_habilitada boolean not null default true,
  add column if not exists visible boolean not null default true,
  add column if not exists updated_by_device_id text;

-- Reconoce suspensiones ya existentes antes de limpiar prefijos históricos.
update public.exam_events
set estado = case
  when coalesce(suspendido, false)
    or materia ~* '^\s*\[(suspendida|suspendido)\]\s*'
    then 'suspendida'
  when lower(coalesce(estado, '')) in ('activa', 'suspendida', 'cancelada', 'reprogramada')
    then lower(estado)
  else 'activa'
end;

-- Normaliza columnas que pueden haber sido creadas previamente fuera del
-- historial local de migraciones.
update public.exam_events
set
  suspendido = estado in ('suspendida', 'cancelada'),
  acta_habilitada = coalesce(acta_habilitada, true),
  visible = coalesce(visible, true);

alter table public.exam_events
  alter column suspendido set default false,
  alter column suspendido set not null,
  alter column acta_habilitada set default true,
  alter column acta_habilitada set not null,
  alter column visible set default true,
  alter column visible set not null;

update public.exam_events
set
  titulo_estado = coalesce(
    nullif(btrim(titulo_estado), ''),
    case estado
      when 'suspendida' then 'MESA SUSPENDIDA'
      when 'cancelada' then 'MESA CANCELADA'
      when 'reprogramada' then 'MESA REPROGRAMADA'
      else null
    end
  ),
  mensaje_estado = coalesce(
    nullif(btrim(mensaje_estado), ''),
    case estado
      when 'suspendida' then 'Pendiente de reprogramación por la institución.'
      when 'cancelada' then 'La mesa fue cancelada por la institución.'
      when 'reprogramada' then 'La mesa tiene una nueva fecha y horario.'
      else null
    end
  );

-- El nombre de la materia queda limpio. El estado se representa mediante su
-- columna específica y las interfaces agregan la etiqueta correspondiente.
update public.exam_events
set materia = btrim(
  regexp_replace(
    materia,
    '^\s*\[(suspendida|suspendido|cancelada|cancelado|reprogramada|reprogramado)\]\s*',
    '',
    'i'
  )
)
where materia ~* '^\s*\[(suspendida|suspendido|cancelada|cancelado|reprogramada|reprogramado)\]\s*';

alter table public.exam_events
  alter column estado set default 'activa',
  alter column estado set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'exam_events_estado_check'
      and conrelid = 'public.exam_events'::regclass
  ) then
    alter table public.exam_events
      add constraint exam_events_estado_check
      check (estado in ('activa', 'suspendida', 'cancelada', 'reprogramada'));
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'exam_events_reprogramacion_check'
      and conrelid = 'public.exam_events'::regclass
  ) then
    alter table public.exam_events
      add constraint exam_events_reprogramacion_check
      check (
        estado <> 'reprogramada'
        or (fecha_reprogramada is not null and hora_reprogramada is not null)
      );
  end if;
end;
$$;

create or replace function public.sync_exam_event_remote_control_fields()
returns trigger
language plpgsql
as $$
begin
  new.estado := lower(coalesce(nullif(btrim(new.estado), ''), 'activa'));

  if new.estado not in ('activa', 'suspendida', 'cancelada', 'reprogramada') then
    raise exception 'Estado de mesa inválido: %', new.estado;
  end if;

  new.suspendido := new.estado in ('suspendida', 'cancelada');
  new.titulo_estado := nullif(btrim(new.titulo_estado), '');
  new.mensaje_estado := nullif(btrim(new.mensaje_estado), '');
  new.updated_by_device_id := nullif(btrim(new.updated_by_device_id), '');

  if new.estado = 'activa' then
    new.titulo_estado := null;
    new.mensaje_estado := null;
    new.fecha_reprogramada := null;
    new.hora_reprogramada := null;
  elsif new.estado <> 'reprogramada' then
    new.fecha_reprogramada := null;
    new.hora_reprogramada := null;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_exam_events_remote_control_sync
  on public.exam_events;

create trigger trg_exam_events_remote_control_sync
before insert or update on public.exam_events
for each row
execute function public.sync_exam_event_remote_control_fields();

create index if not exists exam_events_estado_idx
  on public.exam_events (estado);

create index if not exists exam_events_visible_idx
  on public.exam_events (visible);

alter table public.exam_events replica identity full;

create table if not exists public.exam_event_change_log (
  id uuid primary key default gen_random_uuid(),
  exam_event_id uuid,
  action text not null check (action in ('insert', 'update', 'delete')),
  device_id text not null,
  previous_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default now()
);

create index if not exists exam_event_change_log_event_idx
  on public.exam_event_change_log (exam_event_id, created_at desc);

create index if not exists exam_event_change_log_device_idx
  on public.exam_event_change_log (device_id, created_at desc);

alter table public.exam_event_change_log enable row level security;

grant all on table public.exam_event_change_log to service_role;
revoke all on table public.exam_event_change_log from anon, authenticated;

-- La Edge Function usa service_role. No se agrega una política pública para el
-- historial, por lo que anon y authenticated no pueden leerlo ni modificarlo.

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1
       from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = 'exam_events'
     ) then
    alter publication supabase_realtime add table public.exam_events;
  end if;
end;
$$;

comment on column public.exam_events.estado is
  'Estado público: activa, suspendida, cancelada o reprogramada.';
comment on column public.exam_events.titulo_estado is
  'Título configurable del aviso público para estados distintos de activa.';
comment on column public.exam_events.mensaje_estado is
  'Mensaje configurable mostrado en listado y detalle.';
comment on column public.exam_events.fecha_reprogramada is
  'Nueva fecha efectiva cuando estado = reprogramada; conserva fecha original.';
comment on column public.exam_events.hora_reprogramada is
  'Nueva hora efectiva cuando estado = reprogramada; conserva hora original.';
comment on column public.exam_events.acta_habilitada is
  'Control remoto del acceso al acta, independiente de que exista acta_url.';
comment on column public.exam_events.visible is
  'Control remoto de visibilidad en la aplicación pública.';
comment on column public.exam_events.updated_by_device_id is
  'Device ID administrativo que realizó la última modificación.';
