enum EstadoNavegacionSage {
  desconocido,
  login,
  modulos,
  submodulosLegajoUnico,
  listadoLegajos,
  seccionesLegajo,
  escolares,
  otraPagina,
  sesionVencida,
  error,
}

class ResultadoDeteccionNavegacionSage {
  const ResultadoDeteccionNavegacionSage({
    required this.estado,
    required this.documentoActivo,
    required this.firma,
    required this.shellPrivado,
  });

  final EstadoNavegacionSage estado;
  final DocumentoNavegacionSage? documentoActivo;
  final String firma;
  final bool shellPrivado;
}

bool activacionNavegacionSageExitosa({
  required bool found,
  required bool activated,
}) => found && activated;

bool cambioNavegacionSageConfirmado({
  required ResultadoDeteccionNavegacionSage resultado,
  required String? firmaOrigen,
  required EstadoNavegacionSage? estadoOrigen,
}) {
  final signatureChanged =
      resultado.firma.isNotEmpty && resultado.firma != firmaOrigen;
  final stateChanged =
      resultado.estado != EstadoNavegacionSage.desconocido &&
      resultado.estado != EstadoNavegacionSage.error &&
      resultado.estado != estadoOrigen;
  return signatureChanged || stateChanged;
}

bool webViewSageVisible({
  required bool historial,
  required bool modulos,
  required bool submodulos,
  required bool carga,
  bool legajo = false,
  bool secciones = false,
  bool escolares = false,
}) =>
    !historial &&
    !modulos &&
    !submodulos &&
    !carga &&
    !legajo &&
    !secciones &&
    !escolares;

class EnlaceNavegacionSage {
  const EnlaceNavegacionSage({
    required this.texto,
    required this.pathname,
    required this.hrefValido,
  });

  final String texto;
  final String pathname;
  final bool hrefValido;

  factory EnlaceNavegacionSage.fromJson(Map<String, dynamic> json) {
    return EnlaceNavegacionSage(
      texto: json['text'] as String? ?? '',
      pathname: json['pathname'] as String? ?? '',
      hrefValido: json['hrefValid'] == true,
    );
  }
}

class DocumentoNavegacionSage {
  const DocumentoNavegacionSage({
    required this.host,
    required this.pathname,
    required this.frameId,
    required this.frameName,
    required this.profundidad,
    required this.visible,
    required this.encabezados,
    required this.enlaces,
    this.hasList2 = false,
    this.hasTabs = false,
    this.hasSchoolFrame = false,
    this.hasHistoryOption = false,
  });

  final String host;
  final String pathname;
  final String frameId;
  final String frameName;
  final int profundidad;
  final bool visible;
  final List<String> encabezados;
  final List<EnlaceNavegacionSage> enlaces;
  final bool hasList2;
  final bool hasTabs;
  final bool hasSchoolFrame;
  final bool hasHistoryOption;

  factory DocumentoNavegacionSage.fromJson(Map<String, dynamic> json) {
    final links = json['links'];
    return DocumentoNavegacionSage(
      host: json['host'] as String? ?? '',
      pathname: json['pathname'] as String? ?? '',
      frameId: json['frameId'] as String? ?? '',
      frameName: json['frameName'] as String? ?? '',
      profundidad: json['depth'] is num ? (json['depth'] as num).toInt() : 0,
      visible: json['visible'] != false,
      encabezados: [
        for (final value in (json['headings'] as List<dynamic>? ?? const []))
          if (value is String) value,
      ],
      enlaces: [
        for (final value in (links as List<dynamic>? ?? const []))
          if (value is Map<String, dynamic>)
            EnlaceNavegacionSage.fromJson(value),
      ],
      hasList2: json['hasList2'] == true,
      hasTabs: json['hasTabs'] == true,
      hasSchoolFrame: json['hasSchoolFrame'] == true,
      hasHistoryOption: json['hasHistoryOption'] == true,
    );
  }
}

class CapturaNavegacionSage {
  const CapturaNavegacionSage({
    required this.host,
    required this.pathname,
    required this.tieneMain,
    required this.encabezados,
    required this.enlaces,
    this.documentos = const [],
  });

  final String host;
  final String pathname;
  final bool tieneMain;
  final List<String> encabezados;
  final List<EnlaceNavegacionSage> enlaces;
  final List<DocumentoNavegacionSage> documentos;

  factory CapturaNavegacionSage.fromJson(Map<String, dynamic> json) {
    final links = json['links'];
    final documents = json['documents'];
    return CapturaNavegacionSage(
      host: json['host'] as String? ?? '',
      pathname: json['pathname'] as String? ?? '',
      tieneMain: json['hasMain'] == true,
      encabezados: [
        for (final value in (json['headings'] as List<dynamic>? ?? const []))
          if (value is String) value,
      ],
      enlaces: [
        for (final value in (links as List<dynamic>? ?? const []))
          if (value is Map<String, dynamic>)
            EnlaceNavegacionSage.fromJson(value),
      ],
      documentos: [
        for (final value in (documents as List<dynamic>? ?? const []))
          if (value is Map<String, dynamic>)
            DocumentoNavegacionSage.fromJson(value),
      ],
    );
  }
}

class OpcionSubmoduloSage {
  const OpcionSubmoduloSage({
    required this.titulo,
    required this.icono,
    this.pathname,
    this.etiquetasAlternativas = const [],
  });

  final String titulo;
  final String? pathname;
  final List<String> etiquetasAlternativas;
  final int icono;
}

const opcionesSubmodulosSage = <OpcionSubmoduloSage>[
  OpcionSubmoduloSage(
    titulo: 'Legajo Alumnos',
    icono: 0xe151,
    pathname: '/dic/Listar2.php',
  ),
  OpcionSubmoduloSage(
    titulo: 'Certificado de Alumno Regular. N. Superior',
    icono: 0xe873,
    etiquetasAlternativas: ['certificado de alumno regular'],
  ),
  OpcionSubmoduloSage(
    titulo: 'Inscripción a una nueva materia (Nivel Superior)',
    icono: 0xe150,
    pathname: '/alumnos_v2/NS_inscrip_nueva_materia_AL.php',
    etiquetasAlternativas: ['inscripcion a una nueva materia'],
  ),
  OpcionSubmoduloSage(
    titulo: 'Mis Inscripciones Anuales',
    icono: 0xe8f9,
    etiquetasAlternativas: ['mis inscripciones anuales'],
  ),
  OpcionSubmoduloSage(
    titulo: 'Inscripción anual obligatoria (Nivel Superior)',
    icono: 0xe878,
    pathname: '/alumnos_v2/NS_inscrip_anual_obligatoria_AL.php',
    etiquetasAlternativas: ['inscripcion anual obligatoria'],
  ),
  OpcionSubmoduloSage(
    titulo: 'Consulta para Tutor/Alumnos',
    icono: 0xe7ef,
    pathname: '/alumnosAdminPanel/seleccionHijo/seleccion-hijo.php',
    etiquetasAlternativas: ['consulta para tutor', 'consulta para alumnos'],
  ),
];
