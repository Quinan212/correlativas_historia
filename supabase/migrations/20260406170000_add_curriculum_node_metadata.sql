alter table public.assistant_curriculum_nodes
  add column if not exists tipo text,
  add column if not exists formato text;
create index if not exists assistant_curriculum_nodes_tipo_idx
  on public.assistant_curriculum_nodes(career_id, tipo);
create index if not exists assistant_curriculum_nodes_formato_idx
  on public.assistant_curriculum_nodes(career_id, formato);
