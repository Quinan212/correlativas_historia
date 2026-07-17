import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import '../busqueda/modelos_busqueda_atlassian.dart';
import '../componentes/componentes_atlassian.dart';
import '../tema/tema_atlassian.dart';
import 'utilidades_atlassian.dart';

class PantallaMateriasAtlassian extends StatefulWidget {
  const PantallaMateriasAtlassian({
    super.key,
    required this.trajectoryListenable,
    required this.localLoadedListenable,
    required this.selectedCareerListenable,
    required this.requestListenable,
    this.initialSearchFocus = false,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final ValueNotifier<bool> localLoadedListenable;
  final ValueNotifier<int> selectedCareerListenable;
  final ValueListenable<SolicitudMateriasAtlassian?> requestListenable;
  final bool initialSearchFocus;

  @override
  State<PantallaMateriasAtlassian> createState() =>
      _PantallaMateriasAtlassianState();
}

class _PantallaMateriasAtlassianState extends State<PantallaMateriasAtlassian> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  EstadoMateriaSageLaboratorio? _status;
  int? _year;
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.requestListenable.addListener(_applyExternalRequest);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _applyExternalRequest(),
    );
    if (widget.initialSearchFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusSearch());
    }
  }

  @override
  void didUpdateWidget(covariant PantallaMateriasAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestListenable == widget.requestListenable) return;
    oldWidget.requestListenable.removeListener(_applyExternalRequest);
    widget.requestListenable.addListener(_applyExternalRequest);
  }

  void _applyExternalRequest() {
    final request = widget.requestListenable.value;
    if (request == null || !mounted) return;
    if (request.careerIndex != null) {
      widget.selectedCareerListenable.value = request.careerIndex!;
    }
    setState(() {
      _status = request.status;
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
    if (request.focusSearch) _focusSearch();
  }

  void _focusSearch() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.requestListenable.removeListener(_applyExternalRequest);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  CarreraTrayectoriaSageLaboratorio? _currentCareer(
    TrayectoriaSageLaboratorio? trajectory,
    int selectedIndex,
  ) {
    if (trajectory == null || trajectory.carreras.isEmpty) return null;
    return trajectory.carreras[selectedIndex
        .clamp(0, trajectory.carreras.length - 1)
        .toInt()];
  }

  List<MateriaTrayectoriaSageLaboratorio> _filter(
    CarreraTrayectoriaSageLaboratorio career,
  ) {
    final query = _normalize(_query);
    final output = career.materias.where((subject) {
      if (_status != null && subject.estado != _status) return false;
      if (_year != null && subject.anio != _year) return false;
      if (query.isEmpty) return true;
      return _normalize(
        '${subject.nombre} ${subject.idSage} ${subject.estadoOriginal}',
      ).contains(query);
    }).toList();
    output.sort((first, second) {
      final firstYear = first.anio ?? 99;
      final secondYear = second.anio ?? 99;
      final byYear = firstYear.compareTo(secondYear);
      if (byYear != 0) return byYear;
      return first.nombre.compareTo(second.nombre);
    });
    return output;
  }

  Future<void> _chooseCareer(TrayectoriaSageLaboratorio trajectory) async {
    if (trajectory.carreras.length < 2) return;
    final selected = await mostrarHojaAtlassian<int>(
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
              for (var index = 0; index < trajectory.carreras.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PanelAtlassian(
                    selected: index == widget.selectedCareerListenable.value,
                    onTap: () => Navigator.of(sheetContext).pop(index),
                    child: Row(
                      children: [
                        Icon(
                          index == widget.selectedCareerListenable.value
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: index == widget.selectedCareerListenable.value
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            nombreCarreraAtlassian(
                              trajectory.carreras[index].nombre,
                            ),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    widget.selectedCareerListenable.value = selected;
    setState(() {
      _status = null;
      _year = null;
      _query = '';
      _searchController.clear();
    });
  }

  Future<void> _chooseStatus() async {
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
                'Filtrar por estado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              PanelAtlassian(
                selected: _status == null,
                onTap: () => Navigator.of(sheetContext).pop('todos'),
                child: const Text('Todos los estados'),
              ),
              const SizedBox(height: 8),
              for (final status in EstadoMateriaSageLaboratorio.values) ...[
                PanelAtlassian(
                  selected: _status == status,
                  onTap: () => Navigator.of(sheetContext).pop(status.clave),
                  child: Row(
                    children: [
                      LozengeAtlassian(
                        label: status.etiqueta,
                        appearance: aparienciaEstadoAtlassian(status),
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
      _status = selected == 'todos'
          ? null
          : EstadoMateriaSageLaboratorioX.desdeClave(selected);
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
      _status = null;
      _year = null;
      _query = '';
    });
  }

  void _openDetail(
    MateriaTrayectoriaSageLaboratorio subject,
    CarreraTrayectoriaSageLaboratorio career,
  ) {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) =>
            PantallaDetalleMateriaAtlassian(subject: subject, career: career),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.localLoadedListenable,
      builder: (context, loaded, _) {
        return ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
          valueListenable: widget.trajectoryListenable,
          builder: (context, trajectory, _) {
            return ValueListenableBuilder<int>(
              valueListenable: widget.selectedCareerListenable,
              builder: (context, selectedIndex, _) {
                final career = _currentCareer(trajectory, selectedIndex);
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Column(
                    children: [
                      EncabezadoSeccionAtlassianColapsable(
                        scrollController: _scrollController,
                        title: 'Materias',
                        subtitle: career == null
                            ? 'Trayectoria académica'
                            : nombreCarreraAtlassian(career.nombre),
                        onSearch: _focusSearch,
                        actions: [
                          if ((trajectory?.carreras.length ?? 0) > 1)
                            BotonIconoAtlassian(
                              icon: Icons.swap_horiz_rounded,
                              tooltip: 'Cambiar carrera',
                              onPressed: () => _chooseCareer(trajectory!),
                            ),
                        ],
                      ),
                      Expanded(
                        child: !loaded
                            ? const Center(child: CircularProgressIndicator())
                            : career == null
                            ? const EstadoVacioAtlassian(
                                icon: Icons.menu_book_outlined,
                                title: 'Sin trayectoria',
                                message:
                                    'Sincronizá SAGE desde la pantalla Inicio.',
                              )
                            : _buildContent(context, career),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    CarreraTrayectoriaSageLaboratorio career,
  ) {
    final filtered = _filter(career);
    final years =
        career.materias
            .map((subject) => subject.anio)
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();
    final groups = <int?, List<MateriaTrayectoriaSageLaboratorio>>{};
    for (final subject in filtered) {
      groups.putIfAbsent(subject.anio, () => []).add(subject);
    }
    final keys = groups.keys.toList()
      ..sort((first, second) => (first ?? 99).compareTo(second ?? 99));

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _FiltrosMateriasAtlassian(
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          status: _status,
          year: _year,
          years: years,
          onSearchChanged: (value) => setState(() => _query = value),
          onClearSearch: () {
            _searchController.clear();
            setState(() => _query = '');
          },
          onChooseStatus: _chooseStatus,
          onChooseYear: () => _chooseYear(years),
          onResetFilters: _resetFilters,
        ),
        const SizedBox(height: 16),
        _ResumenMateriasAtlassian(career: career, visible: filtered.length),
        const SizedBox(height: 20),
        if (filtered.isEmpty)
          const EstadoVacioAtlassian(
            icon: Icons.search_off_rounded,
            title: 'Sin resultados',
            message: 'Revisá la búsqueda y los filtros.',
          )
        else
          for (final yearKey in keys) ...[
            SeparadorTituloAtlassian(
              title: yearKey == null ? 'Sin año' : '$yearKey° año',
              subtitle: '${groups[yearKey]!.length} materias',
            ),
            const SizedBox(height: 8),
            PanelAtlassian(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < groups[yearKey]!.length;
                    index++
                  ) ...[
                    _FilaMateriaTrayectoriaAtlassian(
                      subject: groups[yearKey]![index],
                      onTap: () => _openDetail(groups[yearKey]![index], career),
                    ),
                    if (index != groups[yearKey]!.length - 1)
                      const Divider(height: 1),
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

class _FiltrosMateriasAtlassian extends StatelessWidget {
  const _FiltrosMateriasAtlassian({
    required this.searchController,
    required this.searchFocusNode,
    required this.status,
    required this.year,
    required this.years,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onChooseStatus,
    required this.onChooseYear,
    required this.onResetFilters,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final EstadoMateriaSageLaboratorio? status;
  final int? year;
  final List<int> years;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onChooseStatus;
  final VoidCallback onChooseYear;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final active =
        (status == null ? 0 : 1) +
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
            focusNode: searchFocusNode,
            hintText: 'Buscar materia',
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final statusField = SelectorAtlassian(
                label: 'Estado',
                value: status?.etiqueta ?? 'Todos',
                icon: Icons.filter_alt_outlined,
                onTap: onChooseStatus,
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
                    Expanded(child: statusField),
                    const SizedBox(width: 10),
                    Expanded(child: yearField),
                  ],
                );
              }
              return Column(
                children: [statusField, const SizedBox(height: 10), yearField],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResumenMateriasAtlassian extends StatelessWidget {
  const _ResumenMateriasAtlassian({
    required this.career,
    required this.visible,
  });

  final CarreraTrayectoriaSageLaboratorio career;
  final int visible;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        final metrics = [
          MetricaAtlassian(
            label: 'Visibles',
            value: '$visible',
            icon: Icons.visibility_outlined,
            appearance: AparienciaLozengeAtlassian.neutral,
          ),
          MetricaAtlassian(
            label: 'Aprobadas',
            value: '${career.aprobadas}',
            icon: Icons.check_circle_outline_rounded,
            appearance: AparienciaLozengeAtlassian.success,
          ),
          MetricaAtlassian(
            label: 'Regulares',
            value: '${career.regulares}',
            icon: Icons.verified_outlined,
            appearance: AparienciaLozengeAtlassian.brand,
          ),
          MetricaAtlassian(
            label: 'Cursando',
            value: '${career.cursando}',
            icon: Icons.pending_actions_rounded,
            appearance: AparienciaLozengeAtlassian.discovery,
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

class _FilaMateriaTrayectoriaAtlassian extends StatelessWidget {
  const _FilaMateriaTrayectoriaAtlassian({
    required this.subject,
    required this.onTap,
  });

  final MateriaTrayectoriaSageLaboratorio subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
              ),
              child: Text(
                subject.anio == null ? '—' : '${subject.anio}°',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 5),
                  LozengeAtlassian(
                    label: subject.estado.etiqueta,
                    appearance: aparienciaEstadoAtlassian(subject.estado),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class PantallaDetalleMateriaAtlassian extends StatelessWidget {
  const PantallaDetalleMateriaAtlassian({
    super.key,
    required this.subject,
    required this.career,
  });

  final MateriaTrayectoriaSageLaboratorio subject;
  final CarreraTrayectoriaSageLaboratorio career;

  @override
  Widget build(BuildContext context) {
    final sameYear = career.materias
        .where(
          (item) => item.anio == subject.anio && item.idSage != subject.idSage,
        )
        .take(5)
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          EncabezadoPaginaAtlassian(
            title: 'Detalle de materia',
            subtitle: nombreCarreraAtlassian(career.nombre),
            leading: BotonIconoAtlassian(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PanelAtlassian(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LozengeAtlassian(
                        label: subject.estado.etiqueta,
                        appearance: aparienciaEstadoAtlassian(subject.estado),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subject.nombre,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PanelAtlassian(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _DatoMateriaAtlassian(
                        label: 'Año',
                        value: subject.anio == null
                            ? 'Sin año'
                            : '${subject.anio}°',
                      ),
                      const Divider(height: 1),
                      _DatoMateriaAtlassian(
                        label: 'Estado',
                        value: subject.estado.etiqueta,
                      ),
                      const Divider(height: 1),
                      _DatoMateriaAtlassian(
                        label: 'Estado SAGE',
                        value: subject.estadoOriginal.trim().isEmpty
                            ? 'Sin dato'
                            : subject.estadoOriginal,
                      ),
                      const Divider(height: 1),
                      _DatoMateriaAtlassian(
                        label: 'ID SAGE',
                        value: subject.idSage.trim().isEmpty
                            ? 'Sin ID'
                            : subject.idSage,
                      ),
                    ],
                  ),
                ),
                if (sameYear.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  SeparadorTituloAtlassian(
                    title: 'Mismo año',
                    subtitle: '${sameYear.length} materias',
                  ),
                  const SizedBox(height: 8),
                  PanelAtlassian(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < sameYear.length;
                          index++
                        ) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sameYear[index].nombre,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                LozengeAtlassian(
                                  label: sameYear[index].estado.etiqueta,
                                  appearance: aparienciaEstadoAtlassian(
                                    sameYear[index].estado,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index != sameYear.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoMateriaAtlassian extends StatelessWidget {
  const _DatoMateriaAtlassian({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
