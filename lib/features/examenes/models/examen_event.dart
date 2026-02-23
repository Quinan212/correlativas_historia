import 'dart:convert';

class ExamenEvent {
  final String careerId; // historia | geografia | politica
  final int? anio; // 1..4 o null si no está claro
  final DateTime? fecha; // null si no hay fecha
  final String? hora; // "HH:mm" o null si no hay hora
  final String materia;
  final String instancia; // "llamado_1" | "llamado_2" | "coloquio"
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
    final p = hora!.split(':');
    final h = int.parse(p[0]);
    final m = int.parse(p[1]);
    return DateTime(fecha!.year, fecha!.month, fecha!.day, h, m);
  }

  static DateTime _parseFechaIso(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Fecha ISO inválida: $iso');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    return DateTime(y, m, d);
  }

  static String _normalizeHora(String raw) {
    var s = raw.trim().toLowerCase().replaceAll(' ', '');
    s = s.replaceAll('hs', '').replaceAll('h', '');
    if (s.contains(':')) {
      final p = s.split(':');
      final hh = int.parse(p[0]);
      final mm = int.parse(p[1]);
      return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    }
    final hh = int.parse(s);
    return '${hh.toString().padLeft(2, '0')}:00';
  }

  factory ExamenEvent.fromJson(Map<String, dynamic> j) {
    String reqString(String key) {
      final v = j[key];
      if (v == null) throw FormatException('Falta "$key" en evento: $j');
      final s = v.toString().trim();
      if (s.isEmpty) throw FormatException('Campo "$key" vacío en evento: $j');
      return s;
    }

    String optString(String key, String fallback) {
      final v = j[key];
      if (v == null) return fallback;
      final s = v.toString().trim();
      return s.isEmpty ? fallback : s;
    }

    int? optInt(String key) {
      final v = j[key];
      if (v == null) return null;
      if (v is num) return v.toInt();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    DateTime? optFecha(String key) {
      final v = j[key];
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return null;
      return _parseFechaIso(s);
    }

    String? optHora(String key) {
      final v = j[key];
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return null;
      return _normalizeHora(s);
    }

    List<String> optDocentes() {
      final v = j['docentes'];
      if (v is List) {
        return v
            .where((e) => e != null)
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (v == null) return const <String>[];
      final s = v.toString().trim();
      if (s.isEmpty) return const <String>[];
      return [s];
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

    // A) array plano
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((m) => ExamenEvent.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    // B) objeto agrupado { careers: { careerId: { "1": [...], "2": [...] } } }
    if (decoded is Map) {
      final root = Map<String, dynamic>.from(decoded);
      final careersDyn = root['careers'];

      if (careersDyn is Map) {
        final careers = Map<String, dynamic>.from(careersDyn);
        final out = <ExamenEvent>[];

        for (final cEntry in careers.entries) {
          final byYearDyn = cEntry.value;
          if (byYearDyn is! Map) continue;
          final byYear = Map<String, dynamic>.from(byYearDyn);

          for (final yEntry in byYear.entries) {
            final listDyn = yEntry.value;
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

    throw FormatException('JSON inválido para eventos');
  }
}