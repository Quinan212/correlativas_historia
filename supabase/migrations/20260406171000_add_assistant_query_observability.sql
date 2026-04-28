alter table public.assistant_queries
  add column if not exists intent text,
  add column if not exists resolved_career_id text,
  add column if not exists resolved_materia_id text,
  add column if not exists resolved_materia_nombre text,
  add column if not exists evidence_count integer;
create index if not exists assistant_queries_intent_created_idx
  on public.assistant_queries(intent, created_at desc);
create index if not exists assistant_queries_resolved_career_created_idx
  on public.assistant_queries(resolved_career_id, created_at desc);
