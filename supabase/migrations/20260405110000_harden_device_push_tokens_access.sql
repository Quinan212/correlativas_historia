drop policy if exists "device_push_tokens_select_all" on public.device_push_tokens;
drop policy if exists "device_push_tokens_insert_all" on public.device_push_tokens;
drop policy if exists "device_push_tokens_update_all" on public.device_push_tokens;

comment on table public.device_push_tokens is
  'FCM tokens de dispositivos. El acceso de clientes va por Edge Functions para evitar exposición directa.';
