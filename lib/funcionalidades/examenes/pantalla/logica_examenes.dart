import '../../../modelos/materia.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../modelos/evento_examen.dart';
import 'visibilidad_examenes.dart';

const _emdash = '\u2014';

String _norm(String s) =>
    sanitizeLowerNoAccents(s).replaceAll(RegExp(r'\s+'), ' ').trim();

String labelCarrera(String id) {
  switch (id) {
    case 'historia':
      return 'Historia';
    case 'geografia':
      return 'Geograf\u00eda';
    case 'politica':
      return 'Ciencia Pol\u00edtica';
    default:
      return sanitizarTexto(id);
  }
}

String _limpiarParaMatch(String s) {
  var value = sanitizeLowerNoAccents(s);

  value = value.replaceAll(
    RegExp(r'cult\.?\s*americanos', caseSensitive: false),
    'culturales americanos',
  );

  value = value.replaceAll(RegExp('[$_emdash\u2013]'), ' ');
  value = value.replaceAll(RegExp(r'[\.\,\;\:\-\(\)\/]'), ' ');

  value = value
      .replaceAll(RegExp(r'\bproc\b'), 'procesos')
      .replaceAll(RegExp(r'\bsoc\b'), 'sociales')
      .replaceAll(RegExp(r'\bpolit\b'), 'politicos')
      .replaceAll(RegExp(r'\bpol\b'), 'politicos')
      .replaceAll(RegExp(r'\becon\b'), 'economicos')
      .replaceAll(RegExp(r'\bcult\b'), 'culturales')
      .replaceAll(RegExp(r'\bamer\b'), 'americanos')
      .replaceAll(RegExp(r'\bcs\b'), 'ciencias')
      .replaceAll(RegExp(r'\barg\b'), 'argentina');

  value = value
      .replaceAll(RegExp(r'\biv\b'), '4')
      .replaceAll(RegExp(r'\biii\b'), '3')
      .replaceAll(RegExp(r'\bii\b'), '2')
      .replaceAll(RegExp(r'\bi\b'), '1');

  value = value.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return value;
}

Set<String> _tokensMatch(String s) {
  final value = _limpiarParaMatch(s);

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

  return value
      .split(' ')
      .where((part) => part.length >= 3 && !stop.contains(part))
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

  for (final palabra in fuertes) {
    if (e.contains(palabra) && !p.contains(palabra)) return true;
  }
  return false;
}

int? _numeroPractica(String s) {
  final value = _limpiarParaMatch(s);
  if (RegExp(r'\b4\b').hasMatch(value)) return 4;
  if (RegExp(r'\b3\b').hasMatch(value)) return 3;
  if (RegExp(r'\b2\b').hasMatch(value)) return 2;
  if (RegExp(r'\b1\b').hasMatch(value)) return 1;
  return null;
}

bool _esAlgunaPractica(String s) {
  final value = _limpiarParaMatch(s);
  return value.contains('practica');
}

bool _matchPracticaDocenteN(String evento, Materia plan) {
  if (!_esAlgunaPractica(evento)) return false;

  final nEv = _numeroPractica(evento);
  if (nEv == null) return false;

  final planValue = _limpiarParaMatch(plan.displayNombre);
  final esPracticaPlan = planValue.contains('practica');
  final esDocentePlan =
      planValue.contains('docente') || planValue.contains('profesional');

  if (!(esPracticaPlan && esDocentePlan)) return false;

  final nPl = _numeroPractica(plan.displayNombre);
  return nPl == nEv;
}

Materia? _matchSujetoEducacion(String evento, List<Materia> plan) {
  final e = _limpiarParaMatch(evento);
  if (!(e.contains('sujeto') && e.contains('educacion'))) return null;

  for (final materia in plan) {
    final p = _limpiarParaMatch(materia.displayNombre);
    if (p.contains('sujeto') && p.contains('educacion')) return materia;
  }
  return null;
}

Materia? _buscarMateriaPlanFlexible({
  required String nombreEvento,
  required int? anioEvento,
  required List<Materia> materiasPlan,
}) {
  final target = _limpiarParaMatch(nombreEvento);

  final sujeto = _matchSujetoEducacion(nombreEvento, materiasPlan);
  if (sujeto != null) return sujeto;

  for (final materia in materiasPlan) {
    if (anioEvento != null && materia.anio != anioEvento) continue;
    if (_matchPracticaDocenteN(nombreEvento, materia)) return materia;
  }

  for (final materia in materiasPlan) {
    if (anioEvento != null && materia.anio != anioEvento) continue;
    if (_limpiarParaMatch(materia.displayNombre) == target) return materia;
  }

  final candidatos = anioEvento != null
      ? materiasPlan.where((m) => m.anio == anioEvento).toList()
      : materiasPlan;

  for (final materia in candidatos) {
    if (_fallaPorPalabraClave(nombreEvento, materia.displayNombre)) continue;
    final cleaned = _limpiarParaMatch(materia.displayNombre);
    if (cleaned.contains(target) || target.contains(cleaned)) return materia;
  }

  final tokEvento = _tokensMatch(nombreEvento);
  Materia? mejor;
  var mejorScore = 0.0;

  for (final materia in candidatos) {
    if (_fallaPorPalabraClave(nombreEvento, materia.displayNombre)) continue;
    final score = _scoreTokens(tokEvento, _tokensMatch(materia.displayNombre));
    if (score > mejorScore) {
      mejorScore = score;
      mejor = materia;
    }
  }

  if (mejorScore >= 0.50) return mejor;
  return null;
}

String _baseDesdeTap(String tap) {
  final value = sanitizarTexto(tap).trim();
  final index = value.lastIndexOf(_emdash);
  if (index == -1) return value;
  return value.substring(0, index).trim();
}

String _stripDivisionNoise(String value) {
  var text = sanitizarTexto(value).trim();
  text = text.replaceAll(
    RegExp(
      r'\s*[-–—]?\s*(comision|comisión|division|división|grupo)\s+([ab])\b',
      caseSensitive: false,
    ),
    '',
  );
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

Materia? _resolverMateriaPlan({
  required String nombreEvento,
  required int? anioEvento,
  required Map<String, Materia> mapaPlan,
}) {
  final materiasPlan = mapaPlan.values.toList();
  final limpio = _stripDivisionNoise(_baseDesdeTap(nombreEvento));

  return mapaPlan[_norm(limpio)] ??
      mapaPlan[_norm(_limpiarParaMatch(limpio))] ??
      _buscarMateriaPlanFlexible(
        nombreEvento: limpio,
        anioEvento: anioEvento,
        materiasPlan: materiasPlan,
      );
}

String _claveVisualMateria({
  required EventoExamen evento,
  required Map<String, Materia> mapaPlan,
}) {
  final plan = _resolverMateriaPlan(
    nombreEvento: evento.materia,
    anioEvento: evento.anio,
    mapaPlan: mapaPlan,
  );

  var displayName = plan?.displayNombre ?? _stripDivisionNoise(evento.materia);

  // Normalizar "Práctica Docente" para el filtro
  final lowName = displayName.toLowerCase();
  if (lowName.contains('practica docente')) {
    final n = _numeroPractica(displayName);
    if (n != null) {
      // Usar números romanos para consistencia con el estilo legacy si es necesario,
      // o números arábigos como pidió el usuario "practica docente 1"
      // El usuario dijo "practica docente II" en el ejemplo pero luego "practica docente 1"
      // "por ejemplo practica docente II practica docente III" -> Usaré Romanos.
      final roman = n == 1
          ? 'I'
          : n == 2
              ? 'II'
              : n == 3
                  ? 'III'
                  : 'IV';
      displayName = 'Práctica Docente $roman';
    }
  }

  var divSuffix = '';
  if (evento.division != null && evento.division!.isNotEmpty) {
    var div = evento.division!.trim();
    // Normalizar "A y B" con 'y' minúscula
    if (div.toUpperCase() == 'A Y B') {
      div = 'A y B';
    }
    divSuffix = ' $_emdash $div';
  }

  return '$displayName$divSuffix';
}

int? anioPlanParaEvento(
  EventoExamen evento,
  Map<String, Materia> mapaPlan,
) {
  final plan = _resolverMateriaPlan(
    nombreEvento: evento.materia,
    anioEvento: evento.anio,
    mapaPlan: mapaPlan,
  );
  return plan?.anio ?? evento.anio;
}

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

class _ResumenFechasMateria {
  DateTime? fechaMin;
  DateTime? fechaMax;
  String? division;

  void add(DateTime? dt, String? div) {
    if (dt == null && div == null) return;
    if (dt != null) {
      if (fechaMin == null || dt.isBefore(fechaMin!)) {
        fechaMin = dt;
      }
      if (fechaMax == null || dt.isAfter(fechaMax!)) {
        fechaMax = dt;
      }
    }
    if (div != null && div.isNotEmpty) {
      if (division == null) {
        division = div;
      } else if (division != div && !division!.contains(div)) {
        // Simple join for now, could be smarter
        division = '$division, $div';
      }
    }
  }
}

class MateriaParaLista {
  MateriaParaLista({
    required this.nombreEvento,
    required this.nombreBase,
    required this.fechaMin,
    required this.fechaActual,
    required this.esColoquio,
    required this.materiaPlan,
    this.division,
  });

  final String nombreEvento;
  final String nombreBase;
  final DateTime? fechaMin;
  final DateTime? fechaActual;
  final bool esColoquio;
  final Materia? materiaPlan;
  final String? division;

  String get nombreMostrable {
    final raw = (materiaPlan?.displayNombre ?? nombreBase).trim();
    final low = raw.toLowerCase();
    if (low.contains('practica docente')) {
      final n = _numeroPractica(raw);
      if (n != null) {
        final roman = n == 1
            ? 'I'
            : n == 2
                ? 'II'
                : n == 3
                    ? 'III'
                    : 'IV';
        return 'Práctica Docente $roman';
      }
    }
    return sanitizarTexto(raw);
  }

  String get formattedDivision {
    if (division == null) return '';
    final d = division!.trim();
    if (d.toUpperCase() == 'A Y B') return 'A y B';
    if (d.toUpperCase() == 'A') return 'A';
    if (d.toUpperCase() == 'B') return 'B';
    return d.toUpperCase();
  }

  String get tipo => sanitizarTexto((materiaPlan?.tipo ?? '').trim());
  String get formato => sanitizarTexto((materiaPlan?.formato ?? '').trim());
  int? get anioPlan => materiaPlan?.anio;
  int? get cuatriPlan => materiaPlan?.cuatri;
  String get codigo => sanitizarTexto((materiaPlan?.codigo ?? '').trim());
}

List<SeccionDeLista> armarSeccionesConPlan({
  required List<EventoExamen> eventos,
  required Map<String, Materia> mapaPlan,
}) {
  // ✅ INTERRUPTOR GENERAL: si esta activado devolvemos lista vacia DIRECTAMENTE
  // Funciona en TODAS las pantallas, TODAS las vistas, absolutamente todo
  if (OCULTAR_TODO_EXAMENES) {
    return const [];
  }

  final coloquios = <String, _ResumenFechasMateria>{};
  final sinAnioOtros = <String, _ResumenFechasMateria>{};

  void setFechas(Map<String, _ResumenFechasMateria> map, String key,
      DateTime? dt, String? div) {
    final prev = map.putIfAbsent(key, () => _ResumenFechasMateria());
    prev.add(dt, div);
  }

  // Ahora tenemos mapas separados para mesas y coloquios POR AÑO
  final porAnioMesas = <int, Map<String, _ResumenFechasMateria>>{};
  final porAnioColoquios = <int, Map<String, _ResumenFechasMateria>>{};

  for (final evento in eventos) {
    final clave = _claveVisualMateria(evento: evento, mapaPlan: mapaPlan);
    final dt = evento.fechaHora;
    final esColoquio = evento.instancia == 'coloquio';

    if (evento.anio == null) {
      if (esColoquio) {
        setFechas(coloquios, clave, dt, evento.division);
      } else {
        setFechas(sinAnioOtros, clave, dt, evento.division);
      }
      continue;
    }

    final year = evento.anio!;
    final map = esColoquio
        ? porAnioColoquios.putIfAbsent(
            year, () => <String, _ResumenFechasMateria>{})
        : porAnioMesas.putIfAbsent(
            year, () => <String, _ResumenFechasMateria>{});

    setFechas(map, clave, dt, evento.division);
  }

  int cmp(
    MapEntry<String, _ResumenFechasMateria> a,
    MapEntry<String, _ResumenFechasMateria> b,
  ) {
    final da = a.value.fechaMin;
    final db = b.value.fechaMin;
    if (da == null && db == null) return a.key.compareTo(b.key);
    if (da == null) return 1;
    if (db == null) return -1;
    final compare = da.compareTo(db);
    return compare != 0 ? compare : a.key.compareTo(b.key);
  }

  List<MateriaParaLista> toMateriaList(
    List<MapEntry<String, _ResumenFechasMateria>> entries, {
    required bool esColoquio,
    required int? anioEvento,
  }) {
    return entries.map((entry) {
      final tap = sanitizarTexto(entry.key);
      final base = _baseDesdeTap(tap);
      final plan = _resolverMateriaPlan(
        nombreEvento: base,
        anioEvento: anioEvento,
        mapaPlan: mapaPlan,
      );

      return MateriaParaLista(
        nombreEvento: tap,
        nombreBase: base,
        fechaMin: entry.value.fechaMin,
        fechaActual: entry.value.fechaMax ?? entry.value.fechaMin,
        esColoquio: esColoquio,
        materiaPlan: plan,
        division: entry.value.division,
      );
    }).toList();
  }

  final out = <SeccionDeLista>[];

  // Unimos todos los años que existen tanto en mesas como en coloquios
  final allYears = {...porAnioMesas.keys, ...porAnioColoquios.keys}.toList()
    ..sort();

  for (final year in allYears) {
    // Primero agregamos las MESAS de este año
    if (porAnioMesas.containsKey(year) && !OCULTAR_TODO_EXAMENES) {
      final entriesMesas = porAnioMesas[year]!.entries.toList()..sort(cmp);
      out.add(
        SeccionDeLista(
          titulo: '$year\u00ba Año',
          materias:
              toMateriaList(entriesMesas, esColoquio: false, anioEvento: year),
          esColoquios: false,
        ),
      );
    }

    // Despues agregamos los COLOQUIOS de este mismo año
    if (porAnioColoquios.containsKey(year) && !OCULTAR_TODO_EXAMENES) {
      final entriesColoquios = porAnioColoquios[year]!.entries.toList()
        ..sort(cmp);
      out.add(
        SeccionDeLista(
          titulo: '📌 Coloquios $year\u00ba Año',
          materias: toMateriaList(entriesColoquios,
              esColoquio: true, anioEvento: year),
          esColoquios: true,
        ),
      );
    }
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
        titulo: 'Sin a\u00f1o asignado',
        materias: toMateriaList(entries, esColoquio: false, anioEvento: null),
        esColoquios: false,
      ),
    );
  }

  return out;
}

List<SeccionDeLista> armarSeccionesSoloPlan({
  required Map<String, Materia> mapaPlan,
}) {
  final materiasUnicas = <String, Materia>{};
  for (final materia in mapaPlan.values) {
    materiasUnicas[materia.id] = materia;
  }

  final porAnio = <int, List<Materia>>{};
  for (final materia in materiasUnicas.values) {
    porAnio.putIfAbsent(materia.anio, () => <Materia>[]).add(materia);
  }

  final years = porAnio.keys.toList()..sort();
  final out = <SeccionDeLista>[];

  for (final year in years) {
    final materias = porAnio[year]!
      ..sort((a, b) {
        final byName = a.displayNombre.compareTo(b.displayNombre);
        if (byName != 0) return byName;
        return a.codigo.compareTo(b.codigo);
      });

    out.add(
      SeccionDeLista(
        titulo: '$year\u00ba A\u00f1o',
        materias: materias
            .map(
              (materia) => MateriaParaLista(
                nombreEvento: materia.displayNombre,
                nombreBase: materia.displayNombre,
                fechaMin: null,
                fechaActual: null,
                esColoquio: false,
                materiaPlan: materia,
              ),
            )
            .toList(),
        esColoquios: false,
      ),
    );
  }

  return out;
}

class DetalleArgs {
  const DetalleArgs({required this.tabId, this.divisionId});
  final String tabId;
  final String? divisionId;
}

class SeleccionParaHoja {
  SeleccionParaHoja({
    required this.llamado1Eventos,
    required this.llamado2Eventos,
    required this.coloquioEventos,
    required this.detalleInicial,
  });

  final List<EventoExamen> llamado1Eventos;
  final List<EventoExamen> llamado2Eventos;
  final List<EventoExamen> coloquioEventos;
  final DetalleArgs? detalleInicial;
}

List<EventoExamen> _sortEventosForSheet(List<EventoExamen> list) {
  final out = List<EventoExamen>.from(list);
  out.sort((a, b) {
    final da = a.fechaHora;
    final db = b.fechaHora;
    if (da == null && db == null) return a.materia.compareTo(b.materia);
    if (da == null) return 1;
    if (db == null) return -1;
    final byDate = da.compareTo(db);
    if (byDate != 0) return byDate;
    return a.materia.compareTo(b.materia);
  });
  return out;
}

SeleccionParaHoja prepararSeleccionParaHoja({
  required List<EventoExamen> all,
  required String careerId,
  required String materia,
  required Map<String, Materia> mapaPlan,
  required bool fromColoquios,
}) {
  final base = sanitizarTexto(_baseDesdeTap(materia));
  final targetPlan = _resolverMateriaPlan(
    nombreEvento: base,
    anioEvento: null,
    mapaPlan: mapaPlan,
  );

  final sameMateria = all.where((e) {
    if (e.careerId != careerId) return false;
    final eventPlan = _resolverMateriaPlan(
      nombreEvento: e.materia,
      anioEvento: e.anio,
      mapaPlan: mapaPlan,
    );
    if (targetPlan != null && eventPlan != null) {
      return eventPlan.id == targetPlan.id;
    }
    return _norm(_stripDivisionNoise(e.materia)) == _norm(base);
  }).toList();

  final e1 = _sortEventosForSheet(
    sameMateria.where((e) => e.instancia == 'llamado_1').toList(),
  );
  final e2 = _sortEventosForSheet(
    sameMateria.where((e) => e.instancia == 'llamado_2').toList(),
  );
  final ec = _sortEventosForSheet(
    sameMateria.where((e) => e.instancia == 'coloquio').toList(),
  );

  final isColoquioOnly =
      fromColoquios || (ec.isNotEmpty && e1.isEmpty && e2.isEmpty);

  return SeleccionParaHoja(
    llamado1Eventos: e1,
    llamado2Eventos: e2,
    coloquioEventos: ec,
    detalleInicial:
        isColoquioOnly ? const DetalleArgs(tabId: 'coloquio') : null,
  );
}
