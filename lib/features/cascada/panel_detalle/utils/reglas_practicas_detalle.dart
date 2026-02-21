import 'package:correlativas_historia/models/materia.dart';

const Set<String> specialCareerIds = {'historia', 'geografia', 'politica'};

String normalizarSinAcentos(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u');

String nombreDetalleTexto(String raw) {
  final rx = RegExp(
    r'pr[aá]ctica\s+profesional\s+docente\s+(iv|4)',
    caseSensitive: false,
  );
  return raw.replaceAll(rx, 'Práctica Docente IV');
}

String nombreDetalleMateria(Materia m) => nombreDetalleTexto(m.nombre);

bool esPracticaIV(Materia m) {
  final s = normalizarSinAcentos(m.nombre);
  final hasPractica = s.contains('practica');
  final hasIV = RegExp(r'\b(iv|4|cuarta)\b').hasMatch(s) || s.contains('residencia');
  return hasPractica && hasIV;
}

bool esPracticaIII(Materia m) {
  final s = normalizarSinAcentos(m.nombre);
  final hasPractica = s.contains('practica');
  final isIII = RegExp(r'\b(iii|3|tercera|3ro|tercero)\b').hasMatch(s);
  return hasPractica && isIII;
}

String? etiquetaEspecialPd4(List<CorrelativaDetallada> det) {
  for (final c in det) {
    final isSpec = c.isSpecial == true;
    final rawName = c.nombre;
    final nameN = normalizarSinAcentos((rawName ?? '').trim());
    final byId = c.id == 'esp_todas_uc_1_2_3';
    final byName = nameN.contains('todas las uc') &&
        (nameN.contains('1') && nameN.contains('2') && nameN.contains('3')) &&
        nameN.contains('ano');
    if (isSpec && (byId || byName)) {
      final candidate = rawName?.trim();
      final base = (candidate != null && candidate.isNotEmpty) ? candidate : 'Todas las UC de 1°, 2° y 3° año';
      return '$base (APROBADAS)';
    }
  }
  return null;
}

String abreviaturaMateria(Materia m) {
  final trimmed = m.codigo.trim();
  if (trimmed.isEmpty) return m.id;
  return trimmed;
}

String? _findMateriaIdByCode(List<Materia> all, String code) {
  final c = code.trim().toLowerCase();
  for (final m in all) {
    final mc = m.codigo.trim().toLowerCase();
    if (mc.isNotEmpty && mc == c) return m.id;
  }
  return null;
}

String? _findMateriaIdByName(List<Materia> all, String nameNeedle) {
  final nneedle = normalizarSinAcentos(nameNeedle.trim());
  for (final m in all) {
    if (normalizarSinAcentos(m.nombre.trim()) == nneedle) return m.id;
  }
  for (final m in all) {
    if (normalizarSinAcentos(m.nombre).contains(nneedle)) return m.id;
  }
  return null;
}

String? _findIdByAny(
    List<Materia> all, {
      List<String> names = const [],
      List<String> codes = const [],
    }) {
  for (final n in names) {
    final id = _findMateriaIdByName(all, n);
    if (id != null) return id;
  }
  for (final c in codes) {
    final id = _findMateriaIdByCode(all, c);
    if (id != null) return id;
  }
  return null;
}

List<(String, String)> overridesPd3Ids(String careerId, List<Materia> all) {
  final comunesA = <({List<String> names, List<String> codes})>[
    (
    names: [
      'Práctica Docente II',
      'Práctica Docente II - Educación Secundaria y Práctica Docente',
      'Practica Docente II - Educacion Secundaria y Practica Docente',
    ],
    codes: ['PD2'],
    ),
    (
    names: [
      'Psicología de la Educación',
      'Psicología Educacional',
      'Psicologia Educacional',
    ],
    codes: ['PE'],
    ),
    (
    names: [
      'Sujeto de la Educación Secundaria',
      'Sujetos de la Educación Secundaria',
    ],
    codes: ['SE'],
    ),
    (
    names: [
      'Didáctica de las Ciencias Sociales',
      'Didactica de las Ciencias Sociales',
    ],
    codes: ['DCS'],
    ),
  ];

  final comunesR = <({List<String> names, List<String> codes})>[
    (names: ['Filosofía', 'Filosofia'], codes: ['FIL']),
  ];

  final porCarreraA = <({List<String> names, List<String> codes})>[];

  if (careerId == 'historia') {
    porCarreraA.addAll([
      (
      names: [
        'Procesos sociales, políticos, económicos y culturales del Feudalismo y la Modernidad',
        'Procesos Sociales, políticos, económicos y culturales del Feudalismo y la Modernidad',
      ],
      codes: const [],
      ),
      (
      names: [
        'Procesos sociales, políticos, económicos y culturales Americanos I',
        'Procesos Sociales, políticos, económicos y culturales Americanos I',
      ],
      codes: const [],
      ),
    ]);
  } else if (careerId == 'geografia') {
    porCarreraA.addAll([
      (
      names: [
        'Organización del Espacio Geográfico Americano',
        'Organizacion del Espacio Geografico Americano',
      ],
      codes: ['OEA'],
      ),
      (
      names: ['Sistema Urbano y Desarrollo Rural Argentino'],
      codes: ['SUR'],
      ),
    ]);
  } else if (careerId == 'politica') {
    porCarreraA.addAll([
      (
      names: [
        'Problemática de la Ciencia Política II',
        'Problematica de la Ciencia Politica II',
      ],
      codes: const [],
      ),
      (
      names: ['Teoría Política I', 'Teoria Politica I'],
      codes: const [],
      ),
    ]);
  }

  final out = <(String, String)>[];

  for (final it in comunesA) {
    final id = _findIdByAny(all, names: it.names, codes: it.codes);
    if (id != null) out.add((id, 'A'));
  }
  for (final it in comunesR) {
    final id = _findIdByAny(all, names: it.names, codes: it.codes);
    if (id != null) out.add((id, 'R'));
  }
  for (final it in porCarreraA) {
    final id = _findIdByAny(all, names: it.names, codes: it.codes);
    if (id != null) out.add((id, 'A'));
  }

  return out;
}

List<(String, String)> mergePd3(List<CorrelativaDetallada> det, List<(String, String)> overrides) {
  final order = <String>[];
  final types = <String, String>{};

  for (final c in det) {
    final t = (c.type.toUpperCase() == 'A') ? 'A' : 'R';
    if (!types.containsKey(c.id)) order.add(c.id);
    types[c.id] = t;
  }

  for (final rec in overrides) {
    final id = rec.$1;
    final tOv = rec.$2;
    final tCur = types[id];

    if (tCur == null) {
      order.add(id);
      types[id] = tOv;
    } else if (tOv == 'A' && tCur == 'R') {
      types[id] = 'A';
    }
  }

  return [for (final key in order) (key, types[key]!)];
}

String etiquetaEstado(String type) => type == 'A' ? '(APROBADA)' : '(REGULARIZADA)';

List<Materia> dependientesDeMateria(List<Materia> all, Materia base, String careerId) {
  final result = <Materia>[];

  for (final mat in all) {
    final hitSimple = mat.correlativas.contains(base.id);
    final hitDetallada = mat.correlativasDetalladas.any((c) => c.id == base.id);
    if (hitSimple || hitDetallada) result.add(mat);
  }

  if (!specialCareerIds.contains(careerId)) return result;

  Materia? findByCode(String code) {
    final c = code.trim().toUpperCase();
    for (final m in all) {
      if (m.codigo.trim().toUpperCase() == c) return m;
    }
    return null;
  }

  Materia? findPracticaIV() {
    for (final m in all) {
      if (esPracticaIV(m)) return m;
    }
    return null;
  }

  final pd1 = findByCode('PD1');
  final pd2 = findByCode('PD2');
  final pd3 = findByCode('PD3');
  final pd4 = findByCode('PD4') ?? findPracticaIV();

  void addIfNotNull(Materia? mat) {
    if (mat == null) return;
    if (!result.contains(mat)) result.add(mat);
  }

  if (pd1 != null && base.id == pd1.id) addIfNotNull(pd2);
  if (pd2 != null && base.id == pd2.id) addIfNotNull(pd3);
  if (pd3 != null && base.id == pd3.id) addIfNotNull(pd4);

  if (base.anio == 1) addIfNotNull(pd3);
  if (base.anio >= 1 && base.anio <= 3) addIfNotNull(pd4);

  return result;
}