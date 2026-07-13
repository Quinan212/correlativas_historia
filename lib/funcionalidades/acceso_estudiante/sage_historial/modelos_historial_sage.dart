enum EstadoHistorialSage {
  esperandoPagina,
  cargandoCarreras,
  cargandoMaterias,
  disponible,
  vacio,
  sesionVencida,
  incompatible,
  error,
}

enum EstadoCargaMateriasSage {
  cargando,
  disponible,
  vacio,
  filaNoEncontrada,
  tablaNoEncontrada,
  timeout,
  error,
}

enum EstadoReporteSage {
  iniciado,
  carreraNoEncontrada,
  subgrillaCargando,
  subgridNoExpandido,
  pagerNoEncontrado,
  botonNoEncontrado,
  error,
}

enum EstadoResolverFilaSage {
  resuelta,
  esperandoPagina,
  carreraNoEncontrada,
  incompatible,
  error,
}

enum EstadoSubgrillaSage {
  expandedReady,
  expandedLoading,
  collapsed,
  staleSubgrid,
  missing,
  timeout,
  error,
}

enum ModoVistaSage { nativa, original }

class HistorialNivelSuperiorSage {
  const HistorialNivelSuperiorSage({required this.carreras});

  final List<CarreraHistorialSage> carreras;
}

class CarreraHistorialSage {
  const CarreraHistorialSage({
    required this.gridRowId,
    this.internalId,
    required this.nombre,
    required this.institucion,
    required this.anioInicio,
    required this.estado,
    required this.estadoInscripcion,
    required this.cursando,
    required this.regulares,
    required this.aprobadas,
    required this.materias,
    this.materiasCargadas = false,
  });

  /// Identificador real de la fila de jqGrid. Es el único identificador
  /// válido para expandir la subgrilla y ubicar sus controles.
  final String gridRowId;

  /// Identificador interno de SAGE, conservado solo como dato de la fila.
  final String? internalId;

  @Deprecated('Usar gridRowId para localizar controles de jqGrid.')
  String get idInterno => internalId ?? gridRowId;
  final String nombre;
  final String institucion;
  final int? anioInicio;
  final String? estado;
  final String? estadoInscripcion;
  final int cursando;
  final int regulares;
  final int aprobadas;
  final List<MateriaHistorialSage> materias;
  final bool materiasCargadas;

  CarreraHistorialSage copyWith({
    String? gridRowId,
    List<MateriaHistorialSage>? materias,
    bool? materiasCargadas,
  }) {
    return CarreraHistorialSage(
      gridRowId: gridRowId ?? this.gridRowId,
      internalId: internalId,
      nombre: nombre,
      institucion: institucion,
      anioInicio: anioInicio,
      estado: estado,
      estadoInscripcion: estadoInscripcion,
      cursando: cursando,
      regulares: regulares,
      aprobadas: aprobadas,
      materias: materias ?? this.materias,
      materiasCargadas: materiasCargadas ?? this.materiasCargadas,
    );
  }
}

class MateriaHistorialSage {
  const MateriaHistorialSage({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.anio,
  });

  final String id;
  final String nombre;
  final String estado;
  final int? anio;
}

class ResultadoMateriasSage {
  const ResultadoMateriasSage({
    required this.estado,
    required this.materias,
    required this.gridRowId,
    this.dynamicTableId,
    this.subgridLoaderVisible = false,
    this.subjectRowCount = 0,
    this.requestedGridRow = false,
    this.masterRowFound = false,
    this.expandCalled = false,
    this.subgridContainerFound = false,
    this.dynamicTableFound = false,
  });

  final EstadoCargaMateriasSage estado;
  final List<MateriaHistorialSage> materias;
  final String gridRowId;
  final String? dynamicTableId;
  final bool subgridLoaderVisible;
  final int subjectRowCount;
  final bool requestedGridRow;
  final bool masterRowFound;
  final bool expandCalled;
  final bool subgridContainerFound;
  final bool dynamicTableFound;
}

class ResultadoReporteSage {
  const ResultadoReporteSage({
    required this.estado,
    this.mensaje,
    this.rowResolved = false,
    this.subgridReady = false,
    this.pagerFound = false,
    this.reportButtonFound = false,
  });

  final EstadoReporteSage estado;
  final String? mensaje;
  final bool rowResolved;
  final bool subgridReady;
  final bool pagerFound;
  final bool reportButtonFound;
}

class ResultadoResolverFilaSage {
  const ResultadoResolverFilaSage({
    required this.estado,
    this.gridRowId,
    this.masterFound = false,
  });

  final EstadoResolverFilaSage estado;
  final String? gridRowId;
  final bool masterFound;
}

class ResultadoSubgrillaSage {
  const ResultadoSubgrillaSage({
    required this.estado,
    this.gridRowId,
    this.dynamicTableId,
    this.masterFound = false,
    this.expanded = false,
    this.dynamicTableFound = false,
    this.b2Ready = false,
    this.pagerFound = false,
    this.academicButtonFound = false,
    this.transcriptButtonFound = false,
    this.recordButtonFound = false,
    this.expandCalled = false,
  });

  final EstadoSubgrillaSage estado;
  final String? gridRowId;
  final String? dynamicTableId;
  final bool masterFound;
  final bool expanded;
  final bool dynamicTableFound;
  final bool b2Ready;
  final bool pagerFound;
  final bool academicButtonFound;
  final bool transcriptButtonFound;
  final bool recordButtonFound;
  final bool expandCalled;
}

List<MateriaHistorialSage> filtrarMateriasSage(
  Iterable<MateriaHistorialSage> materias, {
  String query = '',
  String filtro = 'Todas',
}) {
  final normalizedQuery = query.trim().toLowerCase();
  return materias
      .where((subject) {
        final status = subject.estado.toLowerCase();
        final matchesQuery =
            normalizedQuery.isEmpty ||
            subject.nombre.toLowerCase().contains(normalizedQuery);
        final matchesFilter = switch (filtro) {
          'Aprobadas' => status.contains('aprob'),
          'Regulares' => status.contains('regular'),
          'Cursando' => status.contains('curs'),
          _ => true,
        };
        return matchesQuery && matchesFilter;
      })
      .toList(growable: false);
}

Map<int?, List<MateriaHistorialSage>> agruparMateriasPorAnioSage(
  Iterable<MateriaHistorialSage> materias,
) {
  final groups = <int?, List<MateriaHistorialSage>>{};
  for (final subject in materias) {
    groups
        .putIfAbsent(subject.anio, () => <MateriaHistorialSage>[])
        .add(subject);
  }
  return groups.map(
    (year, subjects) => MapEntry(year, List.unmodifiable(subjects)),
  );
}
