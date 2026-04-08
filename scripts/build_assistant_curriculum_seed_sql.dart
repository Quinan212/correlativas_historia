import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current.path;
  final careers = <_CareerConfig>[
    _CareerConfig('historia', 'Historia', '$root/assets/historia.html'),
    _CareerConfig('geografia', 'Geografia', '$root/assets/geografia.html'),
    _CareerConfig('politica', 'Ciencia Politica', '$root/assets/politica.html'),
  ];

  final nodes = <_Node>[];
  final edges = <_Edge>[];

  for (final career in careers) {
    final html = File(career.assetPath).readAsStringSync();
    final materias = _parseMateriasFromHtml(html);
    final byId = {for (final m in materias) m.id: m};

    for (final m in materias) {
      nodes.add(_Node(
        careerId: career.careerId,
        careerName: career.careerName,
        materiaId: m.id,
        materiaNombre: m.nombre,
        materiaNormalized: _normalize(m.nombre),
        anio: m.anio,
        tipo: m.tipo,
        formato: m.formato,
      ));
    }

    for (final base in materias) {
      for (final target in materias) {
        if (base.id == target.id) continue;

        final bySimple = target.correlativas.contains(base.id);
        final reqType = target.reqTypeById[base.id];

        if (!bySimple && reqType == null) continue;

        edges.add(_Edge(
          careerId: career.careerId,
          fromMateriaId: base.id,
          fromMateriaNombre: base.nombre,
          toMateriaId: target.id,
          toMateriaNombre: target.nombre,
          requirementType: reqType,
          sourceRef: career.assetPath.replaceAll('\\', '/').split('/').last,
        ));
      }
    }
  }

  final out = StringBuffer()
    ..writeln(
        "delete from public.assistant_curriculum_edges where career_id in ('historia','geografia','politica');")
    ..writeln(
        "delete from public.assistant_curriculum_nodes where career_id in ('historia','geografia','politica');");

  for (final n in nodes) {
    out.writeln(
      "insert into public.assistant_curriculum_nodes (career_id, career_name, materia_id, materia_nombre, materia_normalized, anio, tipo, formato) values "
      "('${_sql(n.careerId)}','${_sql(n.careerName)}','${_sql(n.materiaId)}','${_sql(n.materiaNombre)}','${_sql(n.materiaNormalized)}', ${n.anio ?? 'null'}, ${n.tipo == null ? 'null' : "'${_sql(n.tipo!)}'"}, ${n.formato == null ? 'null' : "'${_sql(n.formato!)}'"}) "
      "on conflict (career_id, materia_id) do update set "
      "career_name=excluded.career_name, materia_nombre=excluded.materia_nombre, materia_normalized=excluded.materia_normalized, anio=excluded.anio, tipo=excluded.tipo, formato=excluded.formato;",
    );
  }

  for (final e in edges) {
    final req = e.requirementType == null ? 'null' : "'${_sql(e.requirementType!)}'";
    out.writeln(
      "insert into public.assistant_curriculum_edges (career_id, from_materia_id, from_materia_nombre, to_materia_id, to_materia_nombre, requirement_type, source_ref) values "
      "('${_sql(e.careerId)}','${_sql(e.fromMateriaId)}','${_sql(e.fromMateriaNombre)}','${_sql(e.toMateriaId)}','${_sql(e.toMateriaNombre)}',$req,'${_sql(e.sourceRef)}') "
      "on conflict (career_id, from_materia_id, to_materia_id) do update set "
      "from_materia_nombre=excluded.from_materia_nombre, to_materia_nombre=excluded.to_materia_nombre, requirement_type=excluded.requirement_type, source_ref=excluded.source_ref;",
    );
  }

  final outPath = '$root/RUIDO/assistant_curriculum_seed.sql';
  File(outPath).writeAsStringSync(out.toString());

  stdout.writeln('Curriculum seed generated: $outPath');
  stdout.writeln('Nodes: ${nodes.length}');
  stdout.writeln('Edges: ${edges.length}');
}

List<_Materia> _parseMateriasFromHtml(String html) {
  final jsArray = _extractMateriasArray(html);
  if (jsArray == null) {
    throw StateError('No se encontro el array materias en el HTML');
  }

  final jsonText = _jsArrayToJson(jsArray);
  final rawList = (json.decode(jsonText) as List<dynamic>)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList(growable: false);

  final result = <_Materia>[];
  for (final row in rawList) {
    final id = (row['id'] ?? '').toString().trim();
    final nombre = (row['nombre'] ?? '').toString().trim();
    if (id.isEmpty || nombre.isEmpty) continue;

    final rawAnio = _pick(row, ['anio', 'año', 'a\u00f1o', 'a\u00c3\u00b1o']);
    final anio = rawAnio is int ? rawAnio : int.tryParse('${rawAnio ?? ''}');

    final correlativas = ((row['correlativas'] as List?) ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    final tipo = _stringOrNull(_pick(row, ['tipo']));
    final formato = _stringOrNull(_pick(row, ['formato']));

    final reqTypeById = <String, String>{};
    final rawDet = _pick(row, ['correlativasDetalladas', 'correlativasdetalladas', 'reqs']);
    for (final req in ((rawDet as List?) ?? const [])) {
      if (req is! Map) continue;
      final map = Map<String, dynamic>.from(req.cast<String, dynamic>());
      final rid = (map['id'] ?? '').toString().trim();
      if (rid.isEmpty) continue;
      final isSpecial = map['isSpecial'] == true;
      if (isSpecial) continue;
      final rawType = (map['type'] ?? 'R').toString().toUpperCase();
      final type = (rawType == 'A' || rawType == 'R') ? rawType : 'R';
      reqTypeById[rid] = type;
    }

    result.add(_Materia(
      id: id,
      nombre: nombre,
      anio: anio,
      correlativas: correlativas,
      reqTypeById: reqTypeById,
      tipo: tipo,
      formato: formato,
    ));
  }

  return result;
}

String? _extractMateriasArray(String html) {
  var src = html;
  src = src.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  src = src.replaceAll(RegExp(r'//[^\n\r]*'), '');

  final match = RegExp(r'\bmaterias\b\s*=\s*\[', caseSensitive: false).firstMatch(src);
  if (match == null) return null;

  final startBracket = match.end - 1;
  var depth = 0;
  var inSingle = false;
  var inDouble = false;
  var escape = false;

  for (var i = startBracket; i < src.length; i++) {
    final ch = src[i];

    if (inSingle) {
      if (escape) {
        escape = false;
      } else if (ch == r'\\') {
        escape = true;
      } else if (ch == "'") {
        inSingle = false;
      }
      continue;
    }

    if (inDouble) {
      if (escape) {
        escape = false;
      } else if (ch == r'\\') {
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

  s = s.replaceAllMapped(
    RegExp(r'([,{]\s*)([A-Za-z_\u00C0-\u024F][A-Za-z0-9_\-\u00C0-\u024F]*)(\s*:)'),
    (m) => '${m.group(1)}"${m.group(2)}"${m.group(3)}',
  );

  s = s.replaceAllMapped(
    RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'"),
    (m) => '"${m.group(1)!.replaceAll('"', r'\\"')}"',
  );

  s = s.replaceAll(RegExp(r',\s*(?=[\]\}])'), '');

  final startOk = s.trimLeft().startsWith('[');
  final endOk = s.trimRight().endsWith(']');
  if (!startOk || !endOk) {
    final inner = s.replaceFirst(RegExp(r'^\s*\['), '').replaceFirst(RegExp(r'\]\s*$'), '');
    s = '[$inner]';
  }

  return s;
}

String _normalize(String value) {
  final lower = value.toLowerCase();
  return lower
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

dynamic _pick(Map<String, dynamic> row, List<String> keys) {
  for (final key in keys) {
    if (row.containsKey(key)) return row[key];
  }
  final normalized = <String, dynamic>{
    for (final entry in row.entries) _normalize(entry.key): entry.value,
  };
  for (final key in keys) {
    final value = normalized[_normalize(key)];
    if (value != null) return value;
  }
  return null;
}

String _sql(String value) => value.replaceAll("'", "''");

String? _stringOrNull(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

class _CareerConfig {
  const _CareerConfig(this.careerId, this.careerName, this.assetPath);

  final String careerId;
  final String careerName;
  final String assetPath;
}

class _Materia {
  const _Materia({
    required this.id,
    required this.nombre,
    required this.anio,
    required this.correlativas,
    required this.reqTypeById,
    required this.tipo,
    required this.formato,
  });

  final String id;
  final String nombre;
  final int? anio;
  final List<String> correlativas;
  final Map<String, String> reqTypeById;
  final String? tipo;
  final String? formato;
}

class _Node {
  const _Node({
    required this.careerId,
    required this.careerName,
    required this.materiaId,
    required this.materiaNombre,
    required this.materiaNormalized,
    required this.anio,
    required this.tipo,
    required this.formato,
  });

  final String careerId;
  final String careerName;
  final String materiaId;
  final String materiaNombre;
  final String materiaNormalized;
  final int? anio;
  final String? tipo;
  final String? formato;
}

class _Edge {
  const _Edge({
    required this.careerId,
    required this.fromMateriaId,
    required this.fromMateriaNombre,
    required this.toMateriaId,
    required this.toMateriaNombre,
    required this.requirementType,
    required this.sourceRef,
  });

  final String careerId;
  final String fromMateriaId;
  final String fromMateriaNombre;
  final String toMateriaId;
  final String toMateriaNombre;
  final String? requirementType;
  final String sourceRef;
}
