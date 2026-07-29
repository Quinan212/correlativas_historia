import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../../examenes/modelos/evento_examen.dart';
import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/pantallas/utilidades_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../modelos/evento_examen_administrador.dart';
import '../proveedores/proveedores_eventos_examen_administrador.dart';
import 'hoja_editor_evento_examen.dart';


const Set<String> _careerIdsVisiblesAdminExamenes = {
  'historia',
  'geografia',
  'politica',
  'musica',
  'artes_visuales',
};

List<CareerInfo> get _careersVisiblesAdminExamenes => [
  for (final career in kCareers)
    if (_careerIdsVisiblesAdminExamenes.contains(career.id)) career,
];

bool _careerVisibleEnAdminExamenes(String careerId) {
  return _careerIdsVisiblesAdminExamenes.contains(careerId);
}

class SeccionEventosExamenAdministrador extends ConsumerStatefulWidget {
  const SeccionEventosExamenAdministrador({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<SeccionEventosExamenAdministrador> createState() =>
      _SeccionEventosExamenAdministradorState();
}

class _SeccionEventosExamenAdministradorState
    extends ConsumerState<SeccionEventosExamenAdministrador> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _careerId = 'historia';
  String _scope = 'todos';
  String _legacyScope = 'actuales';
  String _viewMode = 'career';
  String _query = '';
  int? _year;
  bool _busy = false;
  bool _refreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      ref.invalidate(proveedorEventosExamenAdministrador);
      await ref.read(proveedorEventosExamenAdministrador.future);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    EventoExamenAdministrador? event,
  ) async {
    if (_busy) return;

    final draft = await mostrarHojaEditorEventoExamen(
      context: context,
      title: event == null
          ? _scope == 'coloquios'
                ? 'Nuevo coloquio'
                : 'Nueva mesa'
          : event.isColoquio
          ? 'Editar coloquio'
          : 'Editar mesa',
      coloquioMode: event?.isColoquio ?? _scope == 'coloquios',
      initialEvent: event,
    );
    if (draft == null || !mounted) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay conexión con Supabase.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final repository = ref.read(
        proveedorRepositorioEventosExamenAdministrador,
      );
      await repository.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(proveedorEventosExamenAdministrador);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Examen guardado.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteEvent(
    BuildContext context,
    EventoExamenAdministrador event,
  ) async {
    if (_busy) return;

    final type = event.isColoquio ? 'coloquio' : 'mesa';
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Eliminar $type'),
            content: Text(
              'Vas a eliminar "${event.materia}". Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null || event.id == null) return;

    setState(() => _busy = true);
    try {
      final repository = ref.read(
        proveedorRepositorioEventosExamenAdministrador,
      );
      await repository.delete(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        id: event.id!,
      );
      ref.invalidate(proveedorEventosExamenAdministrador);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_capitalize(type)} eliminado.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseCareer() async {
    final careers = _careersVisiblesAdminExamenes;
    final selected = await mostrarHojaAtlassian<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Seleccionar carrera',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: careers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final career = careers[index];
                      return PanelAtlassian(
                        selected: career.id == _careerId,
                        onTap: () => Navigator.of(sheetContext).pop(career.id),
                        child: Row(
                          children: [
                            Icon(
                              career.id == _careerId
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: career.id == _careerId
                                  ? Theme.of(sheetContext).colorScheme.primary
                                  : Theme.of(
                                      sheetContext,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                career.nombre,
                                style: Theme.of(sheetContext).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _careerId = selected;
      _viewMode = 'career';
      _year = null;
    });
  }

  Future<void> _chooseYear(List<int> years) async {
    final selected = await mostrarHojaAtlassian<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filtrar por año',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              PanelAtlassian(
                selected: _year == null,
                onTap: () => Navigator.of(sheetContext).pop('todos'),
                child: const Text('Todos los años'),
              ),
              const SizedBox(height: 8),
              for (final year in years) ...[
                PanelAtlassian(
                  selected: _year == year,
                  onTap: () => Navigator.of(sheetContext).pop('$year'),
                  child: Text('$year.º año'),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _year = selected == 'todos' ? null : int.parse(selected));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _scope = 'todos';
      _legacyScope = 'actuales';
      _viewMode = 'career';
      _query = '';
      _year = null;
    });
  }

  List<int> _availableYears(List<EventoExamenAdministrador> source) {
    final wantsLegacy = _legacyScope == 'legacy';
    final years = source
        .where((event) {
          if (!_careerVisibleEnAdminExamenes(event.careerId)) return false;
          if (event.legacy != wantsLegacy) return false;
          if (_viewMode == 'career' && event.careerId != _careerId) {
            return false;
          }
          return true;
        })
        .map(_resolvedYear)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    return years;
  }

  List<EventoExamenAdministrador> _filter(
    List<EventoExamenAdministrador> source,
  ) {
    final normalizedQuery = sanitizeLowerNoAccents(_query.trim());
    final wantsLegacy = _legacyScope == 'legacy';

    final filtered = source.where((event) {
      if (!_careerVisibleEnAdminExamenes(event.careerId)) return false;
      if (event.legacy != wantsLegacy) return false;
      if (_viewMode == 'career' && event.careerId != _careerId) return false;
      if (_scope == 'llamados' && event.isColoquio) return false;
      if (_scope == 'coloquios' && !event.isColoquio) return false;
      if (_year != null && _resolvedYear(event) != _year) return false;
      if (normalizedQuery.isEmpty) return true;

      final searchable = sanitizeLowerNoAccents(
        '${event.materia} ${event.docentes.join(' ')} ${_careerLabel(event.careerId)}',
      );
      return searchable.contains(normalizedQuery);
    }).toList(growable: false);

    filtered.sort((first, second) {
      if (_viewMode == 'global') {
        final career = _careerLabel(
          first.careerId,
        ).compareTo(_careerLabel(second.careerId));
        if (career != 0) return career;
      }
      final year = _yearSortValue(
        _resolvedYear(first),
      ).compareTo(_yearSortValue(_resolvedYear(second)));
      if (year != 0) return year;
      final date = _compareDate(first.fechaVigente, second.fechaVigente);
      if (date != 0) return date;
      final matter = first.materia.compareTo(second.materia);
      if (matter != 0) return matter;
      return (first.horaVigente ?? '').compareTo(second.horaVigente ?? '');
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(proveedorEventosExamenAdministrador);
    final all = eventsAsync.asData?.value ?? const <EventoExamenAdministrador>[];
    final years = _availableYears(all);
    final headerHeight = MediaQuery.paddingOf(context).top + 72;
    final header = EncabezadoSeccionAtlassianColapsable(
      scrollController: _scrollController,
      title: 'Exámenes',
      subtitle: 'Administración de mesas y coloquios',
      leading: BotonIconoAtlassian(
        icon: Icons.arrow_back_rounded,
        tooltip: 'Volver',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      actions: [
        BotonIconoAtlassian(
          icon: Icons.add_rounded,
          tooltip: 'Nuevo examen',
          selected: true,
          onPressed: _busy ? null : () => unawaited(_openEditor(context, null)),
        ),
        BotonIconoAtlassian(
          icon: Icons.refresh_rounded,
          tooltip: 'Actualizar',
          onPressed: _refreshing ? null : () => unawaited(_refresh()),
        ),
      ],
    );

    return Stack(
      children: [
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                headerHeight + 16,
                16,
                72 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FiltrosAdministradorExamenesAtlassian(
                          careerId: _careerId,
                          scope: _scope,
                          legacyScope: _legacyScope,
                          viewMode: _viewMode,
                          year: _year,
                          years: years,
                          searchController: _searchController,
                          onChooseCareer: _chooseCareer,
                          onChooseYear: () => _chooseYear(years),
                          onScopeChanged: (value) =>
                              setState(() => _scope = value),
                          onLegacyScopeChanged: (value) => setState(() {
                            _legacyScope = value;
                            _year = null;
                          }),
                          onViewModeChanged: (value) => setState(() {
                            _viewMode = value;
                            _year = null;
                          }),
                          onSearchChanged: (value) =>
                              setState(() => _query = value),
                          onClearSearch: _clearSearch,
                          onResetFilters: _resetFilters,
                        ),
                        const SizedBox(height: 16),
                        eventsAsync.when(
                          loading: () => const _CargaAdministradorExamenes(),
                          error: (error, _) => EstadoVacioAtlassian(
                            icon: Icons.error_outline_rounded,
                            title: 'No se pudieron cargar los exámenes',
                            message: error.toString(),
                            action: BotonAtlassian(
                              label: 'Reintentar',
                              icon: Icons.refresh_rounded,
                              primary: true,
                              onPressed: () => unawaited(_refresh()),
                            ),
                          ),
                          data: (items) {
                            final filtered = _filter(items);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ResumenAdministradorExamenesAtlassian(
                                  events: filtered,
                                ),
                                const SizedBox(height: 20),
                                _ResultadosAdministradorExamenesAtlassian(
                                  events: filtered,
                                  viewMode: _viewMode,
                                  busy: _busy,
                                  onNew: () =>
                                      unawaited(_openEditor(context, null)),
                                  onEdit: (event) =>
                                      unawaited(_openEditor(context, event)),
                                  onDelete: (event) =>
                                      unawaited(_deleteEvent(context, event)),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(alignment: Alignment.topCenter, child: header),
      ],
    );
  }
}

class _FiltrosAdministradorExamenesAtlassian extends StatelessWidget {
  const _FiltrosAdministradorExamenesAtlassian({
    required this.careerId,
    required this.scope,
    required this.legacyScope,
    required this.viewMode,
    required this.year,
    required this.years,
    required this.searchController,
    required this.onChooseCareer,
    required this.onChooseYear,
    required this.onScopeChanged,
    required this.onLegacyScopeChanged,
    required this.onViewModeChanged,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onResetFilters,
  });

  final String careerId;
  final String scope;
  final String legacyScope;
  final String viewMode;
  final int? year;
  final List<int> years;
  final TextEditingController searchController;
  final VoidCallback onChooseCareer;
  final VoidCallback onChooseYear;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<String> onLegacyScopeChanged;
  final ValueChanged<String> onViewModeChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final active =
        (scope == 'todos' ? 0 : 1) +
        (legacyScope == 'actuales' ? 0 : 1) +
        (viewMode == 'career' ? 0 : 1) +
        (year == null ? 0 : 1) +
        (searchController.text.trim().isEmpty ? 0 : 1);

    return PanelAtlassian(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Buscar y filtrar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (active > 0)
                TextButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: Text('Limpiar ($active)'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          CampoBusquedaAtlassian(
            controller: searchController,
            hintText: 'Buscar materia o docente',
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
          const SizedBox(height: 10),
          ControlSegmentadoAtlassian<String>(
            value: viewMode,
            segments: const [
              SegmentoAtlassian(
                value: 'career',
                label: 'Por carrera',
                icon: Icons.school_outlined,
              ),
              SegmentoAtlassian(
                value: 'global',
                label: 'Vista global',
                icon: Icons.view_list_outlined,
              ),
            ],
            onChanged: onViewModeChanged,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final career = SelectorAtlassian(
                label: 'Carrera',
                value: viewMode == 'global'
                    ? 'Todas las carreras'
                    : _careerLabel(careerId),
                icon: Icons.school_outlined,
                onTap: viewMode == 'global' ? null : onChooseCareer,
                enabled: viewMode != 'global',
              );
              final yearSelector = SelectorAtlassian(
                label: 'Año',
                value: year == null ? 'Todos' : '$year.º año',
                icon: Icons.calendar_view_month_outlined,
                onTap: years.isEmpty ? null : onChooseYear,
                enabled: years.isNotEmpty,
              );

              if (constraints.maxWidth >= 620) {
                return Row(
                  children: [
                    Expanded(child: career),
                    const SizedBox(width: 10),
                    SizedBox(width: 190, child: yearSelector),
                  ],
                );
              }
              return Column(
                children: [
                  career,
                  const SizedBox(height: 10),
                  yearSelector,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          ControlSegmentadoAtlassian<String>(
            value: scope,
            segments: const [
              SegmentoAtlassian(value: 'todos', label: 'Todos'),
              SegmentoAtlassian(
                value: 'llamados',
                label: 'Llamados',
                icon: Icons.event_note_outlined,
              ),
              SegmentoAtlassian(
                value: 'coloquios',
                label: 'Coloquios',
                icon: Icons.groups_2_outlined,
              ),
            ],
            onChanged: onScopeChanged,
          ),
          const SizedBox(height: 10),
          ControlSegmentadoAtlassian<String>(
            value: legacyScope,
            segments: const [
              SegmentoAtlassian(
                value: 'actuales',
                label: 'Actuales',
                icon: Icons.auto_awesome_outlined,
              ),
              SegmentoAtlassian(
                value: 'legacy',
                label: 'Legacy',
                icon: Icons.history_rounded,
              ),
            ],
            onChanged: onLegacyScopeChanged,
          ),
        ],
      ),
    );
  }
}

class _ResumenAdministradorExamenesAtlassian extends StatelessWidget {
  const _ResumenAdministradorExamenesAtlassian({required this.events});

  final List<EventoExamenAdministrador> events;

  @override
  Widget build(BuildContext context) {
    final visible = events.where((event) => event.visible).length;
    final withActa = events.where((event) {
      return event.actaHabilitada &&
          (event.actaUrl?.trim().isNotEmpty ?? false);
    }).length;
    final changed = events
        .where((event) => event.estado != EstadoEventoExamen.activa)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        final metrics = [
          MetricaAtlassian(
            label: 'Registros',
            value: '${events.length}',
            icon: Icons.list_alt_rounded,
            appearance: AparienciaLozengeAtlassian.brand,
          ),
          MetricaAtlassian(
            label: 'Visibles',
            value: '$visible',
            icon: Icons.visibility_outlined,
            appearance: AparienciaLozengeAtlassian.success,
          ),
          MetricaAtlassian(
            label: 'Con acta',
            value: '$withActa',
            icon: Icons.description_outlined,
            appearance: AparienciaLozengeAtlassian.neutral,
          ),
          MetricaAtlassian(
            label: 'Con cambios',
            value: '$changed',
            icon: Icons.notification_important_outlined,
            appearance: AparienciaLozengeAtlassian.warning,
          ),
        ];

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics) SizedBox(width: width, child: metric),
          ],
        );
      },
    );
  }
}

class _ResultadosAdministradorExamenesAtlassian extends StatelessWidget {
  const _ResultadosAdministradorExamenesAtlassian({
    required this.events,
    required this.viewMode,
    required this.busy,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
  });

  final List<EventoExamenAdministrador> events;
  final String viewMode;
  final bool busy;
  final VoidCallback onNew;
  final ValueChanged<EventoExamenAdministrador> onEdit;
  final ValueChanged<EventoExamenAdministrador> onDelete;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return EstadoVacioAtlassian(
        icon: Icons.event_busy_rounded,
        title: 'Sin resultados',
        message: 'Revisá la carrera, el año o los filtros seleccionados.',
        action: BotonAtlassian(
          label: 'Nuevo examen',
          icon: Icons.add_rounded,
          primary: true,
          onPressed: busy ? null : onNew,
        ),
      );
    }

    final groups = <String, List<EventoExamenAdministrador>>{};
    for (final event in events) {
      final key = viewMode == 'global'
          ? _careerLabel(event.careerId)
          : _yearLabel(_resolvedYear(event));
      groups.putIfAbsent(key, () => <EventoExamenAdministrador>[]).add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries) ...[
          SeparadorTituloAtlassian(
            title: entry.key,
            subtitle: '${entry.value.length} registros',
          ),
          const SizedBox(height: 6),
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                for (var index = 0; index < entry.value.length; index++) ...[
                  _FilaAdministradorExamenAtlassian(
                    event: entry.value[index],
                    showYear: viewMode == 'global',
                    busy: busy,
                    onEdit: () => onEdit(entry.value[index]),
                    onDelete: () => onDelete(entry.value[index]),
                  ),
                  if (index != entry.value.length - 1)
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

enum _AccionEventoAdministrador { editar, borrar }

class _FilaAdministradorExamenAtlassian extends StatelessWidget {
  const _FilaAdministradorExamenAtlassian({
    required this.event,
    required this.showYear,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final EventoExamenAdministrador event;
  final bool showYear;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final future = event.fechaVigente?.isAfter(DateTime.now()) ?? false;
    final hasStatus = event.mostrarAvisoEstado;
    final statusColor = _statusForeground(context, event.estado);
    final metadata = <String>[
      if (showYear && _resolvedYear(event) != null)
        '${_resolvedYear(event)}.º año',
      formatoFechaHoraAtlassian(event.fechaVigente, event.horaVigente),
    ];

    return Material(
      color: hasStatus
          ? _statusBackground(context, event.estado)
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: busy ? null : onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasStatus
                      ? _statusIconBackground(context, event.estado)
                      : future
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                ),
                child: Icon(
                  hasStatus
                      ? _statusIcon(event.estado)
                      : future
                      ? Icons.event_available_rounded
                      : Icons.event_note_rounded,
                  color: hasStatus
                      ? statusColor
                      : future
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.materia,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    if (hasStatus) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.mensajeEstadoEfectivo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      metadata.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (event.docentes.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        event.docentes.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasStatus)
                    LozengeAtlassian(
                      label: event.estadoEtiqueta,
                      appearance: _statusAppearance(event.estado),
                    )
                  else
                    LozengeAtlassian(
                      label: _shortInstanceLabel(event.instancia),
                      appearance: event.isColoquio
                          ? AparienciaLozengeAtlassian.discovery
                          : AparienciaLozengeAtlassian.brand,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!event.visible)
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.visibility_off_outlined,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (event.actaHabilitada &&
                          (event.actaUrl?.trim().isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.description_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      PopupMenuButton<_AccionEventoAdministrador>(
                        enabled: !busy,
                        tooltip: 'Acciones',
                        icon: const Icon(Icons.more_horiz_rounded),
                        onSelected: (action) {
                          if (action ==
                              _AccionEventoAdministrador.editar) {
                            onEdit();
                          } else {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _AccionEventoAdministrador.editar,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Editar'),
                            ),
                          ),
                          PopupMenuItem(
                            value: _AccionEventoAdministrador.borrar,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.delete_outline_rounded),
                              title: Text('Borrar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CargaAdministradorExamenes extends StatelessWidget {
  const _CargaAdministradorExamenes();

  @override
  Widget build(BuildContext context) {
    return PanelAtlassian(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              'Cargando exámenes…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

int _compareDate(DateTime? first, DateTime? second) {
  if (first == null && second == null) return 0;
  if (first == null) return 1;
  if (second == null) return -1;
  return first.compareTo(second);
}

int _yearSortValue(int? year) => year ?? 99;

int? _resolvedYear(EventoExamenAdministrador event) {
  if (event.anio != null) return event.anio;

  final matter = sanitizeLowerNoAccents(event.materia);
  if (event.careerId == 'historia') {
    if (matter.contains('practica docente i')) return 1;
    if (matter.contains('didactica de las ciencias sociales')) return 2;
    if (matter.contains('practica docente ii')) return 2;
    if (matter.contains('epistemologia de la historia')) return 3;
    if (matter.contains('practica docente iii')) return 3;
  } else if (event.careerId == 'geografia') {
    if (matter.contains('practica docente iii')) return 3;
  } else if (event.careerId == 'politica') {
    if (matter.contains('practica docente ii')) return 2;
    if (matter.contains('didactica de las ciencias sociales')) return 2;
    if (matter.contains('practica docente iii')) return 3;
  }
  return null;
}

String _careerLabel(String careerId) {
  for (final career in kCareers) {
    if (career.id == careerId) return career.nombre;
  }
  return careerId;
}

String _yearLabel(int? year) => year == null ? 'Sin año' : '$year.º año';

String _shortInstanceLabel(String raw) {
  return switch (raw) {
    'llamado_1' => 'Llamado 1',
    'llamado_2' => 'Llamado 2',
    'coloquio' => 'Coloquio',
    _ => 'Examen',
  };
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

AparienciaLozengeAtlassian _statusAppearance(EstadoEventoExamen status) {
  return switch (status) {
    EstadoEventoExamen.activa => AparienciaLozengeAtlassian.success,
    EstadoEventoExamen.suspendida => AparienciaLozengeAtlassian.warning,
    EstadoEventoExamen.cancelada => AparienciaLozengeAtlassian.danger,
    EstadoEventoExamen.reprogramada => AparienciaLozengeAtlassian.discovery,
  };
}

IconData _statusIcon(EstadoEventoExamen status) {
  return switch (status) {
    EstadoEventoExamen.activa => Icons.check_circle_outline_rounded,
    EstadoEventoExamen.suspendida => Icons.warning_amber_rounded,
    EstadoEventoExamen.cancelada => Icons.cancel_outlined,
    EstadoEventoExamen.reprogramada => Icons.event_repeat_rounded,
  };
}

Color _statusBackground(BuildContext context, EstadoEventoExamen status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa => Colors.transparent,
    EstadoEventoExamen.suspendida =>
      dark ? const Color(0xFF262112) : const Color(0xFFFFFBE6),
    EstadoEventoExamen.cancelada =>
      dark ? const Color(0xFF321A1A) : const Color(0xFFFFEBE6),
    EstadoEventoExamen.reprogramada =>
      dark ? const Color(0xFF16233A) : const Color(0xFFE9F2FF),
  };
}

Color _statusIconBackground(
  BuildContext context,
  EstadoEventoExamen status,
) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa =>
      Theme.of(context).colorScheme.primaryContainer,
    EstadoEventoExamen.suspendida =>
      dark ? const Color(0xFF4A3B00) : const Color(0xFFFFF3CD),
    EstadoEventoExamen.cancelada =>
      dark ? const Color(0xFF5A2020) : const Color(0xFFFFD5D2),
    EstadoEventoExamen.reprogramada =>
      dark ? const Color(0xFF173A66) : const Color(0xFFD6E8FF),
  };
}

Color _statusForeground(BuildContext context, EstadoEventoExamen status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa => Theme.of(context).colorScheme.primary,
    EstadoEventoExamen.suspendida =>
      dark ? const Color(0xFFFFD54F) : const Color(0xFF8A5D00),
    EstadoEventoExamen.cancelada =>
      dark ? const Color(0xFFFF8F85) : const Color(0xFFAE2A19),
    EstadoEventoExamen.reprogramada =>
      dark ? const Color(0xFF85B8FF) : const Color(0xFF0052CC),
  };
}
