part of '../../eventos_examen_administrador_escritorio.dart';

class _BarraLateralEscritorio extends StatelessWidget {
  const _BarraLateralEscritorio({
    required this.selectedCareerId,
    required this.stats,
    required this.onCareerChanged,
  });

  final String selectedCareerId;
  final _EstadisticasEventosExamen stats;
  final ValueChanged<String> onCareerChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administración',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mesas y coloquios',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _ItemBarraLateral(
            label: 'Todas las carreras',
            detail:
                '${stats.totalMesas} mesas · ${stats.totalColoquios} coloquios',
            icon: Icons.dashboard_customize_rounded,
            selected: selectedCareerId == 'all',
            onTap: () => onCareerChanged('all'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'CARRERAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ..._adminCareers.map(
            (career) => _ItemBarraLateral(
              label: career.nombre,
              detail:
                  '${(stats.mesasByCareer as Map)[career.id] ?? 0} mesas · ${(stats.coloquiosByCareer as Map)[career.id] ?? 0} coloquios',
              icon: Icons.school_rounded,
              selected: selectedCareerId == career.id,
              onTap: () => onCareerChanged(career.id),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _NotaOperador(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _ItemBarraLateral extends StatelessWidget {
  const _ItemBarraLateral({
    required this.label,
    required this.detail,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? theme.colorScheme.primary : theme.hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: selected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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

class _NotaOperador extends StatelessWidget {
  const _NotaOperador({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vista pensada para preceptoría y dirección: filtrar, revisar y editar sin salir de la pantalla.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? null : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
