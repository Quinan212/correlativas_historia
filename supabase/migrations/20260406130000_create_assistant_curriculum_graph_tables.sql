create table if not exists public.assistant_curriculum_nodes (
  id bigserial primary key,
  career_id text not null,
  career_name text not null,
  materia_id text not null,
  materia_nombre text not null,
  materia_normalized text not null,
  anio integer,
  created_at timestamptz not null default timezone('utc', now()),
  unique (career_id, materia_id)
);

create table if not exists public.assistant_curriculum_edges (
  id bigserial primary key,
  career_id text not null,
  from_materia_id text not null,
  from_materia_nombre text not null,
  to_materia_id text not null,
  to_materia_nombre text not null,
  requirement_type text,
  source_ref text not null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (career_id, from_materia_id, to_materia_id)
);

create index if not exists assistant_curriculum_nodes_career_idx
  on public.assistant_curriculum_nodes(career_id);

create index if not exists assistant_curriculum_nodes_normalized_idx
  on public.assistant_curriculum_nodes(career_id, materia_normalized);

create index if not exists assistant_curriculum_edges_from_idx
  on public.assistant_curriculum_edges(career_id, from_materia_id);

create index if not exists assistant_curriculum_edges_to_idx
  on public.assistant_curriculum_edges(career_id, to_materia_id);

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'assistant_curriculum_nodes_career_check'
  ) then
    alter table public.assistant_curriculum_nodes
      add constraint assistant_curriculum_nodes_career_check
      check (career_id in ('historia', 'geografia', 'politica'));
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'assistant_curriculum_edges_career_check'
  ) then
    alter table public.assistant_curriculum_edges
      add constraint assistant_curriculum_edges_career_check
      check (career_id in ('historia', 'geografia', 'politica'));
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'assistant_curriculum_edges_requirement_check'
  ) then
    alter table public.assistant_curriculum_edges
      add constraint assistant_curriculum_edges_requirement_check
      check (requirement_type is null or requirement_type in ('A', 'R'));
  end if;
end
$$;
