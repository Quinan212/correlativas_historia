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
('historia', 1, '2026-05-11', '18:30', 'Problemática del Conocimiento Histórico', 'llamado_1', ARRAY['Borche, Javier', 'Carmarán, Rosana', 'Medina, Jorge']::text[]),
('historia', 1, '2026-05-11', '18:30', 'Procesos Sociales, Políticos, Económicos y Culturales de la Antigüedad', 'llamado_1', ARRAY['Borche, Javier', 'Carmarán, Rosana', 'Medina, Jorge']::text[]),
('historia', 1, '2026-05-11', '18:30', 'Procesos Sociales, Políticos, Económicos y Culturales de los Pueblos Originarios de América', 'llamado_1', ARRAY['Frigo, Flavia', 'Galarza, Guillermo', 'DRI, Gabriela']::text[]),
('historia', 2, '2026-05-12', '18:30', 'Procesos Sociales, Políticos, Económicos y Culturales Americanos I', 'llamado_1', ARRAY['Frigo, Flavia', 'PONCE, Guadalupe', 'Medina, Jorge']::text[]),
('historia', 2, '2026-05-12', '18:30', 'Procesos Sociales, Políticos, Económicos y Culturales del Feudalismo y la Modernidad', 'llamado_1', ARRAY['Frigo, Flavia', 'PONCE, Guadalupe', 'Medina, Jorge']::text[]),
('historia', 2, '2026-05-13', '18:30', 'Psicología Educacional', 'llamado_1', ARRAY['IGUAL, Inés', 'GAY, Giuliana', 'MEDINA, Jorge']::text[]),
('historia', 3, '2026-05-14', '18:30', 'Historia y Política de la Educación Argentina', 'llamado_1', ARRAY['BORCHE, Javier', 'CODURI, Emilia', 'LEIVA, Carina']::text[]),
('historia', 3, '2026-05-14', '18:30', 'Procesos Sociales, Políticos, Económicos y Culturales Americanos II', 'llamado_1', ARRAY['POZZI, Gerardo', 'CARMARÁN, Rosana', 'ROBINSON, Soledad']::text[]),
('historia', 3, '2026-05-11', '18:30', 'Procesos Sociales, Políticos, Económicos y Culturales Contemporáneos I', 'llamado_1', ARRAY['FRIGO, Flavia', 'Galarza, Guillermo', 'DRI, Gabriela']::text[]),
('historia', 3, '2026-05-15', '18:30', 'Sociología de la Educación', 'llamado_1', ARRAY['FERNÁNDEZ, María del Carmen', 'RUIZ DÍAZ, Carlos', 'VILLA, Claudio']::text[]),
('historia', 4, '2026-05-15', '18:30', 'Didáctica de la Historia', 'llamado_1', ARRAY['VELAZQUE PENS, Marcelo', 'ROBINSON, Soledad', 'IGUAL, Inés']::text[]),
('geografia', 1, '2026-05-11', '18:30', 'Naturaleza y Sociedad I', 'llamado_1', ARRAY['LUGRIN, Patricia', 'URGATAMENDIA, Jorge', 'LINDT, Elizabet']::text[]),
('geografia', 1, '2026-05-11', '18:30', 'Paisajes Geográficos Mundiales', 'llamado_1', ARRAY['CODURI, Emilia', 'PALAVECINI, Patricia', 'LINDT, Elizabet']::text[]),
('geografia', 1, '2026-05-11', '18:30', 'Espacios Urbanos y Rurales en el Mundo Contemporáneo', 'llamado_1', ARRAY['CODURI, Emilia', 'PALAVECINI, Patricia', 'LINDT, Elizabet']::text[]),
('geografia', 2, '2026-05-12', '18:30', 'Organización del Espacio Geográfico Americano', 'llamado_1', ARRAY['MOSER, Sebastian', 'PALAVECINI, Patricia', 'LINDT, Elizabet']::text[]),
('geografia', 3, '2026-05-14', '18:30', 'Historia y Política de la Educación Argentina', 'llamado_1', ARRAY['CODURI, Emilia', 'BORCHE, Javier', 'LEIVA, Carina']::text[]),
('geografia', 3, '2026-05-11', '18:30', 'Naturaleza y Sociedad II', 'llamado_1', ARRAY['LUGRIN, Patricia', 'URGATAMENDIA, Jorge', 'LINDT, Elizabet']::text[]),
('politica', 1, '2026-05-14', '18:30', 'Antropología Social', 'llamado_1', ARRAY['MARTINEZ, Gustavo', 'ROBINSON, Soledad', 'IGUAL, Inés']::text[]),
('politica', 1, '2026-05-14', '18:30', 'Derecho Constitucional', 'llamado_1', ARRAY['VELAZQUE PENS, Marcelo', 'MOREL, José Luis', 'PIEDRABUENA, Aldo']::text[]),
('politica', 2, '2026-05-14', '18:30', 'Derecho Privado', 'llamado_1', ARRAY['MOREL, José Luis', 'VELAZQUE PENS, Marcelo', 'PIEDRABUENA, Aldo']::text[]),
('politica', 2, '2026-05-15', '18:30', 'Procesos Históricos Contemporáneos', 'llamado_1', ARRAY['ROBINSON, Soledad', 'VELAZQUE PENS, Marcelo', 'OVELAR, Silvina']::text[]),
('politica', 2, '2026-05-15', '18:30', 'Teoría Política I', 'llamado_1', ARRAY['OVELAR, Silvina', 'VELAZQUE PENS, Marcelo', 'ROBINSON, Soledad']::text[]),
('politica', 2, '2026-05-15', '18:30', 'Problemática de la Ciencia Política II', 'llamado_1', ARRAY['VELAZQUE PENS, Marcelo', 'OVELAR, Silvina', 'ROBINSON, Soledad']::text[])
;
