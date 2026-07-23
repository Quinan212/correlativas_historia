import 'dart:convert';

import '../../../compartido/utilidades/sanitizar_texto.dart';

enum EstadoEventoExamen { activa, suspendida, cancelada, reprogramada }

extension EstadoEventoExamenX on EstadoEventoExamen {
  String get valorBaseDatos => name;

  String get etiqueta => switch (this) {
    EstadoEventoExamen.activa => 'ACTIVA',
    EstadoEventoExamen.suspendida => 'SUSPENDIDA',
    EstadoEventoExamen.cancelada => 'CANCELADA',
    EstadoEventoExamen.reprogramada => 'REPROGRAMADA',
  };

  String get tituloPredeterminado => switch (this) {
    EstadoEventoExamen.activa => '',
    EstadoEventoExamen.suspendida => 'MESA SUSPENDIDA',
    EstadoEventoExamen.cancelada => 'MESA CANCELADA',
    EstadoEventoExamen.reprogramada => 'MESA REPROGRAMADA',
  };

  String get mensajePredeterminado => switch (this) {
    EstadoEventoExamen.activa => '',
    EstadoEventoExamen.suspendida =>
      'Pendiente de reprogramación por la institución.',
    EstadoEventoExamen.cancelada => 'La mesa fue cancelada por la institución.',
    EstadoEventoExamen.reprogramada =>
      'La mesa tiene una nueva fecha y horario.',
  };
}

EstadoEventoExamen estadoEventoExamenDesdeValor(
  dynamic raw, {
  bool suspendido = false,
  String materia = '',
}) {
  final text = raw?.toString().trim().toLowerCase() ?? '';
  switch (text) {
    case 'suspendida':
    case 'suspendido':
      return EstadoEventoExamen.suspendida;
    case 'cancelada':
    case 'cancelado':
      return EstadoEventoExamen.cancelada;
    case 'reprogramada':
    case 'reprogramado':
      return EstadoEventoExamen.reprogramada;
    case 'activa':
    case 'activo':
      return EstadoEventoExamen.activa;
  }

  final upperMateria = materia.toUpperCase();
  if (suspendido ||
      upperMateria.contains('[SUSPENDIDA]') ||
      upperMateria.contains('[SUSPENDIDO]')) {
    return EstadoEventoExamen.suspendida;
  }
  return EstadoEventoExamen.activa;
}

class EventoExamen {
  final String? id;
  final String careerId;
  final int? anio;
  final DateTime? fecha;
  final String? hora;
  final String materia;
  final String instancia;
  final List<String> docentes;
  final String? division;
  final String? actaUrl;
  final bool legacy;
  final EstadoEventoExamen estado;
  final String? tituloEstado;
  final String? mensajeEstado;
  final DateTime? fechaReprogramada;
  final String? horaReprogramada;
  final bool actaHabilitada;
  final bool visible;

  const EventoExamen({
    this.id,
    required this.careerId,
    required this.anio,
    required this.fecha,
    required this.hora,
    required this.materia,
    required this.instancia,
    required this.docentes,
    this.division,
    required this.actaUrl,
    this.legacy = false,
    EstadoEventoExamen estado = EstadoEventoExamen.activa,
    bool suspendido = false,
    this.tituloEstado,
    this.mensajeEstado,
    this.fechaReprogramada,
    this.horaReprogramada,
    this.actaHabilitada = true,
    this.visible = true,
  }) : estado = suspendido && estado == EstadoEventoExamen.activa
           ? EstadoEventoExamen.suspendida
           : estado;

  bool get suspendido =>
      estado == EstadoEventoExamen.suspendida ||
      estado == EstadoEventoExamen.cancelada;

  bool get mostrarAvisoEstado => estado != EstadoEventoExamen.activa;

  String get tituloEstadoEfectivo {
    final custom = tituloEstado?.trim() ?? '';
    return custom.isEmpty ? estado.tituloPredeterminado : custom;
  }

  String get mensajeEstadoEfectivo {
    final custom = mensajeEstado?.trim() ?? '';
    return custom.isEmpty ? estado.mensajePredeterminado : custom;
  }

  DateTime? get fechaVigente {
    if (estado == EstadoEventoExamen.reprogramada &&
        fechaReprogramada != null) {
      return fechaReprogramada;
    }
    return fecha;
  }

  String? get horaVigente {
    if (estado == EstadoEventoExamen.reprogramada &&
        (horaReprogramada?.trim().isNotEmpty ?? false)) {
      return horaReprogramada;
    }
    return hora;
  }

  bool get tieneFechaOriginalDistinta {
    if (estado != EstadoEventoExamen.reprogramada ||
        fecha == null ||
        fechaReprogramada == null) {
      return false;
    }
    return fecha!.year != fechaReprogramada!.year ||
        fecha!.month != fechaReprogramada!.month ||
        fecha!.day != fechaReprogramada!.day ||
        (hora ?? '') != (horaReprogramada ?? '');
  }

  bool get puedeAbrirActa =>
      actaHabilitada && (actaUrl?.trim().isNotEmpty ?? false);

  EventoExamen copyWith({
    String? id,
    String? careerId,
    int? anio,
    DateTime? fecha,
    String? hora,
    String? materia,
    String? instancia,
    List<String>? docentes,
    String? division,
    String? actaUrl,
    bool? legacy,
    EstadoEventoExamen? estado,
    bool? suspendido,
    String? tituloEstado,
    String? mensajeEstado,
    DateTime? fechaReprogramada,
    String? horaReprogramada,
    bool? actaHabilitada,
    bool? visible,
  }) {
    var nextEstado = estado ?? this.estado;
    if (suspendido == true && nextEstado == EstadoEventoExamen.activa) {
      nextEstado = EstadoEventoExamen.suspendida;
    } else if (suspendido == false &&
        nextEstado == EstadoEventoExamen.suspendida) {
      nextEstado = EstadoEventoExamen.activa;
    }

    return EventoExamen(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      anio: anio ?? this.anio,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      materia: materia ?? this.materia,
      instancia: instancia ?? this.instancia,
      docentes: docentes ?? this.docentes,
      division: division ?? this.division,
      actaUrl: actaUrl ?? this.actaUrl,
      legacy: legacy ?? this.legacy,
      estado: nextEstado,
      tituloEstado: tituloEstado ?? this.tituloEstado,
      mensajeEstado: mensajeEstado ?? this.mensajeEstado,
      fechaReprogramada: fechaReprogramada ?? this.fechaReprogramada,
      horaReprogramada: horaReprogramada ?? this.horaReprogramada,
      actaHabilitada: actaHabilitada ?? this.actaHabilitada,
      visible: visible ?? this.visible,
    );
  }

  DateTime? get fechaHora {
    final effectiveDate = fechaVigente;
    final effectiveTime = horaVigente;
    if (effectiveDate == null) return null;
    if (effectiveTime == null) {
      return DateTime(
        effectiveDate.year,
        effectiveDate.month,
        effectiveDate.day,
      );
    }
    final parts = effectiveTime.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
      hours,
      minutes,
    );
  }

  static DateTime _parseFechaIso(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      throw FormatException('Fecha ISO invalida: $iso');
    }
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  static String _normalizeHora(String raw) {
    var value = raw.trim().toLowerCase().replaceAll(' ', '');
    value = value.replaceAll('hs', '').replaceAll('h', '');
    if (value.contains(':')) {
      final parts = value.split(':');
      final hh = int.parse(parts[0]);
      final mm = int.parse(parts[1]);
      return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    }
    final hh = int.parse(value);
    return '${hh.toString().padLeft(2, '0')}:00';
  }

  factory EventoExamen.fromJson(Map<String, dynamic> j) {
    dynamic rawValue(List<String> keys) {
      for (final key in keys) {
        if (j.containsKey(key) && j[key] != null) {
          return j[key];
        }
      }
      return null;
    }

    String reqString(String key) {
      final value = rawValue([key, _snakeCase(key)]);
      if (value == null) {
        throw FormatException('Falta "$key" en evento: $j');
      }
      final text = sanitizarTexto(value.toString());
      if (text.isEmpty) {
        throw FormatException('Campo "$key" vacio en evento: $j');
      }
      return text;
    }

    String optString(String key, String fallback) {
      final value = rawValue([key, _snakeCase(key)]);
      if (value == null) return fallback;
      final text = sanitizarTexto(value.toString());
      return text.isEmpty ? fallback : text;
    }

    String? nullableString(List<String> keys) {
      final value = rawValue(keys);
      if (value == null) return null;
      final text = sanitizarTexto(value.toString()).trim();
      return text.isEmpty ? null : text;
    }

    int? optInt(String key) {
      final value = rawValue([key, _snakeCase(key)]);
      if (value == null) return null;
      if (value is num) return value.toInt();
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      return int.tryParse(text);
    }

    DateTime? optFecha(String key) {
      final value = rawValue([key, _snakeCase(key)]);
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return _parseFechaIso(text);
    }

    String? optHora(String key) {
      final value = rawValue([key, _snakeCase(key)]);
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return _normalizeHora(text);
    }

    bool optBool(List<String> keys, {required bool fallback}) {
      final value = rawValue(keys);
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final text = value.trim().toLowerCase();
        if (text == 'true' || text == '1' || text == 'si' || text == 'sí') {
          return true;
        }
        if (text == 'false' || text == '0' || text == 'no') return false;
      }
      return fallback;
    }

    bool optLegacy() => optBool(['legacy'], fallback: false);

    String? optActaUrl() => nullableString(['actaUrl', 'acta_url']);

    List<String> optDocentes() {
      final value = j['docentes'];
      if (value is List) {
        return value
            .where((e) => e != null)
            .map((e) => normalizeDocenteDisplayName(e.toString()))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value == null) return const <String>[];
      final text = normalizeDocenteDisplayName(value.toString());
      if (text.isEmpty) return const <String>[];
      return [text];
    }

    final materia = reqString('materia');
    final legacySuspended = optBool([
      'suspendido',
      'suspendida',
      'is_suspended',
    ], fallback: false);
    final estado = estadoEventoExamenDesdeValor(
      rawValue(['estado']),
      suspendido: legacySuspended,
      materia: materia,
    );

    return EventoExamen(
      id: nullableString(['id']),
      careerId: reqString('careerId'),
      anio: optInt('anio'),
      fecha: optFecha('fecha'),
      hora: optHora('hora'),
      materia: materia,
      instancia: optString('instancia', 'llamado_1'),
      docentes: optDocentes(),
      division: nullableString(['division']),
      actaUrl: optActaUrl(),
      legacy: optLegacy(),
      estado: estado,
      tituloEstado: nullableString(['tituloEstado', 'titulo_estado']),
      mensajeEstado: nullableString(['mensajeEstado', 'mensaje_estado']),
      fechaReprogramada: optFecha('fechaReprogramada'),
      horaReprogramada: optHora('horaReprogramada'),
      actaHabilitada: optBool([
        'actaHabilitada',
        'acta_habilitada',
      ], fallback: true),
      visible: optBool(['visible'], fallback: true),
    );
  }

  static List<EventoExamen> listFromAssetString(String raw) {
    final decoded = jsonDecode(raw);

    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((m) => EventoExamen.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    if (decoded is Map) {
      final root = Map<String, dynamic>.from(decoded);
      final careersDyn = root['careers'];

      if (careersDyn is Map) {
        final careers = Map<String, dynamic>.from(careersDyn);
        final out = <EventoExamen>[];

        for (final careerEntry in careers.entries) {
          final byYearDyn = careerEntry.value;
          if (byYearDyn is! Map) continue;
          final byYear = Map<String, dynamic>.from(byYearDyn);

          for (final yearEntry in byYear.entries) {
            final listDyn = yearEntry.value;
            if (listDyn is! List) continue;

            for (final item in listDyn) {
              if (item is Map) {
                out.add(EventoExamen.fromJson(Map<String, dynamic>.from(item)));
              }
            }
          }
        }
        return out;
      }
    }

    throw FormatException('JSON invalido para eventos');
  }
}

String _snakeCase(String input) {
  final out = <String>[];
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    final isUpper = ch.toUpperCase() == ch && ch.toLowerCase() != ch;
    if (isUpper && i > 0) {
      out.add('_');
      out.add(ch.toLowerCase());
    } else {
      out.add(ch.toLowerCase());
    }
  }
  return out.join();
}
