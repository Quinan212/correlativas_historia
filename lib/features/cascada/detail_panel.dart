export 'panel_detalle/panel_detalle_materia.dart';
/*
import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../shared/providers/app_state.dart';
  import '../../models/materia.dart';
  
  bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
  
  Color _darken(Color c, [double t = 0.2]) {
    final r = Color.lerp(c, Colors.black, t);
    return r ?? c;
  }
  
  const _amberCard = Color(0xFFFFFBEB);
  const _amberBd = Color(0xFFFDE68A);
  const _amberChip = Color(0xFFFEF3C7);
  const _amberTxt = Color(0xFF92400E);
  
  const _emeraldCard = Color(0xFFECFDF5);
  const _emeraldBd = Color(0xFFA7F3D0);
  const _emeraldChip = Color(0xFFE7F8EF);
  const _emeraldTxt = Color(0xFF065F46);
  
  const _blueCard = Color(0xFFF0F7FF);
  const _blueBd = Color(0xFFBFDBFE);
  const _bluePill = Color(0xFFE5EDFF);
  const _blueTxt = Color(0xFF1D4ED8);
  
  class _DarkPalette {
    static const fgBg = Color(0xFF223761);
    static const fgBd = Color(0xFF3E60A4);
    static const fgFg = Color(0xFFBFD4FF);
  
    static const feBg = Color(0xFF1E4F45);
    static const feBd = Color(0xFF2D8C78);
    static const feFg = Color(0xFFBFEFE0);
  
    static const ppBg = Color(0xFF3A2769);
    static const ppBd = Color(0xFF7351D4);
    static const ppFg = Color(0xFFE7D7FF);
  
    static const asigBg = fgBg;
    static const asigBd = fgBd;
    static const asigFg = fgFg;
  
    static const semBg = feBg;
    static const semBd = feBd;
    static const semFg = feFg;
  
    static const stBg = ppBg;
    static const stBd = ppBd;
    static const stFg = ppFg;
  
    static const tallerBg = Color(0xFF5A3027);
    static const tallerBd = Color(0xFFB75B33);
    static const tallerFg = Color(0xFFF4CBB5);
  
    static const reqBg = Color(0xFF55451A);
    static const reqBd = Color(0xFF8A6F2C);
    static const reqFg = Color(0xFFEED083);
  
    static const amberCard = Color(0xFF2B2414);
    static const amberBd = reqBd;
  
    static const emeraldCard = Color(0xFF15372F);
    static const emeraldBd = feBd;
  
    static const blueCard = Color(0xFF16233F);
    static const blueBd = fgBd;
    static const bluePill = Color(0xFF1D2E54);
    static const blueTxt = fgFg;
  }
  
  const Set<String> _specialCareerIds = {
    'historia',
    'geografia',
    'politica',
  };
  
  String _n(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
  
  String _displayPd4Name(String raw) {
    final rx = RegExp(
      r'pr[aá]ctica\s+profesional\s+docente\s+(iv|4)',
      caseSensitive: false,
    );
    return raw.replaceAll(rx, 'Práctica Docente IV');
  }
  
  bool _isPracticaIV(Materia m) {
    final s = _n(m.nombre);
    final hasPractica = s.contains('practica');
    final hasIV =
        RegExp(r'\b(iv|4|cuarta)\b').hasMatch(s) || s.contains('residencia');
    return hasPractica && hasIV;
  }
  
  bool _isPracticaIII(Materia m) {
    final s = _n(m.nombre);
    final hasPractica = s.contains('practica');
    final isIII =
    RegExp(r'\b(iii|3|tercera|3ro|tercero)\b').hasMatch(s);
    return hasPractica && isIII;
  }
  
  String? _pd4SpecialLabel(List<CorrelativaDetallada> det) {
    for (final c in det) {
      final isSpec = c.isSpecial == true;
      final rawName = c.nombre;
      final nameN = _n((rawName ?? '').trim());
      final byId = c.id == 'esp_todas_uc_1_2_3';
      final byName = nameN.contains('todas las uc') &&
          (nameN.contains('1') && nameN.contains('2') && nameN.contains('3')) &&
          nameN.contains('ano');
      if (isSpec && (byId || byName)) {
        final candidate = rawName?.trim();
        final base = candidate != null && candidate.isNotEmpty
            ? candidate
            : 'Todas las UC de 1°, 2° y 3° año';
        return '$base (APROBADAS)';
      }
    }
    return null;
  }
  
  String _abbrForMateria(Materia m) {
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
    final nneedle = _n(nameNeedle);
    for (final m in all) {
      if (_n(m.nombre) == nneedle) return m.id;
    }
    for (final m in all) {
      if (_n(m.nombre).contains(nneedle)) return m.id;
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
  
  List<(String, String)> _pd3OverridesIds(
      String careerId,
      List<Materia> all,
      ) {
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
  
  List<(String, String)> _mergePd3(
      List<CorrelativaDetallada> det,
      List<(String, String)> overrides,
      ) {
    final order = <String>[];
    final types = <String, String>{};
  
    for (final c in det) {
      final type = c.type;
      final t = (type?.toUpperCase() == 'A') ? 'A' : 'R';
      if (!types.containsKey(c.id)) order.add(c.id);
      types[c.id] = t;
    }
  
    for (final rec in overrides) {
      final id = rec.$1;
      final tOv = rec.$2;
      final tCurrent = types[id];
      if (tCurrent == null) {
        order.add(id);
        types[id] = tOv;
      } else if (tOv == 'A' && tCurrent == 'R') {
        types[id] = 'A';
      }
    }
  
    return [for (final key in order) (key, types[key]!)];
  }
  
  String _statusLabel(String type) {
    return type == 'A' ? '(APROBADA)' : '(REGULARIZADA)';
  }
  
  Color _statusColor(bool isDark, bool isYellow) {
    if (isYellow) {
      return isDark ? _DarkPalette.reqFg : _amberTxt;
    }
    return isDark ? _DarkPalette.feFg : _emeraldTxt;
  }
  
  class DetailPanel extends ConsumerWidget {
    const DetailPanel({super.key});
  
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final plan = ref.watch(planProvider).valueOrNull;
      final selectedId = ref.watch(selectedMateriaIdProvider);
      if (plan == null || selectedId == null) return const SizedBox.shrink();
  
      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      final isDark = _isDark(context);
  
      final all = plan.materias;
      final m = all.firstWhere((x) => x.id == selectedId);
      final career = ref.watch(selectedCareerInfoProvider);
      final dependents = _getDependents(all, m, career.id);
  
      final handleBar = Center(
        child: Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: cs.outlineVariant,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                offset: Offset(0, 2),
                color: Color(0x33000000),
              ),
            ],
          ),
        ),
      );
  
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          handleBar,
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? _darken(cs.surface) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Color(0x11000000),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _displayPd4Name(m.nombre),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? cs.onSurface
                                : const Color(0xFF111827),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        icon: Icon(
                          Icons.close,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          ref.read(selectedMateriaIdProvider.notifier).state =
                          null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tipoChip(context, m.tipo),
                      _formatoChip(context, m.formato),
                      _yearChip(context, m.anio),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (_, c) {
                      final twoCols = c.maxWidth >= 760;
                      final left = _correlativasRequeridas(
                        context,
                        ref,
                        all,
                        m,
                        career.id,
                      );
                      final right =
                      _materiasQueHabilita(context, ref, dependents);
                      if (twoCols) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: left),
                            const SizedBox(width: 16),
                            Expanded(child: right),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          left,
                          const SizedBox(height: 16),
                          right,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  
    Widget _buildInteractiveRow({
      required BuildContext context,
      required WidgetRef ref,
      required Materia? targetMateria,
      required String abbr,
      required String name,
      String? statusType,
      required bool isDark,
      required bool isYellow,
    }) {
      final cs = Theme.of(context).colorScheme;
  
      final bgColor = isDark
          ? (isYellow ? _DarkPalette.amberCard : _DarkPalette.emeraldCard)
          : (isYellow ? _amberCard : _emeraldCard);
      final bdColor = isDark
          ? (isYellow ? _DarkPalette.amberBd : _DarkPalette.emeraldBd)
          : (isYellow ? _amberBd : _emeraldBd);
  
      final chipBg = isDark
          ? (isYellow ? _DarkPalette.reqBg : _DarkPalette.feBg)
          : (isYellow ? _amberChip : _emeraldChip);
      final chipBd = isDark
          ? (isYellow ? _DarkPalette.reqBd : _DarkPalette.feBd)
          : (isYellow ? _amberBd : _emeraldBd);
      final chipFg = isDark
          ? (isYellow ? _DarkPalette.reqFg : _DarkPalette.feFg)
          : (isYellow ? _amberTxt : _emeraldTxt);
  
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: targetMateria != null
              ? () {
            ref.read(selectedMateriaIdProvider.notifier).state =
                targetMateria.id;
          }
              : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: bdColor),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: chipBd),
                  ),
                  child: Text(
                    abbr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: chipFg,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      if (statusType != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _statusLabel(statusType),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: _statusColor(isDark, isYellow),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (targetMateria != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: chipFg.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  
    Widget _correlativasRequeridas(
        BuildContext context,
        WidgetRef ref,
        List<Materia> all,
        Materia m,
        String careerId,
        ) {
      final cs = Theme.of(context).colorScheme;
      final isDark = _isDark(context);
  
      final det = m.correlativasDetalladas;
      final specials = det.where((c) => c.isSpecial == true).toList();
      final onlySpecials = det.isNotEmpty && specials.length == det.length;
  
      if (_isPracticaIV(m)) {
        final label = _pd4SpecialLabel(det) ??
            'Todas las UC de 1°, 2° y 3° año (APROBADAS)';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correlativas Requeridas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            _especialBlock(context, label),
          ],
        );
      }
  
      if (_isPracticaIII(m)) {
        final baseDet = det.where((c) => c.isSpecial != true).toList();
        final ov = _pd3OverridesIds(careerId, all)
            .where((rec) => rec.$1 != m.id)
            .toList();
        final entries = _mergePd3(baseDet, ov);
  
        final items = entries.map((tuple) {
          final id = tuple.$1;
          final type = tuple.$2;
          final mat = all.firstWhere(
                (x) => x.id == id,
            orElse: () => Materia.fromMap({
              'id': id,
              'codigo': id,
              'nombre': id,
              'anio': 0,
              'tipo': '',
              'formato': '',
              'correlativas': [],
              'correlativasDetalladas': [],
            }),
          );
          return (mat, type);
        }).toList();
  
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correlativas Requeridas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((e) {
              final mat = e.$1;
              final type = e.$2;
              final abbr = _abbrForMateria(mat);
              return _buildInteractiveRow(
                context: context,
                ref: ref,
                targetMateria: mat.id == mat.nombre ? null : mat,
                abbr: abbr,
                name: _displayPd4Name(mat.nombre),
                statusType: type,
                isDark: isDark,
                isYellow: true,
              );
            }),
            if (items.isEmpty)
              Text(
                '—',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            _especialBlock(
              context,
              'Todas las UC de Primer año (APROBADAS)',
            ),
          ],
        );
      }
  
      if (onlySpecials) {
        final s = specials.first;
        final rawType = s.type ?? '';
        final stype = rawType.trim().toUpperCase();
        final tipo = stype.isEmpty
            ? ''
            : stype == 'A'
            ? ' (APROBADAS)'
            : stype == 'R'
            ? ' (REGULARIZADAS)'
            : ' ($stype)';
        final texto = (s.nombre?.trim().isNotEmpty ?? false)
            ? s.nombre!.trim()
            : 'Requisito especial';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correlativas Requeridas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            _especialBlock(context, '$texto$tipo'),
          ],
        );
      }
  
      final entries = det.map<(String, String)>((c) {
        final type = c.type;
        final t = (type?.toUpperCase() == 'A') ? 'A' : 'R';
        return (c.id, t);
      }).toList();
  
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correlativas Requeridas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...entries.map((tuple) {
            final id = tuple.$1;
            final type = tuple.$2;
            final mat = all.firstWhere(
                  (x) => x.id == id,
              orElse: () => Materia(
                id: id,
                codigo: id,
                nombre: 'Desconocida',
                anio: 0,
                tipo: '',
                formato: '',
                correlativas: const [],
                correlativasDetalladas: const [],
              ),
            );
            final abbr = _abbrForMateria(mat);
  
            return _buildInteractiveRow(
              context: context,
              ref: ref,
              targetMateria:
              mat.nombre == 'Desconocida' ? null : mat,
              abbr: abbr,
              name: _displayPd4Name(mat.nombre),
              statusType: type,
              isDark: isDark,
              isYellow: true,
            );
          }),
          if (entries.isEmpty)
            Text(
              '—',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
        ],
      );
    }
  
    Widget _materiasQueHabilita(
        BuildContext context,
        WidgetRef ref,
        List<Materia> dependents,
        ) {
      final cs = Theme.of(context).colorScheme;
      final isDark = _isDark(context);
  
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Materias que Habilita',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (dependents.isEmpty)
            Text(
              'No es correlativa con otras materias.',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            )
          else
            ...dependents.map((d) {
              final abbr = _abbrForMateria(d);
              return _buildInteractiveRow(
                context: context,
                ref: ref,
                targetMateria: d,
                abbr: abbr,
                name: _displayPd4Name(d.nombre),
                statusType: null,
                isDark: isDark,
                isYellow: false,
              );
            }),
        ],
      );
    }
  
    Widget _especialBlock(BuildContext context, String text) {
      final cs = Theme.of(context).colorScheme;
      final isDark = _isDark(context);
      final card = isDark ? _DarkPalette.blueCard : _blueCard;
      final bd = isDark ? _DarkPalette.blueBd : _blueBd;
      final pill = isDark ? _DarkPalette.bluePill : _bluePill;
      final fg = isDark ? _DarkPalette.blueTxt : _blueTxt;
  
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bd),
        ),
        child: Row(
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: bd),
              ),
              child: Text(
                'Especial',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }
  
    Widget _chipBase({
      required String text,
      required Color bg,
      required Color bd,
      required Color fg,
      bool bold = false,
    }) {
      return Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: bd),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            color: fg,
          ),
        ),
      );
    }
  
    Widget _tipoChip(BuildContext context, String tipo) {
      final isDark = _isDark(context);
      Color bg, bd, fg;
  
      if (!isDark) {
        switch (tipo.trim()) {
          case 'Formación General':
            bg = const Color(0xFFDBEAFE);
            bd = const Color(0xFFBFDBFE);
            fg = _blueTxt;
            break;
          case 'Formación Específica':
            bg = const Color(0xFFD1FAE5);
            bd = const Color(0xFFA7F3D0);
            fg = _emeraldTxt;
            break;
          case 'Práctica Profesional':
            bg = const Color(0xFFEDE9FE);
            bd = const Color(0xFFC4B5FD);
            fg = const Color(0xFF5B21B6);
            break;
          default:
            bg = const Color(0xFFF3F4F6);
            bd = const Color(0xFFE5E7EB);
            fg = const Color(0xFF374151);
        }
        return _chipBase(text: tipo, bg: bg, bd: bd, fg: fg, bold: true);
      }
  
      switch (tipo.trim()) {
        case 'Formación General':
          bg = _darken(_DarkPalette.fgBg);
          bd = _DarkPalette.fgBd;
          fg = _DarkPalette.fgFg;
          break;
        case 'Formación Específica':
          bg = _darken(_DarkPalette.feBg);
          bd = _DarkPalette.feBd;
          fg = _DarkPalette.feFg;
          break;
        case 'Práctica Profesional':
          bg = _darken(_DarkPalette.ppBg);
          bd = _DarkPalette.ppBd;
          fg = _DarkPalette.ppFg;
          break;
        default:
          bg = _darken(const Color(0xFF29313A));
          bd = const Color(0xFF3E4753);
          fg = const Color(0xFFE5E7EB);
      }
      return _chipBase(text: tipo, bg: bg, bd: bd, fg: fg, bold: true);
    }
  
    Widget _formatoChip(BuildContext context, String formato) {
      final isDark = _isDark(context);
      Color bg, bd, fg;
  
      if (!isDark) {
        switch (formato.trim()) {
          case 'Asignatura':
            bg = const Color(0xFFDBEAFE);
            bd = const Color(0xFFBFDBFE);
            fg = _blueTxt;
            break;
          case 'Seminario':
            bg = const Color(0xFFD1FAE5);
            bd = const Color(0xFFA7F3D0);
            fg = _emeraldTxt;
            break;
          case 'Seminario-Taller':
            bg = const Color(0xFFEDE9FE);
            bd = const Color(0xFFC4B5FD);
            fg = const Color(0xFF5B21B6);
            break;
          case 'Taller':
            bg = const Color(0xFFFFEDD5);
            bd = const Color(0xFFFED7AA);
            fg = const Color(0xFF9A3412);
            break;
          default:
            bg = const Color(0xFFF3F4F6);
            bd = const Color(0xFFE5E7EB);
            fg = const Color(0xFF374151);
        }
        return _chipBase(
          text: formato,
          bg: bg,
          bd: bd,
          fg: fg,
          bold: true,
        );
      }
  
      switch (formato.trim()) {
        case 'Asignatura':
          bg = _darken(_DarkPalette.asigBg);
          bd = _DarkPalette.asigBd;
          fg = _DarkPalette.asigFg;
          break;
        case 'Seminario':
          bg = _darken(_DarkPalette.semBg);
          bd = _DarkPalette.semBd;
          fg = _DarkPalette.semFg;
          break;
        case 'Seminario-Taller':
          bg = _darken(_DarkPalette.stBg);
          bd = _DarkPalette.stBd;
          fg = _DarkPalette.stFg;
          break;
        case 'Taller':
          bg = _darken(_DarkPalette.tallerBg);
          bd = _DarkPalette.tallerBd;
          fg = _DarkPalette.tallerFg;
          break;
        default:
          bg = _darken(const Color(0xFF29313A));
          bd = const Color(0xFF3E4753);
          fg = const Color(0xFFE5E7EB);
      }
      return _chipBase(
        text: formato,
        bg: bg,
        bd: bd,
        fg: fg,
        bold: true,
      );
    }
  
    Widget _yearChip(BuildContext context, int anio) {
      final cs = Theme.of(context).colorScheme;
      final isDark = _isDark(context);
      return _chipBase(
        text: '$anio° Año',
        bg: isDark
            ? _darken(cs.surface, 0.25)
            : const Color(0xFFF3F4F6),
        bd: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        fg: cs.onSurface,
        bold: true,
      );
    }
  
    List<Materia> _getDependents(
        List<Materia> all,
        Materia base,
        String careerId,
        ) {
      final result = <Materia>[];
  
      for (final mat in all) {
        final hitSimple = mat.correlativas.contains(base.id);
        final hitDetallada =
        mat.correlativasDetalladas.any((c) => c.id == base.id);
        if (hitSimple || hitDetallada) result.add(mat);
      }
  
      if (!_specialCareerIds.contains(careerId)) {
        return result;
      }
  
      Materia? findByCode(String code) {
        final c = code.trim().toUpperCase();
        for (final m in all) {
          if (m.codigo.trim().toUpperCase() == c) return m;
        }
        return null;
      }
  
      Materia? findPracticaIV() {
        for (final m in all) {
          if (_isPracticaIV(m)) return m;
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
  
      if (pd1 != null && base.id == pd1.id) {
        addIfNotNull(pd2);
      }
      if (pd2 != null && base.id == pd2.id) {
        addIfNotNull(pd3);
      }
      if (pd3 != null && base.id == pd3.id) {
        addIfNotNull(pd4);
      }
  
      if (base.anio == 1) {
        addIfNotNull(pd3);
      }
      if (base.anio >= 1 && base.anio <= 3) {
        addIfNotNull(pd4);
      }
  
      return result;
    }
  }

 */