import 'package:flutter/material.dart';

import 'modelos_historial_sage.dart';

class PantallaHistorialSage extends StatefulWidget {
  const PantallaHistorialSage({
    required this.historial,
    required this.estado,
    required this.onExpandCareer,
    required this.onReport,
    required this.onRefresh,
    required this.onShowOriginal,
    required this.onBack,
    this.reportsEnabled = true,
    super.key,
  });

  final HistorialNivelSuperiorSage? historial;
  final EstadoHistorialSage estado;
  final Future<ResultadoMateriasSage> Function(CarreraHistorialSage career)
  onExpandCareer;
  final Future<void> Function(CarreraHistorialSage career, String title)
  onReport;
  final Future<void> Function() onRefresh;
  final VoidCallback onShowOriginal;
  final VoidCallback onBack;
  final bool reportsEnabled;

  @override
  State<PantallaHistorialSage> createState() => _PantallaHistorialSageState();
}

class _PantallaHistorialSageState extends State<PantallaHistorialSage> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'Todas';
  String? _selectedId;
  final Set<String> _loading = <String>{};
  final Map<String, EstadoCargaMateriasSage> _materiaStates =
      <String, EstadoCargaMateriasSage>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final career = _selectedCareer;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Historial académico'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Ver página original',
            onPressed: widget.onShowOriginal,
            icon: const Icon(Icons.language_rounded),
          ),
        ],
      ),
      body: _body(context, career),
    );
  }

  Widget _body(BuildContext context, CarreraHistorialSage? selected) {
    final historial = widget.historial;
    final canKeepShowingData =
        widget.estado == EstadoHistorialSage.disponible ||
        widget.estado == EstadoHistorialSage.cargandoCarreras ||
        widget.estado == EstadoHistorialSage.cargandoMaterias;
    if (!canKeepShowingData || historial == null || selected == null) {
      return _stateBody(context);
    }
    final filteredSubjects = _filteredSubjects(selected.materias);
    final loadState = _materiaStates[selected.gridRowId];
    final isLoading = _loading.contains(selected.gridRowId);
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (widget.estado == EstadoHistorialSage.cargandoCarreras ||
              widget.estado == EstadoHistorialSage.cargandoMaterias)
            _LoadingBanner(
              text: widget.estado == EstadoHistorialSage.cargandoMaterias
                  ? 'Cargando materias…'
                  : 'Cargando historial…',
            ),
          _CareerPicker(
            careers: historial.carreras,
            selectedId: selected.gridRowId,
            onChanged: (id) => setState(() => _selectedId = id),
          ),
          const SizedBox(height: 16),
          _CareerHeader(career: selected),
          const SizedBox(height: 14),
          _Summary(career: selected),
          const SizedBox(height: 18),
          _ReportActions(
            enabled: widget.reportsEnabled,
            onReport: (title) => widget.onReport(selected, title),
          ),
          const SizedBox(height: 18),
          _Filters(
            controller: _searchController,
            filter: _filter,
            onFilter: (value) => setState(() => _filter = value),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (!selected.materiasCargadas)
            FilledButton.icon(
              onPressed: isLoading ? null : () => _expand(selected),
              icon: const Icon(Icons.table_rows_rounded),
              label: Text(
                isLoading
                    ? 'Cargando materias…'
                    : loadState == null ||
                          loadState == EstadoCargaMateriasSage.cargando
                    ? 'Cargar materias'
                    : 'Reintentar',
              ),
            ),
          if (!selected.materiasCargadas &&
              loadState != null &&
              loadState != EstadoCargaMateriasSage.cargando)
            _InfoCard(text: _materiasStateMessage(loadState)),
          if (selected.materiasCargadas && selected.materias.isEmpty)
            const _InfoCard(text: 'No hay materias registradas.'),
          if (selected.materiasCargadas &&
              selected.materias.isNotEmpty &&
              filteredSubjects.isEmpty)
            const _InfoCard(
              text: 'No hay materias que coincidan con el filtro seleccionado.',
            ),
          if (selected.materiasCargadas && filteredSubjects.isNotEmpty)
            _SubjectsList(materias: filteredSubjects),
        ],
      ),
    );
  }

  Widget _stateBody(BuildContext context) {
    final text = switch (widget.estado) {
      EstadoHistorialSage.esperandoPagina => 'Esperando la página de SAGE…',
      EstadoHistorialSage.cargandoCarreras => 'Cargando historial…',
      EstadoHistorialSage.cargandoMaterias => 'Cargando materias…',
      EstadoHistorialSage.vacio => 'No hay carreras disponibles',
      EstadoHistorialSage.sesionVencida => 'La sesión de SAGE venció',
      EstadoHistorialSage.incompatible => 'SAGE cambió su estructura',
      _ => 'No se pudo obtener el historial',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
            TextButton(
              onPressed: widget.onShowOriginal,
              child: const Text('Ver página original'),
            ),
          ],
        ),
      ),
    );
  }

  CarreraHistorialSage? get _selectedCareer {
    final historial = widget.historial;
    if (historial == null || historial.carreras.isEmpty) return null;
    final id = _selectedId;
    return historial.carreras.firstWhere(
      (career) => career.gridRowId == id,
      orElse: () => historial.carreras.first,
    );
  }

  List<MateriaHistorialSage> _filteredSubjects(
    List<MateriaHistorialSage> subjects,
  ) => filtrarMateriasSage(
    subjects,
    query: _searchController.text,
    filtro: _filter,
  );

  Future<void> _expand(CarreraHistorialSage career) async {
    setState(() {
      _loading.add(career.gridRowId);
      _materiaStates[career.gridRowId] = EstadoCargaMateriasSage.cargando;
    });
    try {
      final result = await widget.onExpandCareer(career);
      if (mounted) {
        setState(() => _materiaStates[career.gridRowId] = result.estado);
      }
    } finally {
      if (mounted) setState(() => _loading.remove(career.gridRowId));
    }
  }

  String _materiasStateMessage(EstadoCargaMateriasSage state) =>
      switch (state) {
        EstadoCargaMateriasSage.vacio => 'No hay materias registradas.',
        EstadoCargaMateriasSage.filaNoEncontrada =>
          'No se encontró la fila de la carrera en SAGE.',
        EstadoCargaMateriasSage.tablaNoEncontrada =>
          'La tabla de materias no está disponible todavía.',
        EstadoCargaMateriasSage.timeout =>
          'SAGE no terminó de cargar las materias. Reintentá.',
        _ => 'No se pudieron cargar las materias. Reintentá.',
      };
}

class _CareerPicker extends StatelessWidget {
  const _CareerPicker({
    required this.careers,
    required this.selectedId,
    required this.onChanged,
  });

  final List<CarreraHistorialSage> careers;
  final String selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    isExpanded: true,
    initialValue: selectedId,
    decoration: const InputDecoration(
      labelText: 'Carrera',
      border: OutlineInputBorder(),
    ),
    items: careers
        .map(
          (career) => DropdownMenuItem(
            value: career.gridRowId,
            child: Text(
              career.nombre.isEmpty ? 'Carrera' : career.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(growable: false),
    onChanged: onChanged,
  );
}

class _CareerHeader extends StatelessWidget {
  const _CareerHeader({required this.career});

  final CarreraHistorialSage career;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nivel Superior', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(career.nombre, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(career.institucion),
          const SizedBox(height: 6),
          Text(
            'Inicio: ${career.anioInicio ?? 'Sin informar'} · ${career.estado ?? 'Estado no informado'}',
          ),
        ],
      ),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.career});

  final CarreraHistorialSage career;

  @override
  Widget build(BuildContext context) {
    final local = _localCounts(career.materias);
    final differs =
        career.materiasCargadas &&
        (local.approved != career.aprobadas ||
            local.regular != career.regulares ||
            local.inProgress != career.cursando);
    return Column(
      children: [
        Row(
          children: [
            _Metric(label: 'Aprobadas', value: career.aprobadas),
            _Metric(label: 'Regulares', value: career.regulares),
            _Metric(label: 'Cursando', value: career.cursando),
          ],
        ),
        if (differs)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Los contadores de SAGE difieren del detalle cargado; se conservan ambos.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  _LocalCounts _localCounts(List<MateriaHistorialSage> subjects) {
    var approved = 0;
    var regular = 0;
    var inProgress = 0;
    for (final subject in subjects) {
      final status = subject.estado.toLowerCase();
      if (status.contains('aprob')) {
        approved++;
      } else if (status.contains('regular')) {
        regular++;
      } else if (status.contains('curs')) {
        inProgress++;
      }
    }
    return _LocalCounts(approved, regular, inProgress);
  }
}

class _LocalCounts {
  const _LocalCounts(this.approved, this.regular, this.inProgress);
  final int approved;
  final int regular;
  final int inProgress;
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          children: [
            Text('$value', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.onReport, required this.enabled});
  final Future<void> Function(String title) onReport;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _ReportButton(
        label: 'Situación académica',
        title: 'Imprimir la Situación Académica del alumno en la carrera',
        onReport: onReport,
        enabled: enabled,
      ),
      _ReportButton(
        label: 'Analítico',
        title: 'Imprimir listado de materias aprobadas',
        onReport: onReport,
        enabled: enabled,
      ),
      _ReportButton(
        label: 'Libreta',
        title: 'Imprimir libreta de calificaciones',
        onReport: onReport,
        enabled: enabled,
      ),
    ],
  );
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({
    required this.label,
    required this.title,
    required this.onReport,
    required this.enabled,
  });
  final String label;
  final String title;
  final Future<void> Function(String title) onReport;
  final bool enabled;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: enabled ? () => onReport(title) : null,
    icon: const Icon(Icons.picture_as_pdf_outlined),
    label: Text(label),
  );
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.controller,
    required this.filter,
    required this.onFilter,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String filter;
  final ValueChanged<String> onFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Buscar materia',
          prefixIcon: Icon(Icons.search_rounded),
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Todas', 'Aprobadas', 'Regulares', 'Cursando']
              .map(
                (value) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(value),
                    selected: filter == value,
                    onSelected: (_) => onFilter(value),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    ],
  );
}

class _SubjectsList extends StatelessWidget {
  const _SubjectsList({required this.materias});
  final List<MateriaHistorialSage> materias;

  @override
  Widget build(BuildContext context) {
    final groups = agruparMateriasPorAnioSage(materias);
    final keys = groups.keys.toList()
      ..sort((a, b) => (a ?? 999).compareTo(b ?? 999));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final year in keys) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              year == null ? 'Sin año informado' : '$year.º año',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...groups[year]!.map(
            (subject) => Card(
              child: ListTile(
                title: Text(
                  subject.nombre.isEmpty ? 'Materia' : subject.nombre,
                ),
                subtitle: Text(
                  subject.estado.isEmpty
                      ? 'Estado no informado'
                      : subject.estado,
                ),
                trailing: Text(subject.anio?.toString() ?? '—'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Text(text)),
  );
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: ListTile(
        leading: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(text),
        subtitle: const Text('La sesión original de SAGE sigue activa.'),
      ),
    ),
  );
}
