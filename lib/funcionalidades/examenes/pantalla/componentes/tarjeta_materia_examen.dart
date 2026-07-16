part of 'lista_materias.dart';

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
