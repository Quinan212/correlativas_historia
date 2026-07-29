import '../../examenes/modelos/evento_examen.dart';

enum EstadoFuenteMesasExcel {
  inicializando,
  comprobando,
  disponible,
  sinCambios,
  disponibleDesdeCopiaLocal,
  sinConexion,
  archivoInvalido,
  estructuraIncompatible,
  datosIncoherentes,
  noDisponible,
}

extension EstadoFuenteMesasExcelX on EstadoFuenteMesasExcel {
  bool get permiteMostrarDatos => switch (this) {
    EstadoFuenteMesasExcel.disponible ||
    EstadoFuenteMesasExcel.sinCambios ||
    EstadoFuenteMesasExcel.disponibleDesdeCopiaLocal ||
    EstadoFuenteMesasExcel.sinConexion => true,
    _ => false,
  };

  bool get estaComprobando =>
      this == EstadoFuenteMesasExcel.inicializando ||
      this == EstadoFuenteMesasExcel.comprobando;

  String get etiqueta => switch (this) {
    EstadoFuenteMesasExcel.inicializando => 'Inicializando',
    EstadoFuenteMesasExcel.comprobando => 'Comprobando',
    EstadoFuenteMesasExcel.disponible => 'Disponible',
    EstadoFuenteMesasExcel.sinCambios => 'Sin cambios',
    EstadoFuenteMesasExcel.disponibleDesdeCopiaLocal => 'Copia local',
    EstadoFuenteMesasExcel.sinConexion => 'Sin conexión',
    EstadoFuenteMesasExcel.archivoInvalido => 'Archivo inválido',
    EstadoFuenteMesasExcel.estructuraIncompatible =>
      'Estructura incompatible',
    EstadoFuenteMesasExcel.datosIncoherentes => 'Datos incoherentes',
    EstadoFuenteMesasExcel.noDisponible => 'No disponible',
  };
}

enum TipoCoincidenciaMateriaExcel {
  exacta,
  codigo,
  alias,
  aproximada,
  ambigua,
  sinCoincidencia,
}

enum EstadoActaExcel {
  noInformada,
  disponible,
  etiquetaSinEnlace,
  enlaceHuerfano,
}

class MateriaCatalogoExcel {
  const MateriaCatalogoExcel({
    required this.id,
    required this.careerId,
    required this.anio,
    required this.codigo,
    required this.nombre,
  });

  final String id;
  final String careerId;
  final int anio;
  final String codigo;
  final String nombre;
}

class ResultadoCoincidenciaMateriaExcel {
  const ResultadoCoincidenciaMateriaExcel({
    required this.tipo,
    required this.nombreFuente,
    required this.confianza,
    required this.margenSegundoCandidato,
    this.materia,
    this.segundoCandidato,
  });

  final TipoCoincidenciaMateriaExcel tipo;
  final String nombreFuente;
  final MateriaCatalogoExcel? materia;
  final MateriaCatalogoExcel? segundoCandidato;
  final double confianza;
  final double margenSegundoCandidato;

  bool get aceptada =>
      materia != null &&
      tipo != TipoCoincidenciaMateriaExcel.ambigua &&
      tipo != TipoCoincidenciaMateriaExcel.sinCoincidencia;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tipo': tipo.name,
    'nombreFuente': nombreFuente,
    'confianza': confianza,
    'margenSegundoCandidato': margenSegundoCandidato,
    'materia': materia == null
        ? null
        : <String, dynamic>{
            'id': materia!.id,
            'careerId': materia!.careerId,
            'anio': materia!.anio,
            'codigo': materia!.codigo,
            'nombre': materia!.nombre,
          },
    'segundoCandidato': segundoCandidato == null
        ? null
        : <String, dynamic>{
            'id': segundoCandidato!.id,
            'careerId': segundoCandidato!.careerId,
            'anio': segundoCandidato!.anio,
            'codigo': segundoCandidato!.codigo,
            'nombre': segundoCandidato!.nombre,
          },
  };

  factory ResultadoCoincidenciaMateriaExcel.fromJson(
    Map<String, dynamic> json,
  ) {
    MateriaCatalogoExcel? materiaDesde(dynamic raw) {
      if (raw is! Map) return null;
      final map = Map<String, dynamic>.from(raw);
      return MateriaCatalogoExcel(
        id: map['id']?.toString() ?? '',
        careerId: map['careerId']?.toString() ?? '',
        anio: (map['anio'] as num?)?.toInt() ?? 0,
        codigo: map['codigo']?.toString() ?? '',
        nombre: map['nombre']?.toString() ?? '',
      );
    }

    final tipoRaw = json['tipo']?.toString() ?? '';
    final tipo = TipoCoincidenciaMateriaExcel.values.firstWhere(
      (value) => value.name == tipoRaw,
      orElse: () => TipoCoincidenciaMateriaExcel.sinCoincidencia,
    );
    return ResultadoCoincidenciaMateriaExcel(
      tipo: tipo,
      nombreFuente: json['nombreFuente']?.toString() ?? '',
      materia: materiaDesde(json['materia']),
      segundoCandidato: materiaDesde(json['segundoCandidato']),
      confianza: (json['confianza'] as num?)?.toDouble() ?? 0,
      margenSegundoCandidato:
          (json['margenSegundoCandidato'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrigenFilaExcel {
  const OrigenFilaExcel({
    required this.hoja,
    required this.filas,
    required this.nombreMateriaFuente,
  });

  final String hoja;
  final List<int> filas;
  final String nombreMateriaFuente;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'hoja': hoja,
    'filas': filas,
    'nombreMateriaFuente': nombreMateriaFuente,
  };

  factory OrigenFilaExcel.fromJson(Map<String, dynamic> json) {
    return OrigenFilaExcel(
      hoja: json['hoja']?.toString() ?? '',
      filas: (json['filas'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(growable: false),
      nombreMateriaFuente: json['nombreMateriaFuente']?.toString() ?? '',
    );
  }
}

class EventoMesaExcel {
  const EventoMesaExcel({
    required this.evento,
    required this.materiaId,
    required this.coincidencia,
    required this.origen,
    required this.estadoActa,
    this.advertencias = const <String>[],
  });

  final EventoExamen evento;
  final String materiaId;
  final ResultadoCoincidenciaMateriaExcel coincidencia;
  final OrigenFilaExcel origen;
  final EstadoActaExcel estadoActa;
  final List<String> advertencias;

  EventoMesaExcel copyWith({
    EventoExamen? evento,
    String? materiaId,
    ResultadoCoincidenciaMateriaExcel? coincidencia,
    OrigenFilaExcel? origen,
    EstadoActaExcel? estadoActa,
    List<String>? advertencias,
  }) {
    return EventoMesaExcel(
      evento: evento ?? this.evento,
      materiaId: materiaId ?? this.materiaId,
      coincidencia: coincidencia ?? this.coincidencia,
      origen: origen ?? this.origen,
      estadoActa: estadoActa ?? this.estadoActa,
      advertencias: advertencias ?? this.advertencias,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'evento': <String, dynamic>{
      'id': evento.id,
      'careerId': evento.careerId,
      'anio': evento.anio,
      'fecha': evento.fecha?.toIso8601String().split('T').first,
      'hora': evento.hora,
      'materia': evento.materia,
      'instancia': evento.instancia,
      'docentes': evento.docentes,
      'division': evento.division,
      'actaUrl': evento.actaUrl,
      'legacy': evento.legacy,
      'estado': evento.estado.name,
      'tituloEstado': evento.tituloEstado,
      'mensajeEstado': evento.mensajeEstado,
      'fechaReprogramada':
          evento.fechaReprogramada?.toIso8601String().split('T').first,
      'horaReprogramada': evento.horaReprogramada,
      'actaHabilitada': evento.actaHabilitada,
      'visible': evento.visible,
    },
    'materiaId': materiaId,
    'coincidencia': coincidencia.toJson(),
    'origen': origen.toJson(),
    'estadoActa': estadoActa.name,
    'advertencias': advertencias,
  };

  factory EventoMesaExcel.fromJson(Map<String, dynamic> json) {
    final eventoRaw = Map<String, dynamic>.from(
      json['evento'] as Map? ?? const <String, dynamic>{},
    );
    final estadoRaw = eventoRaw['estado']?.toString() ?? 'activa';
    final estado = EstadoEventoExamen.values.firstWhere(
      (value) => value.name == estadoRaw,
      orElse: () => EstadoEventoExamen.activa,
    );
    DateTime? fechaDesde(dynamic raw) {
      final text = raw?.toString().trim() ?? '';
      return text.isEmpty ? null : DateTime.tryParse(text);
    }

    final evento = EventoExamen(
      id: eventoRaw['id']?.toString(),
      careerId: eventoRaw['careerId']?.toString() ?? '',
      anio: (eventoRaw['anio'] as num?)?.toInt(),
      fecha: fechaDesde(eventoRaw['fecha']),
      hora: eventoRaw['hora']?.toString(),
      materia: eventoRaw['materia']?.toString() ?? '',
      instancia: eventoRaw['instancia']?.toString() ?? 'llamado_1',
      docentes: (eventoRaw['docentes'] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => value.toString())
          .toList(growable: false),
      division: eventoRaw['division']?.toString(),
      actaUrl: eventoRaw['actaUrl']?.toString(),
      legacy: eventoRaw['legacy'] == true,
      estado: estado,
      tituloEstado: eventoRaw['tituloEstado']?.toString(),
      mensajeEstado: eventoRaw['mensajeEstado']?.toString(),
      fechaReprogramada: fechaDesde(eventoRaw['fechaReprogramada']),
      horaReprogramada: eventoRaw['horaReprogramada']?.toString(),
      actaHabilitada: eventoRaw['actaHabilitada'] != false,
      visible: eventoRaw['visible'] != false,
    );

    final estadoActaRaw = json['estadoActa']?.toString() ?? '';
    final estadoActa = EstadoActaExcel.values.firstWhere(
      (value) => value.name == estadoActaRaw,
      orElse: () => EstadoActaExcel.noInformada,
    );
    return EventoMesaExcel(
      evento: evento,
      materiaId: json['materiaId']?.toString() ?? '',
      coincidencia: ResultadoCoincidenciaMateriaExcel.fromJson(
        Map<String, dynamic>.from(
          json['coincidencia'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      origen: OrigenFilaExcel.fromJson(
        Map<String, dynamic>.from(
          json['origen'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      estadoActa: estadoActa,
      advertencias:
          (json['advertencias'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => value.toString())
              .toList(growable: false),
    );
  }
}

class DiagnosticoHojaExcel {
  const DiagnosticoHojaExcel({
    required this.nombre,
    required this.tipo,
    required this.valida,
    required this.filasLeidas,
    required this.eventosGenerados,
    required this.filasRechazadas,
    required this.filasFusionadas,
    required this.duplicadosFusionados,
    required this.actasEncontradas,
    required this.actasAsociadas,
    this.advertencias = const <String>[],
    this.errores = const <String>[],
  });

  final String nombre;
  final String tipo;
  final bool valida;
  final int filasLeidas;
  final int eventosGenerados;
  final int filasRechazadas;
  final int filasFusionadas;
  final int duplicadosFusionados;
  final int actasEncontradas;
  final int actasAsociadas;
  final List<String> advertencias;
  final List<String> errores;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'nombre': nombre,
    'tipo': tipo,
    'valida': valida,
    'filasLeidas': filasLeidas,
    'eventosGenerados': eventosGenerados,
    'filasRechazadas': filasRechazadas,
    'filasFusionadas': filasFusionadas,
    'duplicadosFusionados': duplicadosFusionados,
    'actasEncontradas': actasEncontradas,
    'actasAsociadas': actasAsociadas,
    'advertencias': advertencias,
    'errores': errores,
  };

  factory DiagnosticoHojaExcel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoHojaExcel(
      nombre: json['nombre']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      valida: json['valida'] == true,
      filasLeidas: (json['filasLeidas'] as num?)?.toInt() ?? 0,
      eventosGenerados: (json['eventosGenerados'] as num?)?.toInt() ?? 0,
      filasRechazadas: (json['filasRechazadas'] as num?)?.toInt() ?? 0,
      filasFusionadas: (json['filasFusionadas'] as num?)?.toInt() ?? 0,
      duplicadosFusionados:
          (json['duplicadosFusionados'] as num?)?.toInt() ?? 0,
      actasEncontradas: (json['actasEncontradas'] as num?)?.toInt() ?? 0,
      actasAsociadas: (json['actasAsociadas'] as num?)?.toInt() ?? 0,
      advertencias:
          (json['advertencias'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => value.toString())
              .toList(growable: false),
      errores: (json['errores'] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }
}

class DiagnosticoLibroExcel {
  const DiagnosticoLibroExcel({
    required this.publicable,
    required this.parserVersion,
    required this.hojasEncontradas,
    required this.hojas,
    required this.eventosGenerados,
    required this.actasEncontradas,
    required this.actasAsociadas,
    required this.coincidenciasExactas,
    required this.coincidenciasPorAlias,
    required this.coincidenciasAproximadas,
    required this.materiasAmbiguas,
    required this.materiasSinCoincidencia,
    this.advertencias = const <String>[],
    this.erroresBloqueantes = const <String>[],
  });

  final bool publicable;
  final int parserVersion;
  final List<String> hojasEncontradas;
  final List<DiagnosticoHojaExcel> hojas;
  final int eventosGenerados;
  final int actasEncontradas;
  final int actasAsociadas;
  final int coincidenciasExactas;
  final int coincidenciasPorAlias;
  final int coincidenciasAproximadas;
  final int materiasAmbiguas;
  final int materiasSinCoincidencia;
  final List<String> advertencias;
  final List<String> erroresBloqueantes;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'publicable': publicable,
    'parserVersion': parserVersion,
    'hojasEncontradas': hojasEncontradas,
    'hojas': hojas.map((value) => value.toJson()).toList(growable: false),
    'eventosGenerados': eventosGenerados,
    'actasEncontradas': actasEncontradas,
    'actasAsociadas': actasAsociadas,
    'coincidenciasExactas': coincidenciasExactas,
    'coincidenciasPorAlias': coincidenciasPorAlias,
    'coincidenciasAproximadas': coincidenciasAproximadas,
    'materiasAmbiguas': materiasAmbiguas,
    'materiasSinCoincidencia': materiasSinCoincidencia,
    'advertencias': advertencias,
    'erroresBloqueantes': erroresBloqueantes,
  };

  factory DiagnosticoLibroExcel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoLibroExcel(
      publicable: json['publicable'] == true,
      parserVersion: (json['parserVersion'] as num?)?.toInt() ?? 0,
      hojasEncontradas:
          (json['hojasEncontradas'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => value.toString())
              .toList(growable: false),
      hojas: (json['hojas'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) => DiagnosticoHojaExcel.fromJson(
              Map<String, dynamic>.from(value),
            ),
          )
          .toList(growable: false),
      eventosGenerados: (json['eventosGenerados'] as num?)?.toInt() ?? 0,
      actasEncontradas: (json['actasEncontradas'] as num?)?.toInt() ?? 0,
      actasAsociadas: (json['actasAsociadas'] as num?)?.toInt() ?? 0,
      coincidenciasExactas:
          (json['coincidenciasExactas'] as num?)?.toInt() ?? 0,
      coincidenciasPorAlias:
          (json['coincidenciasPorAlias'] as num?)?.toInt() ?? 0,
      coincidenciasAproximadas:
          (json['coincidenciasAproximadas'] as num?)?.toInt() ?? 0,
      materiasAmbiguas: (json['materiasAmbiguas'] as num?)?.toInt() ?? 0,
      materiasSinCoincidencia:
          (json['materiasSinCoincidencia'] as num?)?.toInt() ?? 0,
      advertencias:
          (json['advertencias'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => value.toString())
              .toList(growable: false),
      erroresBloqueantes:
          (json['erroresBloqueantes'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => value.toString())
              .toList(growable: false),
    );
  }
}

class MetadatosFuenteMesasExcel {
  const MetadatosFuenteMesasExcel({
    required this.parserVersion,
    required this.checkedAt,
    required this.validatedAt,
    required this.sourceHash,
    required this.sourceSize,
    this.eTag,
    this.lastModified,
  });

  final int parserVersion;
  final DateTime checkedAt;
  final DateTime validatedAt;
  final String sourceHash;
  final int sourceSize;
  final String? eTag;
  final String? lastModified;

  MetadatosFuenteMesasExcel copyWith({
    DateTime? checkedAt,
    DateTime? validatedAt,
    String? sourceHash,
    int? sourceSize,
    String? eTag,
    String? lastModified,
  }) {
    return MetadatosFuenteMesasExcel(
      parserVersion: parserVersion,
      checkedAt: checkedAt ?? this.checkedAt,
      validatedAt: validatedAt ?? this.validatedAt,
      sourceHash: sourceHash ?? this.sourceHash,
      sourceSize: sourceSize ?? this.sourceSize,
      eTag: eTag ?? this.eTag,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'parserVersion': parserVersion,
    'checkedAt': checkedAt.toIso8601String(),
    'validatedAt': validatedAt.toIso8601String(),
    'sourceHash': sourceHash,
    'sourceSize': sourceSize,
    'eTag': eTag,
    'lastModified': lastModified,
  };

  factory MetadatosFuenteMesasExcel.fromJson(Map<String, dynamic> json) {
    return MetadatosFuenteMesasExcel(
      parserVersion: (json['parserVersion'] as num?)?.toInt() ?? 0,
      checkedAt: DateTime.tryParse(json['checkedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      validatedAt:
          DateTime.tryParse(json['validatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sourceHash: json['sourceHash']?.toString() ?? '',
      sourceSize: (json['sourceSize'] as num?)?.toInt() ?? 0,
      eTag: json['eTag']?.toString(),
      lastModified: json['lastModified']?.toString(),
    );
  }
}

class ResultadoImportacionMesasExcel {
  const ResultadoImportacionMesasExcel({
    required this.eventos,
    required this.diagnostico,
  });

  final List<EventoMesaExcel> eventos;
  final DiagnosticoLibroExcel diagnostico;
}

class CopiaLocalMesasExcel {
  const CopiaLocalMesasExcel({
    required this.eventos,
    required this.metadatos,
    required this.diagnostico,
  });

  final List<EventoMesaExcel> eventos;
  final MetadatosFuenteMesasExcel metadatos;
  final DiagnosticoLibroExcel diagnostico;
}
