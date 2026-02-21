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
    return CorrelativaDetallada(
      id: rawId?.toString() ?? '',
      type: rawType?.toString() ?? '',
      formato: m['formato'] as String?,
      tipo: m['tipo'] as String?,
      isSpecial: (m['isSpecial'] as bool?) ?? false,
      nombre: m['nombre'] as String?,
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
    final rawAnio = m['año'] ?? m['anio'];
    final int anio = rawAnio is int ? rawAnio : int.parse(rawAnio.toString());

    final rawCuatri = m['cuatri'];
    final int? cuatri = rawCuatri == null
        ? null
        : (rawCuatri is int ? rawCuatri : int.tryParse(rawCuatri.toString()));

    final rawHoras = m['horas'];
    final String? horas =
    rawHoras == null ? null : rawHoras.toString().trim().isEmpty ? null : rawHoras.toString();

    final rawDet = m['correlativasDetalladas'] ?? m['reqs'];
    final detList = (rawDet as List? ?? [])
        .map((e) => CorrelativaDetallada.fromMap(
        (e as Map).cast<String, dynamic>()))
        .toList();

    return Materia(
      id: m['id'] as String,
      codigo: (m['codigo'] ?? '').toString(),
      nombre: m['nombre'] as String,
      anio: anio,
      cuatri: cuatri,
      tipo: (m['tipo'] ?? '').toString(),
      formato: (m['formato'] ?? '').toString(),
      correlativas: ((m['correlativas'] as List?) ?? []).map((e) => e.toString()).toList(),
      horas: horas,
      correlativasDetalladas: detList,
    );
  }
}

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

bool _matchesPDIV(String raw) {
  final s = _normalize(raw);
  final hasPractica = s.contains('practica');
  final hasIV = RegExp(r'\b(iv|4|cuarta)\b').hasMatch(s);
  final docenteResid = s.contains('docente') || s.contains('residencia');
  return hasPractica && hasIV && docenteResid;
}

bool _matchesPDIII(String raw) {
  final s = _normalize(raw);
  final hasPractica = s.contains('practica');
  final hasIII = RegExp(r'\b(iii|3|tercera)\b').hasMatch(s);
  return hasPractica && hasIII;
}

extension MateriaNaming on Materia {
  static final RegExp _ppdRe = RegExp(
    r'pr[aá]ctica\s+profesional\s+docente',
    caseSensitive: false,
  );
  static final RegExp _multiSpace = RegExp(r'\s{2,}');

  String get displayNombre {
    final raw = nombre;
    if (raw.isEmpty) return raw;

    if (_matchesPDIV(raw) && _ppdRe.hasMatch(raw)) {
      var out = raw.replaceFirst(_ppdRe, 'Práctica Docente');
      out = out.replaceAll(_multiSpace, ' ').trim();
      return out;
    }
    return raw;
  }

  bool get isPracticaDocenteIV => _matchesPDIV(nombre);
  bool get isPracticaDocenteIII => _matchesPDIII(nombre);
}