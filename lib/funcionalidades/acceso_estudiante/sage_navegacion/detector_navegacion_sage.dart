import 'modelos_navegacion_sage.dart';

class DetectorNavegacionSage {
  const DetectorNavegacionSage();

  static const _host = 'sage.entrerios.gov.ar';

  EstadoNavegacionSage detectar(CapturaNavegacionSage captura) {
    return detectarResultado(captura).estado;
  }

  ResultadoDeteccionNavegacionSage detectarResultado(
    CapturaNavegacionSage captura,
  ) {
    final documentos = captura.documentos.isEmpty
        ? <DocumentoNavegacionSage>[
            DocumentoNavegacionSage(
              host: captura.host,
              pathname: captura.pathname,
              frameId: '',
              frameName: '',
              profundidad: 0,
              visible: true,
              encabezados: captura.encabezados,
              enlaces: captura.enlaces,
            ),
          ]
        : captura.documentos;
    final rootIsPrivate = documentos.any(
      (documento) =>
          documento.profundidad == 0 &&
          documento.pathname.toLowerCase() == '/pregase/index.php',
    );
    if (documentos.every(
      (documento) => documento.host.toLowerCase() != _host,
    )) {
      return const ResultadoDeteccionNavegacionSage(
        estado: EstadoNavegacionSage.desconocido,
        documentoActivo: null,
        firma: '',
        shellPrivado: false,
      );
    }

    final posteriores =
        documentos
            .where(
              (documento) =>
                  documento.visible && _esRutaPosterior(documento.pathname),
            )
            .toList()
          ..sort((a, b) => b.profundidad.compareTo(a.profundidad));
    if (posteriores.isNotEmpty) {
      return _resultado(
        EstadoNavegacionSage.otraPagina,
        posteriores.first,
        shellPrivado: rootIsPrivate || captura.tieneMain,
      );
    }

    final activo = _seleccionarDocumento(documentos);
    if (activo == null) {
      return ResultadoDeteccionNavegacionSage(
        estado: EstadoNavegacionSage.desconocido,
        documentoActivo: null,
        firma: '',
        shellPrivado: rootIsPrivate || captura.tieneMain,
      );
    }
    final ruta = activo.pathname.toLowerCase();
    final textos = activo.encabezados
        .map(normalizar)
        .where((value) => value.isNotEmpty)
        .toList();
    final enlaces = activo.enlaces
        .map((link) => normalizar(link.texto))
        .where((value) => value.isNotEmpty)
        .toList();

    if (ruta.startsWith('/login') || textos.any(_esIngreso)) {
      return _resultado(
        EstadoNavegacionSage.login,
        activo,
        shellPrivado: false,
      );
    }
    if ([
      ...textos,
      ...enlaces,
    ].any((value) => value.contains('sesion vencida'))) {
      return _resultado(
        EstadoNavegacionSage.sesionVencida,
        activo,
        shellPrivado: false,
      );
    }

    final tieneModulo = textos.any(_esEncabezadoModulos);
    final tieneLegajo = activo.enlaces.any(
      (link) => normalizar(link.texto).contains('legajo unico alumno'),
    );
    final esRutaModulo = ruta.toLowerCase() == '/pregase/index.php';
    if (tieneLegajo && (tieneModulo || esRutaModulo)) {
      return _resultado(
        EstadoNavegacionSage.modulos,
        activo,
        shellPrivado: true,
        opciones: const ['legajo_unico'],
      );
    }

    final tieneSubmodulos = textos.any(_esEncabezadoSubmodulos);
    final esRutaSubmodulos =
        ruta.toLowerCase() == '/pregase/menuprincipal_nuevo.php';
    final opciones = _opcionesSubmodulosReconocidas(activo.enlaces);
    if ((tieneSubmodulos || esRutaSubmodulos) && opciones.length >= 3) {
      return _resultado(
        EstadoNavegacionSage.submodulosLegajoUnico,
        activo,
        shellPrivado: true,
        opciones: opciones,
      );
    }
    if (ruta.isEmpty && textos.isEmpty && enlaces.isEmpty) {
      return _resultado(
        EstadoNavegacionSage.desconocido,
        activo,
        shellPrivado: rootIsPrivate || captura.tieneMain,
      );
    }
    return _resultado(
      EstadoNavegacionSage.otraPagina,
      activo,
      shellPrivado: rootIsPrivate || captura.tieneMain,
    );
  }

  ResultadoDeteccionNavegacionSage _resultado(
    EstadoNavegacionSage estado,
    DocumentoNavegacionSage documento, {
    required bool shellPrivado,
    List<String> opciones = const [],
  }) {
    final etiqueta = switch (estado) {
      EstadoNavegacionSage.modulos => 'modulos',
      EstadoNavegacionSage.submodulosLegajoUnico => 'submodulos',
      EstadoNavegacionSage.login => 'login',
      EstadoNavegacionSage.sesionVencida => 'sesion_vencida',
      EstadoNavegacionSage.otraPagina => 'otra_pagina',
      EstadoNavegacionSage.desconocido => 'desconocido',
      EstadoNavegacionSage.error => 'error',
    };
    final ordenadas = [...opciones]..sort();
    final frame = documento.frameId.isNotEmpty
        ? documento.frameId
        : documento.frameName;
    final firma = [
      frame,
      documento.pathname.toLowerCase(),
      etiqueta,
      ordenadas.join(','),
    ].join('|');
    return ResultadoDeteccionNavegacionSage(
      estado: estado,
      documentoActivo: documento,
      firma: firma,
      shellPrivado: shellPrivado && estado != EstadoNavegacionSage.login,
    );
  }

  DocumentoNavegacionSage? _seleccionarDocumento(
    List<DocumentoNavegacionSage> documentos,
  ) {
    final visibles = documentos.where((documento) => documento.visible).toList()
      ..sort((a, b) => b.profundidad.compareTo(a.profundidad));
    if (visibles.isNotEmpty) return visibles.first;
    return documentos.isEmpty ? null : documentos.first;
  }

  static bool _esRutaPosterior(String pathname) {
    final path = pathname.toLowerCase();
    return path == '/dic/listar2.php' ||
        path == '/dic/tabs.php' ||
        path.startsWith('/alumnos_v2/') ||
        path.startsWith('/alumnosadminpanel/');
  }

  static bool _esEncabezadoModulos(String value) {
    return value == 'modulos' || value.startsWith('modulos ');
  }

  static bool _esEncabezadoSubmodulos(String value) {
    return value == 'submodulos' || value.startsWith('submodulos ');
  }

  static bool _esIngreso(String value) {
    return value == 'ingresar' || value == 'iniciar sesion';
  }

  static List<String> _opcionesSubmodulosReconocidas(
    Iterable<EnlaceNavegacionSage> enlaces,
  ) {
    final found = <String>[];
    for (final option in opcionesSubmodulosSage) {
      final labels = <String>[
        option.titulo,
        ...option.etiquetasAlternativas,
      ].map(normalizar);
      final matched = enlaces.any((link) {
        if (!link.hrefValido) return false;
        final text = normalizar(link.texto);
        final path = link.pathname.toLowerCase();
        return labels.any(text.contains) ||
            (option.pathname != null && path == option.pathname!.toLowerCase());
      });
      if (matched) found.add(_claveOpcion(option));
    }
    return found;
  }

  static String _claveOpcion(OpcionSubmoduloSage option) {
    final title = normalizar(option.titulo);
    if (title.startsWith('legajo alumnos')) return 'legajo';
    if (title.startsWith('certificado')) return 'certificado';
    if (title.startsWith('inscripcion a una nueva materia')) {
      return 'inscripcion_materia';
    }
    if (title.startsWith('mis inscripciones')) return 'mis_inscripciones';
    if (title.startsWith('inscripcion anual obligatoria')) {
      return 'inscripcion_anual';
    }
    return 'consulta';
  }

  static String normalizar(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
