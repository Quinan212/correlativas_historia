delete from public.exam_events
where instancia = 'llamado_1';

insert into public.exam_events (
  career_id,
  anio,
  fecha,
  hora,
  materia,
  instancia,
  docentes
)
values
('historia', 1, '2026-05-11', '18:30', 'ProblemÃ¡tica del Conocimiento HistÃ³rico', 'llamado_1', ARRAY['Borche, Javier', 'CarmarÃ¡n, Rosana', 'Medina, Jorge']::text[]),
('historia', 1, '2026-05-11', '18:30', 'Procesos Sociales, PolÃ­ticos, EconÃ³micos y Culturales de la AntigÃ¼edad', 'llamado_1', ARRAY['Borche, Javier', 'CarmarÃ¡n, Rosana', 'Medina, Jorge']::text[]),
('historia', 1, '2026-05-11', '18:30', 'Procesos Sociales, PolÃ­ticos, EconÃ³micos y Culturales de los Pueblos Originarios de AmÃ©rica', 'llamado_1', ARRAY['Frigo, Flavia', 'Galarza, Guillermo', 'DRI, Gabriela']::text[]),
('historia', 2, '2026-05-12', '18:30', 'Procesos Sociales, PolÃ­ticos, EconÃ³micos y Culturales Americanos I', 'llamado_1', ARRAY['Frigo, Flavia', 'PONCE, Guadalupe', 'Medina, Jorge']::text[]),
('historia', 2, '2026-05-12', '18:30', 'Procesos Sociales, PolÃ­ticos, EconÃ³micos y Culturales del Feudalismo y la Modernidad', 'llamado_1', ARRAY['Frigo, Flavia', 'PONCE, Guadalupe', 'Medina, Jorge']::text[]),
('historia', 2, '2026-05-13', '18:30', 'PsicologÃ­a Educacional', 'llamado_1', ARRAY['IGUAL, InÃ©s', 'GAY, Giuliana', 'MEDINA, Jorge']::text[]),
('historia', 3, '2026-05-14', '18:30', 'Historia y PolÃ­tica de la EducaciÃ³n Argentina', 'llamado_1', ARRAY['BORCHE, Javier', 'CODURI, Emilia', 'LEIVA, Carina']::text[]),
('historia', 3, '2026-05-14', '18:30', 'Procesos Sociales, PolÃ­ticos, EconÃ³micos y Culturales Americanos II', 'llamado_1', ARRAY['POZZI, Gerardo', 'CARMARÃN, Rosana', 'ROBINSON, Soledad']::text[]),
('historia', 3, '2026-05-11', '18:30', 'Procesos Sociales, PolÃ­ticos, EconÃ³micos y Culturales ContemporÃ¡neos I', 'llamado_1', ARRAY['FRIGO, Flavia', 'Galarza, Guillermo', 'DRI, Gabriela']::text[]),
('historia', 3, '2026-05-15', '18:30', 'SociologÃ­a de la EducaciÃ³n', 'llamado_1', ARRAY['FERNÃNDEZ, MarÃ­a del Carmen', 'RUIZ DÃAZ, Carlos', 'VILLA, Claudio']::text[]),
('historia', 4, '2026-05-15', '18:30', 'DidÃ¡ctica de la Historia', 'llamado_1', ARRAY['VELAZQUE PENS, Marcelo', 'ROBINSON, Soledad', 'IGUAL, InÃ©s']::text[]),
('geografia', 1, '2026-05-11', '18:30', 'Naturaleza y Sociedad I', 'llamado_1', ARRAY['LUGRIN, Patricia', 'URGATAMENDIA, Jorge', 'LINDT, Elizabet']::text[]),
('geografia', 1, '2026-05-11', '18:30', 'Paisajes GeogrÃ¡ficos Mundiales', 'llamado_1', ARRAY['CODURI, Emilia', 'PALAVECINI, Patricia', 'LINDT, Elizabet']::text[]),
('geografia', 1, '2026-05-11', '18:30', 'Espacios Urbanos y Rurales en el Mundo ContemporÃ¡neo', 'llamado_1', ARRAY['CODURI, Emilia', 'PALAVECINI, Patricia', 'LINDT, Elizabet']::text[]),
('geografia', 2, '2026-05-12', '18:30', 'OrganizaciÃ³n del Espacio GeogrÃ¡fico Americano', 'llamado_1', ARRAY['MOSER, Sebastian', 'PALAVECINI, Patricia', 'LINDT, Elizabet']::text[]),
('geografia', 3, '2026-05-14', '18:30', 'Historia y PolÃ­tica de la EducaciÃ³n Argentina', 'llamado_1', ARRAY['CODURI, Emilia', 'BORCHE, Javier', 'LEIVA, Carina']::text[]),
('geografia', 3, '2026-05-11', '18:30', 'Naturaleza y Sociedad II', 'llamado_1', ARRAY['LUGRIN, Patricia', 'URGATAMENDIA, Jorge', 'LINDT, Elizabet']::text[]),
('politica', 1, '2026-05-14', '18:30', 'AntropologÃ­a Social', 'llamado_1', ARRAY['MARTINEZ, Gustavo', 'ROBINSON, Soledad', 'IGUAL, InÃ©s']::text[]),
('politica', 1, '2026-05-14', '18:30', 'Derecho Constitucional', 'llamado_1', ARRAY['VELAZQUE PENS, Marcelo', 'MOREL, JosÃ© Luis', 'PIEDRABUENA, Aldo']::text[]),
('politica', 2, '2026-05-14', '18:30', 'Derecho Privado', 'llamado_1', ARRAY['MOREL, JosÃ© Luis', 'VELAZQUE PENS, Marcelo', 'PIEDRABUENA, Aldo']::text[]),
('politica', 2, '2026-05-15', '18:30', 'Procesos HistÃ³ricos ContemporÃ¡neos', 'llamado_1', ARRAY['ROBINSON, Soledad', 'VELAZQUE PENS, Marcelo', 'OVELAR, Silvina']::text[]),
('politica', 2, '2026-05-15', '18:30', 'TeorÃ­a PolÃ­tica I', 'llamado_1', ARRAY['OVELAR, Silvina', 'VELAZQUE PENS, Marcelo', 'ROBINSON, Soledad']::text[]),
('politica', 2, '2026-05-15', '18:30', 'ProblemÃ¡tica de la Ciencia PolÃ­tica II', 'llamado_1', ARRAY['VELAZQUE PENS, Marcelo', 'OVELAR, Silvina', 'ROBINSON, Soledad']::text[])
;
