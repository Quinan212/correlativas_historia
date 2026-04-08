import 'package:flutter/material.dart';

import 'package:correlativas_historia/features/cascada/grilla/utils/estilos_chips.dart';

import '../logica_examenes.dart';
import '../sheet/materia_banner_assets.dart';

class ListaMaterias extends StatelessWidget {
  const ListaMaterias({
    super.key,
    required this.careerId,
    required this.secciones,
    required this.proximos,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.onTapMateria,
  });

  final String careerId;
  final List<SeccionDeLista> secciones;
  final List<MateriaParaLista> proximos;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (secciones.isEmpty) {
      return Center(
        child: Text(
          'No hay materias para los filtros seleccionados.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      children: [
        if (proximos.isNotEmpty && !examsHiddenMode) ...[
          _ProximosStrip(
            careerId: careerId,
            proximos: proximos,
            onTapMateria: onTapMateria,
          ),
          const SizedBox(height: 14),
        ],
        for (var i = 0; i < secciones.length; i++) ...[
          _Seccion(
            key: ValueKey('${secciones[i].titulo}-$i'),
            careerId: careerId,
            titulo: secciones[i].titulo,
            materias: secciones[i].materias,
            esColoquios: secciones[i].esColoquios,
            examsHiddenMode: examsHiddenMode,
            hiddenModeMessage: hiddenModeMessage,
            onTapMateria: onTapMateria,
            initiallyExpanded: i == 0,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProximosStrip extends StatelessWidget {
  const _ProximosStrip({
    required this.careerId,
    required this.proximos,
    required this.onTapMateria,
  });

  final String careerId;
  final List<MateriaParaLista> proximos;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos exámenes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: proximos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final item = proximos[i];
                final dt = item.fechaActual;
                final hasDate = dt != null;
                final days = _daysLabel(dt);
                final when = hasDate
                    ? _fmtFechaHora(
                        dt,
                        shortUndefinedHourLabel: 'A definir',
                      )
                    : 'A confirmar';
                final banner = MateriaBannerAssets.resolve(
                  careerId: careerId,
                  materia: item.nombreBase,
                  anio: item.anioPlan,
                );

                return SizedBox(
                  width: 236,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          onTapMateria(item.nombreEvento, item.esColoquio),
                      borderRadius: BorderRadius.circular(14),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? cs.outlineVariant
                                : const Color(0xFFE5E7EB),
                          ),
                          color: isDark ? cs.surface : const Color(0xFFFAFAFA),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 62,
                              margin: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isDark
                                    ? const Color(0xFF1F2937)
                                    : const Color(0xFFE5E7EB),
                                image: banner == null
                                    ? null
                                    : DecorationImage(
                                        image: AssetImage(banner),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.centerLeft,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 4, 10, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nombreMostrable,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      when,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    _statusPill(
                                      context,
                                      label: days,
                                      confirmed: hasDate,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    super.key,
    required this.careerId,
    required this.titulo,
    required this.materias,
    required this.esColoquios,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.onTapMateria,
    required this.initiallyExpanded,
  });

  final String careerId;
  final String titulo;
  final List<MateriaParaLista> materias;
  final bool esColoquios;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final void Function(String materia, bool fromColoquios) onTapMateria;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey('sec-$titulo'),
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isDark
                      ? cs.primary.withValues(alpha: 0.18)
                      : const Color(0xFFDBEAFE),
                ),
                child: Text(
                  '${materias.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? cs.onSurface : const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          children: [
            for (final m in materias) ...[
              _TarjetaMateria(
                careerId: careerId,
                item: m,
                examsHiddenMode: examsHiddenMode,
                hiddenModeMessage: hiddenModeMessage,
                onTap: () => onTapMateria(m.nombreEvento, esColoquios),
              ),
              if (m != materias.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaMateria extends StatelessWidget {
  const _TarjetaMateria({
    required this.careerId,
    required this.item,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.onTap,
  });

  final String careerId;
  final MateriaParaLista item;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasPlan = item.materiaPlan != null;
    final dt = item.fechaActual;
    final hasDate = dt != null;
    final fecha = hasDate ? _fmtFecha(dt) : 'A confirmar';
    final hora = hasDate
        ? _horaLabel(
            dt,
            esColoquio: item.esColoquio,
            shortUndefinedLabel: true,
          )
        : 'Sin horario';
    final statusLabel = hasDate ? _daysLabel(dt) : 'A confirmar';

    final fmt = item.formato;
    final tipo = item.tipo;

    final (fmtBg, fmtFg, fmtBd) = (hasPlan && fmt.isNotEmpty)
        ? coloresFormato(isDark, fmt)
        : (Colors.transparent, cs.onSurfaceVariant, Colors.transparent);

    final (tipoBg, tipoFg, tipoBd) = (hasPlan && tipo.isNotEmpty)
        ? coloresTipo(isDark, tipo)
        : (Colors.transparent, cs.onSurfaceVariant, Colors.transparent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: examsHiddenMode ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: theme.shadowColor.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nombreMostrable,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (examsHiddenMode)
                        Text(
                          hiddenModeMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$fecha · $hora',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (examsHiddenMode)
                            _statusPill(
                              context,
                              label: 'Proximamente',
                              confirmed: false,
                            )
                          else
                            _statusPill(
                              context,
                              label: statusLabel,
                              confirmed: hasDate,
                            ),
                          if (hasPlan && fmt.isNotEmpty)
                            _chip(
                              text: normalizarFormatoChip(fmt),
                              bg: fmtBg,
                              fg: fmtFg,
                              bd: fmtBd,
                            ),
                          if (hasPlan && tipo.isNotEmpty)
                            _chip(
                              text: tipo,
                              bg: tipoBg,
                              fg: tipoFg,
                              bd: tipoBd,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!examsHiddenMode) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _statusPill(
  BuildContext context, {
  required String label,
  required bool confirmed,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  final bg = confirmed
      ? (isDark ? const Color(0xFF13302A) : const Color(0xFFECFDF3))
      : (isDark ? const Color(0xFF3A2B10) : const Color(0xFFFFF7ED));
  final fg = confirmed
      ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857))
      : (isDark ? const Color(0xFFFED7AA) : const Color(0xFFC2410C));

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: confirmed
            ? (isDark ? cs.outlineVariant : const Color(0xFFA7F3D0))
            : (isDark ? cs.outlineVariant : const Color(0xFFFED7AA)),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    ),
  );
}

Widget _chip({
  required String text,
  required Color bg,
  required Color fg,
  required Color bd,
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
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}

String _fmtFecha(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m';
}

String _fmtHora(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

bool _hasDefinedHour(DateTime dt) {
  return !(dt.hour == 0 && dt.minute == 0);
}

String _horaLabel(
  DateTime dt, {
  required bool esColoquio,
  bool shortUndefinedLabel = false,
}) {
  if (_hasDefinedHour(dt)) return _fmtHora(dt);
  if (shortUndefinedLabel) return 'A definir';
  return esColoquio
      ? 'A definir · consultar con docente de catedra'
      : 'A definir';
}

String _fmtFechaHora(
  DateTime dt, {
  String shortUndefinedHourLabel = 'A definir',
}) {
  final hora = _hasDefinedHour(dt) ? _fmtHora(dt) : shortUndefinedHourLabel;
  return '${_fmtFecha(dt)} · $hora';
}

String _daysLabel(DateTime? dt) {
  if (dt == null) return 'A confirmar';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final diff = target.difference(today).inDays;
  if (diff < -14) return 'Fue hace mas de dos semanas';
  if (diff < -7) return 'Fue hace mas de una semana';
  if (diff == -1) return 'Fue ayer';
  if (diff < 0) {
    final daysAgo = diff.abs();
    return daysAgo == 1 ? 'Fue hace un dia' : 'Fue hace $daysAgo dias';
  }
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Manana';
  return 'En $diff dias';
}
