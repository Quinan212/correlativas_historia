enum EstadoExtraccionLegajoSage {
  cargando,
  disponible,
  vacio,
  estructuraIncompatible,
  error,
}

enum EtapaLegajoSage { ninguna, miLegajo, secciones, escolares }

enum TipoAccionLegajoSage {
  ninguna,
  abrirPerfil,
  abrirSeccion,
  abrirEscolares,
  abrirHistorial,
}

class PerfilLegajoSage {
  const PerfilLegajoSage({
    required this.rowId,
    required this.firmaTecnica,
    required this.nombreVisible,
    required this.camposVisibles,
    this.frameId = '',
    this.pathname = '',
  });

  final String rowId;
  final String firmaTecnica;
  final String nombreVisible;
  final Map<String, String> camposVisibles;
  final String frameId;
  final String pathname;
}

class SeccionLegajoSage {
  const SeccionLegajoSage({
    required this.clave,
    required this.titulo,
    required this.firmaTecnica,
    required this.frameId,
    required this.pathname,
    this.pathnameDestino,
    this.controlEncontrado = true,
  });

  final String clave;
  final String titulo;
  final String firmaTecnica;
  final String frameId;
  final String pathname;
  final String? pathnameDestino;
  final bool controlEncontrado;
}

class OpcionEscolarSage {
  const OpcionEscolarSage({
    required this.clave,
    required this.titulo,
    required this.firmaTecnica,
    required this.frameId,
    required this.pathname,
    this.pathnameDestino,
    this.controlEncontrado = true,
  });

  final String clave;
  final String titulo;
  final String firmaTecnica;
  final String frameId;
  final String pathname;
  final String? pathnameDestino;
  final bool controlEncontrado;
}

class ResultadoExtraccionLegajoSage {
  const ResultadoExtraccionLegajoSage({
    required this.etapa,
    required this.estado,
    required this.firma,
    this.frameId = '',
    this.pathname = '',
    this.perfiles = const [],
    this.secciones = const [],
    this.opcionesEscolares = const [],
    this.parentFrameFound = false,
    this.childFrameFound = false,
    this.childReady = false,
    this.historyGridFound = false,
    this.childPathname = '',
    this.historyControlFound = false,
  });

  final EtapaLegajoSage etapa;
  final EstadoExtraccionLegajoSage estado;
  final String firma;
  final String frameId;
  final String pathname;
  final List<PerfilLegajoSage> perfiles;
  final List<SeccionLegajoSage> secciones;
  final List<OpcionEscolarSage> opcionesEscolares;
  final bool parentFrameFound;
  final bool childFrameFound;
  final bool childReady;
  final bool historyGridFound;
  final String childPathname;
  final bool historyControlFound;

  bool get disponible => estado == EstadoExtraccionLegajoSage.disponible;
}

class ResultadoAccionLegajoSage {
  const ResultadoAccionLegajoSage({
    required this.found,
    required this.activated,
    required this.mechanism,
    required this.frameId,
    required this.pathnameBefore,
    this.matchedBy = '',
  });

  final bool found;
  final bool activated;
  final String mechanism;
  final String frameId;
  final String pathnameBefore;
  final String matchedBy;

  bool get success => found && activated;

  factory ResultadoAccionLegajoSage.fromJson(Map<String, dynamic> json) {
    return ResultadoAccionLegajoSage(
      found: json['found'] == true,
      activated: json['activated'] == true,
      mechanism: json['mechanism'] as String? ?? '',
      frameId: json['frameId'] as String? ?? '',
      pathnameBefore: json['pathnameBefore'] as String? ?? '',
      matchedBy: json['matchedBy'] as String? ?? '',
    );
  }
}

String normalizarLegajoSage(String value) {
  return value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll(':', ' - ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool esHistorialLegajoSage(String pathname) =>
    pathname.toLowerCase().endsWith('/alumnos_v2/ns_historial_alumnado.php');
