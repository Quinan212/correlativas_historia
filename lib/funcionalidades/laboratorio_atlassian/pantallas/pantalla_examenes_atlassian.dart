import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../examenes/datos/repositorio_examenes.dart';
import '../../examenes/modelos/evento_examen.dart';
import '../busqueda/modelos_busqueda_atlassian.dart';
import '../componentes/componentes_atlassian.dart';
import '../tema/tema_atlassian.dart';
import 'utilidades_atlassian.dart';

class PantallaExamenesAtlassian extends StatefulWidget {
  const PantallaExamenesAtlassian({
    super.key,
    required this.onSearch,
    required this.requestListenable,
  });

  final VoidCallback onSearch;
  final ValueListenable<SolicitudExamenesAtlassian?> requestListenable;

  @override
  State<PantallaExamenesAtlassian> createState() =>
      _PantallaExamenesAtlassianState();
}

class _PantallaExamenesAtlassianState extends State<PantallaExamenesAtlassian> {
  static const _repository = RepositorioExamenes();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<List<EventoExamen>> _future;
  String _careerId = 'historia';
  String _scope = 'todos';
  int? _year;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
    widget.requestListenable.addListener(_applyExternalRequest);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _applyExternalRequest(),
    );
  }

  @override
  void didUpdateWidget(covariant PantallaExamenesAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestListenable == widget.requestListenable) return;
    oldWidget.requestListenable.removeListener(_applyExternalRequest);
    widget.requestListenable.addListener(_applyExternalRequest);
  }

  void _applyExternalRequest() {
    final request = widget.requestListenable.value;
    if (request == null || !mounted) return;
    setState(() {
      if ((request.careerId ?? '').trim().isNotEmpty) {
        _careerId = request.careerId!;
      }
      if ((request.scope ?? '').trim().isNotEmpty) {
        _scope = request.scope!;
      }
      _year = request.year;
      if (request.query != null) {
        _query = request.query!.trim();
        _searchController.text = _query;
        _searchController.selection = TextSelection.collapsed(
          offset: _searchController.text.length,
        );
      }
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    widget.requestListenable.removeListener(_applyExternalRequest);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<EventoExamen>> _load() async {
    final results = await Future.wait<List<EventoExamen>>([
      _repository.loadJulioLlamado1(),
      _repository.loadJulioLlamado2(),
      _repository.loadJulioColoquios(),
      _repository.loadLlamado1(),
      _repository.loadLlamado2(),
      _repository.loadColoquios(),
    ]);
    final all = <EventoExamen>[
      ...results[0],
      ...results[1],
      ...results[2],
      ...results[3],
      ...results[4],
      ...results[5],
    ];
    all.removeWhere((e) => e.legacy);
    all.sort((first, second) {
      final firstDate = first.fechaHora;
      final secondDate = second.fechaHora;
      if (firstDate == null && secondDate == null) {
        return first.materia.compareTo(second.materia);
      }
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;
      return firstDate.compareTo(secondDate);
    });
    return List<EventoExamen>.unmodifiable(all);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _future = next;
    });
    await next;
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
        builder: (_) => PantallaDetalleExamenAtlassian(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.paddingOf(context).top + 72;
    final header = EncabezadoSeccionAtlassianColapsable(
      scrollController: _scrollController,
      title: 'Exámenes',
      subtitle: 'Mesas, llamados y coloquios',
      actions: [
        BotonIconoAtlassian(
          icon: Icons.refresh_rounded,
          tooltip: 'Actualizar',
          onPressed: () => unawaited(_refresh()),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<List<EventoExamen>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
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
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: headerHeight),
                      child: EstadoVacioAtlassian(
                        icon: Icons.error_outline_rounded,
                        title: 'No se pudieron cargar los exámenes',
                        message: snapshot.error.toString(),
                        action: BotonAtlassian(
                          label: 'Reintentar',
                          icon: Icons.refresh_rounded,
                          primary: true,
                          onPressed: () => unawaited(_refresh()),
                        ),
                      ),
                    ),
                  );
                }

                final all = snapshot.data ?? const <EventoExamen>[];
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
                        onScopeChanged: (value) {
                          setState(() => _scope = value);
                        },
                        onSearchChanged: (value) {
                          setState(() => _query = value);
                        },
                        onClearSearch: _clearSearch,
                        onResetFilters: _resetFilters,
                      ),
                      const SizedBox(height: 16),
                      _ResumenExamenesAtlassian(events: filtered),
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
          Align(
            alignment: Alignment.topCenter,
            child: header,
          ),
        ],
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
    final withActa = events.where((event) => event.actaUrl != null).length;
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
  const _FilaExamenAtlassian({required this.event, required this.onTap});

  final EventoExamen event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final future = event.fechaHora?.isAfter(DateTime.now()) ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSuspended = event.suspendido;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSuspended
            ? (isDark ? const Color(0xFF262112) : const Color(0xFFFFFBE6))
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSuspended
                    ? (isDark ? const Color(0xFF4A3B00) : const Color(0xFFFFF3CD))
                    : (future
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
              ),
              child: Icon(
                isSuspended
                    ? Icons.warning_amber_rounded
                    : (future
                        ? Icons.event_available_rounded
                        : Icons.event_note_rounded),
                color: isSuspended
                    ? (isDark ? const Color(0xFFFFD54F) : const Color(0xFFB78103))
                    : (future
                        ? (isDark
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
                  if (isSuspended) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFB78103),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Pendiente de reprogramación',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFB78103),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    formatoFechaHoraAtlassian(event.fecha, event.hora),
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
                if (isSuspended)
                  const LozengeAtlassian(
                    label: 'SUSPENDIDA',
                    appearance: AparienciaLozengeAtlassian.warning,
                  )
                else
                  LozengeAtlassian(
                    label: _shortInstanceLabel(event.instancia),
                    appearance: event.instancia == 'coloquio'
                        ? AparienciaLozengeAtlassian.discovery
                        : AparienciaLozengeAtlassian.brand,
                  ),
                const SizedBox(height: 6),
                if ((event.actaUrl ?? '').trim().isNotEmpty) ...[
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

class PantallaDetalleExamenAtlassian extends StatelessWidget {
  const PantallaDetalleExamenAtlassian({super.key, required this.event});

  final EventoExamen event;

  Future<void> _openAct(BuildContext context) async {
    final raw = event.actaUrl?.trim() ?? '';
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el acta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          EncabezadoPaginaAtlassian(
            title: 'Detalle del examen',
            subtitle: _instanceLabel(event.instancia),
            centerTitle: true,
            leading: BotonIconoAtlassian(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                120 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                PanelAtlassian(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (event.suspendido)
                            const LozengeAtlassian(
                              label: 'SUSPENDIDA',
                              appearance: AparienciaLozengeAtlassian.warning,
                            ),
                          LozengeAtlassian(
                            label: _shortInstanceLabel(event.instancia),
                            appearance: event.instancia == 'coloquio'
                                ? AparienciaLozengeAtlassian.discovery
                                : AparienciaLozengeAtlassian.brand,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          event.materia,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (event.suspendido) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF382C00) : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                          border: Border.all(
                            color: isDark ? const Color(0xFFFFB300) : const Color(0xFFFFC107),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFFB300),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MESA SUSPENDIDA',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFB78103),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Pendiente de reprogramación por la institución.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? const Color(0xFFFFECB3) : const Color(0xFF5D4037),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                PanelAtlassian(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _DatoExamenAtlassian(
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha',
                        value: formatoFechaAtlassian(event.fecha),
                      ),
                      const Divider(height: 1),
                      _DatoExamenAtlassian(
                        icon: Icons.schedule_rounded,
                        label: 'Hora',
                        value: event.hora ?? 'Sin horario',
                      ),
                      const Divider(height: 1),
                      _DatoExamenAtlassian(
                        icon: Icons.school_outlined,
                        label: 'Año',
                        value: event.anio == null
                            ? 'Sin año'
                            : '${event.anio}°',
                      ),
                      const Divider(height: 1),
                      _DatoExamenAtlassian(
                        icon: Icons.groups_outlined,
                        label: 'Docentes',
                        value: event.docentes.isEmpty
                            ? 'Sin docentes informados'
                            : event.docentes.join(', '),
                      ),
                      if ((event.division ?? '').trim().isNotEmpty) ...[
                        const Divider(height: 1),
                        _DatoExamenAtlassian(
                          icon: Icons.badge_outlined,
                          label: 'División',
                          value: event.division!,
                        ),
                      ],
                    ],
                  ),
                ),
                if ((event.actaUrl ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  BotonAtlassian(
                    label: 'Abrir acta',
                    icon: Icons.open_in_new_rounded,
                    primary: true,
                    expanded: true,
                    onPressed: () => unawaited(_openAct(context)),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
