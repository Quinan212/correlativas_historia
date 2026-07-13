part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _NotificacionesEstudiantePantalla extends StatelessWidget {
  const _NotificacionesEstudiantePantalla({
    required this.history,
    required this.entries,
  });

  final List<EntradaHistorialEstudiante> history;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movements = _buildStudentMovements(
      history,
      entries,
    ).take(24).toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notificaciones'),
      ),
      body: SafeArea(
        top: false,
        child: movements.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Sin movimientos recientes.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                itemCount: movements.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.28),
                ),
                itemBuilder: (context, index) => _FilaMovimientoEstudiante(
                  movement: movements[index],
                  history: history,
                  allEntries: entries,
                ),
              ),
      ),
    );
  }
}

class _FilaMovimientoEstudiante extends StatelessWidget {
  const _FilaMovimientoEstudiante({
    required this.movement,
    this.history,
    this.allEntries,
  });

  final _MovimientoEstudiante movement;
  final List<EntradaHistorialEstudiante>? history;
  final List<_CurriculumEntry>? allEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: movement.entry == null
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _DetalleMateriaEstudiantePantalla(
                    entry: movement.entry!,
                    allEntries: allEntries ?? const [],
                    history: history ?? const [],
                  ),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.55),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(movement.icon, color: movement.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movement.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                      ),
                      if (movement.dateLabel != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          movement.dateLabel!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movement.detail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (movement.entry != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
