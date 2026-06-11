import 'package:flutter/material.dart';

import '../../../compartido/utilidades/sanitizar_texto.dart';

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

  bool get isColoquio => instancia == 'coloquio';

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
    );
  }

  Map<String, dynamic> toRowPayload() {
    return {
      'id': id,
      'career_id': careerId,
      'anio': anio,
      'fecha': fecha == null
          ? null
          : '${fecha!.year.toString().padLeft(4, '0')}-${fecha!.month.toString().padLeft(2, '0')}-${fecha!.day.toString().padLeft(2, '0')}',
      'hora': hora == null || hora!.trim().isEmpty ? null : hora,
      'materia': materia,
      'instancia': instancia,
      'docentes': docentes,
      'acta_url': actaUrl,
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

    return EventoExamenAdministrador(
      id: row['id']?.toString().trim(),
      careerId: sanitizarTexto((row['career_id'] ?? '').toString().trim()),
      anio: parseInt(row['anio']),
      fecha: parseDate(row['fecha']),
      hora: parseHora(row['hora']),
      materia: sanitizarTexto((row['materia'] ?? '').toString().trim()),
      instancia:
          sanitizarTexto((row['instancia'] ?? 'llamado_1').toString().trim()),
      docentes: parseDocentes(row['docentes']),
      actaUrl: sanitizarTexto((row['acta_url'] ?? '').toString().trim()).isEmpty
          ? null
          : sanitizarTexto(row['acta_url'].toString().trim()),
    );
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

  EventoExamenAdministrador toModel() {
    return EventoExamenAdministrador(
      id: id,
      careerId: careerId,
      anio: anio,
      fecha: fecha,
      hora: hora == null
          ? null
          : '${hora!.hour.toString().padLeft(2, '0')}:${hora!.minute.toString().padLeft(2, '0')}',
      materia: materia,
      instancia: instancia,
      docentes: docentes
          .map(normalizeDocenteDisplayName)
          .where((docente) => docente.isNotEmpty)
          .toList(growable: false),
      actaUrl: actaUrl,
    );
  }
}
