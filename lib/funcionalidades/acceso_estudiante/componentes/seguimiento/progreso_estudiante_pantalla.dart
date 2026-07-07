part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _ProgresoEstudiantePantalla extends StatelessWidget {
  const _ProgresoEstudiantePantalla({
    required this.payload,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectApproved(current);
    }).length;
    final inProgress = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectInProgress(current);
    }).length;
    final available = entries
        .where((entry) => entry.current == null && entry.available)
        .length;
    final blocked = entries
        .where((entry) => entry.current == null && !entry.available)
        .length;
    final total = entries.length;
    final progress = total == 0 ? 0.0 : approved / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mi avance'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _TarjetaProgresoGrande(
              progress: progress,
              approved: approved,
              totalPlan: total,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.check_circle_rounded,
                    label: 'Aprobadas',
                    value: '$approved',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgress',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.task_alt_rounded,
                    label: 'Disponibles',
                    value: '$available',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.lock_rounded,
                    label: 'No disponibles',
                    value: '$blocked',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TarjetaVidrio(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagn\u00f3stico breve',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _progressDiagnosis(
                      student: payload.student,
                      approved: approved,
                      available: available,
                      blocked: blocked,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final year in [1, 2, 3, 4]) ...[
              if (entries.any((entry) => entry.materia.anio == year))
                _TarjetaProgresoAnio(
                  year: year,
                  entries: entries
                      .where((entry) => entry.materia.anio == year)
                      .toList(growable: false),
                ),
              if (entries.any((entry) => entry.materia.anio == year))
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaProgresoAnio extends StatelessWidget {
  const _TarjetaProgresoAnio({
    required this.year,
    required this.entries,
  });

  final int year;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectApproved(current);
    }).length;
    final inProgress = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectInProgress(current);
    }).length;
    final available = entries
        .where((entry) => entry.current == null && entry.available)
        .length;
    final total = entries.length;

    return _TarjetaVidrio(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_etiquetaAnio(year)} a\u00f1o',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _PildoraSeccion(label: '$approved/$total aprobadas'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$inProgress cursando \u00b7 $available disponibles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
