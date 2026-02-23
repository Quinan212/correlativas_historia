import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/examen_event.dart';
import '../../../models/materia.dart';

class ExamenesRepo {
  const ExamenesRepo();

  Future<List<ExamenEvent>> loadLlamado1() =>
      _loadJson('assets/examenes_llamado1.json');

  Future<List<ExamenEvent>> loadLlamado2() =>
      _loadJson('assets/examenes_llamado2.json');

  Future<List<ExamenEvent>> loadColoquios() =>
      _loadJson('assets/coloquios_feb_mar_2026.json');

  Future<List<ExamenEvent>> _loadJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw);

    // Caso 1: el JSON ya es una lista de eventos
    if (decoded is List) {
      return decoded
          .map((e) => _eventoDesdeJson((e as Map).cast<String, dynamic>()))
          .toList();
    }

    // Caso 2: tu formato actual (root map con careers -> carrera -> año -> lista)
    if (decoded is Map) {
      final root = decoded.cast<String, dynamic>();

      final careersRaw = root['careers'];
      if (careersRaw is! Map) {
        throw StateError(
          'JSON inválido: esperaba "careers" como Map en $assetPath',
        );
      }

      final careers = careersRaw.cast<String, dynamic>();
      final out = <ExamenEvent>[];

      for (final carreraEntry in careers.entries) {
        final yearsRaw = carreraEntry.value;

        if (yearsRaw is! Map) continue;
        final years = yearsRaw.cast<String, dynamic>();

        for (final yearEntry in years.entries) {
          final eventosRaw = yearEntry.value;

          if (eventosRaw is! List) continue;
          for (final item in eventosRaw) {
            if (item is! Map) continue;
            out.add(_eventoDesdeJson(item.cast<String, dynamic>()));
          }
        }
      }

      return out;
    }

    throw StateError('Formato de JSON inesperado en $assetPath');
  }
}

ExamenEvent _eventoDesdeJson(Map<String, dynamic> m) {
  // esto asume que tu modelo tiene factory ExamenEvent.fromJson
  return ExamenEvent.fromJson(m);
}

// ----------------------
// LOADER DEL PLAN (HTML)
// ----------------------

class PlanData {
  final List<Materia> materias;
  final Uri? pdfUrl;

  PlanData({required this.materias, required this.pdfUrl});
}

Future<PlanData> loadPlanFromHistoriaHtml() =>
    loadPlanFromHtml('assets/historia.html');

Future<PlanData> loadPlanFromGeografiaHtml() =>
    loadPlanFromHtml('assets/geografia.html');

Future<PlanData> loadPlanFromPoliticaHtml() =>
    loadPlanFromHtml('assets/politica.html');

Future<PlanData> loadPlanFromHtmlAsset(String assetPath) =>
    loadPlanFromHtml(assetPath);

Future<PlanData> loadPlanFromHtml(String assetPath) async {
  final html = await rootBundle.loadString(assetPath);

  final jsArray = _extractMateriasArray(html);
  if (jsArray == null) {
    throw StateError('No se encontró el array "materias" en $assetPath');
  }

  final jsonText = _jsArrayToJson(jsArray);
  final dynamicList = json.decode(jsonText) as List;

  _applyReqsToCorrelativasDetalladas(dynamicList);
  _applyFixPracticaIV(dynamicList);

  final materias = dynamicList
      .map((e) => Materia.fromMap(e as Map<String, dynamic>))
      .toList();

  final pdfMatch =
  RegExp(r"const\s+pdfUrl\s*=\s*'([^']+)'", multiLine: true)
      .firstMatch(html);
  final pdfUrl = pdfMatch != null ? Uri.tryParse(pdfMatch.group(1)!) : null;

  return PlanData(materias: materias, pdfUrl: pdfUrl);
}

String? _extractMateriasArray(String html) {
  var src = html;
  src = src.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  src = src.replaceAll(RegExp(r'//[^\n\r]*'), '');

  final m =
  RegExp(r'\bmaterias\b\s*=\s*\[', caseSensitive: false).firstMatch(src);
  if (m == null) return null;

  final startBracket = m.end - 1;
  var depth = 0;
  var inSingle = false;
  var inDouble = false;
  var escape = false;

  for (var i = startBracket; i < src.length; i++) {
    final ch = src[i];

    if (inSingle) {
      if (escape) {
        escape = false;
      } else if (ch == r'\') {
        escape = true;
      } else if (ch == "'") {
        inSingle = false;
      }
      continue;
    }

    if (inDouble) {
      if (escape) {
        escape = false;
      } else if (ch == r'\') {
        escape = true;
      } else if (ch == '"') {
        inDouble = false;
      }
      continue;
    }

    if (ch == "'") {
      inSingle = true;
      continue;
    }
    if (ch == '"') {
      inDouble = true;
      continue;
    }

    if (ch == '[') {
      depth++;
    } else if (ch == ']') {
      depth--;
      if (depth == 0) {
        return src.substring(startBracket, i + 1);
      }
    }
  }
  return null;
}

String _jsArrayToJson(String jsArray) {
  var s = jsArray;

  s = s.replaceAll(RegExp(r'/\*[\s\S]*?\*/', multiLine: true), '');
  s = s.replaceAll(RegExp(r'//[^\n\r]*', multiLine: true), '');

  String quoteKey(String key) {
    final re = RegExp('([\\{,])\\s*$key\\s*:', multiLine: true);
    s = s.replaceAllMapped(re, (m) => '${m.group(1)} "$key":');
    return s;
  }

  for (final k in const [
    'id',
    'codigo',
    'nombre',
    'año',
    'anio',
    'tipo',
    'formato',
    'correlativas',
    'horas',
    'correlativasDetalladas',
    'type',
    'isSpecial',
    'nombreCorto',
    'cuatri',
    'reqs',
    'text',
  ]) {
    quoteKey(k);
  }

  s = s.replaceAllMapped(
    RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'"),
        (m) => '"${m.group(1)!.replaceAll('"', r'\"')}"',
  );

  s = s.replaceAll(RegExp(r',\s*(?=[\]\}])'), '');

  final startOk = s.trimLeft().startsWith('[');
  final endOk = s.trimRight().endsWith(']');
  if (!startOk || !endOk) {
    final inner =
    s.replaceFirst(RegExp(r'^\s*\['), '').replaceFirst(RegExp(r'\]\s*$'), '');
    s = '[$inner]';
  }

  return s;
}

void _applyReqsToCorrelativasDetalladas(List<dynamic> list) {
  for (final item in list) {
    if (item is! Map) continue;
    final map = item.cast<String, dynamic>();

    final reqs = map['reqs'];
    if (reqs is! List || reqs.isEmpty) continue;

    final existingRaw = map['correlativasDetalladas'];
    final det = existingRaw is List ? List<dynamic>.from(existingRaw) : <dynamic>[];

    for (final r in reqs) {
      if (r is! Map) continue;
      final rmap = r.cast<String, dynamic>();

      final bool isSpecial = rmap['isSpecial'] == true;
      final String rawType = (rmap['type'] ?? 'R').toString().toUpperCase();
      final String type = (rawType == 'A' || rawType == 'R') ? rawType : 'R';

      final String? id = rmap['id']?.toString();
      final String? text = rmap['text']?.toString();

      final out = <String, dynamic>{
        'id': id ?? 'esp_${map['id']}_${det.length}',
        'type': type,
        'isSpecial': isSpecial,
      };

      if (text != null && text.trim().isNotEmpty) {
        out['nombre'] = text.trim();
      }

      det.add(out);
    }

    map['correlativasDetalladas'] = det;
  }
}

void _applyFixPracticaIV(List<dynamic> list) {
  for (final item in list) {
    if (item is! Map) continue;
    final map = item.cast<String, dynamic>();
    final nombre = (map['nombre'] ?? '').toString().toLowerCase();

    final match = nombre.contains('práctica docente iv') ||
        nombre.contains('practica docente iv');

    if (match) {
      map['correlativas'] = <String>[];
      map['correlativasDetalladas'] = [
        {
          'id': 'esp_todas_uc_1_2_3',
          'type': 'A',
          'isSpecial': true,
          'nombre': 'Todas las UC de 1°, 2° y 3° año',
        },
      ];
    }
  }
}