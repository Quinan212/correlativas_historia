enum EstadoMateriaSageLaboratorio {
  aprobada,
  regular,
  cursando,
  noRegularizada,
  desconocida,
}

extension EstadoMateriaSageLaboratorioX on EstadoMateriaSageLaboratorio {
  String get clave => switch (this) {
    EstadoMateriaSageLaboratorio.aprobada => 'aprobada',
    EstadoMateriaSageLaboratorio.regular => 'regular',
    EstadoMateriaSageLaboratorio.cursando => 'cursando',
    EstadoMateriaSageLaboratorio.noRegularizada => 'no_regularizada',
    EstadoMateriaSageLaboratorio.desconocida => 'desconocida',
  };

  String get etiqueta => switch (this) {
    EstadoMateriaSageLaboratorio.aprobada => 'Aprobada',
    EstadoMateriaSageLaboratorio.regular => 'Regular',
    EstadoMateriaSageLaboratorio.cursando => 'Cursando',
    EstadoMateriaSageLaboratorio.noRegularizada => 'No regularizada',
    EstadoMateriaSageLaboratorio.desconocida => 'Sin clasificar',
  };

  static EstadoMateriaSageLaboratorio desdeClave(String value) {
    return switch (value.trim().toLowerCase()) {
      'aprobada' => EstadoMateriaSageLaboratorio.aprobada,
      'regular' => EstadoMateriaSageLaboratorio.regular,
      'cursando' => EstadoMateriaSageLaboratorio.cursando,
      'no_regularizada' => EstadoMateriaSageLaboratorio.noRegularizada,
      _ => EstadoMateriaSageLaboratorio.desconocida,
    };
  }
}

enum TipoDocumentoAcademicoSage { situacionAcademica, analitico, libreta }

extension TipoDocumentoAcademicoSageX on TipoDocumentoAcademicoSage {
  String get clave => switch (this) {
    TipoDocumentoAcademicoSage.situacionAcademica => 'situacion_academica',
    TipoDocumentoAcademicoSage.analitico => 'analitico',
    TipoDocumentoAcademicoSage.libreta => 'libreta',
  };

  String get etiqueta => switch (this) {
    TipoDocumentoAcademicoSage.situacionAcademica => 'Situación académica',
    TipoDocumentoAcademicoSage.analitico => 'Analítico',
    TipoDocumentoAcademicoSage.libreta => 'Libreta',
  };

  String get tituloReporte => switch (this) {
    TipoDocumentoAcademicoSage.situacionAcademica =>
      'Imprimir la Situación Académica del alumno en la carrera',
    TipoDocumentoAcademicoSage.analitico =>
      'Imprimir listado de materias aprobadas',
    TipoDocumentoAcademicoSage.libreta => 'Imprimir libreta de calificaciones',
  };

  static TipoDocumentoAcademicoSage? desdeClave(String value) {
    return switch (value.trim().toLowerCase()) {
      'situacion_academica' => TipoDocumentoAcademicoSage.situacionAcademica,
      'analitico' => TipoDocumentoAcademicoSage.analitico,
      'libreta' => TipoDocumentoAcademicoSage.libreta,
      _ => null,
    };
  }
}

class DocumentoAcademicoSage {
  const DocumentoAcademicoSage({
    required this.tipo,
    required this.gridRowId,
    required this.careerKey,
    required this.carrera,
    required this.institucion,
    this.disponible = true,
  });

  final TipoDocumentoAcademicoSage tipo;
  final String gridRowId;
  final String careerKey;
  final String carrera;
  final String institucion;
  final bool disponible;

  String get identidadCarrera => careerKey.trim().isNotEmpty
      ? careerKey.trim().toLowerCase()
      : <String>[
          carrera.trim().toLowerCase(),
          institucion.trim().toLowerCase(),
        ].join('|');

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tipo': tipo.clave,
    'grid_row_id': gridRowId,
    'career_key': careerKey,
    'carrera': carrera,
    'institucion': institucion,
    'disponible': disponible,
  };

  factory DocumentoAcademicoSage.fromJson(Map<String, dynamic> json) {
    return DocumentoAcademicoSage(
      tipo:
          TipoDocumentoAcademicoSageX.desdeClave(
            (json['tipo'] ?? '').toString(),
          ) ??
          TipoDocumentoAcademicoSage.analitico,
      gridRowId: (json['grid_row_id'] ?? '').toString(),
      careerKey: (json['career_key'] ?? '').toString(),
      carrera: (json['carrera'] ?? '').toString(),
      institucion: (json['institucion'] ?? '').toString(),
      disponible: json['disponible'] != false,
    );
  }
}

class PerfilTrayectoriaSageLaboratorio {
  const PerfilTrayectoriaSageLaboratorio({
    required this.nombre,
    this.dni,
    this.campos = const <String, String>{},
  });

  final String nombre;
  final String? dni;
  final Map<String, String> campos;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'nombre': nombre,
    'dni': dni,
    'campos': campos,
  };

  factory PerfilTrayectoriaSageLaboratorio.fromJson(Map<String, dynamic> json) {
    final rawFields = json['campos'];
    final fields = <String, String>{};
    if (rawFields is Map) {
      rawFields.forEach((key, value) {
        fields[key.toString()] = value?.toString() ?? '';
      });
    }
    return PerfilTrayectoriaSageLaboratorio(
      nombre: (json['nombre'] ?? 'Estudiante SAGE').toString(),
      dni: _nullableText(json['dni']),
      campos: Map<String, String>.unmodifiable(fields),
    );
  }
}

class MateriaTrayectoriaSageLaboratorio {
  const MateriaTrayectoriaSageLaboratorio({
    required this.idSage,
    required this.nombre,
    required this.estadoOriginal,
    required this.estado,
    this.anio,
  });

  final String idSage;
  final String nombre;
  final String estadoOriginal;
  final EstadoMateriaSageLaboratorio estado;
  final int? anio;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id_sage': idSage,
    'nombre': nombre,
    'estado_original': estadoOriginal,
    'estado': estado.clave,
    'anio': anio,
  };

  factory MateriaTrayectoriaSageLaboratorio.fromJson(
    Map<String, dynamic> json,
  ) {
    return MateriaTrayectoriaSageLaboratorio(
      idSage: (json['id_sage'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      estadoOriginal: (json['estado_original'] ?? '').toString(),
      estado: EstadoMateriaSageLaboratorioX.desdeClave(
        (json['estado'] ?? '').toString(),
      ),
      anio: _nullableInt(json['anio']),
    );
  }
}

class CarreraTrayectoriaSageLaboratorio {
  const CarreraTrayectoriaSageLaboratorio({
    required this.gridRowId,
    required this.nombre,
    required this.institucion,
    required this.materias,
    this.internalId,
    this.careerContextId,
    this.careerKey = '',
    this.anioInicio,
    this.estado,
    this.estadoInscripcion,
    this.aprobadasInformadas,
    this.regularesInformadas,
    this.cursandoInformadas,
  });

  final String gridRowId;
  final String? internalId;
  final String? careerContextId;
  final String careerKey;
  final String nombre;
  final String institucion;
  final int? anioInicio;
  final String? estado;
  final String? estadoInscripcion;
  final int? aprobadasInformadas;
  final int? regularesInformadas;
  final int? cursandoInformadas;
  final List<MateriaTrayectoriaSageLaboratorio> materias;

  int contar(EstadoMateriaSageLaboratorio target) =>
      materias.where((materia) => materia.estado == target).length;

  int get aprobadas =>
      aprobadasInformadas ?? contar(EstadoMateriaSageLaboratorio.aprobada);
  int get regulares =>
      regularesInformadas ?? contar(EstadoMateriaSageLaboratorio.regular);
  int get cursando =>
      cursandoInformadas ?? contar(EstadoMateriaSageLaboratorio.cursando);
  int get noRegularizadas =>
      contar(EstadoMateriaSageLaboratorio.noRegularizada);
  int get sinClasificar => contar(EstadoMateriaSageLaboratorio.desconocida);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'grid_row_id': gridRowId,
    'internal_id': internalId,
    'career_context_id': careerContextId,
    'career_key': careerKey,
    'nombre': nombre,
    'institucion': institucion,
    'anio_inicio': anioInicio,
    'estado': estado,
    'estado_inscripcion': estadoInscripcion,
    'aprobadas_informadas': aprobadasInformadas,
    'regulares_informadas': regularesInformadas,
    'cursando_informadas': cursandoInformadas,
    'materias': materias.map((materia) => materia.toJson()).toList(),
  };

  factory CarreraTrayectoriaSageLaboratorio.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawSubjects = json['materias'];
    final subjects = <MateriaTrayectoriaSageLaboratorio>[];
    if (rawSubjects is List) {
      for (final item in rawSubjects) {
        if (item is Map) {
          subjects.add(
            MateriaTrayectoriaSageLaboratorio.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    return CarreraTrayectoriaSageLaboratorio(
      gridRowId: (json['grid_row_id'] ?? '').toString(),
      internalId: _nullableText(json['internal_id']),
      careerContextId: _nullableText(json['career_context_id']),
      careerKey: (json['career_key'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      institucion: (json['institucion'] ?? '').toString(),
      anioInicio: _nullableInt(json['anio_inicio']),
      estado: _nullableText(json['estado']),
      estadoInscripcion: _nullableText(json['estado_inscripcion']),
      aprobadasInformadas: _nullableInt(json['aprobadas_informadas']),
      regularesInformadas: _nullableInt(json['regulares_informadas']),
      cursandoInformadas: _nullableInt(json['cursando_informadas']),
      materias: List<MateriaTrayectoriaSageLaboratorio>.unmodifiable(subjects),
    );
  }
}

class TrayectoriaSageLaboratorio {
  const TrayectoriaSageLaboratorio({
    required this.perfil,
    required this.carreras,
    required this.capturadaEn,
    this.sincronizadaEn,
    this.documentos = const <DocumentoAcademicoSage>[],
    this.versionEsquema = 2,
  });

  final int versionEsquema;
  final PerfilTrayectoriaSageLaboratorio perfil;
  final List<CarreraTrayectoriaSageLaboratorio> carreras;
  final List<DocumentoAcademicoSage> documentos;
  final DateTime capturadaEn;
  final DateTime? sincronizadaEn;

  bool get listaParaSincronizar => carreras.isNotEmpty && totalMaterias > 0;

  int get totalMaterias => carreras.fold<int>(
    0,
    (total, carrera) => total + carrera.materias.length,
  );

  TrayectoriaSageLaboratorio confirmarSincronizacion(DateTime instant) {
    return TrayectoriaSageLaboratorio(
      versionEsquema: versionEsquema,
      perfil: perfil,
      carreras: carreras,
      documentos: documentos,
      capturadaEn: capturadaEn,
      sincronizadaEn: instant,
    );
  }

  TrayectoriaSageLaboratorio conDocumentos(
    List<DocumentoAcademicoSage> nuevosDocumentos,
  ) {
    return TrayectoriaSageLaboratorio(
      versionEsquema: versionEsquema < 2 ? 2 : versionEsquema,
      perfil: perfil,
      carreras: carreras,
      documentos: List<DocumentoAcademicoSage>.unmodifiable(nuevosDocumentos),
      capturadaEn: capturadaEn,
      sincronizadaEn: sincronizadaEn,
    );
  }

  List<DocumentoAcademicoSage> documentosDeCarrera(
    CarreraTrayectoriaSageLaboratorio carrera,
  ) {
    final structural = carrera.careerKey.trim().toLowerCase();
    return documentos
        .where((documento) {
          if (!documento.disponible) return false;
          if (structural.isNotEmpty && documento.careerKey.trim().isNotEmpty) {
            return documento.careerKey.trim().toLowerCase() == structural;
          }
          if (documento.gridRowId.trim().isNotEmpty &&
              carrera.gridRowId.trim().isNotEmpty) {
            return documento.gridRowId.trim() == carrera.gridRowId.trim();
          }
          return documento.carrera.trim().toLowerCase() ==
                  carrera.nombre.trim().toLowerCase() &&
              documento.institucion.trim().toLowerCase() ==
                  carrera.institucion.trim().toLowerCase();
        })
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'version_esquema': versionEsquema,
    'perfil': perfil.toJson(),
    'carreras': carreras.map((carrera) => carrera.toJson()).toList(),
    'documentos': documentos.map((documento) => documento.toJson()).toList(),
    'capturada_en': capturadaEn.toIso8601String(),
    'sincronizada_en': sincronizadaEn?.toIso8601String(),
  };

  factory TrayectoriaSageLaboratorio.fromJson(Map<String, dynamic> json) {
    final rawCareers = json['carreras'];
    final careers = <CarreraTrayectoriaSageLaboratorio>[];
    if (rawCareers is List) {
      for (final item in rawCareers) {
        if (item is Map) {
          careers.add(
            CarreraTrayectoriaSageLaboratorio.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    final rawDocuments = json['documentos'];
    final documents = <DocumentoAcademicoSage>[];
    if (rawDocuments is List) {
      for (final item in rawDocuments) {
        if (item is Map) {
          documents.add(
            DocumentoAcademicoSage.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final rawProfile = json['perfil'];
    return TrayectoriaSageLaboratorio(
      versionEsquema: _nullableInt(json['version_esquema']) ?? 1,
      perfil: rawProfile is Map
          ? PerfilTrayectoriaSageLaboratorio.fromJson(
              Map<String, dynamic>.from(rawProfile),
            )
          : const PerfilTrayectoriaSageLaboratorio(nombre: 'Estudiante SAGE'),
      carreras: List<CarreraTrayectoriaSageLaboratorio>.unmodifiable(careers),
      documentos: List<DocumentoAcademicoSage>.unmodifiable(documents),
      capturadaEn:
          DateTime.tryParse((json['capturada_en'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sincronizadaEn: DateTime.tryParse(
        (json['sincronizada_en'] ?? '').toString(),
      ),
    );
  }
}

class EstadoPreparacionSageLaboratorio {
  const EstadoPreparacionSageLaboratorio({
    required this.mensaje,
    this.progreso,
    this.bloqueado = false,
  });

  final String mensaje;
  final double? progreso;
  final bool bloqueado;
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
