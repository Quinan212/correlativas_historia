export 'panel/panel_evaluacion.dart';

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/providers/app_state.dart';
import '../../../models/materia.dart';

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _darken(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t)!;

class EvaluationPanel extends ConsumerWidget {
  const EvaluationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan =
    ref.watch(planProvider).maybeWhen(data: (p) => p, orElse: () => null);
    final selId = ref.watch(selectedCalcMateriaIdProvider);
    final statusMap = ref.watch(correlativaStatusMapProvider);

    if (plan == null || selId == null) return const SizedBox.shrink();

    final careerId = ref.watch(selectedCareerInfoProvider).id;

    final course0 = plan.materias.firstWhere((m) => m.id == selId);

    // 1) Inyecta specials PD3/PD4 (sin tocar HTML)
    var detInjected = _injectPdSpecials(course0);

    // 2) Overrides PD3: fuerza algunos requisitos a "A" (aprobada) y agrega faltantes
    if (_isPd3ByName(course0)) {
      final specials = detInjected.where((c) => c.isSpecial == true).toList();
      final base = detInjected.where((c) => c.isSpecial != true).toList();

      final ov = _pd3OverridesIds(careerId, plan.materias);
      final merged = _applyPd3OverridesToDet(base, ov, course0.id);

      detInjected = [...merged, ...specials];
    }

    final course = _copyWithDet(course0, detInjected);

    final reqBlock =
    _requirementsBlock(context, ref, course, plan.materias, statusMap);
    final res = evaluateCourse(course, statusMap, plan.materias);

    Widget panelCard(Widget child) {
      final cs = Theme.of(context).colorScheme;
      final dark = _isDark(context);
      return Container(
        decoration: BoxDecoration(
          color: dark ? _darken(cs.surface) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context)),
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Color(0x14000000)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reqBlock != null) ...[
          panelCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, 'Materias'),
                const SizedBox(height: 10),
                reqBlock,
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        panelCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Resultado'),
              const SizedBox(height: 10),
              _resultSection(context, res),
            ],
          ),
        ),
      ],
    );
  }

  // --------- estilos ---------

  TextStyle _gf({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.2,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  Color _border(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? cs.outlineVariant : const Color(0xFFE5E7EB);
  }

  Color _titleColor(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? cs.onSurface : const Color(0xFF111827);
  }

  Color _subtitleColor(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? cs.onSurfaceVariant : const Color(0xFF6B7280);
  }

  Color _chipBg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? _darken(cs.surface, 0.30) : const Color(0xFFF3F4F6);
  }

  Color _chipSelectedBg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? _darken(cs.primary, 0.72) : const Color(0xFFDBEAFE);
  }

  Color _chipFg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? cs.onSurface : const Color(0xFF374151);
  }

  Color _chipSelectedFg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final dark = _isDark(c);
    return dark ? cs.onSurface : const Color(0xFF1D4ED8);
  }

  BorderSide _chipSide(BuildContext c, {required bool selected}) {
    if (selected) return const BorderSide(color: Color(0xFF93C5FD));
    return BorderSide(color: _border(c));
  }

  TextStyle _chipTextStyle(BuildContext c, {required bool selected}) {
    return _gf(
      size: 13,
      weight: FontWeight.w600,
      color: selected ? _chipSelectedFg(c) : _chipFg(c),
      height: 1.0,
    );
  }

  String _labelFor(String opt) {
    if (opt == 'no-regularizada') return 'no\u00A0regularizada';
    return opt;
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    final dark = _isDark(context);
    final dot = dark ? cs.primary : const Color(0xFF005B7F);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: _gf(
            size: 14.5,
            weight: FontWeight.w600,
            color: _titleColor(context),
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // --------- helpers PD3/PD4 ---------

  String _normNoAcc(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  bool _isPd4ByName(Materia m) {
    final s = _normNoAcc(m.nombre);
    final hasPractica = s.contains('practica');
    final hasIV =
        RegExp(r'\b(iv|4|cuarta)\b').hasMatch(s) || s.contains('residencia');
    final hasDocente = s.contains('docente');
    return hasPractica && hasIV && hasDocente;
  }

  bool _isPd3ByName(Materia m) {
    final s = _normNoAcc(m.nombre);
    final hasPractica = s.contains('practica');
    final hasIII = RegExp(r'\b(iii|3|tercera|3ro|tercero)\b').hasMatch(s);
    return hasPractica && hasIII;
  }

  List<CorrelativaDetallada> _injectPdSpecials(Materia course) {
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

  // --------- overrides PD3 (como DetailPanel) ---------

  String? _findMateriaIdByCode(List<Materia> all, String code) {
    final c = code.trim().toLowerCase();
    for (final m in all) {
      final mc = m.codigo.trim().toLowerCase();
      if (mc.isNotEmpty && mc == c) return m.id;
    }
    return null;
  }

  String? _findMateriaIdByName(List<Materia> all, String nameNeedle) {
    final nneedle = _normNoAcc(nameNeedle.trim());
    for (final m in all) {
      if (_normNoAcc(m.nombre.trim()) == nneedle) return m.id;
    }
    for (final m in all) {
      if (_normNoAcc(m.nombre).contains(nneedle)) return m.id;
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

  List<(String, String)> _pd3OverridesIds(String careerId, List<Materia> all) {
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

  List<CorrelativaDetallada> _applyPd3OverridesToDet(
      List<CorrelativaDetallada> det,
      List<(String, String)> overrides,
      String courseId,
      ) {
    final order = <String>[];
    final types = <String, String>{};

    // base (lo que venga del plan)
    for (final c in det) {
      if (c.id == courseId) continue;
      final t = (c.type.toUpperCase() == 'A') ? 'A' : 'R';
      if (!types.containsKey(c.id)) order.add(c.id);
      types[c.id] = t;
    }

    // overrides (agrega y/o sube R -> A)
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

    // reconstruye correlativasDetalladas (sin tocar specials)
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

  Materia _copyWithDet(Materia m, List<CorrelativaDetallada> det) {
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

  // --------- materias (requisitos) SIN caja ---------

  Widget? _requirementsBlock(
      BuildContext context,
      WidgetRef ref,
      Materia course,
      List<Materia> all,
      Map<String, String> status,
      ) {
    final notifier = ref.read(correlativaStatusMapProvider.notifier);

    bool isPracticaIVEspecial(CorrelativaDetallada c) {
      final n = course.nombre.toLowerCase();
      final isPDIV =
          n.contains('práctica docente iv') || n.contains('practica docente iv');
      final sName = (c.nombre ?? '').toLowerCase();
      return isPDIV &&
          c.isSpecial == true &&
          c.type.toUpperCase() == 'A' &&
          sName.contains('todas las uc');
    }

    String? nombreMateria(String id) {
      final hit = all.where((m) => m.id == id);
      if (hit.isEmpty) return null;
      return hit.first.nombre;
    }

    final seen = <String>{};
    final uniqueDet = <CorrelativaDetallada>[];

    for (final c in course.correlativasDetalladas) {
      final tipo = c.type.toUpperCase();

      final title = (c.isSpecial == true && (c.nombre?.trim().isNotEmpty ?? false))
          ? c.nombre!.trim()
          : (nombreMateria(c.id) ?? c.id).trim();

      final key = '${title.toLowerCase()}|$tipo';
      if (seen.add(key)) uniqueDet.add(c);
    }

    if (uniqueDet.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(uniqueDet.length, (i) {
        final c = uniqueDet[i];

        final title = (c.isSpecial == true && (c.nombre?.trim().isNotEmpty ?? false))
            ? c.nombre!
            : (nombreMateria(c.id) ?? c.id);

        final tipo = c.type.toUpperCase();
        final esSpecial = c.isSpecial == true;
        final esPDIV = isPracticaIVEspecial(c);

        // especiales tipo A: solo 2 opciones
        final usarDosOpciones = esSpecial && tipo == 'A';

        final subtitle = (tipo == 'A')
            ? ((esSpecial || esPDIV)
            ? 'Deben estar APROBADAS (A)'
            : 'Debe estar APROBADA (A)')
            : (tipo == 'R' ? 'Debe estar REGULARIZADA (R)' : '');

        final opciones = usarDosOpciones
            ? const ['no-regularizada', 'aprobada']
            : const ['no-regularizada', 'regularizada', 'aprobada'];

        var value = status[c.id] ?? 'no-regularizada';

        // si ahora solo admite 2 opciones, limpiamos “regularizada”
        if (usarDosOpciones && value == 'regularizada') {
          value = 'no-regularizada';
          notifier.setStatus(c.id, value);
        }

        return Padding(
          padding: EdgeInsets.only(bottom: i == uniqueDet.length - 1 ? 0 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: _gf(
                  size: 15.5,
                  weight: FontWeight.w500,
                  color: _titleColor(context),
                  height: 1.15,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: _gf(
                    size: 12.5,
                    weight: FontWeight.w400,
                    color: _subtitleColor(context),
                    height: 1.25,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(opciones.length, (j) {
                    final opt = opciones[j];
                    final selected = value == opt;

                    return Padding(
                      padding: EdgeInsets.only(
                          right: j == opciones.length - 1 ? 0 : 10),
                      child: ChoiceChip(
                        showCheckmark: true,
                        checkmarkColor: selected
                            ? _chipSelectedFg(context)
                            : _chipFg(context),
                        label: Text(
                          _labelFor(opt),
                          maxLines: 1,
                          softWrap: false,
                        ),
                        selected: selected,
                        onSelected: (_) => notifier.setStatus(c.id, opt),
                        backgroundColor: _chipBg(context),
                        selectedColor: _chipSelectedBg(context),
                        side: _chipSide(context, selected: selected),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: _chipTextStyle(context, selected: selected),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity:
                        const VisualDensity(horizontal: -2, vertical: -2),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // --------- resultado SIN caja ---------

  String _stripLeadBullet(String? s) {
    if (s == null) return '';
    var t = s.trimLeft();
    while (t.startsWith('•') ||
        t.startsWith('-') ||
        t.startsWith('–') ||
        t.startsWith('—')) {
      t = t.substring(1).trimLeft();
    }
    return t;
  }

  Widget _resultSection(BuildContext context, EvalResult res) {
    final cs = Theme.of(context).colorScheme;
    final dark = _isDark(context);

    Color colorFor(String label) {
      switch (label) {
        case 'No puede cursar':
          return const Color(0xFFDC2626);
        case 'Cursada condicional':
        case 'Cursa con restricciones':
          return const Color(0xFFF59E0B);
        case 'Puede cursar sin restricciones':
          return const Color(0xFF16A34A);
        default:
          return dark ? cs.onSurface : const Color(0xFF374151);
      }
    }

    Widget cap(String title, bool on, {bool restricted = false}) {
      final bg = on
          ? (restricted
          ? (dark
          ? _darken(const Color(0xFFF59E0B), 0.78)
          : const Color(0xFFFEF3C7))
          : (dark
          ? _darken(const Color(0xFF16A34A), 0.78)
          : const Color(0xFFD1FAE5)))
          : (dark ? _darken(cs.surface, 0.30) : const Color(0xFFF3F4F6));

      final fg = on
          ? (restricted ? const Color(0xFFF59E0B) : const Color(0xFF16A34A))
          : (dark ? cs.onSurfaceVariant : const Color(0xFF6B7280));

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _border(context)),
        ),
        child: Text(
          title,
          style: _gf(size: 12, weight: FontWeight.w600, color: fg, height: 1.0),
        ),
      );
    }

    final noteColor = dark ? cs.onSurface : const Color(0xFF111827);
    final muted = dark ? cs.onSurfaceVariant : const Color(0xFF4B5563);

    final explanation = res.detailedExplanation?.trim();
    final strategy = res.strategy?.trim();
    final hasExplanation = explanation != null && explanation.isNotEmpty;
    final hasStrategy = strategy != null && strategy.isNotEmpty;

    final noteWidgets = <Widget>[];
    for (final raw in res.notes) {
      final clean = _stripLeadBullet(raw);
      if (clean.trim().isEmpty) continue;

      noteWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: _gf(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: noteColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  clean,
                  style: _gf(
                    size: 13.5,
                    weight: FontWeight.w400,
                    color: noteColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          res.overallLabel,
          style: _gf(
            size: 18,
            weight: FontWeight.w500,
            color: colorFor(res.overallLabel),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            cap('Actividades', res.activities,
                restricted: res.activitiesRestricted),
            cap('Parciales', res.exams, restricted: res.examsRestricted),
            cap('Promoción', res.promotion, restricted: false),
          ],
        ),
        if (noteWidgets.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...noteWidgets,
        ],
        if (hasExplanation) ...[
          const SizedBox(height: 8),
          Text(
            explanation!,
            style: _gf(
              size: 13.5,
              weight: FontWeight.w400,
              color: muted,
              height: 1.35,
            ),
          ),
        ],
        if (hasStrategy) ...[
          const SizedBox(height: 10),
          Text(
            'Estrategia: $strategy',
            style: _gf(
              size: 13.5,
              weight: FontWeight.w600,
              color: noteColor,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}
*/
