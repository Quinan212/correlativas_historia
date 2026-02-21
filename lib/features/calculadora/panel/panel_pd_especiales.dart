import '../../../models/materia.dart';

class PdEspeciales {
  static Materia prepararCurso({
    required Materia course0,
    required String careerId,
    required List<Materia> all,
  }) {
    var detInjected = _injectPdSpecials(course0);

    if (_isPd3ByName(course0)) {
      final specials = detInjected.where((c) => c.isSpecial == true).toList();
      final base = detInjected.where((c) => c.isSpecial != true).toList();

      final ov = _pd3OverridesIds(careerId, all);
      final merged = _applyPd3OverridesToDet(base, ov, course0.id);

      detInjected = [...merged, ...specials];
    }

    return _copyWithDet(course0, detInjected);
  }

  static Materia _copyWithDet(Materia m, List<CorrelativaDetallada> det) {
    return Materia(
      id: m.id,
      codigo: m.codigo,
      nombre: m.nombre,
      anio: m.anio,
      cuatri: m.cuatri,
      tipo: m.tipo,
      formato: m.formato,
      correlativas: m.correlativas,
      horas: m.horas,
      correlativasDetalladas: det,
    );
  }

  static String _normNoAcc(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  static bool _isPd4ByName(Materia m) {
    final s = _normNoAcc(m.nombre);
    final hasPractica = s.contains('practica');
    final hasIV =
        RegExp(r'\b(iv|4|cuarta)\b').hasMatch(s) || s.contains('residencia');
    final hasDocente = s.contains('docente');
    return hasPractica && hasIV && hasDocente;
  }

  static bool _isPd3ByName(Materia m) {
    final s = _normNoAcc(m.nombre);
    final hasPractica = s.contains('practica');
    final hasIII = RegExp(r'\b(iii|3|tercera|3ro|tercero)\b').hasMatch(s);
    return hasPractica && hasIII;
  }

  static List<CorrelativaDetallada> _injectPdSpecials(Materia course) {
    final det = List<CorrelativaDetallada>.from(course.correlativasDetalladas);

    if (_isPd4ByName(course)) {
      final exists = det.any((c) =>
      c.isSpecial == true &&
          (c.id == 'esp_todas_uc_1_2_3' ||
              _normNoAcc((c.nombre ?? '')).contains('todas las uc')));
      if (!exists) {
        det.insert(
          0,
          CorrelativaDetallada(
            id: 'esp_todas_uc_1_2_3',
            type: 'A',
            isSpecial: true,
            nombre: 'Todas las UC de 1°, 2° y 3° año',
          ),
        );
      }
    }

    if (_isPd3ByName(course)) {
      final exists =
      det.any((c) => c.isSpecial == true && c.id == 'esp_todas_uc_1');
      if (!exists) {
        det.add(
          CorrelativaDetallada(
            id: 'esp_todas_uc_1',
            type: 'A',
            isSpecial: true,
            nombre: 'Todas las UC de Primer año',
          ),
        );
      }
    }

    return det;
  }

  static String? _findMateriaIdByCode(List<Materia> all, String code) {
    final c = code.trim().toLowerCase();
    for (final m in all) {
      final mc = m.codigo.trim().toLowerCase();
      if (mc.isNotEmpty && mc == c) return m.id;
    }
    return null;
  }

  static String? _findMateriaIdByName(List<Materia> all, String nameNeedle) {
    final nneedle = _normNoAcc(nameNeedle.trim());
    for (final m in all) {
      if (_normNoAcc(m.nombre.trim()) == nneedle) return m.id;
    }
    for (final m in all) {
      if (_normNoAcc(m.nombre).contains(nneedle)) return m.id;
    }
    return null;
  }

  static String? _findIdByAny(
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

  static List<(String, String)> _pd3OverridesIds(String careerId, List<Materia> all) {
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

  static List<CorrelativaDetallada> _applyPd3OverridesToDet(
      List<CorrelativaDetallada> det,
      List<(String, String)> overrides,
      String courseId,
      ) {
    final order = <String>[];
    final types = <String, String>{};

    for (final c in det) {
      if (c.id == courseId) continue;
      final t = (c.type.toUpperCase() == 'A') ? 'A' : 'R';
      if (!types.containsKey(c.id)) order.add(c.id);
      types[c.id] = t;
    }

    for (final rec in overrides) {
      final id = rec.$1;
      final tOv = rec.$2;
      if (id == courseId) continue;

      final tCur = types[id];
      if (tCur == null) {
        order.add(id);
        types[id] = tOv;
      } else if (tOv == 'A' && tCur == 'R') {
        types[id] = 'A';
      }
    }

    final byId = <String, CorrelativaDetallada>{};
    for (final c in det) {
      byId[c.id] = c;
    }

    return [
      for (final id in order)
        CorrelativaDetallada(
          id: id,
          type: types[id] ?? (byId[id]?.type ?? 'R'),
          isSpecial: byId[id]?.isSpecial ?? false,
          nombre: byId[id]?.nombre,
          formato: byId[id]?.formato,
          tipo: byId[id]?.tipo,
        ),
    ];
  }
}