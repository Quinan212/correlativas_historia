import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../examenes/modelos/evento_examen.dart';
import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../../laboratorio_atlassian/pantallas/utilidades_atlassian.dart';
import '../componentes/dialogo_actualizacion_mesas_excel.dart';
import '../controladores/controlador_mesas_excel.dart';
import '../modelos/modelos_mesas_excel.dart';
import 'pantalla_detalle_examen_excel_atlassian.dart';

class PantallaExamenesExcelAtlassian extends StatefulWidget {
  const PantallaExamenesExcelAtlassian({super.key, required this.controller});

  final ControladorMesasExcel controller;

  @override
  State<PantallaExamenesExcelAtlassian> createState() =>
      _PantallaExamenesExcelAtlassianState();
}

class _PantallaExamenesExcelAtlassianState
    extends State<PantallaExamenesExcelAtlassian> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _careerId = 'historia';
  String _scope = 'todos';
  int? _year;
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PantallaExamenesExcelAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  List<EventoExamen> get _allEvents =>
      widget.controller.eventos
          .map((item) => item.evento)
          .where((event) => !event.legacy && event.visible)
          .toList(growable: false)
        ..sort((first, second) {
          final firstDate = first.fechaHora;
          final secondDate = second.fechaHora;
          if (firstDate == null && secondDate == null) {
            return first.materia.compareTo(second.materia);
          }
          if (firstDate == null) return 1;
          if (secondDate == null) return -1;
          return firstDate.compareTo(secondDate);
        });

  Future<void> _refresh() => widget.controller.actualizar(force: true);

  Future<void> _refreshConDialogo() => mostrarDialogoActualizacionMesasExcel(
    context: context,
    controller: widget.controller,
  );

  String _formatLastUpdate(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    if (sameDay) return 'hoy $hour:$minute';
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Widget _buildLastUpdateIndicator(BuildContext context) {
    final checking = widget.controller.estaComprobando;
    final validatedAt = widget.controller.metadatos?.validatedAt;
    if (!checking && validatedAt == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final text = checking
        ? 'Actualizando Excel...'
        : 'Actualizado ${_formatLastUpdate(validatedAt!)}';

    return Semantics(
      liveRegion: checking,
      label: text,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            checking ? Icons.sync_rounded : Icons.schedule_rounded,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  List<EventoExamen> _filter(List<EventoExamen> source) {
    final normalizedQuery = _normalize(_query);
    return source
        .where((event) {
          if (event.careerId != _careerId) return false;
          if (_year != null && event.anio != _year) return false;
          if (_scope == 'llamados' && event.instancia == 'coloquio')
            return false;
          if (_scope == 'coloquios' && event.instancia != 'coloquio')
            return false;
          if (normalizedQuery.isEmpty) return true;
          final content = _normalize(
            '${event.materia} ${event.docentes.join(' ')} ${event.division ?? ''}',
          );
          return content.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _chooseCareer() async {
    const careers = <(String, String)>[
      ('historia', 'Historia'),
      ('geografia', 'Geografía'),
      ('politica', 'Ciencia Política'),
      ('artes_visuales', 'Artes Visuales'),
      ('musica', 'Música'),
    ];
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
                'Seleccionar carrera',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final career in careers) ...[
                PanelAtlassian(
                  selected: _careerId == career.$1,
                  onTap: () => Navigator.of(sheetContext).pop(career.$1),
                  child: Row(
                    children: [
                      Icon(
                        _careerId == career.$1
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _careerId == career.$1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        career.$2,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _careerId = selected;
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
                style: Theme.of(context).textTheme.titleLarge,
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
                  child: Text('$year° año'),
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

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _scope = 'todos';
      _year = null;
      _query = '';
    });
  }

  void _openDetail(EventoExamen event) {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) => PantallaDetalleExamenExcelAtlassian(event: event),
      ),
    );
  }

  Map<String, List<EventoExamen>> _group(List<EventoExamen> events) {
    final groups = <String, List<EventoExamen>>{};
    for (final event in events) {
      final label = _instanceLabel(event.instancia);
      groups.putIfAbsent(label, () => <EventoExamen>[]).add(event);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.paddingOf(context).top + 72;
    final header = EncabezadoSeccionAtlassianColapsable(
      scrollController: _scrollController,
      title: 'Exámenes',
      subtitle: 'Mesas, llamados y coloquios',
      leading: BotonIconoAtlassian(
        icon: Icons.arrow_back_rounded,
        tooltip: 'Volver',
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        BotonIconoAtlassian(
          icon: Icons.refresh_rounded,
          tooltip: 'Actualizar Excel',
          onPressed: widget.controller.estaComprobando
              ? null
              : () => unawaited(_refreshConDialogo()),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Builder(
              builder: (context) {
                final all = _allEvents;
                if (widget.controller.estaComprobando) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        headerHeight + 16,
                        16,
                        140 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        _FiltrosExamenesAtlassian(
                          careerId: _careerId,
                          scope: _scope,
                          year: _year,
                          years: const [1, 2, 3, 4],
                          searchController: _searchController,
                          onChooseCareer: () {},
                          onChooseYear: () {},
                          onScopeChanged: (_) {},
                          onSearchChanged: (_) {},
                          onClearSearch: () {},
                          onResetFilters: () {},
                        ),
                        const SizedBox(height: 16),
                        const _EsqueletoExamenesAtlassian(),
                      ],
                    ),
                  );
                }

                if (!widget.controller.tieneDatos && all.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, headerHeight, 24, 24),
                      child: EstadoVacioAtlassian(
                        icon: Icons.event_busy_rounded,
                        title: 'Exámenes temporalmente no disponibles',
                        message:
                            widget.controller.mensajeError ??
                            'La fuente institucional no pudo validarse.',
                        action: BotonAtlassian(
                          label: 'Reintentar',
                          icon: Icons.refresh_rounded,
                          primary: true,
                          onPressed: () => unawaited(_refreshConDialogo()),
                        ),
                      ),
                    ),
                  );
                }

                final filtered = _filter(all);
                final years =
                    all
                        .where((event) => event.careerId == _careerId)
                        .map((event) => event.anio)
                        .whereType<int>()
                        .toSet()
                        .toList()
                      ..sort();
                final grouped = _group(filtered);

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      headerHeight + 16,
                      16,
                      140 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      _FiltrosExamenesAtlassian(
                        careerId: _careerId,
                        scope: _scope,
                        year: _year,
                        years: years,
                        searchController: _searchController,
                        onChooseCareer: _chooseCareer,
                        onChooseYear: () => _chooseYear(years),
                        onScopeChanged: (value) =>
                            setState(() => _scope = value),
                        onSearchChanged: (value) =>
                            setState(() => _query = value),
                        onClearSearch: _clearSearch,
                        onResetFilters: _resetFilters,
                      ),
                      const SizedBox(height: 16),
                      _ResumenExamenesAtlassian(events: filtered),
                      if (widget.controller.metadatos != null ||
                          widget.controller.estaComprobando) ...[
                        const SizedBox(height: 12),
                        _buildLastUpdateIndicator(context),
                      ],
                      const SizedBox(height: 20),
                      if (filtered.isEmpty)
                        const EstadoVacioAtlassian(
                          icon: Icons.event_busy_rounded,
                          title: 'Sin resultados',
                          message: 'Revisá la carrera, el año o los filtros.',
                        )
                      else
                        for (final entry in grouped.entries) ...[
                          SeparadorTituloAtlassian(
                            title: entry.key,
                            subtitle: '${entry.value.length} registros',
                          ),
                          const SizedBox(height: 8),
                          PanelAtlassian(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < entry.value.length;
                                  index++
                                ) ...[
                                  _FilaExamenAtlassian(
                                    event: entry.value[index],
                                    onTap: () =>
                                        _openDetail(entry.value[index]),
                                  ),
                                  if (index != entry.value.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      const SizedBox(height: 48),
                    ],
                  ),
                );
              },
            ),
          ),
          Align(alignment: Alignment.topCenter, child: header),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
            child: IgnorePointer(child: AccesoBusquedaAtlassian(onTap: () {})),
          ),
        ],
      ),
    );
  }
}

class _FiltrosExamenesAtlassian extends StatelessWidget {
  const _FiltrosExamenesAtlassian({
    required this.careerId,
    required this.scope,
    required this.year,
    required this.years,
    required this.searchController,
    required this.onChooseCareer,
    required this.onChooseYear,
    required this.onScopeChanged,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onResetFilters,
  });

  final String careerId;
  final String scope;
  final int? year;
  final List<int> years;
  final TextEditingController searchController;
  final VoidCallback onChooseCareer;
  final VoidCallback onChooseYear;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onResetFilters;

  String get _careerLabel => switch (careerId) {
    'geografia' => 'Geografía',
    'politica' => 'Ciencia Política',
    _ => 'Historia',
  };

  @override
  Widget build(BuildContext context) {
    final active =
        (year == null ? 0 : 1) +
        (scope == 'todos' ? 0 : 1) +
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
          LayoutBuilder(
            builder: (context, constraints) {
              final career = SelectorAtlassian(
                label: 'Carrera',
                value: _careerLabel,
                icon: Icons.school_outlined,
                onTap: onChooseCareer,
              );
              final yearField = SelectorAtlassian(
                label: 'Año',
                value: year == null ? 'Todos' : '$year° año',
                icon: Icons.calendar_view_month_outlined,
                onTap: years.isEmpty ? null : onChooseYear,
                enabled: years.isNotEmpty,
              );
              if (constraints.maxWidth >= 620) {
                return Row(
                  children: [
                    Expanded(child: career),
                    const SizedBox(width: 10),
                    SizedBox(width: 190, child: yearField),
                  ],
                );
              }
              return Column(
                children: [career, const SizedBox(height: 10), yearField],
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
        ],
      ),
    );
  }
}

class _ResumenExamenesAtlassian extends StatelessWidget {
  const _ResumenExamenesAtlassian({required this.events});

  final List<EventoExamen> events;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = events.where((event) {
      final date = event.fechaHora;
      return date != null && date.isAfter(now);
    }).length;
    final withActa = events.where((event) => event.puedeAbrirActa).length;
    final colloquiums = events
        .where((event) => event.instancia == 'coloquio')
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
            label: 'Próximos',
            value: '$upcoming',
            icon: Icons.upcoming_outlined,
            appearance: AparienciaLozengeAtlassian.success,
          ),
          MetricaAtlassian(
            label: 'Coloquios',
            value: '$colloquiums',
            icon: Icons.forum_outlined,
            appearance: AparienciaLozengeAtlassian.discovery,
          ),
          MetricaAtlassian(
            label: 'Con acta',
            value: '$withActa',
            icon: Icons.description_outlined,
            appearance: AparienciaLozengeAtlassian.neutral,
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

class _FilaExamenAtlassian extends StatelessWidget {
  const _FilaExamenAtlassian({
    required this.event,
    required this.onTap,
    this.onLongPress,
  });

  final EventoExamen event;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final future = event.fechaHora?.isAfter(DateTime.now()) ?? false;
    final hasStatus = event.mostrarAvisoEstado;
    final statusColor = _statusForeground(context, event.estado);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: hasStatus ? _statusBackground(context, event.estado) : null,
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
                    : (future
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
              ),
              child: Icon(
                hasStatus
                    ? _statusIcon(event.estado)
                    : (future
                          ? Icons.event_available_rounded
                          : Icons.event_note_rounded),
                color: hasStatus
                    ? statusColor
                    : (future
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary)
                          : Theme.of(context).colorScheme.onSurfaceVariant),
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
                    formatoFechaHoraAtlassian(
                      event.fechaVigente,
                      event.horaVigente,
                    ),
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
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasStatus)
                  LozengeAtlassian(
                    label: event.estado.etiqueta,
                    appearance: _statusAppearance(event.estado),
                  )
                else
                  LozengeAtlassian(
                    label: _shortInstanceLabel(event.instancia),
                    appearance: event.instancia == 'coloquio'
                        ? AparienciaLozengeAtlassian.discovery
                        : AparienciaLozengeAtlassian.brand,
                  ),
                const SizedBox(height: 6),
                if (event.puedeAbrirActa) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.description_rounded,
                        size: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Con acta',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else
                  const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(EstadoEventoExamen status) {
  return switch (status) {
    EstadoEventoExamen.activa => 'Activa',
    EstadoEventoExamen.suspendida => 'Suspendida',
    EstadoEventoExamen.cancelada => 'Cancelada',
    EstadoEventoExamen.reprogramada => 'Reprogramada',
  };
}

class _AvisoEstadoExamenAtlassian extends StatelessWidget {
  const _AvisoEstadoExamenAtlassian({required this.event});

  final EventoExamen event;

  @override
  Widget build(BuildContext context) {
    final foreground = _statusForeground(context, event.estado);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusBackground(context, event.estado),
        borderRadius: BorderRadius.circular(RadioAtlassian.medium),
        border: Border.all(
          color: foreground.withValues(alpha: 0.75),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusIconBackground(context, event.estado),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(event.estado), color: foreground, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.tituloEstadoEfectivo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  event.mensajeEstadoEfectivo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

Color _statusIconBackground(BuildContext context, EstadoEventoExamen status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa => Theme.of(context).colorScheme.primaryContainer,
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

class _DatoExamenAtlassian extends StatelessWidget {
  const _DatoExamenAtlassian({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 78,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

String _instanceLabel(String raw) {
  return switch (raw) {
    'llamado_1' => 'Primer llamado',
    'llamado_2' => 'Segundo llamado',
    'coloquio' => 'Coloquios',
    _ => 'Exámenes',
  };
}

String _shortInstanceLabel(String raw) {
  return switch (raw) {
    'llamado_1' => 'Llamado 1',
    'llamado_2' => 'Llamado 2',
    'coloquio' => 'Coloquio',
    _ => 'Examen',
  };
}

String _normalize(String value) {
  const replacements = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  var out = value.toLowerCase();
  replacements.forEach((key, replacement) {
    out = out.replaceAll(key, replacement);
  });
  return out.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class _EsqueletoExamenesAtlassian extends StatelessWidget {
  const _EsqueletoExamenesAtlassian();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeparadorTituloAtlassian(
          title: 'Primer llamado',
          subtitle: '4 registros',
        ),
        const SizedBox(height: 8),
        PanelAtlassian(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                _FilaExamenAtlassian(
                  event: EventoExamen(
                    careerId: 'historia',
                    anio: 1,
                    fecha: DateTime.now(),
                    hora: '19:00',
                    materia: i % 2 == 0
                        ? 'Problemática del Conocimiento Histórico'
                        : 'Didáctica General y Práctica Docente',
                    instancia: 'llamado_1',
                    docentes: const ['Docente Ficticio Uno', 'Docente Dos'],
                    actaUrl: null,
                  ),
                  onTap: () {},
                ),
                if (i != 3) const Divider(height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SeparadorTituloAtlassian(
          title: 'Segundo llamado',
          subtitle: '3 registros',
        ),
        const SizedBox(height: 8),
        PanelAtlassian(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                _FilaExamenAtlassian(
                  event: EventoExamen(
                    careerId: 'historia',
                    anio: 2,
                    fecha: DateTime.now(),
                    hora: '19:00',
                    materia: 'Historia de las Ideas Políticas y Sociales',
                    instancia: 'llamado_2',
                    docentes: const ['Docente Ficticio Tres'],
                    actaUrl: null,
                  ),
                  onTap: () {},
                ),
                if (i != 2) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
