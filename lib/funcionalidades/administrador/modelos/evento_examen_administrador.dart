import 'package:flutter/material.dart';

import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../../examenes/modelos/evento_examen.dart';

class EventoExamenAdministrador {
  const EventoExamenAdministrador({
    this.id,
    required this.careerId,
    required this.anio,
    required this.fecha,
    required this.hora,
    required this.materia,
    required this.instancia,
    required this.docentes,
    required this.actaUrl,
    this.estado = EstadoEventoExamen.activa,
    this.tituloEstado,
    this.mensajeEstado,
    this.fechaReprogramada,
    this.horaReprogramada,
    this.actaHabilitada = true,
    this.visible = true,
    this.legacy = false,
    this.updatedAt,
    this.updatedByDeviceId,
  });

  final String? id;
  final String careerId;
  final int? anio;
  final DateTime? fecha;
  final String? hora;
  final String materia;
  final String instancia;
  final List<String> docentes;
  final String? actaUrl;
  final EstadoEventoExamen estado;
  final String? tituloEstado;
  final String? mensajeEstado;
  final DateTime? fechaReprogramada;
  final String? horaReprogramada;
  final bool actaHabilitada;
  final bool visible;
  final bool legacy;
  final DateTime? updatedAt;
  final String? updatedByDeviceId;

  bool get isColoquio => instancia == 'coloquio';
  String get estadoEtiqueta => estado.etiqueta;
  bool get mostrarAvisoEstado => estado != EstadoEventoExamen.activa;
  DateTime? get fechaVigente =>
      estado == EstadoEventoExamen.reprogramada && fechaReprogramada != null
      ? fechaReprogramada
      : fecha;
  String? get horaVigente =>
      estado == EstadoEventoExamen.reprogramada &&
          (horaReprogramada?.trim().isNotEmpty ?? false)
      ? horaReprogramada
      : hora;

  String get tituloEstadoEfectivo {
    final custom = tituloEstado?.trim() ?? '';
    return custom.isEmpty ? estado.tituloPredeterminado : custom;
  }

  String get mensajeEstadoEfectivo {
    final custom = mensajeEstado?.trim() ?? '';
    return custom.isEmpty ? estado.mensajePredeterminado : custom;
  }

  EventoExamenAdministrador copyWith({
    String? id,
    String? careerId,
    int? anio,
    DateTime? fecha,
    String? hora,
    String? materia,
    String? instancia,
    List<String>? docentes,
    String? actaUrl,
    EstadoEventoExamen? estado,
    String? tituloEstado,
    String? mensajeEstado,
    DateTime? fechaReprogramada,
    String? horaReprogramada,
    bool? actaHabilitada,
    bool? visible,
    bool? legacy,
    DateTime? updatedAt,
    String? updatedByDeviceId,
  }) {
    return EventoExamenAdministrador(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      anio: anio ?? this.anio,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      materia: materia ?? this.materia,
      instancia: instancia ?? this.instancia,
      docentes: docentes ?? this.docentes,
      actaUrl: actaUrl ?? this.actaUrl,
      estado: estado ?? this.estado,
      tituloEstado: tituloEstado ?? this.tituloEstado,
      mensajeEstado: mensajeEstado ?? this.mensajeEstado,
      fechaReprogramada: fechaReprogramada ?? this.fechaReprogramada,
      horaReprogramada: horaReprogramada ?? this.horaReprogramada,
      actaHabilitada: actaHabilitada ?? this.actaHabilitada,
      visible: visible ?? this.visible,
      legacy: legacy ?? this.legacy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByDeviceId: updatedByDeviceId ?? this.updatedByDeviceId,
    );
  }

  Map<String, dynamic> toRowPayload() {
    return {
      'id': id,
      'career_id': careerId,
      'anio': anio,
      'fecha': _formatDate(fecha),
      'hora': _cleanNullable(hora),
      'materia': materia,
      'instancia': instancia,
      'docentes': docentes,
      'acta_url': _cleanNullable(actaUrl),
      'estado': estado.valorBaseDatos,
      'titulo_estado': _cleanNullable(tituloEstado),
      'mensaje_estado': _cleanNullable(mensajeEstado),
      'fecha_reprogramada': _formatDate(fechaReprogramada),
      'hora_reprogramada': _cleanNullable(horaReprogramada),
      'acta_habilitada': actaHabilitada,
      'visible': visible,
      'legacy': legacy,
      'expected_updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory EventoExamenAdministrador.fromRow(Map<String, dynamic> row) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      final text = raw.toString().trim();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    int? parseInt(dynamic raw) {
      if (raw == null) return null;
      if (raw is num) return raw.toInt();
      final text = raw.toString().trim();
      if (text.isEmpty) return null;
      return int.tryParse(text);
    }

    bool parseBool(dynamic raw, {required bool fallback}) {
      if (raw is bool) return raw;
      if (raw is num) return raw != 0;
      final text = raw?.toString().trim().toLowerCase() ?? '';
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
      return fallback;
    }

    List<String> parseDocentes(dynamic raw) {
      if (raw is List) {
        return raw
            .where((item) => item != null)
            .map((item) => normalizeDocenteDisplayName(item.toString()))
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
      final text = raw?.toString().trim() ?? '';
      if (text.isEmpty) return const <String>[];
      return text
          .split(',')
          .map((item) => normalizeDocenteDisplayName(item.trim()))
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    String? parseHora(dynamic raw) {
      if (raw == null) return null;
      final text = raw.toString().trim();
      if (text.isEmpty) return null;
      final parts = text.split(':');
      if (parts.length < 2) return text;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return text;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    String? parseNullableText(dynamic raw) {
      final text = sanitizarTexto(raw?.toString() ?? '').trim();
      return text.isEmpty ? null : text;
    }

    final materia = sanitizarTexto((row['materia'] ?? '').toString().trim());
    final legacySuspended = parseBool(row['suspendido'], fallback: false);

    return EventoExamenAdministrador(
      id: parseNullableText(row['id']),
      careerId: sanitizarTexto((row['career_id'] ?? '').toString().trim()),
      anio: parseInt(row['anio']),
      fecha: parseDate(row['fecha']),
      hora: parseHora(row['hora']),
      materia: materia,
      instancia: sanitizarTexto(
        (row['instancia'] ?? 'llamado_1').toString().trim(),
      ),
      docentes: parseDocentes(row['docentes']),
      actaUrl: parseNullableText(row['acta_url']),
      estado: estadoEventoExamenDesdeValor(
        row['estado'],
        suspendido: legacySuspended,
        materia: materia,
      ),
      tituloEstado: parseNullableText(row['titulo_estado']),
      mensajeEstado: parseNullableText(row['mensaje_estado']),
      fechaReprogramada: parseDate(row['fecha_reprogramada']),
      horaReprogramada: parseHora(row['hora_reprogramada']),
      actaHabilitada: parseBool(row['acta_habilitada'], fallback: true),
      visible: parseBool(row['visible'], fallback: true),
      legacy: parseBool(row['legacy'], fallback: false),
      updatedAt: parseDate(row['updated_at']),
      updatedByDeviceId: parseNullableText(row['updated_by_device_id']),
    );
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  static String? _cleanNullable(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class BorradorEventoExamenAdministrador {
  const BorradorEventoExamenAdministrador({
    this.id,
    required this.careerId,
    required this.anio,
    required this.fecha,
    required this.hora,
    required this.materia,
    required this.instancia,
    required this.docentes,
    required this.actaUrl,
    required this.estado,
    required this.tituloEstado,
    required this.mensajeEstado,
    required this.fechaReprogramada,
    required this.horaReprogramada,
    required this.actaHabilitada,
    required this.visible,
    this.legacy = false,
    this.updatedAt,
  });

  final String? id;
  final String careerId;
  final int? anio;
  final DateTime? fecha;
  final TimeOfDay? hora;
  final String materia;
  final String instancia;
  final List<String> docentes;
  final String? actaUrl;
  final EstadoEventoExamen estado;
  final String? tituloEstado;
  final String? mensajeEstado;
  final DateTime? fechaReprogramada;
  final TimeOfDay? horaReprogramada;
  final bool actaHabilitada;
  final bool visible;
  final bool legacy;
  final DateTime? updatedAt;

  EventoExamenAdministrador toModel() {
    String? formatTime(TimeOfDay? value) => value == null
        ? null
        : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

    return EventoExamenAdministrador(
      id: id,
      careerId: careerId,
      anio: anio,
      fecha: fecha,
      hora: formatTime(hora),
      materia: materia,
      instancia: instancia,
      docentes: docentes
          .map(normalizeDocenteDisplayName)
          .where((docente) => docente.isNotEmpty)
          .toList(growable: false),
      actaUrl: actaUrl,
      estado: estado,
      tituloEstado: tituloEstado,
      mensajeEstado: mensajeEstado,
      fechaReprogramada: fechaReprogramada,
      horaReprogramada: formatTime(horaReprogramada),
      actaHabilitada: actaHabilitada,
      visible: visible,
      legacy: legacy,
      updatedAt: updatedAt,
    );
  }
}
