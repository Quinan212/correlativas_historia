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
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
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
          const SizedBox(height: 14),
          _CareerHeader(career: selected),
          const SizedBox(height: 10),
          _CareerDetail(career: selected),
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
              label:                 Text(
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
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedId,
      decoration: InputDecoration(
        labelText: 'Carrera',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      items: careers
          .map(
            (career) => DropdownMenuItem(
              value: career.gridRowId,
              child: Text(
                career.nombre.isEmpty ? 'Carrera' : _titulo(career.nombre),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _CareerHeader extends StatelessWidget {
  const _CareerHeader({required this.career});

  final CarreraHistorialSage career;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E5E86), Color(0xFF0A3D5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolución',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _titulo(career.nombre),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

class _CareerDetail extends StatelessWidget {
  const _CareerDetail({required this.career});

  final CarreraHistorialSage career;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _titulo(career.institucion),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Inicio: ${career.anioInicio ?? 'Sin informar'} · ${career.estado != null ? _titulo(career.estado!) : 'Estado no informado'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Nivel superior',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
            _Metric(
              label: 'Aprobadas',
              value: career.aprobadas,
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _Metric(
              label: 'Regulares',
              value: career.regulares,
              color: const Color(0xFFE65100),
            ),
            const SizedBox(width: 8),
            _Metric(
              label: 'Cursando',
              value: career.cursando,
              color: const Color(0xFF1565C0),
            ),
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
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              '$value',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.onReport, required this.enabled});
  final Future<void> Function(String title) onReport;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PdfChip(
            label: 'Situación académica',
            title: 'Imprimir la Situación Académica del alumno en la carrera',
            onReport: onReport,
            enabled: enabled,
          ),
          const SizedBox(width: 8),
          _PdfChip(
            label: 'Analítico',
            title: 'Imprimir listado de materias aprobadas',
            onReport: onReport,
            enabled: enabled,
          ),
          const SizedBox(width: 8),
          _PdfChip(
            label: 'Libreta',
            title: 'Imprimir libreta de calificaciones',
            onReport: onReport,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}

class _PdfChip extends StatelessWidget {
  const _PdfChip({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onReport(title) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled
                  ? theme.colorScheme.outlineVariant
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 16,
                color: enabled ? const Color(0xFFE53935) : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Todas', 'Aprobadas', 'Regulares', 'Cursando']
              .map(
                (value) {
                  final active = filter == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onFilter(value),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF0E5E86).withValues(alpha: 0.08)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFF0E5E86).withValues(alpha: 0.3)
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (active) ...[
                                Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: const Color(0xFF0E5E86),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                value,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? const Color(0xFF0E5E86)
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
    final theme = Theme.of(context);
    final groups = agruparMateriasPorAnioSage(materias);
    final keys = groups.keys.toList()
      ..sort((a, b) => (a ?? 999).compareTo(b ?? 999));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final year in keys) ...[
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              year == null ? 'Sin año informado' : '$year.º año',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...groups[year]!.map(
            (subject) {
              final statusLower = subject.estado.toLowerCase();
              final statusColor = statusLower.contains('aprob')
                  ? const Color(0xFF2E7D32)
                  : statusLower.contains('curs')
                      ? const Color(0xFF1565C0)
                      : statusLower.contains('regular')
                          ? const Color(0xFFE65100)
                          : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.nombre.isEmpty
                                  ? 'Materia'
                                  : _titulo(subject.nombre),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subject.estado.isEmpty
                                  ? 'Estado no informado'
                                  : _titulo(subject.estado),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: statusColor ??
                                    theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        subject.anio?.toString() ?? '—',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Text(text),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'La sesión original de SAGE sigue activa.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _titulo(String texto) {
  if (texto.isEmpty) return texto;
  const conectores = {'de', 'en', 'y', 'e', 'o', 'u', 'a', 'el', 'la', 'los',
      'las', 'del', 'al', 'por', 'para', 'con', 'sin', 'su', 'sus', 'un', 'una',
      'unos', 'unas', 'lo'};
  return _normalizarTexto(texto)
      .split(' ')
      .map((p) {
        if (p.isEmpty) return p;
        final lower = p.toLowerCase();
        if (conectores.contains(lower)) return lower;
        if (_esSiglaConPuntos(p)) return p;
        if (p.length <= 4 && p == p.toUpperCase() && !p.contains('.')) return p;
        return '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}';
      })
      .join(' ');
}

bool _esSiglaConPuntos(String palabra) {
  return RegExp(r'^([A-Z]\.)+$').hasMatch(palabra);
}

String _normalizarTexto(String texto) {
  var t = texto
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAllMapped(RegExp(r'(\w),(\w)'), (m) => '${m.group(1)}, ${m.group(2)}')
      .replaceAllMapped(RegExp(r'\.(\S)'), (m) => '. ${m.group(1)}')
      .trim();
  while (t.contains('.  ')) {
    t = t.replaceAll('.  ', '. ');
  }
  return t;
}
