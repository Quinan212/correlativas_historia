part of '../../seccion_eventos_examen_administrador.dart';

class _SelectorAlcance extends StatelessWidget {
  const _SelectorAlcance({
    required this.scope,
    required this.onChanged,
  });

  final String scope;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ChoiceChip(
          label: const Text('Mesas'),
          selected: scope == 'mesas',
          onSelected: (_) => onChanged('mesas'),
        ),
        ChoiceChip(
          label: const Text('Coloquios'),
          selected: scope == 'coloquios',
          onSelected: (_) => onChanged('coloquios'),
        ),
      ],
    );
  }
}

class _CareerScopeView extends StatelessWidget {
  const _CareerScopeView({
    required this.careerEvents,
    required this.busy,
    required this.scope,
    required this.onEdit,
    required this.onDelete,
  });

  final List<EventoExamenAdministrador> careerEvents;
  final bool busy;
  final String scope;
  final ValueChanged<EventoExamenAdministrador> onEdit;
  final ValueChanged<EventoExamenAdministrador> onDelete;

  @override
  Widget build(BuildContext context) {
    final scoped = careerEvents
        .where((event) =>
            scope == 'coloquios' ? event.isColoquio : !event.isColoquio)
        .toList(growable: false)
      ..sort((a, b) {
        final byYear = _yearSortValue(_resolvedYear(a))
            .compareTo(_yearSortValue(_resolvedYear(b)));
        if (byYear != 0) return byYear;
        final byFecha = _compareDate(a.fecha, b.fecha);
        if (byFecha != 0) return byFecha;
        final byMateria = a.materia.compareTo(b.materia);
        if (byMateria != 0) return byMateria;
        return (a.hora ?? '').compareTo(b.hora ?? '');
      });

    final grouped = <int?, List<EventoExamenAdministrador>>{};
    for (final event in scoped) {
      grouped
          .putIfAbsent(
              _resolvedYear(event), () => <EventoExamenAdministrador>[])
          .add(event);
    }

    for (final list in grouped.values) {
      list.sort((a, b) {
        final byFecha = _compareDate(a.fecha, b.fecha);
        if (byFecha != 0) return byFecha;
        final byMateria = a.materia.compareTo(b.materia);
        if (byMateria != 0) return byMateria;
        return (a.hora ?? '').compareTo(b.hora ?? '');
      });
    }

    final years = [1, 2, 3, 4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final year in years) ...[
          _TarjetaGrupoAnio(
            title: '$year° año',
            events: grouped[year] ?? const <EventoExamenAdministrador>[],
            busy: busy,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TarjetaGrupoAnio extends StatelessWidget {
  const _TarjetaGrupoAnio({
    required this.title,
    required this.events,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final List<EventoExamenAdministrador> events;
  final bool busy;
  final ValueChanged<EventoExamenAdministrador> onEdit;
  final ValueChanged<EventoExamenAdministrador> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mesas =
        events.where((event) => !event.isColoquio).toList(growable: false);
    final coloquios =
        events.where((event) => event.isColoquio).toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(

          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${events.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          children: [
            if (mesas.isNotEmpty) ...[
              Text(
                'Mesas',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...mesas.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaEventoExamen(
                    event: event,
                    busy: busy,
                    onEdit: () => onEdit(event),
                    onDelete: () => onDelete(event),
                  ),
                ),
              ),
            ],
            if (coloquios.isNotEmpty) ...[
              if (mesas.isNotEmpty) const SizedBox(height: 6),
              Text(
                'Coloquios',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...coloquios.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaEventoExamen(
                    event: event,
                    busy: busy,
                    onEdit: () => onEdit(event),
                    onDelete: () => onDelete(event),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaEventoExamen extends StatelessWidget {
  const _TarjetaEventoExamen({
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.busy,
  });

  final EventoExamenAdministrador event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final careerLabel = _etiquetaCarrera(event.careerId);
    final displayYear = _resolvedYear(event);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Insignia(label: careerLabel),
              _Insignia(
                label: event.isColoquio ? 'Coloquio' : 'Mesa',
              ),
              if (displayYear != null) _Insignia(label: '$displayYear° año'),
              if (event.hora != null) _Insignia(label: event.hora!),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.materia,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (event.fecha != null) ...[
            const SizedBox(height: 4),
            Text(_formatDate(event.fecha!), style: theme.textTheme.bodyMedium),
          ],
          if (event.docentes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.docentes.join(' / '),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Borrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
