import '../../../models/materia.dart';
import '../models/examen_event.dart';

String _norm(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String labelCarrera(String id) {
  switch (id) {
    case 'historia':
      return 'Historia';
    case 'geografia':
      return 'Geografía';
    case 'politica':
      return 'Ciencia Política';
    default:
      return id;
  }
}

// --------------------
// MATCH FLEXIBLE PLAN
// --------------------

String _limpiarParaMatch(String s) {
  var t = s.toLowerCase();

  t = t
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');

  // arregla pegados tipo "cult.americanos"
  t = t.replaceAll(
    RegExp(r'cult\.?\s*americanos', caseSensitive: false),
    'culturales americanos',
  );

  // separadores a espacio
  t = t.replaceAll('—', ' ');
  t = t.replaceAll(RegExp(r'[\.\,\;\:\-\(\)\/]'), ' ');

  // abreviaturas
  t = t
      .replaceAll(RegExp(r'\bproc\b'), 'procesos')
      .replaceAll(RegExp(r'\bsoc\b'), 'sociales')
      .replaceAll(RegExp(r'\bpolit\b'), 'politicos')
      .replaceAll(RegExp(r'\bpol\b'), 'politicos')
      .replaceAll(RegExp(r'\becon\b'), 'economicos')
      .replaceAll(RegExp(r'\bcult\b'), 'culturales')
      .replaceAll(RegExp(r'\bamer\b'), 'americanos')
      .replaceAll(RegExp(r'\bcs\b'), 'ciencias')
      .replaceAll(RegExp(r'\barg\b'), 'argentina'); // ✅ clave para Argentina I

  // romanos -> números
  t = t
      .replaceAll(RegExp(r'\biv\b'), '4')
      .replaceAll(RegExp(r'\biii\b'), '3')
      .replaceAll(RegExp(r'\bii\b'), '2')
      .replaceAll(RegExp(r'\bi\b'), '1');

  // limpieza final
  t = t.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();

  return t;
}


Set<String> _tokensMatch(String s) {
  final t = _limpiarParaMatch(s);

  const stop = {
    'de',
    'del',
    'la',
    'las',
    'el',
    'los',
    'y',
    'en',
    'a',
    'al',
    'i',
    'ii',
    'iii',
    'iv',
    'v',
    'vi',
    // ruido
    'educacion',
    'educativa',
    'educacional',
    'ciencias',
    'sociales',
    'procesos',
    'culturales',
    'politicos',
    'economicos',
    'argentinos',
    'americanos',
  };

  return t
      .split(' ')
      .where((p) => p.length >= 3 && !stop.contains(p))
      .toSet();
}

double _scoreTokens(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final inter = a.intersection(b).length;
  final denom = a.length > b.length ? a.length : b.length;
  return inter / denom;
}

bool _fallaPorPalabraClave(String evento, String plan) {
  final e = _limpiarParaMatch(evento);
  final p = _limpiarParaMatch(plan);

  const fuertes = [
    'sujeto',
    'sociologia',
    'psicologia',
    'filosofia',
    'pedagogia',
    'didactica',
    'epistemologia',
    'antiguedad',
    'feudalismo',
    'derechos humanos',
  ];

  for (final f in fuertes) {
    if (e.contains(f) && !p.contains(f)) return true;
  }
  return false;
}

// ---- práctica docente: acepta "Práctica III", "Práctica Docente I - Comisión B", etc ----

int? _numeroPractica(String s) {
  final t = _limpiarParaMatch(s);

  if (RegExp(r'\biv\b').hasMatch(t) || RegExp(r'\b4\b').hasMatch(t)) return 4;
  if (RegExp(r'\biii\b').hasMatch(t) || RegExp(r'\b3\b').hasMatch(t)) return 3;
  if (RegExp(r'\bii\b').hasMatch(t) || RegExp(r'\b2\b').hasMatch(t)) return 2;
  if (RegExp(r'\bi\b').hasMatch(t) || RegExp(r'\b1\b').hasMatch(t)) return 1;

  return null;
}

bool _esAlgunaPractica(String s) {
  final t = _limpiarParaMatch(s);
  return t.contains('practica');
}

bool _matchPracticaDocenteN(String evento, Materia plan) {
  if (!_esAlgunaPractica(evento)) return false;

  final nEv = _numeroPractica(evento);
  if (nEv == null) return false;

  final pl = _limpiarParaMatch(plan.displayNombre);

  // el plan puede decir "practica docente", "practica profesional docente", etc
  final esPracticaPlan = pl.contains('practica');
  final esDocentePlan = pl.contains('docente') || pl.contains('profesional');

  if (!(esPracticaPlan && esDocentePlan)) return false;

  final nPl = _numeroPractica(plan.displayNombre);
  return nPl == nEv;
}

// ---- atajo seguro para “Sujeto de la Educación” ----

Materia? _matchSujetoEducacion(String evento, List<Materia> plan) {
  final e = _limpiarParaMatch(evento);
  if (!(e.contains('sujeto') && e.contains('educacion'))) return null;

  // buscamos en el plan una que tenga ambas palabras
  for (final m in plan) {
    final p = _limpiarParaMatch(m.displayNombre);
    if (p.contains('sujeto') && p.contains('educacion')) return m;
  }
  return null;
}

Materia? _buscarMateriaPlanFlexible({
  required String nombreEvento,
  required int? anioEvento,
  required List<Materia> materiasPlan,
}) {
  final n0 = _limpiarParaMatch(nombreEvento);

  // 0) atajos por casos que te rompen chips
  final sujeto = _matchSujetoEducacion(nombreEvento, materiasPlan);
  if (sujeto != null) return sujeto;

  // 1) prácticas (I/II/III/IV), aunque venga sin "docente"
  for (final m in materiasPlan) {
    if (anioEvento != null && m.anio != anioEvento) continue;
    if (_matchPracticaDocenteN(nombreEvento, m)) return m;
  }

  // 2) exacto (por limpiar)
  for (final m in materiasPlan) {
    if (anioEvento != null && m.anio != anioEvento) continue;
    if (_limpiarParaMatch(m.displayNombre) == n0) return m;
  }

  final candidatos = (anioEvento != null)
      ? materiasPlan.where((m) => m.anio == anioEvento).toList()
      : materiasPlan;

  // 3) contains
  for (final m in candidatos) {
    if (_fallaPorPalabraClave(nombreEvento, m.displayNombre)) continue;
    final a = _limpiarParaMatch(m.displayNombre);
    if (a.contains(n0) || n0.contains(a)) return m;
  }

  // 4) tokens
  final tokEvento = _tokensMatch(nombreEvento);

  Materia? mejor;
  var mejorScore = 0.0;

  for (final m in candidatos) {
    if (_fallaPorPalabraClave(nombreEvento, m.displayNombre)) continue;
    final score = _scoreTokens(tokEvento, _tokensMatch(m.displayNombre));
    if (score > mejorScore) {
      mejorScore = score;
      mejor = m;
    }
  }

  if (mejorScore >= 0.50) return mejor;

  return null;
}

// --------------------
// DUPLICADOS SOLO COLOQUIOS (A/B)
// --------------------

String? _sufijoDesdeTap(String tap) {
  final s = tap.trim();
  final i = s.lastIndexOf('—');
  if (i == -1) return null;
  final suf = s.substring(i + 1).trim();
  if (suf.isEmpty) return null;
  return suf;
}

String _baseDesdeTap(String tap) {
  final s = tap.trim();
  final i = s.lastIndexOf('—');
  if (i == -1) return s;
  return s.substring(0, i).trim();
}

bool _docentesContienen(ExamenEvent e, String needle) {
  final n = _limpiarParaMatch(needle);
  for (final d in e.docentes) {
    if (_limpiarParaMatch(d).contains(n)) return true;
  }
  return false;
}

bool _esIdeasII(String nombre) {
  final n = _limpiarParaMatch(nombre);
  return n.contains('historia de las ideas') &&
      (n.contains('ii') || RegExp(r'\b2\b').hasMatch(n));
}

bool _esDidacticaCsSociales(String nombre) {
  final n = _limpiarParaMatch(nombre);
  return n.contains('didactica') &&
      (n.contains('ciencias sociales') ||
          (n.contains('ciencias') && n.contains('sociales')));
}

String _divisionColoquio(ExamenEvent e, String base) {
  if (_esIdeasII(base)) return _docentesContienen(e, 'borche') ? 'B' : 'A';
  if (_esDidacticaCsSociales(base)) return _docentesContienen(e, 'patricia') ? 'B' : 'A';
  return 'A';
}

// --------------------
// LISTA
// --------------------

class SeccionDeLista {
  SeccionDeLista({
    required this.titulo,
    required this.materias,
    required this.esColoquios,
  });

  final String titulo;
  final List<MateriaParaLista> materias;
  final bool esColoquios;
}

class MateriaParaLista {
  MateriaParaLista({
    required this.nombreEvento, // puede traer "— A/B" solo en coloquios
    required this.nombreBase,
    required this.fechaMin,
    required this.esColoquio,
    required this.materiaPlan,
  });

  final String nombreEvento;
  final String nombreBase;
  final DateTime? fechaMin;
  final bool esColoquio;
  final Materia? materiaPlan;

  String get nombreMostrable {
    final base = (materiaPlan?.displayNombre ?? nombreBase).trim();
    final suf = _sufijoDesdeTap(nombreEvento);
    if (suf == null) return base;
    return '$base — $suf';
  }

  String get tipo => (materiaPlan?.tipo ?? '').trim();
  String get formato => (materiaPlan?.formato ?? '').trim();
  int? get anioPlan => materiaPlan?.anio;
  int? get cuatriPlan => materiaPlan?.cuatri;
  String get codigo => (materiaPlan?.codigo ?? '').trim();
}

List<SeccionDeLista> armarSeccionesConPlan({
  required List<ExamenEvent> eventos,
  required Map<String, Materia> mapaPlan,
}) {
  final porAnio = <int, Map<String, DateTime?>>{};
  final coloquios = <String, DateTime?>{};
  final sinAnioOtros = <String, DateTime?>{};

  // duplicados SOLO para coloquios
  final cuentaColoquios = <String, int>{};

  void setMin(Map<String, DateTime?> map, String key, DateTime? dt) {
    final prev = map[key];
    if (prev == null) {
      map[key] = dt;
      return;
    }
    if (dt == null) return;
    if (dt.isBefore(prev)) map[key] = dt;
  }

  // contar duplicados solo en coloquios
  for (final e in eventos) {
    if (e.anio == null && e.instancia == 'coloquio') {
      final base = e.materia.trim();
      cuentaColoquios[base] = (cuentaColoquios[base] ?? 0) + 1;
    }
  }

  // cargar mínimos (llamados normales sin A/B)
  for (final e in eventos) {
    final base = e.materia.trim();
    final dt = e.fechaHora;

    if (e.anio == null) {
      if (e.instancia == 'coloquio') {
        final dup = (cuentaColoquios[base] ?? 0) > 1;
        final key = dup ? '$base — ${_divisionColoquio(e, base)}' : base;
        setMin(coloquios, key, dt);
      } else {
        setMin(sinAnioOtros, base, dt);
      }
      continue;
    }

    final y = e.anio!;
    final map = porAnio.putIfAbsent(y, () => <String, DateTime?>{});
    setMin(map, base, dt);
  }

  int cmp(MapEntry<String, DateTime?> a, MapEntry<String, DateTime?> b) {
    final da = a.value;
    final db = b.value;
    if (da == null && db == null) return a.key.compareTo(b.key);
    if (da == null) return 1;
    if (db == null) return -1;
    final c = da.compareTo(db);
    return c != 0 ? c : a.key.compareTo(b.key);
  }

  List<MateriaParaLista> toMateriaList(
      List<MapEntry<String, DateTime?>> entries, {
        required bool esColoquio,
        required int? anioEvento,
      }) {
    final materiasPlan = mapaPlan.values.toList();

    return entries.map((e) {
      final tap = e.key; // puede traer "— A/B" solo en coloquios
      final base = _baseDesdeTap(tap);

      // lookup fuerte + flexible
      final plan = mapaPlan[_norm(base)] ??
          mapaPlan[_norm(_limpiarParaMatch(base))] ??
          _buscarMateriaPlanFlexible(
            nombreEvento: base,
            anioEvento: anioEvento,
            materiasPlan: materiasPlan,
          );

      return MateriaParaLista(
        nombreEvento: tap,
        nombreBase: base,
        fechaMin: e.value,
        esColoquio: esColoquio,
        materiaPlan: plan,
      );
    }).toList();
  }

  final out = <SeccionDeLista>[];

  final years = porAnio.keys.toList()..sort();
  for (final y in years) {
    final entries = porAnio[y]!.entries.toList()..sort(cmp);
    out.add(
      SeccionDeLista(
        titulo: '$yº Año',
        materias: toMateriaList(entries, esColoquio: false, anioEvento: y),
        esColoquios: false,
      ),
    );
  }

  if (coloquios.isNotEmpty) {
    final entries = coloquios.entries.toList()..sort(cmp);
    out.add(
      SeccionDeLista(
        titulo: 'COLOQUIOS',
        materias: toMateriaList(entries, esColoquio: true, anioEvento: null),
        esColoquios: true,
      ),
    );
  }

  if (sinAnioOtros.isNotEmpty) {
    final entries = sinAnioOtros.entries.toList()..sort(cmp);
    out.add(
      SeccionDeLista(
        titulo: 'Sin año asignado',
        materias: toMateriaList(entries, esColoquio: false, anioEvento: null),
        esColoquios: false,
      ),
    );
  }

  return out;
}

// --------------------
// PICK PARA SHEET
// --------------------

class DetalleArgs {
  const DetalleArgs({required this.titulo, required this.evento});
  final String titulo;
  final ExamenEvent? evento;
}

class PickParaSheet {
  PickParaSheet({
    required this.llamado1,
    required this.llamado2,
    required this.detalleInicial,
  });

  final ExamenEvent? llamado1;
  final ExamenEvent? llamado2;
  final DetalleArgs? detalleInicial;
}

ExamenEvent? _pickAny(List<ExamenEvent> list) {
  if (list.isEmpty) return null;
  final withDate = list.where((e) => e.fechaHora != null).toList();
  if (withDate.isNotEmpty) return withDate.first;
  return list.first;
}

PickParaSheet prepararPickParaSheet({
  required List<ExamenEvent> all,
  required String careerId,
  required String materia, // puede venir con "— A/B" solo en coloquios
  required bool fromColoquios,
}) {
  final base = _baseDesdeTap(materia);
  final suf = _sufijoDesdeTap(materia);

  final sameMateriaBase = all.where(
        (e) => e.careerId == careerId && e.materia.trim() == base.trim(),
  );

  var sameMateria = fromColoquios
      ? sameMateriaBase.where((e) => e.instancia == 'coloquio').toList()
      : sameMateriaBase.where((e) => e.instancia != 'coloquio').toList();

  // si viene A/B, filtramos SOLO para coloquios
  if (fromColoquios && suf != null) {
    final S = suf.toUpperCase();

    if (_esIdeasII(base)) {
      if (S == 'B') {
        final f = sameMateria.where((e) => _docentesContienen(e, 'borche')).toList();
        if (f.isNotEmpty) sameMateria = f;
      } else if (S == 'A') {
        final f = sameMateria.where((e) => !_docentesContienen(e, 'borche')).toList();
        if (f.isNotEmpty) sameMateria = f;
      }
    }

    if (_esDidacticaCsSociales(base)) {
      if (S == 'B') {
        final f = sameMateria.where((e) => _docentesContienen(e, 'patricia')).toList();
        if (f.isNotEmpty) sameMateria = f;
      } else if (S == 'A') {
        final f = sameMateria.where((e) => !_docentesContienen(e, 'patricia')).toList();
        if (f.isNotEmpty) sameMateria = f;
      }
    }
  }

  final e1 = _pickAny(sameMateria.where((e) => e.instancia == 'llamado_1').toList());
  final e2 = _pickAny(sameMateria.where((e) => e.instancia == 'llamado_2').toList());
  final ec = _pickAny(sameMateria.where((e) => e.instancia == 'coloquio').toList());

  final isColoquioOnly =
      fromColoquios || (ec != null && (e1 == null && e2 == null));

  return PickParaSheet(
    llamado1: e1,
    llamado2: e2,
    detalleInicial: isColoquioOnly ? DetalleArgs(titulo: 'Coloquio', evento: ec) : null,
  );
}