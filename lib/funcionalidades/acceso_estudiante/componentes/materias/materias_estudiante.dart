part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _TarjetaMaterias extends StatelessWidget {
  const _TarjetaMaterias({
    required this.payload,
    required this.plan,
    required this.history,
    required this.loadingPlan,
    required this.query,
    required this.searchController,
    required this.selectedYear,
    required this.selectedStatus,
    required this.onYearSelected,
    required this.onStatusSelected,
    required this.onQueryChanged,
  });

  final DatosAccesoEstudiante payload;
  final List<Materia> plan;
  final List<EntradaHistorialEstudiante> history;
  final bool loadingPlan;
  final String query;
  final TextEditingController searchController;
  final int selectedYear;
  final String selectedStatus;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loadingPlan && plan.isEmpty) {
      return _TarjetaVidrio(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapa académico',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 12),
            Text(
              'Cargando correlatividades de tu carrera...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);
    final normalizedQuery = _norm(query);
    bool matchesStatus(_CurriculumEntry entry) {
      return switch (selectedStatus) {
        'aprobadas' =>
          entry.current != null && _isSubjectApproved(entry.current!),
        'bloqueadas' => _isEntryBlocked(entry),
        'cursando' =>
          entry.current != null && _isSubjectInProgress(entry.current!),
        _ => true,
      };
    }

    bool matchesSearch(_CurriculumEntry entry) {
      if (normalizedQuery.isEmpty) return true;
      return _norm(entry.materia.displayNombre).contains(normalizedQuery) ||
          _norm(entry.materia.nombre).contains(normalizedQuery);
    }

    final filteredEntries = entries
        .where(
          (entry) =>
              (selectedYear == 0 || entry.materia.anio == selectedYear) &&
              matchesStatus(entry) &&
              matchesSearch(entry),
        )
        .toList(growable: false);
    final grouped = <int, List<_CurriculumEntry>>{
      1: <_CurriculumEntry>[],
      2: <_CurriculumEntry>[],
      3: <_CurriculumEntry>[],
      4: <_CurriculumEntry>[],
    };
    for (final entry in filteredEntries) {
      grouped[entry.materia.anio]!.add(entry);
    }
    final approvedCount = entries
        .where((e) => e.current != null && _isSubjectApproved(e.current!))
        .length;
    final inProgressCount = entries
        .where((e) => e.current != null && _isSubjectInProgress(e.current!))
        .length;
    final availableCount = entries
        .where((e) => e.current == null && e.available)
        .length;
    final blockedCount = entries.where(_isEntryBlocked).length;
    final yearsToShow = selectedYear == 0 ? const [1, 2, 3, 4] : [selectedYear];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mapa de correlatividades',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acá ves lo aprobado, lo que ya podés cursar y lo que sigue bloqueado por correlativas.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.check_circle_rounded,
                    label: 'Aprobadas',
                    value: '$approvedCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgressCount',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.task_alt_rounded,
                    label: 'Habilitadas',
                    value: '$availableCount',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.lock_rounded,
                    label: 'Bloqueadas',
                    value: '$blockedCount',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.menu_book_rounded,
                    label: 'Plan total',
                    value: '${entries.length}',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Buscar materia',
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.22),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.22),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _EtiquetaFiltroAnio(
                label: 'Todos',
                selected: selectedYear == 0 && selectedStatus == 'todos',
                onTap: () {
                  onYearSelected(0);
                  onStatusSelected('todos');
                },
              ),
              const SizedBox(width: 8),
              for (final year in [1, 2, 3, 4]) ...[
                _EtiquetaFiltroAnio(
                  label: '$year° año',
                  selected: selectedYear == year,
                  onTap: () => onYearSelected(year),
                ),
                const SizedBox(width: 8),
              ],
              for (final item in const [
                ('aprobadas', 'Aprobadas'),
                ('bloqueadas', 'Bloqueadas'),
                ('cursando', 'Cursando'),
              ]) ...[
                _EtiquetaFiltroAnio(
                  label: item.$2,
                  selected: selectedStatus == item.$1,
                  onTap: () => onStatusSelected(item.$1),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${filteredEntries.length} materias visibles',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (filteredEntries.isEmpty)
          _TarjetaVidrio(
            child: Text(
              'No encontramos materias con esos filtros.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final year in yearsToShow) ...[
            _GrupoMateriasAnio(
              year: year,
              entries: grouped[year] ?? const [],
              allEntries: entries,
              history: history,
            ),
            if (year != yearsToShow.last) const SizedBox(height: 16),
          ],
      ],
    );
  }
}

class _GrupoMateriasAnio extends StatelessWidget {
  const _GrupoMateriasAnio({
    required this.year,
    required this.entries,
    required this.allEntries,
    required this.history,
  });

  final int year;
  final List<_CurriculumEntry> entries;
  final List<_CurriculumEntry> allEntries;
  final List<EntradaHistorialEstudiante> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) return const SizedBox.shrink();

    final approved = entries.where((e) {
      final current = e.current;
      return current != null &&
          current.status.toLowerCase().trim() == 'aprobada';
    }).length;
    final blocked = entries
        .where((e) => e.current == null && !e.available)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$year° año',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _PildoraSeccion(label: '$approved aprobadas'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${entries.length} materias${blocked == 0 ? '' : ' · $blocked bloqueadas'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in entries) ...[
          _FilaMateria(
            entry: entry,
            history: history,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _DetalleMateriaEstudiantePantalla(
                    entry: entry,
                    allEntries: allEntries,
                    history: history,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FilaMateria extends StatelessWidget {
  const _FilaMateria({
    required this.entry,
    required this.history,
    required this.onTap,
  });

  final _CurriculumEntry entry;
  final List<EntradaHistorialEstudiante> history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateLabel = _subjectStateForRow(entry);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.022),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.materia.displayNombre,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              _LineaMetaMateria(
                icon: _subjectStateIcon(entry),
                iconColor: _subjectStateColor(context, entry),
                label: stateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_subjectCardDate(entry, history) != null) ...[
                const SizedBox(height: 6),
                _LineaMetaMateria(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  label: _subjectCardDate(entry, history)!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetalleMateriaEstudiantePantalla extends StatelessWidget {
  const _DetalleMateriaEstudiantePantalla({
    required this.entry,
    required this.allEntries,
    required this.history,
  });

  final _CurriculumEntry entry;
  final List<_CurriculumEntry> allEntries;
  final List<EntradaHistorialEstudiante> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = entry.current;
    final historySteps = _subjectHistorySteps(entry, history);
    final unlocks = _subjectsUnlockedBy(entry, allEntries);

    return Scaffold(
      appBar: _BannerDetalleMateria(title: entry.materia.displayNombre),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        children: [
          _TableroEstadoMateria(entry: entry),
          _TarjetaHistorialMateria(steps: historySteps),
          const SizedBox(height: 16),
          _TarjetaVidrio(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current != null &&
                          _estadoMateriaParaRequisito(current) == 'aprobada'
                      ? 'Lo que desbloquea'
                      : 'Correlativas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (current != null &&
                    _estadoMateriaParaRequisito(current) == 'aprobada') ...[
                  Text(
                    'Aprobar esta materia te permite avanzar en estas materias:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (unlocks.isEmpty)
                    Text(
                      'No desbloquea otras materias del plan.',
                      style: theme.textTheme.bodyLarge,
                    )
                  else
                    Column(
                      children: [
                        for (final unlock in unlocks.take(8)) ...[
                          _UnlockRow(title: unlock.materia.displayNombre),
                          const SizedBox(height: 10),
                        ],
                        if (unlocks.length > 8)
                          Text(
                            '+ ${unlocks.length - 8} materias más',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                ] else if (_isUdiMateria(entry.materia) ||
                    _isPracticaDocenteIV(entry.materia))
                  Text(
                    _isPracticaDocenteIV(entry.materia)
                        ? 'Para la Residencia necesitás tener aprobados todos los años anteriores.'
                        : 'Para esta UDI necesitás tener aprobados todos los años anteriores.',
                    style: theme.textTheme.bodyLarge,
                  )
                else if (entry.missing.isEmpty)
                  Text(
                    current != null
                        ? 'Cumplís con los requisitos de correlativas.'
                        : 'Materia desbloqueada. Podés cursar o rendir.',
                    style: theme.textTheme.bodyLarge,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Te faltan estas correlativas:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in entry.missing)
                            _EtiquetaEstado(label: item),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Banner azul de la pantalla de detalle de materia
// ──────────────────────────────────────────────────────────────
class _BannerDetalleMateria extends StatelessWidget
    implements PreferredSizeWidget {
  const _BannerDetalleMateria({required this.title});

  final String title;

  static const Color _c1 = Color(0xFF005B7F);
  static const Color _c2 = Color(0xFF004966);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _c1,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c1, _c2],
          ),
        ),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1.15,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _UnlockRow extends StatelessWidget {
  const _UnlockRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_open_rounded,
            size: 18,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _CompactInsignia(
            label: 'Desbloquea',
            color: theme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _TarjetaHistorialMateria extends StatelessWidget {
  const _TarjetaHistorialMateria({required this.steps});

  final List<_PasoHistorialMateria> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _TarjetaVidrio(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movimientos de la materia',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (steps.isEmpty)
            Text(
              'Todavía no hay movimientos guardados para esta materia.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                for (final step in steps) ...[
                  _FilaHistorialMateria(step: step),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _FilaHistorialMateria extends StatelessWidget {
  const _FilaHistorialMateria({required this.step});

  final _PasoHistorialMateria step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: step.color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(step.icon, color: step.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (step.dateLabel != null)
                      Text(
                        step.dateLabel!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (step.detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.detail!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

class _MovimientoEstudiante {
  const _MovimientoEstudiante({
    required this.title,
    required this.detail,
    required this.dateLabel,
    required this.icon,
    required this.color,
    this.entry,
  });

  final String title;
  final String detail;
  final String? dateLabel;
  final IconData icon;
  final Color color;
  final _CurriculumEntry? entry;
}

class _PasoHistorialMateria {
  const _PasoHistorialMateria({
    required this.label,
    required this.detail,
    required this.dateLabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final String? detail;
  final String? dateLabel;
  final Color color;
  final IconData icon;
}

// ──────────────────────────────────────────────────────────────
// Dashboard 2×2 de estado de materia
// ──────────────────────────────────────────────────────────────
