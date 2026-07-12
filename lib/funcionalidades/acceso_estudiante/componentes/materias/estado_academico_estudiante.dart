part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _TableroEstadoMateria extends StatelessWidget {
  const _TableroEstadoMateria({required this.entry});

  final _CurriculumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = entry.current;

    // ── colores y datos del estado ─────────────────────────
    final bool isApproved =
        current != null && _estadoMateriaParaRequisito(current) == 'aprobada';
    final bool isInProgress = current != null && _isSubjectInProgress(current);
    final bool isBlocked = _isEntryBlocked(entry);

    final Color statusColor = isApproved
        ? const Color(0xFF2EAD57)
        : isInProgress
            ? const Color(0xFF1E6FDB)
            : isBlocked
                ? const Color(0xFFDC2626)
                : cs.onSurfaceVariant;

    final IconData statusIcon = isApproved
        ? Icons.check_circle_rounded
        : isInProgress
            ? Icons.play_circle_rounded
            : isBlocked
                ? Icons.block_rounded
                : Icons.remove_circle_outline_rounded;

    final String statusLabel = isApproved
        ? 'Aprobada'
        : isInProgress
            ? 'Cursando'
            : isBlocked
                ? 'No disponible'
                : 'Sin cursar';

    // ── nota ──────────────────────────────────────────────
    final String? noteLabel = current?.grade != null
        ? 'Nota ${current!.grade!.toStringAsFixed(0)}'
        : null;
    final String? periodLabel = current?.sourceDate != null
        ? nombreMesAcademico(current!.sourceDate!)
        : (current?.academicPeriod.isNotEmpty ?? false)
            ? _etiquetaPeriodo(current!.academicPeriod)
            : null;
    final String? condLabel = current?.detailStatus != null
        ? _etiquetaDetalle(current!.detailStatus!)
        : null;
    final hasSourceDate = current?.sourceDate != null;
    final noteFlex = hasSourceDate ? 3 : 4;
    final conditionFlex = hasSourceDate ? 4 : 6;
    const dateFlex = 3;

    const double spacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fila 1: grande (estado actual) + chico (valor estado)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Card grande: Estado actual ──────────────────
              Expanded(
                flex: 3,
                child: TarjetaMetricaVidrio(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 22,
                          color: statusColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Estado actual',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revisá el estado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: spacing),
              // ── Card chica: estado ─────────────────────────
              Expanded(
                flex: 2,
                  child: TarjetaMetricaVidrio(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcon, size: 26, color: statusColor),
                      const Spacer(),
                      Text(
                        statusLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Fila 2 solo si hay nota o condición
        if (current != null && (noteLabel != null || condLabel != null)) ...[
          const SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card chica: nota + período ─────────────
                if (noteLabel != null)
                  Expanded(
                    flex: noteFlex,
                    child: TarjetaMetricaVidrio(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 22,
                            color: Color(0xFFD97706),
                          ),
                          const Spacer(),
                          Text(
                            noteLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            periodLabel ?? 'Período',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (noteLabel != null && condLabel != null)
                  const SizedBox(width: spacing),
                // ── Card chica: condición ──────────────────
                if (condLabel != null)
                  Expanded(
                    flex: conditionFlex,
                    child: TarjetaMetricaVidrio(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            condLabel.toLowerCase().contains('directa')
                                ? Icons.verified_rounded
                                : condLabel
                                        .toLowerCase()
                                        .contains('extraordinaria')
                                    ? Icons.warning_amber_rounded
                                    : Icons.event_available_rounded,
                            size: 22,
                            color: condLabel.toLowerCase().contains('directa')
                                ? const Color(0xFF2EAD57)
                                : condLabel
                                        .toLowerCase()
                                        .contains('extraordinaria')
                                    ? const Color(0xFFD97706)
                                    : cs.primary,
                          ),
                          const Spacer(),
                          Text(
                            condLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Condición',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ── Card chica: fecha de aprobación ───────────
                if (hasSourceDate) ...[
                  const SizedBox(width: spacing),
                  Expanded(
                    flex: dateFlex,
                    child: TarjetaMetricaVidrio(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 22,
                            color: Color(0xFF7C3AED),
                          ),
                          const Spacer(),
                          Text(
                            '${current.sourceDate!.year}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${current.sourceDate!.day.toString().padLeft(2, '0')}/${current.sourceDate!.month.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

class _PildoraSeccion extends StatelessWidget {
  const _PildoraSeccion({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _EtiquetaFiltroAnio extends StatelessWidget {
  const _EtiquetaFiltroAnio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.10)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.20)
                  : theme.colorScheme.outline.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _LineaMetaMateria extends StatelessWidget {
  const _LineaMetaMateria({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
      ],
    );
  }
}
