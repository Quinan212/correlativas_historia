alter table public.device_registry
add column if not exists last_active_at timestamptz;
