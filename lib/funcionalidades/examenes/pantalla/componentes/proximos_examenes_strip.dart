part of 'lista_materias.dart';

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
