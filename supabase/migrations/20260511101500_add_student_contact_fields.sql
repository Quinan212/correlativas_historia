alter table public.academic_students
  add column if not exists contact_phone text,
  add column if not exists contact_email text;
