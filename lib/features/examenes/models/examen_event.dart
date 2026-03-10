import 'dart:convert';

import '../../../shared/utils/text_sanitize.dart';

class ExamenEvent {
  final String careerId;
  final int? anio;
  final DateTime? fecha;
  final String? hora;
  final String materia;
  final String instancia;
  final List<String> docentes;

  const ExamenEvent({
    required this.careerId,
    required this.anio,
    required this.fecha,
    required this.hora,
    required this.materia,
    required this.instancia,
    required this.docentes,
  });

  DateTime? get fechaHora {
    if (fecha == null) return null;
    if (hora == null) return DateTime(fecha!.year, fecha!.month, fecha!.day);
    final parts = hora!.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return DateTime(fecha!.year, fecha!.month, fecha!.day, hours, minutes);
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

  factory ExamenEvent.fromJson(Map<String, dynamic> j) {
    String reqString(String key) {
      final value = j[key];
      if (value == null) {
        throw FormatException('Falta "$key" en evento: $j');
      }
      final text = sanitizeText(value.toString());
      if (text.isEmpty) {
        throw FormatException('Campo "$key" vacio en evento: $j');
      }
      return text;
    }

    String optString(String key, String fallback) {
      final value = j[key];
      if (value == null) return fallback;
      final text = sanitizeText(value.toString());
      return text.isEmpty ? fallback : text;
    }

    int? optInt(String key) {
      final value = j[key];
      if (value == null) return null;
      if (value is num) return value.toInt();
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      return int.tryParse(text);
    }

    DateTime? optFecha(String key) {
      final value = j[key];
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return _parseFechaIso(text);
    }

    String? optHora(String key) {
      final value = j[key];
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return _normalizeHora(text);
    }

    List<String> optDocentes() {
      final value = j['docentes'];
      if (value is List) {
        return value
            .where((e) => e != null)
            .map((e) => sanitizeText(e.toString()))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value == null) return const <String>[];
      final text = sanitizeText(value.toString());
      if (text.isEmpty) return const <String>[];
      return [text];
    }

    return ExamenEvent(
      careerId: reqString('careerId'),
      anio: optInt('anio'),
      fecha: optFecha('fecha'),
      hora: optHora('hora'),
      materia: reqString('materia'),
      instancia: optString('instancia', 'llamado_1'),
      docentes: optDocentes(),
    );
  }

  static List<ExamenEvent> listFromAssetString(String raw) {
    final decoded = jsonDecode(raw);

    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((m) => ExamenEvent.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    if (decoded is Map) {
      final root = Map<String, dynamic>.from(decoded);
      final careersDyn = root['careers'];

      if (careersDyn is Map) {
        final careers = Map<String, dynamic>.from(careersDyn);
        final out = <ExamenEvent>[];

        for (final careerEntry in careers.entries) {
          final byYearDyn = careerEntry.value;
          if (byYearDyn is! Map) continue;
          final byYear = Map<String, dynamic>.from(byYearDyn);

          for (final yearEntry in byYear.entries) {
            final listDyn = yearEntry.value;
            if (listDyn is! List) continue;

            for (final item in listDyn) {
              if (item is Map) {
                out.add(ExamenEvent.fromJson(Map<String, dynamic>.from(item)));
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
