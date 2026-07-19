-- Insert July 2026 exam data (non-legacy)
INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-27', '19:00', 'Problemática del Conocimiento Histórico', 'llamado_2', ARRAY['Carmarán, Rosana','Borche, Javier','Medina, Jorge'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Problemática del Conocimiento Histórico' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-27', '19:00', 'Pedagogía', 'llamado_2', ARRAY['Barrios, Eugenia','Salud, Diana','Leiva, Carina','Díaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pedagogía' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-29', '19:00', 'Didáctica General', 'llamado_2', ARRAY['Fernández, María','Pizzio, Marcos','Diaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica General' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-27', '19:00', 'P.S.P.E. y C. de la Antigüedad', 'llamado_2', ARRAY['Carmarán, Rosana','Borche, Javier','Medina, Jorge'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. de la Antigüedad' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-29', '19:00', 'P.S.P.E. y C. de los Pueblos Originarios de América', 'llamado_2', ARRAY['Frigo, Flavia','Galarza, Guillermo','Olivieri, Alejandro'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. de los Pueblos Originarios de América' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-29', '19:00', 'Naturaleza y Sociedad I', 'llamado_2', ARRAY['Carrera, Franklin','Lindt, Elizabet','Moser, Sebastián'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Naturaleza y Sociedad I' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-27', '19:00', 'Geografía de Entre Ríos', 'llamado_2', ARRAY['Lugrín, Patricia','Carrera, Franklin','Lindt, Elizabet'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Geografía de Entre Ríos' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-27', '19:00', 'Paisajes Geográficos Mundiales', 'llamado_2', ARRAY['Coduri, Emilia','Palavicini, Patricia','Menoni, Evelyn'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Paisajes Geográficos Mundiales' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-28', '19:00', 'Espacios Urbanos y Rurales en el Mundo Contemporáneo', 'llamado_2', ARRAY['Coduri, Emilia','Lugrin, Patricia','Palavicini, Patricia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Espacios Urbanos y Rurales en el Mundo Contemporáneo' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-27', '19:00', 'Pedagogía', 'llamado_2', ARRAY['Barrios, Eugenia','Salud, Diana','Leiva, Carina','Díaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pedagogía' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-29', '19:00', 'Didáctica General', 'llamado_2', ARRAY['Fernández, María','Pizzio, Marcos','Diaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica General' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-28', '19:00', 'Instituciones del Derecho Privado / Derecho Privado', 'llamado_2', ARRAY['Morel, José Luis','Piedrabuena, Aldo','Moser, Sebastian'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Instituciones del Derecho Privado / Derecho Privado' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-27', '19:00', 'Problemática de la Ciencia Política I', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Diaz, Ignacio','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Problemática de la Ciencia Política I' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-27', '19:00', 'Procesos Históricos Modernos', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Robinson, Soledad','Alanis, Araceli'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Procesos Históricos Modernos' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-28', '19:00', 'Antropología Social', 'llamado_2', ARRAY['Martínez, Gustavo','Morel, José Luis','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Antropología Social' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-27', '19:00', 'Pedagogía', 'llamado_2', ARRAY['Barrios, Eugenia','Salud, Diana','Leiva, Carina','Díaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pedagogía' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-29', '19:00', 'Didáctica General', 'llamado_2', ARRAY['Fernández, María','Pizzio, Marcos','Diaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica General' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-29', '19:00', 'Economía', 'llamado_2', ARRAY['Belottini, Fernando','Morel, José Luis','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Economía' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-29', '19:00', 'Filosofía', 'llamado_2', ARRAY['Leiva, Carina','Pizzio, Marcos','Ochoa, Natalia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Filosofía' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-30', '19:00', 'P.S.P.E. y C. del Feudalismo y la Modernidad', 'llamado_2', ARRAY['Frigo, Flavia','Medina, Jorge','Galarza, Guillermo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. del Feudalismo y la Modernidad' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-30', '19:00', 'Psicología Educacional', 'llamado_2', ARRAY['Cañete, Marcela','Gay, Giuliana','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Psicología Educacional' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-22', '19:00', 'El Mundo y las Nuevas Territorialidades', 'llamado_2', ARRAY['Robinson, Soledad','Medina, Jorge','Olivieri, Alejandro'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'El Mundo y las Nuevas Territorialidades' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-29', '19:00', 'P.S.P.E. y C. Americanos I', 'llamado_2', ARRAY['Frigo, Flavia','Medina, Jorge','Olivieri, Alejandro'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Americanos I' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-29', '19:00', 'Filosofía', 'llamado_2', ARRAY['Leiva, Carina','Pizzio, Marcos','Ochoa, Natalia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Filosofía' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-31', '19:00', 'Didáctica de las Ciencias Sociales', 'llamado_2', ARRAY['Palavicini, Patricia','Carrera, Franklin','Velazque Pens, Marcelo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica de las Ciencias Sociales' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-30', '19:00', 'Psicología Educacional', 'llamado_2', ARRAY['Cañete, Marcela','Gay, Giuliana','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Psicología Educacional' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-28', '19:00', 'Organización del Espacio Geográfico Americano', 'llamado_2', ARRAY['Lugrín, Patricia','Carrera, Franklin','Lindt, Elizabet'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Organización del Espacio Geográfico Americano' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-28', '19:00', 'Historia Social y Política Argentina y Latinoamericana', 'llamado_2', ARRAY['Moser, Sebastián','Leiva, Carina','Leguiza, Julieta'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia Social y Política Argentina y Latinoamericana' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-28', '19:00', 'Problemática de la Ciencia Política II', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Diaz, Ignacio','Ozuna, Ana'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Problemática de la Ciencia Política II' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-29', '19:00', 'Filosofía', 'llamado_2', ARRAY['Leiva, Carina','Pizzio, Marcos','Ochoa, Natalia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Filosofía' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-30', '19:00', 'Psicología Educacional', 'llamado_2', ARRAY['Cañete, Marcela','Gay, Giuliana','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Psicología Educacional' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-29', '19:00', 'Economía Política', 'llamado_2', ARRAY['Belottini, Fernando','Morel, José Luis','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Economía Política' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-27', '19:00', 'Teoría Política', 'llamado_2', ARRAY['Diaz, Ignacio','Ozuna, Ana','Espíndola, Estéfano'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Teoría Política' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-28', '19:00', 'Historia Social y Política Argentina y Latinoamericana', 'llamado_2', ARRAY['Moser, Sebastián','Leiva, Carina','Leguiza, Julieta'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia Social y Política Argentina y Latinoamericana' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-28', '19:00', 'Derecho Constitucional', 'llamado_2', ARRAY['Morel, José Luis','Piedrabuena, Aldo','Moser, Sebastian'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derecho Constitucional' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-31', '19:00', 'Historia de la Educación Argentina', 'llamado_2', ARRAY['Borche, Javier','Coduri, Emilia','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de la Educación Argentina' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-28', '19:00', 'Didáctica de la Historia', 'llamado_2', ARRAY['Robinson, Soledad','Velazque, Pens','Lower, Griselda'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica de la Historia' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-28');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-29', '19:00', 'P.S.P.E. y C. Argentinos I', 'llamado_2', ARRAY['Dri, Gabriela','Medina, Jorge','Segovia, Paola'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Argentinos I' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-29', '19:00', 'P.S.P.E. y C. Americanos II', 'llamado_2', ARRAY['Carmarán, Rosana','Pozzi, Gerardo','Martínez, Yanina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Americanos II' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-31', '19:00', 'P.S.P.E. y C. Contemporáneos I', 'llamado_2', ARRAY['Frigo, Flavia','Dri, Gabriela','Segovia, Paola'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Contemporáneos I' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-31', '19:00', 'Sociología de la Educación', 'llamado_2', ARRAY['Fernández, María','Ruiz Díaz, Carlos','Villa, Claudio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Sociología de la Educación' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-30', '19:00', 'Organización del Espacio Geográfico Argentino', 'llamado_2', ARRAY['Coduri, Emilia','Palavicini, Patricia','Carrera, Franklin'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Organización del Espacio Geográfico Argentino' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-31', '19:00', 'Sociología de la Educación', 'llamado_2', ARRAY['Fernández, María','Ruiz Díaz, Carlos','Villa, Claudio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Sociología de la Educación' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-30', '19:00', 'Didáctica de la Geografía', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Medina, Jorge','Díaz, Ignacio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica de la Geografía' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-29', '19:00', 'Epistemología de la Geografía', 'llamado_2', ARRAY['Moser, Sebastián','Lidebinsky, José Luis','Carrera, Franklin'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Epistemología de la Geografía' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-31', '19:00', 'Naturaleza y Sociedad II', 'llamado_2', ARRAY['Urgatamendia, Jorge','Carrera, Franklin','Cotto, Rodolfo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Naturaleza y Sociedad II' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-31', '19:00', 'Historia de la Educación Argentina', 'llamado_2', ARRAY['Borche, Javier','Coduri, Emilia','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de la Educación Argentina' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-31', '19:00', 'Derecho Administrativo', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Morel, José Luis','Díaz, Ignacio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derecho Administrativo' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-31', '19:00', 'Teoría Política II', 'llamado_2', ARRAY['Diaz, Ignacio','Velazque Pens, Marcelo','Ozuna, Ana'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Teoría Política II' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-29', '19:00', 'Procesos Históricos Contemporáneos', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Robinson, Soledad','Roda, María Laura'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Procesos Históricos Contemporáneos' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-31', '19:00', 'Historia de la Educación Argentina', 'llamado_2', ARRAY['Borche, Javier','Coduri, Emilia','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de la Educación Argentina' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-31', '19:00', 'Derechos Humanos, Ética y Ciudadanía', 'llamado_2', ARRAY['Carmarán, Rosana','Moser, Sebastián','Torales Kling, Lidia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derechos Humanos, Ética y Ciudadanía' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 4, '2026-07-31', '19:00', 'P.S.P.E. y C. Contemporáneos II', 'llamado_2', ARRAY['García, Diego','Dri, Gabriela','Almirón, Diego'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Contemporáneos II' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 4, '2026-07-31', '19:00', 'P.S.P.E. y C. Americanos III', 'llamado_2', ARRAY['Frigo, Flavia','Olivieri, Alejandro','Gómez, Jeremías'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Americanos III' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 4, '2026-07-31', '19:00', 'Derechos Humanos, Ética y Ciudadanía', 'llamado_2', ARRAY['Carmarán, Rosana','Moser, Sebastián','Torales Kling, Lidia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derechos Humanos, Ética y Ciudadanía' AND instancia = 'llamado_2' AND career_id = 'historia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 4, '2026-07-31', '19:00', 'Geografía Económica', 'llamado_2', ARRAY['Velazque Pens, Marcelo','Lindt, Elizabet','González, Carlos'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Geografía Económica' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 4, '2026-07-30', '19:00', 'Geografía Política y Cultural', 'llamado_2', ARRAY['Palavicini, Patricia','Lindt, Elizabet','Dri, Gabriela'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Geografía Política y Cultural' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 4, '2026-07-31', '19:00', 'Derechos Humanos, Ética y Ciudadanía', 'llamado_2', ARRAY['Carmarán, Rosana','Moser, Sebastián','Torales Kling, Lidia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derechos Humanos, Ética y Ciudadanía' AND instancia = 'llamado_2' AND career_id = 'geografia' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 4, '2026-07-29', '19:00', 'Relaciones Internacionales', 'llamado_2', ARRAY['Diaz, Ignacio','Ozuna, Ana','Romero, Adrián'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Relaciones Internacionales' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 4, '2026-07-30', '19:00', 'Pensamiento Político Latinoamericano y Argentino', 'llamado_2', ARRAY['Díaz, Ignacio','Ozuna, Ana','Maidana, Carolina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pensamiento Político Latinoamericano y Argentino' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-30');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 4, '2026-07-31', '19:00', 'Sistemas Políticos Comparados', 'llamado_2', ARRAY['Diaz, Ignacio','Velazque Pens, Marcelo','Leonardi, Julio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Sistemas Políticos Comparados' AND instancia = 'llamado_2' AND career_id = 'politica' AND fecha = '2026-07-31');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-20', '19:00', 'Problemática del Conocimiento Histórico', 'llamado_1', ARRAY['Carmarán, Rosana','Borche, Javier','Medina, Jorge'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Problemática del Conocimiento Histórico' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-20', '19:00', 'Pedagogía', 'llamado_1', ARRAY['Barrios, Eugenia','Salud, Diana','Leiva, Carina','Díaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pedagogía' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-22', '19:00', 'Didáctica General', 'llamado_1', ARRAY['Fernández, María','Pizzio, Marcos','Diaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica General' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-20', '19:00', 'P.S.P.E. y C. de la Antigüedad', 'llamado_1', ARRAY['Carmarán, Rosana','Borche, Javier','Medina, Jorge'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. de la Antigüedad' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 1, '2026-07-22', '19:00', 'P.S.P.E. y C. de los Pueblos Originarios de América', 'llamado_1', ARRAY['Frigo, Flavia','Galarza, Guillermo','Olivieri, Alejandro'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. de los Pueblos Originarios de América' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-20', '19:00', 'Naturaleza y Sociedad I', 'llamado_1', ARRAY['Carrera, Franklin','Lindt, Elizabet','Moser, Sebastián'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Naturaleza y Sociedad I' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-20', '19:00', 'Geografía de Entre Ríos', 'llamado_1', ARRAY['Lugrín, Patricia','Carrera, Franklin','Lindt, Elizabet'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Geografía de Entre Ríos' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-22', '19:00', 'Paisajes Geográficos Mundiales', 'llamado_1', ARRAY['Coduri, Emilia','Palavicini, Patricia','Menoni, Evelyn'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Paisajes Geográficos Mundiales' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-21', '19:00', 'Espacios Urbanos y Rurales en el Mundo Contemporáneo', 'llamado_1', ARRAY['Coduri, Emilia','Lugrin, Patricia','Palavicini, Patricia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Espacios Urbanos y Rurales en el Mundo Contemporáneo' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-20', '19:00', 'Pedagogía', 'llamado_1', ARRAY['Barrios, Eugenia','Salud, Diana','Leiva, Carina','Díaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pedagogía' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 1, '2026-07-22', '19:00', 'Didáctica General', 'llamado_1', ARRAY['Fernández, María','Pizzio, Marcos','Diaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica General' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-20', '19:00', 'Problemática de la Ciencia Política I', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Diaz, Ignacio','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Problemática de la Ciencia Política I' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-20', '19:00', 'Procesos Históricos Modernos', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Robinson, Soledad','Alanis, Araceli'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Procesos Históricos Modernos' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-21', '19:00', 'Antropología Social', 'llamado_1', ARRAY['Martínez, Gustavo','Morel, José Luis','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Antropología Social' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-20', '19:00', 'Pedagogía', 'llamado_1', ARRAY['Barrios, Eugenia','Salud, Diana','Leiva, Carina','Díaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pedagogía' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-22', '19:00', 'Didáctica General', 'llamado_1', ARRAY['Fernández, María','Pizzio, Marcos','Diaz, Romina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica General' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-22', '19:00', 'Economía', 'llamado_1', ARRAY['Belottini, Fernando','Morel, José Luis','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Economía' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 1, '2026-07-21', '19:00', 'Derecho Constitucional', 'llamado_1', ARRAY['Morel, José Luis','Piedrabuena, Aldo','Moser, Sebastián'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derecho Constitucional' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-22', '19:00', 'Filosofía', 'llamado_1', ARRAY['Leiva, Carina','Pizzio, Marcos','Ochoa, Natalia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Filosofía' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-23', '19:00', 'P.S.P.E. y C. del Feudalismo y la Modernidad', 'llamado_1', ARRAY['Frigo, Flavia','Medina, Jorge','Galarza, Guillermo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. del Feudalismo y la Modernidad' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-23', '19:00', 'Psicología Educacional', 'llamado_1', ARRAY['Cañete, Marcela','Gay, Giuliana','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Psicología Educacional' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-22', '19:00', 'P.S.P.E. y C. Americanos I', 'llamado_1', ARRAY['Frigo, Flavia','Medina, Jorge','Olivieri, Alejandro'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Americanos I' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-22', '19:00', 'El Mundo y las Nuevas Territorialidades', 'llamado_1', ARRAY['Robinson, Soledad','Medina, Jorge','Olivieri, Alejandro'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'El Mundo y las Nuevas Territorialidades' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-22', '19:00', 'Filosofía', 'llamado_1', ARRAY['Leiva, Carina','Pizzio, Marcos','Ochoa, Natalia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Filosofía' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-24', '19:00', 'Didáctica de las Ciencias Sociales', 'llamado_1', ARRAY['Palavicini, Patricia','Carrera, Franklin','Velazque Pens, Marcelo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica de las Ciencias Sociales' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-23', '19:00', 'Psicología Educacional', 'llamado_1', ARRAY['Cañete, Marcela','Gay, Giuliana','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Psicología Educacional' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-21', '19:00', 'Organización del Espacio Geográfico Americano', 'llamado_1', ARRAY['Lugrín, Patricia','Carrera, Franklin','Lindt, Elizabet'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Organización del Espacio Geográfico Americano' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 2, '2026-07-21', '19:00', 'Historia Social y Política Argentina y Latinoamericana', 'llamado_1', ARRAY['Moser, Sebastián','Leiva, Carina','Leguiza, Julieta'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia Social y Política Argentina y Latinoamericana' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-21', '19:00', 'Problemática de la Ciencia Política II', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Diaz, Ignacio','Ozuna, Ana'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Problemática de la Ciencia Política II' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-22', '19:00', 'Filosofía', 'llamado_1', ARRAY['Leiva, Carina','Pizzio, Marcos','Ochoa, Natalia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Filosofía' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-23', '19:00', 'Psicología Educacional', 'llamado_1', ARRAY['Cañete, Marcela','Gay, Giuliana','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Psicología Educacional' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-22', '19:00', 'Economía Política', 'llamado_1', ARRAY['Belottini, Fernando','Morel, José Luis','Piedrabuena, Aldo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Economía Política' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-20', '19:00', 'Teoría Política', 'llamado_1', ARRAY['Diaz, Ignacio','Ozuna, Ana','Espíndola, Estéfano'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Teoría Política' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-20');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-21', '19:00', 'Historia Social y Política Argentina y Latinoamericana', 'llamado_1', ARRAY['Moser, Sebastián','Leiva, Carina','Leguiza, Julieta'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia Social y Política Argentina y Latinoamericana' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 2, '2026-07-21', '19:00', 'Derecho Privado', 'llamado_1', ARRAY['Morel, José Luis','Piedrabuena, Aldo','Moser, Sebastián'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derecho Privado' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-24', '19:00', 'Historia de la Educación Argentina', 'llamado_1', ARRAY['Borche, Javier','Coduri, Emilia','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de la Educación Argentina' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-21', '19:00', 'Didáctica de la Historia', 'llamado_1', ARRAY['Robinson, Soledad','Velazque, Pens','Lower, Griselda'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica de la Historia' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-22', '19:00', 'P.S.P.E. y C. Argentinos I', 'llamado_1', ARRAY['Dri, Gabriela','Medina, Jorge','Segovia, Paola'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Argentinos I' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-22', '19:00', 'P.S.P.E. y C. Americanos II', 'llamado_1', ARRAY['Carmarán, Rosana','Pozzi, Gerardo','Martínez, Yanina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Americanos II' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-24', '19:00', 'P.S.P.E. y C. Contemporáneos I', 'llamado_1', ARRAY['Frigo, Flavia','Dri, Gabriela','Braghini, María Noel'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Contemporáneos I' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 3, '2026-07-24', '19:00', 'Sociología de la Educación', 'llamado_1', ARRAY['Fernández, María','Ruiz Díaz, Carlos','Villa, Claudio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Sociología de la Educación' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-23', '19:00', 'Organización del Espacio Geográfico Argentino', 'llamado_1', ARRAY['Coduri, Emilia','Palavicini, Patricia','Lindt, Elizabet'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Organización del Espacio Geográfico Argentino' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-24', '19:00', 'Sociología de la Educación', 'llamado_1', ARRAY['Fernández, María','Ruiz Díaz, Carlos','Villa, Claudio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Sociología de la Educación' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-23', '19:00', 'Didáctica de la Geografía', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Medina, Jorge','Díaz, Ignacio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Didáctica de la Geografía' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-22', '19:00', 'Epistemología de la Geografía', 'llamado_1', ARRAY['Moser, Sebastián','Lidebinsky, José Luis','Carrera, Franklin'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Epistemología de la Geografía' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-24', '19:00', 'Naturaleza y Sociedad II', 'llamado_1', ARRAY['Urgatamendia, Jorge','Carrera, Franklin','Cotto, Rodolfo'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Naturaleza y Sociedad II' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 3, '2026-07-24', '19:00', 'Historia de la Educación Argentina', 'llamado_1', ARRAY['Borche, Javier','Coduri, Emilia','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de la Educación Argentina' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-24', '19:00', 'Derecho Administrativo', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Morel, José Luis','Díaz, Ignacio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derecho Administrativo' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-24', '19:00', 'Teoría Política II', 'llamado_1', ARRAY['Diaz, Ignacio','Velazque Pens, Marcelo','Segovia, Paola'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Teoría Política II' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-22', '19:00', 'Procesos Históricos Contemporáneos', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Robinson, Soledad','Roda, María Laura'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Procesos Históricos Contemporáneos' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-24', '19:00', 'Historia de la Educación Argentina', 'llamado_1', ARRAY['Borche, Javier','Coduri, Emilia','Leiva, Carina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de la Educación Argentina' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 3, '2026-07-24', '19:00', 'Derechos Humanos, Ética y Ciudadanía', 'llamado_1', ARRAY['Carmarán, Rosana','Moser, Sebastián','Torales Kling, Lidia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derechos Humanos, Ética y Ciudadanía' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 4, '2026-07-24', '19:00', 'P.S.P.E. y C. Contemporáneos II', 'llamado_1', ARRAY['García, Diego','Dri, Gabriela','Almirón, Diego'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Contemporáneos II' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 4, '2026-07-24', '19:00', 'P.S.P.E. y C. Americanos III', 'llamado_1', ARRAY['Frigo, Flavia','Olivieri, Alejandro','Gómez, Jeremías'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'P.S.P.E. y C. Americanos III' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 4, '2026-07-24', '19:00', 'Derechos Humanos, Ética y Ciudadanía', 'llamado_1', ARRAY['Carmarán, Rosana','Moser, Sebastián','Torales Kling, Lidia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derechos Humanos, Ética y Ciudadanía' AND instancia = 'llamado_1' AND career_id = 'historia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 4, '2026-07-24', '19:00', 'Geografía Económica', 'llamado_1', ARRAY['Velazque Pens, Marcelo','Lindt, Elizabet','González, Carlos'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Geografía Económica' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 4, '2026-07-23', '19:00', 'Geografía Política y Cultural', 'llamado_1', ARRAY['Palavecini, Patricia','Lindt, Elizabet','Leonardi, Julio'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Geografía Política y Cultural' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', 4, '2026-07-24', '19:00', 'Derechos Humanos, Ética y Ciudadanía', 'llamado_1', ARRAY['Carmarán, Rosana','Moser, Sebastián','Torales Kling, Lidia'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Derechos Humanos, Ética y Ciudadanía' AND instancia = 'llamado_1' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 4, '2026-07-22', '19:00', 'Relaciones Internacionales', 'llamado_1', ARRAY['Diaz, Ignacio','Ovelar (Suplente)','Romero, Adrián'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Relaciones Internacionales' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-22');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 4, '2026-07-23', '19:00', 'Pensamiento Político Latinoamericano y Argentino', 'llamado_1', ARRAY['Díaz, Ignacio','Ovelar (Suplente)','Maidana, Carolina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Pensamiento Político Latinoamericano y Argentino' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-23');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', 4, '2026-07-24', '19:00', 'Sistemas Políticos Comparados', 'llamado_1', ARRAY['Diaz, Ignacio','Velazque Pens, Marcelo','Luna, Alina'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Sistemas Políticos Comparados' AND instancia = 'llamado_1' AND career_id = 'politica' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-21', '19:00', 'Historia de las Ideas II', 'coloquio', ARRAY['Carmarán, Rosana'], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de las Ideas II' AND instancia = 'coloquio' AND career_id = 'historia' AND fecha = '2026-07-21');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', NULL, NULL, NULL, 'Historia de las ideas II', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Historia de las ideas II' AND instancia = 'coloquio' AND career_id = 'historia');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', NULL, '2026-07-29', '19:00', 'práctica II (Historia)', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'práctica II (Historia)' AND instancia = 'coloquio' AND career_id = 'historia' AND fecha = '2026-07-29');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', NULL, NULL, NULL, 'Epistemologia de la Historia', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Epistemologia de la Historia' AND instancia = 'coloquio' AND career_id = 'historia');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', 2, '2026-07-27', '19:30', 'ESI', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'ESI' AND instancia = 'coloquio' AND career_id = 'historia' AND fecha = '2026-07-27');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'historia', NULL, NULL, NULL, 'Argentinos II', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Argentinos II' AND instancia = 'coloquio' AND career_id = 'historia');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', NULL, NULL, NULL, 'practica docente II C.P', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'practica docente II C.P' AND instancia = 'coloquio' AND career_id = 'politica');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'politica', NULL, '2026-07-24', '18:30', 'Taller de Oralidad, Lectura, Escritura y TIC', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Taller de Oralidad, Lectura, Escritura y TIC' AND instancia = 'coloquio' AND career_id = 'politica' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', NULL, '2026-07-24', '18:30', 'Taller de Oralidad, Lectura, Escritura y TIC', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Taller de Oralidad, Lectura, Escritura y TIC' AND instancia = 'coloquio' AND career_id = 'geografia' AND fecha = '2026-07-24');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', NULL, NULL, NULL, 'tecnicas de representacion', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'tecnicas de representacion' AND instancia = 'coloquio' AND career_id = 'geografia');

INSERT INTO public.exam_events (career_id, anio, fecha, hora, materia, instancia, docentes, division, legacy)
SELECT 'geografia', NULL, NULL, NULL, 'Practica docente II', 'coloquio', ARRAY[]::text[], NULL, false
WHERE NOT EXISTS (SELECT 1 FROM public.exam_events WHERE materia = 'Practica docente II' AND instancia = 'coloquio' AND career_id = 'geografia');
