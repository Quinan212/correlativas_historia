import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../compartido/utilidades/sanitizar_texto.dart';
import '../../../../modelos/materia.dart';

import '../logica_examenes.dart';
import '../hoja/recursos_banner_materia.dart';

class ListaMaterias extends StatelessWidget {
  const ListaMaterias({
    super.key,
    required this.careerId,
    required this.secciones,
    required this.proximos,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.isZeus,
    required this.onTapMateria,
  });

  final String careerId;
  final List<SeccionDeLista> secciones;
  final List<MateriaParaLista> proximos;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final bool isZeus;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final horizontalPadding = isDesktop ? 20.0 : (isZeus ? 14.0 : 12.0);
        final bottomPadding = isDesktop ? 24.0 : (isZeus ? 20.0 : 16.0);

        final content = [
          // Banner informativo (se muestra siempre que haya mensaje definido)
          if (hiddenModeMessage.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: isZeus ? 14 : 10),
              child: _BannerAviso(
                message: hiddenModeMessage,
                isZeus: isZeus,
              ),
            ),
          if (proximos.isNotEmpty && !examsHiddenMode) ...[
            _ProximosStrip(
              careerId: careerId,
              proximos: proximos,
              isZeus: isZeus,
              onTapMateria: onTapMateria,
            ),
            SizedBox(height: isZeus ? 16 : 14),
          ],
          if (!isDesktop)
            for (var i = 0; i < secciones.length; i++) ...[
              _Seccion(
                key: ValueKey('${secciones[i].titulo}-$i'),
                careerId: careerId,
                titulo: secciones[i].titulo,
                materias: secciones[i].materias,
                esColoquios: secciones[i].esColoquios,
                examsHiddenMode: examsHiddenMode,
                hiddenModeMessage: hiddenModeMessage,
                isZeus: isZeus,
                onTapMateria: onTapMateria,
              ),
              SizedBox(height: isZeus ? 14 : 10),
            ]
          else
            LayoutBuilder(
              builder: (context, sectionConstraints) {
                final sectionCols = sectionConstraints.maxWidth >= 1800
                    ? 3
                    : sectionConstraints.maxWidth >= 1180
                        ? 2
                        : sectionConstraints.maxWidth >= 700
                            ? 2
                            : 1;
                final sectionSpacing = isZeus ? 16.0 : 14.0;
                final sectionWidth = (sectionConstraints.maxWidth -
                        sectionSpacing * (sectionCols - 1)) /
                    sectionCols;

                return Wrap(
                  spacing: sectionSpacing,
                  runSpacing: sectionSpacing,
                  children: [
                    for (var i = 0; i < secciones.length; i++)
                      SizedBox(
                        width: sectionWidth,
                        child: _Seccion(
                          key: ValueKey('${secciones[i].titulo}-$i'),
                          careerId: careerId,
                          titulo: secciones[i].titulo,
                          materias: secciones[i].materias,
                          esColoquios: secciones[i].esColoquios,
                          examsHiddenMode: examsHiddenMode,
                          hiddenModeMessage: hiddenModeMessage,
                          isZeus: isZeus,
                          onTapMateria: onTapMateria,
                        ),
                      ),
                  ],
                );
              },
            ),
        ];

        final canOwnVerticalScroll = isDesktop && constraints.hasBoundedHeight;

        return ListView(
          shrinkWrap: !canOwnVerticalScroll,
          physics: canOwnVerticalScroll
              ? null
              : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isZeus ? 12 : 10,
            horizontalPadding,
            bottomPadding,
          ),
          children: content,
        );
      },
    );
  }
}

class _ProximosStrip extends StatelessWidget {
  const _ProximosStrip({
    required this.careerId,
    required this.proximos,
    required this.isZeus,
    required this.onTapMateria,
  });

  final String careerId;
  final List<MateriaParaLista> proximos;
  final bool isZeus;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(isZeus ? 22 : 18),
        border: Border.all(
          color: isZeus
              ? cs.primary.withValues(alpha: isDark ? 0.35 : 0.18)
              : (isDark ? cs.outlineVariant : const Color(0xFFD1D5DB)),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: isZeus ? 16 : 6,
            offset: Offset(0, isZeus ? 8 : 3),
            color: theme.shadowColor.withValues(alpha: isZeus ? 0.12 : 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        isZeus ? 14 : 12,
        isZeus ? 14 : 12,
        isZeus ? 14 : 12,
        isZeus ? 14 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos exámenes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: isZeus ? 0.1 : 0,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < proximos.length; i++) ...[
                  if (i != 0) const SizedBox(width: 10),
                  _TarjetaProximo(
                    key: ValueKey(
                      '${proximos[i].nombreEvento}-${proximos[i].fechaActual?.toIso8601String() ?? 'sin-fecha'}',
                    ),
                    careerId: careerId,
                    item: proximos[i],
                    isDark: isDark,
                    theme: theme,
                    cs: cs,
                    onTapMateria: onTapMateria,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProximo extends StatelessWidget {
  const _TarjetaProximo({
    super.key,
    required this.careerId,
    required this.item,
    required this.isDark,
    required this.theme,
    required this.cs,
    required this.onTapMateria,
  });

  final String careerId;
  final MateriaParaLista item;
  final bool isDark;
  final ThemeData theme;
  final ColorScheme cs;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final dt = item.fechaActual;
    final hasDate = dt != null;
    final info = _tiempoRelativo(dt);
    final dateLabel = hasDate ? _fmtFecha(dt) : 'Sin fecha';
    final timeLabel = hasDate
        ? _etiquetaHora(
            dt,
            esColoquio: item.esColoquio,
            shortUndefinedLabel: true,
          )
        : null;
    final banner = RecursosBannerMateria.resolve(
      careerId: careerId,
      materia: item.nombreBase,
      anio: item.anioPlan,
    );

    return SizedBox(
      width: 236,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapMateria(item.nombreEvento, item.esColoquio),
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: info.isExpired
                    ? (isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFD1D5DB))
                    : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
              ),
              color: info.isExpired
                  ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6))
                  : (isDark ? cs.surface : const Color(0xFFFAFAFA)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 62,
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: info.isExpired
                        ? (isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFD1D5DB))
                        : (isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFE5E7EB)),
                    image: banner == null
                        ? null
                        : DecorationImage(
                            image: AssetImage(banner),
                            fit: BoxFit.cover,
                            alignment: Alignment.centerLeft,
                            colorFilter: info.isExpired
                                ? ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.4),
                                    BlendMode.saturation,
                                  )
                                : null,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayNameForScreen(item),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: info.isExpired ? cs.onSurfaceVariant : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _metaChip(
                            icon: Icons.calendar_today_rounded,
                            text: dateLabel,
                            bg: info.isExpired
                                ? (isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE5E7EB))
                                : (isDark
                                    ? const Color(0xFF1F2937)
                                    : const Color(0xFFF3F4F6)),
                            fg: info.isExpired
                                ? (isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280))
                                : (isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF4B5563)),
                            bd: info.isExpired
                                ? (isDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFFD1D5DB))
                                : (isDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFFD1D5DB)),
                          ),
                          if (timeLabel != null)
                            _metaChip(
                              icon: Icons.schedule_rounded,
                              text: timeLabel,
                              bg: info.isExpired
                                  ? (isDark
                                      ? const Color(0xFF374151)
                                      : const Color(0xFFE5E7EB))
                                  : (isDark
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFFF3F4F6)),
                              fg: info.isExpired
                                  ? (isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280))
                                  : (isDark
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF4B5563)),
                              bd: info.isExpired
                                  ? (isDark
                                      ? const Color(0xFF4B5563)
                                      : const Color(0xFFD1D5DB))
                                  : (isDark
                                      ? const Color(0xFF4B5563)
                                      : const Color(0xFFD1D5DB)),
                            ),
                          if (item.esColoquio &&
                              item.formattedDivision.isNotEmpty)
                            _chip(
                              text: item.formattedDivision,
                              bg: isDark
                                  ? cs.secondaryContainer.withValues(alpha: 0.4)
                                  : const Color(0xFFF3F4F6),
                              fg: isDark
                                  ? cs.onSecondaryContainer
                                  : const Color(0xFF374151),
                              bd: isDark
                                  ? cs.outlineVariant.withValues(alpha: 0.5)
                                  : const Color(0xFFD1D5DB),
                            ),
                          _statusPill(
                            context,
                            label: info.label,
                            confirmed: hasDate,
                            isExpired: info.isExpired,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    required this.isZeus,
    required this.onTapMateria,
  });

  final String careerId;
  final String titulo;
  final List<MateriaParaLista> materias;
  final bool esColoquios;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final bool isZeus;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isZeus ? 6 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isZeus)
            Container(
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary],
                ),
              ),
            ),
          Row(
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
          SizedBox(height: isZeus ? 12 : 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 980;
              if (!isDesktop) {
                return Column(
                  children: [
                    for (var i = 0; i < materias.length; i++) ...[
                      _TarjetaMateria(
                        careerId: careerId,
                        item: materias[i],
                        examsHiddenMode: examsHiddenMode,
                        hiddenModeMessage: hiddenModeMessage,
                        isZeus: isZeus,
                        onTap: () => onTapMateria(
                          materias[i].nombreEvento,
                          esColoquios,
                        ),
                      ),
                      if (i != materias.length - 1)
                        SizedBox(height: isZeus ? 12 : 10),
                    ],
                  ],
                );
              }

              final spacing = isZeus ? 12.0 : 10.0;
              final rawCols = constraints.maxWidth >= 1800
                  ? 4
                  : (constraints.maxWidth >= 1320
                      ? 3
                      : (constraints.maxWidth >= 900
                          ? 2
                          : (constraints.maxWidth >= 480 ? 2 : 1)));
              final cols = math.max(
                1,
                math.min(rawCols, materias.isEmpty ? 1 : materias.length),
              );
              final cardWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in materias)
                    SizedBox(
                      width: cardWidth,
                      child: _TarjetaMateria(
                        careerId: careerId,
                        item: item,
                        examsHiddenMode: examsHiddenMode,
                        hiddenModeMessage: hiddenModeMessage,
                        isZeus: isZeus,
                        onTap: () =>
                            onTapMateria(item.nombreEvento, esColoquios),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------- Banner informativo ----------

class _BannerAviso extends StatelessWidget {
  const _BannerAviso({
    required this.message,
    required this.isZeus,
  });

  final String message;
  final bool isZeus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isZeus ? 14 : 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(isZeus ? 16 : 12),
        border: Border.all(
          color: isDark ? const Color(0xFF2B6CB0) : const Color(0xFF90CDF4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: isDark ? const Color(0xFF90CDF4) : const Color(0xFF2B6CB0),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Helper: información de tiempo relativo ----------

class _TiempoRelativoInfo {
  final String label;
  final bool isExpired;

  const _TiempoRelativoInfo({required this.label, required this.isExpired});
}

_TiempoRelativoInfo _tiempoRelativo(DateTime? dt) {
  if (dt == null)
    return const _TiempoRelativoInfo(label: 'Sin fecha', isExpired: false);

  final now = DateTime.now();
  final diff = dt.difference(now);
  final isExpired = diff.isNegative;

  if (!isExpired) {
    // Futuro
    final totalMinutes = diff.inMinutes;
    final totalHours = (totalMinutes / 60).ceil();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final daysDiff = target.difference(today).inDays;

    if (daysDiff == 0)
      return const _TiempoRelativoInfo(label: 'Hoy', isExpired: false);
    if (totalHours <= 48)
      return _TiempoRelativoInfo(
          label: 'En $totalHours horas', isExpired: false);
    if (daysDiff == 1)
      return const _TiempoRelativoInfo(label: 'Mañana', isExpired: false);
    return _TiempoRelativoInfo(label: 'En $daysDiff días', isExpired: false);
  }

  // Pasado
  final ago = diff.abs();
  final totalMinutes = ago.inMinutes;
  final totalHours = (totalMinutes / 60).floor();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final daysAgo = target.difference(today).inDays.abs();

  if (totalMinutes < 60)
    return const _TiempoRelativoInfo(label: 'Ahora mismo', isExpired: true);
  if (totalHours < 2)
    return const _TiempoRelativoInfo(label: 'Hace 1 hora', isExpired: true);
  if (totalHours < 24)
    return _TiempoRelativoInfo(
        label: 'Hace $totalHours horas', isExpired: true);
  if (daysAgo == 1)
    return const _TiempoRelativoInfo(label: 'Ayer', isExpired: true);
  if (daysAgo == 2)
    return const _TiempoRelativoInfo(label: 'Anteayer', isExpired: true);
  if (daysAgo < 7)
    return _TiempoRelativoInfo(label: 'Hace $daysAgo días', isExpired: true);
  if (daysAgo < 14)
    return const _TiempoRelativoInfo(label: 'Hace 1 semana', isExpired: true);
  if (daysAgo < 21)
    return const _TiempoRelativoInfo(label: 'Hace 2 semanas', isExpired: true);
  if (daysAgo < 30)
    return const _TiempoRelativoInfo(label: 'Hace 3 semanas', isExpired: true);
  if (daysAgo < 60)
    return const _TiempoRelativoInfo(label: 'Hace 1 mes', isExpired: true);
  if (daysAgo < 90)
    return const _TiempoRelativoInfo(label: 'Hace 2 meses', isExpired: true);
  if (daysAgo < 180)
    return const _TiempoRelativoInfo(label: 'Hace 3 meses', isExpired: true);
  return const _TiempoRelativoInfo(label: 'Expirado', isExpired: true);
}

// ---------- Componentes ----------

class _TarjetaMateria extends StatelessWidget {
  const _TarjetaMateria({
    required this.careerId,
    required this.item,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.isZeus,
    required this.onTap,
  });

  final String careerId;
  final MateriaParaLista item;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final bool isZeus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPhone = MediaQuery.sizeOf(context).width < 700;

    final dt = item.fechaActual;
    final hasDate = dt != null;
    final info = _tiempoRelativo(dt);
    final fecha = hasDate ? _fmtFecha(dt) : 'Sin fecha';
    final hora = hasDate
        ? _etiquetaHora(
            dt,
            esColoquio: item.esColoquio,
            shortUndefinedLabel: true,
          )
        : 'Sin horario';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: examsHiddenMode ? null : onTap,
        borderRadius: BorderRadius.circular(isZeus ? 18 : 16),
        child: Ink(
          decoration: BoxDecoration(
            color: info.isExpired
                ? (isDark ? const Color(0xFF1A202C) : const Color(0xFFF9FAFB))
                : (isDark ? cs.surface : Colors.white),
            borderRadius: BorderRadius.circular(isZeus ? 18 : 16),
            border: Border.all(
              color: info.isExpired
                  ? (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB))
                  : (isZeus
                      ? cs.primary.withValues(alpha: isDark ? 0.28 : 0.14)
                      : (isDark ? cs.outlineVariant : const Color(0xFFD1D5DB))),
            ),
            boxShadow: isPhone
                ? const []
                : [
                    BoxShadow(
                      blurRadius: isZeus ? 10 : 5,
                      spreadRadius: -1,
                      offset: Offset(0, isZeus ? 4 : 2),
                      color: theme.shadowColor.withValues(
                        alpha: isZeus ? 0.10 : 0.05,
                      ),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isZeus ? 12 : 10,
              vertical: isZeus ? 10 : 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _daysInsignia(context, dt),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayNameForScreen(item),
                        softWrap: true,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: info.isExpired ? cs.onSurfaceVariant : null,
                          decoration: info.isExpired
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _metaChip(
                              icon: Icons.calendar_today_rounded,
                              text: fecha,
                              bg: info.isExpired
                                  ? (isDark
                                      ? const Color(0xFF374151)
                                      : const Color(0xFFE5E7EB))
                                  : (isDark
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFFF3F4F6)),
                              fg: info.isExpired
                                  ? (isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280))
                                  : (isDark
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF4B5563)),
                              bd: info.isExpired
                                  ? (isDark
                                      ? const Color(0xFF4B5563)
                                      : const Color(0xFFD1D5DB))
                                  : (isDark
                                      ? const Color(0xFF4B5563)
                                      : const Color(0xFFD1D5DB)),
                            ),
                            if (hasDate)
                              _metaChip(
                                icon: Icons.schedule_rounded,
                                text: hora,
                                bg: info.isExpired
                                    ? (isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB))
                                    : (isDark
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFFF3F4F6)),
                                fg: info.isExpired
                                    ? (isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF6B7280))
                                    : (isDark
                                        ? const Color(0xFFE5E7EB)
                                        : const Color(0xFF4B5563)),
                                bd: info.isExpired
                                    ? (isDark
                                        ? const Color(0xFF4B5563)
                                        : const Color(0xFFD1D5DB))
                                    : (isDark
                                        ? const Color(0xFF4B5563)
                                        : const Color(0xFFD1D5DB)),
                              ),
                            if (item.esColoquio &&
                                item.formattedDivision.isNotEmpty)
                              _chip(
                                text: item.formattedDivision,
                                bg: isDark
                                    ? cs.secondaryContainer
                                        .withValues(alpha: 0.4)
                                    : const Color(0xFFF3F4F6),
                                fg: isDark
                                    ? cs.onSecondaryContainer
                                    : const Color(0xFF374151),
                                bd: isDark
                                    ? cs.outlineVariant.withValues(alpha: 0.5)
                                    : const Color(0xFFD1D5DB),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _displayNameForScreen(MateriaParaLista item) {
  final raw =
      sanitizarTexto(item.materiaPlan?.displayNombre ?? item.nombreBase).trim();
  final low = sanitizeLowerNoAccents(raw);
  if (!low.contains('practica docente')) return raw;

  final match = RegExp(
    r'practica\s+docente\s+(i{1,3}|iv|\d+)',
    caseSensitive: false,
  ).firstMatch(low);
  if (match == null) return 'Práctica Docente';

  final token = match.group(1)!.toLowerCase();
  final number = switch (token) {
    'i' => 1,
    'ii' => 2,
    'iii' => 3,
    'iv' => 4,
    _ => int.tryParse(token),
  };

  return number == null ? 'Práctica Docente' : 'Práctica Docente $number';
}

Widget _daysInsignia(BuildContext context, DateTime? dt) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final info = _tiempoRelativo(dt);
  final text = _daysInsigniaTextCompact(dt);
  final parts = text.split('\n');
  final primaryText = parts.first;
  final secondaryText = parts.length > 1 ? parts.last : null;

  late final Color border;
  late final LinearGradient gradient;

  if (info.isExpired) {
    border = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF374151), Color(0xFF4B5563)]
          : const [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
    );
  } else {
    border = isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
    gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF1F9D55), Color(0xFF0F766E)]
          : const [Color(0xFF22C55E), Color(0xFF16A34A)],
    );
  }

  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          offset: const Offset(0, 5),
          color: Colors.black.withValues(alpha: 0.10),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          primaryText,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            height: 1.0,
            letterSpacing: 0.15,
          ),
        ),
        if (secondaryText != null) ...[
          const SizedBox(height: 4),
          Text(
            secondaryText,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 9.5,
              height: 1.0,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    ),
  );
}

String _daysInsigniaTextCompact(DateTime? dt) {
  if (dt == null) return 'SIN\nFECHA';

  final now = DateTime.now();
  final diff = dt.difference(now);
  final isExpired = diff.isNegative;

  if (!isExpired) {
    final totalMinutes = diff.inMinutes;
    final totalHours = (totalMinutes / 60).ceil();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final daysDiff = target.difference(today).inDays;

    if (daysDiff == 0) return 'HOY';
    if (totalHours <= 48) return '$totalHours\nHORAS';
    if (daysDiff == 1) return '1\nDIA';
    return '$daysDiff\nDIAS';
  }

  // Pasado
  final ago = diff.abs();
  final totalMinutes = ago.inMinutes;
  final totalHours = (totalMinutes / 60).floor();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final daysAgo = target.difference(today).inDays.abs();

  if (totalMinutes < 60) return 'AHORA';
  if (totalHours < 2) return '1\nHORA';
  if (totalHours < 24) return '$totalHours\nHORAS';
  if (daysAgo == 1) return 'AYER';
  if (daysAgo < 7) return '$daysAgo\nDIAS';
  if (daysAgo < 14) return '1\nSEM';
  if (daysAgo < 21) return '2\nSEM';
  if (daysAgo < 30) return '3\nSEM';
  if (daysAgo < 60) return '1\nMES';
  if (daysAgo < 90) return '2\nMESES';
  if (daysAgo < 180) return '3\nMESES';
  return 'EXP\n';
}

String _etiquetaDiasCompacta(DateTime? dt) {
  if (dt == null) return 'Sin fecha';
  final info = _tiempoRelativo(dt);
  return info.label;
}

// ignore: unused_element
String _daysInsigniaText(DateTime? dt) {
  if (dt == null) return 'SIN\nFECHA';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final diff = target.difference(today).inDays;

  if (diff == 0) return 'HOY';
  if (diff == 1) return '1\nDÍA';
  if (diff > 1) return '$diff\nDÍAS';

  final absDays = diff.abs();
  return absDays == 1 ? '1\nDÍA' : '$absDays\nDÍAS';
}

Widget _statusPill(
  BuildContext context, {
  required String label,
  required bool confirmed,
  bool isExpired = false,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  late final Color bg;
  late final Color fg;

  if (isExpired) {
    bg = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    fg = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  } else if (confirmed) {
    bg = isDark ? const Color(0xFF13302A) : const Color(0xFFECFDF3);
    fg = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857);
  } else {
    bg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    fg = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: isExpired
            ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB))
            : (confirmed
                ? (isDark ? cs.outlineVariant : const Color(0xFFA7F3D0))
                : (isDark ? cs.outlineVariant : const Color(0xFFD1D5DB))),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w800,
        fontSize: 10,
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        fontSize: 10,
      ),
    ),
  );
}

Widget _metaChip({
  required IconData icon,
  required String text,
  required Color bg,
  required Color fg,
  required Color bd,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: bd),
      boxShadow: [
        BoxShadow(
          blurRadius: 8,
          offset: const Offset(0, 2),
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ],
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

String _etiquetaHora(
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

// ignore: unused_element
String _etiquetaDias(DateTime? dt) {
  if (dt == null) return 'Sin fecha';
  final info = _tiempoRelativo(dt);
  return info.label;
}
