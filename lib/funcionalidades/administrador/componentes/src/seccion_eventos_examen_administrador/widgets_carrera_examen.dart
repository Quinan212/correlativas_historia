part of '../../seccion_eventos_examen_administrador.dart';

class _SelectorAlcance extends StatelessWidget {
  const _SelectorAlcance({required this.scope, required this.onChanged});

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


class _SelectorOrigenEventos extends StatelessWidget {
  const _SelectorOrigenEventos({
    required this.origin,
    required this.onChanged,
  });

  final String origin;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ChoiceChip(
          label: const Text('Actuales'),
          selected: origin == 'actuales',
          onSelected: (_) => onChanged('actuales'),
        ),
        ChoiceChip(
          label: const Text('Legacy'),
          selected: origin == 'legacy',
          onSelected: (_) => onChanged('legacy'),
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
    required this.legacyScope,
    required this.onEdit,
    required this.onDelete,
    this.yearFilter,
    this.searchQuery = '',
  });

  final List<EventoExamenAdministrador> careerEvents;
  final bool busy;
  final String scope;
  final String legacyScope;
  final ValueChanged<EventoExamenAdministrador> onEdit;
  final ValueChanged<EventoExamenAdministrador> onDelete;
  final int? yearFilter;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wantsLegacy = legacyScope == 'legacy';
    final scoped =
        careerEvents
            .where((event) {
              final matchesScope = switch (scope) {
                'coloquios' => event.isColoquio,
                'todos' => true,
                _ => !event.isColoquio,
              };
              if (!matchesScope || event.legacy != wantsLegacy) {
                return false;
              }
              if (yearFilter != null && _resolvedYear(event) != yearFilter) {
                return false;
              }
              final query = _clean(searchQuery);
              if (query.isEmpty) return true;
              final searchable = _clean(
                '${event.materia} ${event.docentes.join(' ')}',
              );
              return searchable.contains(query);
            })
            .toList(growable: false)
          ..sort((a, b) {
            final byYear = _yearSortValue(
              _resolvedYear(a),
            ).compareTo(_yearSortValue(_resolvedYear(b)));
            if (byYear != 0) return byYear;
            final byFecha = _compareDate(a.fechaVigente, b.fechaVigente);
            if (byFecha != 0) return byFecha;
            final byMateria = a.materia.compareTo(b.materia);
            if (byMateria != 0) return byMateria;
            return (a.horaVigente ?? '').compareTo(b.horaVigente ?? '');
          });

    if (scoped.isEmpty) {
      final eventLabel = switch (scope) {
        'coloquios' => 'coloquios',
        'todos' => 'eventos',
        _ => 'mesas',
      };
      final originLabel = wantsLegacy ? 'legacy' : 'actuales';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'Todavía no hay $eventLabel $originLabel.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < scoped.length; index++) ...[
          if (index == 0 ||
              _resolvedYear(scoped[index]) !=
                  _resolvedYear(scoped[index - 1]))
            _EncabezadoAnio(year: _resolvedYear(scoped[index])),
          _FilaEventoExamenCarrera(
            event: scoped[index],
            busy: busy,
            onEdit: () => onEdit(scoped[index]),
            onDelete: () => onDelete(scoped[index]),
          ),
          if (index < scoped.length - 1 &&
              _resolvedYear(scoped[index]) ==
                  _resolvedYear(scoped[index + 1]))
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant,
            ),
        ],
      ],
    );
  }
}

class _EncabezadoAnio extends StatelessWidget {
  const _EncabezadoAnio({required this.year});

  final int? year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        year == null ? 'Sin año' : '$year.º año',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FilaEventoExamenCarrera extends StatelessWidget {
  const _FilaEventoExamenCarrera({
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
    final displayYear = _resolvedYear(event);
    final metadata = <String>[
      event.isColoquio ? 'Coloquio' : 'Mesa',
      if (displayYear != null) '$displayYear.º año',
      if (event.fechaVigente != null) _formatDate(event.fechaVigente!),
      if (event.horaVigente != null) event.horaVigente!,
    ];

    final statusColor = switch (event.estado.name) {
      'cancelada' => theme.colorScheme.error,
      'suspendida' => const Color(0xFFD9A400),
      'reprogramada' => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.materia,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (metadata.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              metadata.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (event.mostrarAvisoEstado) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: statusColor),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${event.estadoEtiqueta}: ${event.mensajeEstadoEfectivo}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!event.visible) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Text(
                  'Oculta en la vista pública',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          if (event.docentes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              event.docentes.join(' / '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 5),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              TextButton.icon(
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.22,
        ),
        borderRadius: BorderRadius.circular(14),
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
              _Insignia(label: event.isColoquio ? 'Coloquio' : 'Mesa'),
              if (displayYear != null) _Insignia(label: '$displayYear° año'),
              if (event.mostrarAvisoEstado)
                _Insignia(label: event.estadoEtiqueta),
              if (!event.visible) const _Insignia(label: 'OCULTA'),
              if (event.horaVigente != null)
                _Insignia(label: event.horaVigente!),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.materia,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (event.fechaVigente != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(event.fechaVigente!),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (event.mostrarAvisoEstado &&
              event.mensajeEstadoEfectivo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              event.mensajeEstadoEfectivo,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (event.docentes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(event.docentes.join(' / '), style: theme.textTheme.bodySmall),
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
