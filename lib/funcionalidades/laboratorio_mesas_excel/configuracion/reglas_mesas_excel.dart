class AliasMateriaExcel {
  const AliasMateriaExcel({
    required this.careerId,
    required this.alias,
    required this.subjectId,
    this.year,
  });

  final String careerId;
  final String alias;
  final String subjectId;
  final int? year;
}

const Map<String, List<String>> aliasCarrerasExcel = <String, List<String>>{
  'historia': <String>[
    'historia',
    'profesorado de historia',
    'profesorado de educacion secundaria en historia',
  ],
  'geografia': <String>[
    'geografia',
    'profesorado de geografia',
    'profesorado de educacion secundaria en geografia',
  ],
  'politica': <String>[
    'ciencia politica',
    'profesorado de ciencia politica',
    'profesorado de educacion secundaria en ciencia politica',
    'politica',
    'cp',
  ],
};

const Map<String, List<String>> aliasEncabezadosExcel = <String, List<String>>{
  'fecha': <String>['fecha', 'dia', 'fecha de examen'],
  'horario': <String>['horario', 'hora'],
  'carrera': <String>['carrera', 'profesorado'],
  'anio': <String>['anio', 'ano', 'curso'],
  'materia': <String>[
    'espacio curricular',
    'materia',
    'asignatura',
    'unidad curricular',
  ],
  'docentes': <String>[
    'docentes',
    'docente',
    'tribunal',
    'equipo docente',
  ],
  'acta': <String>['acta', 'acta volante', 'enlace'],
};

const List<AliasMateriaExcel> aliasMateriasExcel = <AliasMateriaExcel>[
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. de la Antigüedad',
    subjectId: 'procesos-antiguedad',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. de los Pueblos Originarios de América',
    subjectId: 'pueblos-originarios',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. del Feudalismo y la Modernidad',
    subjectId: 'procesos-feudalismo-modernidad',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. Americanos I',
    subjectId: 'procesos-americanos-1',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. Americanos II',
    subjectId: 'procesos-americanos-2',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. Americanos III',
    subjectId: 'procesos-americanos-3',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. Argentinos I',
    subjectId: 'procesos-argentina-1',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Argentinos II',
    subjectId: 'procesos-argentina-2',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. Contemporáneos I',
    subjectId: 'procesos-contemporaneos-1',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'P.S.P.E. y C. Contemporáneos II',
    subjectId: 'procesos-contemporaneos-2',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Práctica Docente I',
    subjectId: 'practica-1',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Práctica II (Historia)',
    subjectId: 'practica-2',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Práctica Docente II',
    subjectId: 'practica-2',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Práctica Docente III',
    subjectId: 'practica-3',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Práctica Docente IV',
    subjectId: 'practica-4',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'ESI',
    subjectId: 'educacion-sexual',
  ),
  AliasMateriaExcel(
    careerId: 'historia',
    alias: 'Historia de la Educación Argentina',
    subjectId: 'historia-politica-educacion',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Taller de Oralidad, Lectura, Escritura y TIC',
    subjectId: 'oralidad_lectura_escritura_y_tic',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Técnicas de Representación Cartográfica',
    subjectId: 'tecnicas_de_la_representacion_cartografica_i',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Práctica Docente I',
    subjectId: 'practica_docente_i',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Práctica Docente II',
    subjectId: 'practica_docente_ii',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Practica docente II',
    subjectId: 'practica_docente_ii',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Práctica Docente III',
    subjectId: 'practica_docente_iii',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Práctica Docente IV',
    subjectId: 'practica_docente_iv',
  ),
  AliasMateriaExcel(
    careerId: 'geografia',
    alias: 'Historia de la Educación Argentina',
    subjectId: 'historia_y_politica_de_la_educacion_argentina',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Taller de Oralidad, Lectura, Escritura y TIC',
    subjectId: 'oralidad_lectura_escritura_y_tic',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Práctica Docente I',
    subjectId: 'practica_profesional_docente_i',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'practica docente II C.P',
    subjectId: 'practica_profesional_docente_ii',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Práctica Docente II',
    subjectId: 'practica_profesional_docente_ii',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Práctica Docente III',
    subjectId: 'practica_profesional_docente_iii',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Práctica Docente IV',
    subjectId: 'practica_profesional_docente_iv_residencia',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Psicología Educacional',
    subjectId: 'psicologia_de_la_educacion',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Sujetos de la Educación Secundaria',
    subjectId: 'sujeto_de_la_educacion_secundaria',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Historia Social y Política Argentina y Latinoamericana',
    subjectId: 'historia_social_politica_argentina_y_latinoamericana',
  ),
  AliasMateriaExcel(
    careerId: 'politica',
    alias: 'Teoría Política',
    subjectId: 'teoria_politica_i',
    year: 2,
  ),
];
