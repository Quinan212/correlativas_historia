-- Add legacy column to exam_events
alter table public.exam_events
  add column if not exists legacy boolean not null default false;

-- Mark existing records as legacy
update public.exam_events
  set legacy = true
  where legacy = false;

create index if not exists exam_events_legacy_idx on public.exam_events (legacy);
