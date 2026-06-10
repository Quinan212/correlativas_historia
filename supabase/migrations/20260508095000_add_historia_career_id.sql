-- Agregar 'historia' a los constraints CHECK de career_id en academic_students
alter table public.academic_students
  drop constraint if exists academic_students_career_id_check;

alter table public.academic_students
  add constraint academic_students_career_id_check
    check (career_id in ('artes_visuales', 'musica', 'historia'));

-- Agregar 'historia' a los constraints CHECK de career_id en academic_student_subjects
alter table public.academic_student_subjects
  drop constraint if exists academic_student_subjects_career_id_check;

alter table public.academic_student_subjects
  add constraint academic_student_subjects_career_id_check
    check (career_id in ('artes_visuales', 'musica', 'historia'));