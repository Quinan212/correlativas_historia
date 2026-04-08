create extension if not exists pg_trgm;

create index if not exists assistant_chunks_chunk_text_trgm_idx
  on public.assistant_chunks using gin (chunk_text gin_trgm_ops);

create index if not exists assistant_queries_status_created_idx
  on public.assistant_queries(status, created_at desc);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'assistant_documents_source_type_check'
      and conrelid = 'public.assistant_documents'::regclass
  ) then
    alter table public.assistant_documents
      add constraint assistant_documents_source_type_check
      check (source_type in ('steiman', 'app_text'));
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'assistant_queries_status_check'
      and conrelid = 'public.assistant_queries'::regclass
  ) then
    alter table public.assistant_queries
      add constraint assistant_queries_status_check
      check (status in ('ok', 'no_evidence', 'error'));
  end if;
end
$$;
