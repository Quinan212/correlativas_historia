import '../compartido/utilidades/sanitizar_texto.dart';

class CorrelativaDetallada {
  final String id;
  final String type;
  final String? formato;
  final String? tipo;
  final bool isSpecial;
  final String? nombre;

  CorrelativaDetallada({
    required this.id,
    required this.type,
    this.formato,
    this.tipo,
    this.nombre,
    this.isSpecial = false,
  });

  factory CorrelativaDetallada.fromMap(Map<String, dynamic> m) {
    final rawId = m['id'];
    final rawType = m['type'];

    String? optText(String key) {
      final value = m[key];
      if (value == null) return null;
      final text = sanitizarTexto(value.toString());
      return text.isEmpty ? null : text;
    }

    return CorrelativaDetallada(
      id: sanitizarTexto(rawId?.toString() ?? ''),
      type: sanitizarTexto(rawType?.toString() ?? ''),
      formato: optText('formato'),
      tipo: optText('tipo'),
      isSpecial: (m['isSpecial'] as bool?) ?? false,
      nombre: optText('nombre'),
    );
  }
}

class Materia {
  final String id;
  final String codigo;
  final String nombre;
  final int anio;
  final int? cuatri;
  final String tipo;
  final String formato;
  final List<String> correlativas;
  final String? horas;
  final List<CorrelativaDetallada> correlativasDetalladas;

  Materia({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.anio,
    required this.tipo,
    required this.formato,
    required this.correlativas,
    required this.correlativasDetalladas,
    this.cuatri,
    this.horas,
  });

  factory Materia.fromMap(Map<String, dynamic> m) {
    final rawAnio = m['a\u00f1o'] ?? m['a\u00c3\u00b1o'] ?? m['anio'];
    final anio = rawAnio is int ? rawAnio : int.parse(rawAnio.toString());

    final rawCuatri = m['cuatri'];
    final cuatri = rawCuatri == null
        ? null
        : (rawCuatri is int ? rawCuatri : int.tryParse(rawCuatri.toString()));

    final rawHoras = m['horas'];
    final horasText =
        rawHoras == null ? null : sanitizarTexto(rawHoras.toString());
    final horas = (horasText == null || horasText.isEmpty) ? null : horasText;

    final rawDet = m['correlativasDetalladas'] ?? m['reqs'];
    final detList = (rawDet as List? ?? [])
        .map((e) =>
            CorrelativaDetallada.fromMap((e as Map).cast<String, dynamic>()))
        .toList();

    return Materia(
      id: sanitizarTexto((m['id'] ?? '').toString()),
      codigo: sanitizarTexto((m['codigo'] ?? '').toString()),
      nombre: sanitizarTexto((m['nombre'] ?? '').toString()),
      anio: anio,
      cuatri: cuatri,
      tipo: sanitizarTexto((m['tipo'] ?? '').toString()),
      formato: sanitizarTexto((m['formato'] ?? '').toString()),
      correlativas: ((m['correlativas'] as List?) ?? [])
          .map((e) => sanitizarTexto(e.toString()))
          .toList(),
      horas: horas,
      correlativasDetalladas: detList,
    );
  }
}

String _normalize(String value) =>
    sanitizeLowerNoAccents(value).replaceAll(RegExp(r'\s+'), ' ').trim();

bool _matchesPDIV(String raw) {
  final value = _normalize(raw);
  final hasPractica = value.contains('practica');
  final hasIv = RegExp(r'\b(iv|4|cuarta)\b').hasMatch(value);
  final docenteResid =
      value.contains('docente') || value.contains('residencia');
  return hasPractica && hasIv && docenteResid;
}

bool _matchesPDIII(String raw) {
  final value = _normalize(raw);
  final hasPractica = value.contains('practica');
  final hasIii = RegExp(r'\b(iii|3|tercera)\b').hasMatch(value);
  return hasPractica && hasIii;
}

extension MateriaNaming on Materia {
  static final RegExp _ppdRe = RegExp(
    'pr[\u00e1a]ctica\\s+profesional\\s+docente',
    caseSensitive: false,
  );
  static final RegExp _multiSpace = RegExp(r'\s{2,}');

  String get displayNombre {
    final raw = sanitizarTexto(nombre);
    if (raw.isEmpty) return raw;

    if (_matchesPDIV(raw) && _ppdRe.hasMatch(raw)) {
      var out = raw.replaceFirst(_ppdRe, 'Pr\u00e1ctica Docente');
      out = out.replaceAll(_multiSpace, ' ').trim();
      return sanitizarTexto(out);
    }

    return raw;
  }

  bool get isPracticaDocenteIV => _matchesPDIV(nombre);
  bool get isPracticaDocenteIII => _matchesPDIII(nombre);
}
