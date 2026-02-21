import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:correlativas_historia/shared/providers/app_state.dart';
import 'package:correlativas_historia/models/materia.dart';

import 'utils/paleta_detalle.dart';
import 'utils/reglas_practicas_detalle.dart';

class DetailPanel extends ConsumerWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider).valueOrNull;
    final selectedId = ref.watch(selectedMateriaIdProvider);
    if (plan == null || selectedId == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final all = plan.materias;
    final m = all.firstWhere((x) => x.id == selectedId);
    final careerId = ref.watch(selectedCareerInfoProvider).id;

    final dependents = dependientesDeMateria(all, m, careerId);

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
            color: isDark ? darken(cs.surface) : Colors.white,
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
                        nombreDetalleMateria(m),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? cs.onSurface : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        ref.read(selectedMateriaIdProvider.notifier).state = null;
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
                      context: context,
                      ref: ref,
                      all: all,
                      m: m,
                      careerId: careerId,
                    );

                    final right = _materiasQueHabilita(
                      context: context,
                      ref: ref,
                      dependents: dependents,
                    );

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
    required bool isYellow,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? (isYellow ? PaletaDetalleOscura.amberCard : PaletaDetalleOscura.emeraldCard)
        : (isYellow ? PaletaDetalle.amberCard : PaletaDetalle.emeraldCard);

    final bdColor = isDark
        ? (isYellow ? PaletaDetalleOscura.amberBd : PaletaDetalleOscura.emeraldBd)
        : (isYellow ? PaletaDetalle.amberBd : PaletaDetalle.emeraldBd);

    final chipBg = isDark
        ? (isYellow ? PaletaDetalleOscura.reqBg : PaletaDetalleOscura.feBg)
        : (isYellow ? PaletaDetalle.amberChip : PaletaDetalle.emeraldChip);

    final chipBd = isDark
        ? (isYellow ? PaletaDetalleOscura.reqBd : PaletaDetalleOscura.feBd)
        : (isYellow ? PaletaDetalle.amberBd : PaletaDetalle.emeraldBd);

    final chipFg = isDark
        ? (isYellow ? PaletaDetalleOscura.reqFg : PaletaDetalleOscura.feFg)
        : (isYellow ? PaletaDetalle.amberTxt : PaletaDetalle.emeraldTxt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: targetMateria != null
            ? () {
          ref.read(selectedMateriaIdProvider.notifier).state = targetMateria.id;
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          etiquetaEstado(statusType),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colorEtiquetaEstado(isDark: isDark, isYellow: isYellow),
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

  Widget _correlativasRequeridas({
    required BuildContext context,
    required WidgetRef ref,
    required List<Materia> all,
    required Materia m,
    required String careerId,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final det = m.correlativasDetalladas;
    final specials = det.where((c) => c.isSpecial == true).toList();
    final onlySpecials = det.isNotEmpty && specials.length == det.length;

    if (esPracticaIV(m)) {
      final label = etiquetaEspecialPd4(det) ?? 'Todas las UC de 1°, 2° y 3° año (APROBADAS)';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correlativas Requeridas',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface),
          ),
          const SizedBox(height: 10),
          _especialBlock(context, label),
        ],
      );
    }

    if (esPracticaIII(m)) {
      final baseDet = det.where((c) => c.isSpecial != true).toList();
      final ov = overridesPd3Ids(careerId, all).where((rec) => rec.$1 != m.id).toList();
      final entries = mergePd3(baseDet, ov);

      final items = entries.map((tuple) {
        final id = tuple.$1;
        final type = tuple.$2;
        final mat = all.firstWhere(
              (x) => x.id == id,
          orElse: () => Materia(
            id: id,
            codigo: id,
            nombre: id,
            anio: 0,
            tipo: '',
            formato: '',
            correlativas: const [],
            correlativasDetalladas: const [],
          ),
        );
        return (mat, type);
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correlativas Requeridas',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface),
          ),
          const SizedBox(height: 10),
          ...items.map((e) {
            final mat = e.$1;
            final type = e.$2;
            final abbr = abreviaturaMateria(mat);

            return _buildInteractiveRow(
              context: context,
              ref: ref,
              targetMateria: mat.nombre == mat.id ? null : mat,
              abbr: abbr,
              name: nombreDetalleTexto(mat.nombre),
              statusType: type,
              isYellow: true,
            );
          }),
          if (items.isEmpty)
            Text('—', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          _especialBlock(context, 'Todas las UC de Primer año (APROBADAS)'),
        ],
      );
    }

    if (onlySpecials) {
      final s = specials.first;
      final stype = (s.type).trim().toUpperCase();
      final tipo = stype.isEmpty
          ? ''
          : stype == 'A'
          ? ' (APROBADAS)'
          : stype == 'R'
          ? ' (REGULARIZADAS)'
          : ' ($stype)';
      final texto = (s.nombre?.trim().isNotEmpty ?? false) ? s.nombre!.trim() : 'Requisito especial';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correlativas Requeridas',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface),
          ),
          const SizedBox(height: 10),
          _especialBlock(context, '$texto$tipo'),
        ],
      );
    }

    final entries = det.map<(String, String)>((c) {
      final t = (c.type.toUpperCase() == 'A') ? 'A' : 'R';
      return (c.id, t);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correlativas Requeridas',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface),
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

          return _buildInteractiveRow(
            context: context,
            ref: ref,
            targetMateria: mat.nombre == 'Desconocida' ? null : mat,
            abbr: abreviaturaMateria(mat),
            name: nombreDetalleTexto(mat.nombre),
            statusType: type,
            isYellow: true,
          );
        }),
        if (entries.isEmpty)
          Text('—', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _materiasQueHabilita({
    required BuildContext context,
    required WidgetRef ref,
    required List<Materia> dependents,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materias que Habilita',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface),
        ),
        const SizedBox(height: 10),
        if (dependents.isEmpty)
          Text(
            'No es correlativa con otras materias.',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          )
        else
          ...dependents.map((d) {
            return _buildInteractiveRow(
              context: context,
              ref: ref,
              targetMateria: d,
              abbr: abreviaturaMateria(d),
              name: nombreDetalleTexto(d.nombre),
              statusType: null,
              isYellow: false,
            );
          }),
      ],
    );
  }

  Widget _especialBlock(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? PaletaDetalleOscura.blueCard : PaletaDetalle.blueCard;
    final bd = isDark ? PaletaDetalleOscura.blueBd : PaletaDetalle.blueBd;
    final pill = isDark ? PaletaDetalleOscura.bluePill : PaletaDetalle.bluePill;
    final fg = isDark ? PaletaDetalleOscura.blueTxt : PaletaDetalle.blueTxt;

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pill,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: bd),
            ),
            child: Text(
              'Especial',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w500, color: fg),
      ),
    );
  }

  Widget _tipoChip(BuildContext context, String tipo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg, bd, fg;

    if (!isDark) {
      switch (tipo.trim()) {
        case 'Formación General':
          bg = const Color(0xFFDBEAFE);
          bd = const Color(0xFFBFDBFE);
          fg = PaletaDetalle.blueTxt;
          break;
        case 'Formación Específica':
          bg = const Color(0xFFD1FAE5);
          bd = const Color(0xFFA7F3D0);
          fg = PaletaDetalle.emeraldTxt;
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
        bg = darken(PaletaDetalleOscura.fgBg);
        bd = PaletaDetalleOscura.fgBd;
        fg = PaletaDetalleOscura.fgFg;
        break;
      case 'Formación Específica':
        bg = darken(PaletaDetalleOscura.feBg);
        bd = PaletaDetalleOscura.feBd;
        fg = PaletaDetalleOscura.feFg;
        break;
      case 'Práctica Profesional':
        bg = darken(PaletaDetalleOscura.ppBg);
        bd = PaletaDetalleOscura.ppBd;
        fg = PaletaDetalleOscura.ppFg;
        break;
      default:
        bg = darken(const Color(0xFF29313A));
        bd = const Color(0xFF3E4753);
        fg = const Color(0xFFE5E7EB);
    }

    return _chipBase(text: tipo, bg: bg, bd: bd, fg: fg, bold: true);
  }

  Widget _formatoChip(BuildContext context, String formato) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg, bd, fg;

    if (!isDark) {
      switch (formato.trim()) {
        case 'Asignatura':
          bg = const Color(0xFFDBEAFE);
          bd = const Color(0xFFBFDBFE);
          fg = PaletaDetalle.blueTxt;
          break;
        case 'Seminario':
          bg = const Color(0xFFD1FAE5);
          bd = const Color(0xFFA7F3D0);
          fg = PaletaDetalle.emeraldTxt;
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
      return _chipBase(text: formato, bg: bg, bd: bd, fg: fg, bold: true);
    }

    switch (formato.trim()) {
      case 'Asignatura':
        bg = darken(PaletaDetalleOscura.asigBg);
        bd = PaletaDetalleOscura.asigBd;
        fg = PaletaDetalleOscura.asigFg;
        break;
      case 'Seminario':
        bg = darken(PaletaDetalleOscura.semBg);
        bd = PaletaDetalleOscura.semBd;
        fg = PaletaDetalleOscura.semFg;
        break;
      case 'Seminario-Taller':
        bg = darken(PaletaDetalleOscura.stBg);
        bd = PaletaDetalleOscura.stBd;
        fg = PaletaDetalleOscura.stFg;
        break;
      case 'Taller':
        bg = darken(PaletaDetalleOscura.tallerBg);
        bd = PaletaDetalleOscura.tallerBd;
        fg = PaletaDetalleOscura.tallerFg;
        break;
      default:
        bg = darken(const Color(0xFF29313A));
        bd = const Color(0xFF3E4753);
        fg = const Color(0xFFE5E7EB);
    }

    return _chipBase(text: formato, bg: bg, bd: bd, fg: fg, bold: true);
  }

  Widget _yearChip(BuildContext context, int anio) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _chipBase(
      text: '$anio° Año',
      bg: isDark ? darken(cs.surface, 0.25) : const Color(0xFFF3F4F6),
      bd: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
      fg: cs.onSurface,
      bold: true,
    );
  }
}