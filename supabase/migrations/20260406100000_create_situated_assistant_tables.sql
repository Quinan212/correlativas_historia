create table if not exists public.assistant_documents (
  id text primary key,
  title text not null,
  source_type text not null,
  source_path text not null,
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.assistant_chunks (
  id bigserial primary key,
  document_id text not null references public.assistant_documents(id) on delete cascade,
  chunk_index integer not null,
  chunk_text text not null,
  source_ref text not null,
  created_at timestamptz not null default timezone('utc', now()),
  unique(document_id, chunk_index)
);

create index if not exists assistant_chunks_document_idx
  on public.assistant_chunks(document_id);

create index if not exists assistant_chunks_source_ref_idx
  on public.assistant_chunks(source_ref);

create table if not exists public.assistant_queries (
  id bigserial primary key,
  device_id text not null,
  question text not null,
  context_type text not null,
  context_id text,
  status text not null,
  answer text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists assistant_queries_created_idx
  on public.assistant_queries(created_at desc);
