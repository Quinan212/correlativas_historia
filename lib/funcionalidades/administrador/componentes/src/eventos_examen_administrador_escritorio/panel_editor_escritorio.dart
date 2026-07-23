part of '../../eventos_examen_administrador_escritorio.dart';

class _PanelEditor extends StatelessWidget {
  const _PanelEditor({
    required this.busy,
    required this.scope,
    required this.editingEvent,
    required this.onClose,
    required this.onSave,
  });

  final bool busy;
  final String scope;
  final EventoExamenAdministrador? editingEvent;
  final VoidCallback onClose;
  final ValueChanged<BorradorEventoExamenAdministrador> onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 460,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: EditorEventoExamenAdministrador(
          key: ValueKey(
            editingEvent == null
                ? 'new-$scope'
                : 'edit-${editingEvent!.id ?? editingEvent!.materia}',
          ),
          title: editingEvent == null
              ? scope == 'mesas'
                    ? 'Nueva mesa'
                    : 'Nuevo coloquio'
              : editingEvent!.isColoquio
              ? 'Editar coloquio'
              : 'Editar mesa',
          coloquioMode: editingEvent?.isColoquio ?? scope == 'coloquios',
          initialEvent: editingEvent,
          busy: busy,
          onCancel: onClose,
          onSave: onSave,
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({
    required this.query,
    required this.scope,
    required this.careerName,
    required this.year,
    required this.onNew,
  });

  final String query;
  final String scope;
  final String careerName;
  final int? year;
  final VoidCallback? onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = scope == 'mesas' ? 'mesas' : 'coloquios';
    final yearText = year == null
        ? ''
        : ' de ${_etiquetaAnio(year).toLowerCase()}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isEmpty
                  ? Icons.event_note_outlined
                  : Icons.search_off_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              query.isEmpty
                  ? 'No hay $typeLabel$yearText en $careerName.'
                  : 'No se encontraron resultados para "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add_rounded),
              label: Text(scope == 'mesas' ? 'Cargar mesa' : 'Cargar coloquio'),
            ),
          ],
        ),
      ),
    );
  }
}
