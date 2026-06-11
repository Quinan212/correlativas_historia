part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _NotificacionesEstudiantePantalla extends StatelessWidget {
  const _NotificacionesEstudiantePantalla({
    required this.history,
    required this.entries,
  });

  final List<EntradaHistorialEstudiante> history;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movements = _buildStudentMovements(history, entries)
        .take(24)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notificaciones'),
      ),
      body: SafeArea(
        top: false,
        child: movements.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Sin movimientos recientes.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                itemCount: movements.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.28),
                ),
                itemBuilder: (context, index) => _FilaMovimientoEstudiante(
                  movement: movements[index],
                  history: history,
                  allEntries: entries,
                ),
              ),
      ),
    );
  }
}

class _FilaMovimientoEstudiante extends StatelessWidget {
  const _FilaMovimientoEstudiante({
    required this.movement,
    this.history,
    this.allEntries,
  });

  final _MovimientoEstudiante movement;
  final List<EntradaHistorialEstudiante>? history;
  final List<_CurriculumEntry>? allEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: movement.entry == null
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _DetalleMateriaEstudiantePantalla(
                    entry: movement.entry!,
                    allEntries: allEntries ?? const [],
                    history: history ?? const [],
                  ),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.55),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                movement.icon,
                color: movement.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movement.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                      ),
                      if (movement.dateLabel != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          movement.dateLabel!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movement.detail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (movement.entry != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProximosPasosEstudiantePantalla extends StatelessWidget {
  const _ProximosPasosEstudiantePantalla({
    required this.payload,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = payload.student;
    final availableEntries = entries
        .where((entry) => entry.current == null && entry.available)
        .toList(growable: false);
    final pendingFinals = entries.where((entry) {
      final current = entry.current;
      if (current == null || _isSubjectApproved(current)) return false;
      return _estadoMateriaParaRequisito(current) == 'regular' ||
          _isSubjectInProgress(current);
    }).toList(growable: false);
    final missingContact = (student.contactPhone?.trim().isEmpty ?? true) ||
        (student.contactEmail?.trim().isEmpty ?? true);

    _CurriculumEntry? bestCandidate;
    var bestUnlockCount = 0;
    for (final entry in availableEntries) {
      final unlockCount = _subjectsUnlockedBy(entry, entries)
          .where((candidate) => candidate.current == null)
          .length;
      if (unlockCount > bestUnlockCount) {
        bestUnlockCount = unlockCount;
        bestCandidate = entry;
      }
    }

    final items = <_ItemProximoPaso>[
      if (availableEntries.isNotEmpty)
        _ItemProximoPaso(
          icon: Icons.task_alt_rounded,
          color: const Color(0xFF0E7490),
          title:
              'Ten\u00e9s ${availableEntries.length} materias disponibles para cursar.',
          detail: availableEntries
              .take(2)
              .map((entry) => entry.materia.displayNombre)
              .join(' \u00b7 '),
        )
      else
        const _ItemProximoPaso(
          icon: Icons.pause_circle_outline_rounded,
          color: Color(0xFF64748B),
          title: 'No hay materias nuevas habilitadas por ahora.',
          detail:
              'Conviene revisar correlativas pendientes o finales en curso.',
        ),
      _ItemProximoPaso(
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFFD97706),
        title:
            'Ten\u00e9s ${pendingFinals.length} finales o cierres pendientes.',
        detail: pendingFinals.isEmpty
            ? 'No hay materias en curso pendientes de cierre.'
            : pendingFinals
                .take(2)
                .map((entry) => entry.materia.displayNombre)
                .join(' \u00b7 '),
      ),
      if (bestCandidate != null)
        _ItemProximoPaso(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF2EAD57),
          title: 'Conviene priorizar ${bestCandidate.materia.displayNombre}.',
          detail: bestUnlockCount == 0
              ? 'Ya est\u00e1 disponible y ayuda a sostener tu avance actual.'
              : 'Puede habilitar $bestUnlockCount materias posteriores si la aprob\u00e1s.',
        ),
      if (missingContact)
        const _ItemProximoPaso(
          icon: Icons.contact_phone_outlined,
          color: Color(0xFF7C3AED),
          title: 'Faltan completar datos de contacto.',
          detail:
              'Revis\u00e1 tel\u00e9fono y correo en la secci\u00f3n Tus datos.',
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pr\u00f3ximos pasos'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _TarjetaVidrio(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PildoraSeccion(label: 'Orientaci\u00f3n r\u00e1pida'),
                  const SizedBox(height: 12),
                  Text(
                    'Qu\u00e9 conviene hacer ahora',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Leemos tu trayectoria actual para marcar lo m\u00e1s urgente, lo disponible y lo que m\u00e1s impacto puede tener en el recorrido.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final item in items) ...[
              _TarjetaProximoPaso(item: item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgresoEstudiantePantalla extends StatelessWidget {
  const _ProgresoEstudiantePantalla({
    required this.payload,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectApproved(current);
    }).length;
    final inProgress = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectInProgress(current);
    }).length;
    final available = entries
        .where((entry) => entry.current == null && entry.available)
        .length;
    final blocked = entries
        .where((entry) => entry.current == null && !entry.available)
        .length;
    final total = entries.length;
    final progress = total == 0 ? 0.0 : approved / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mi avance'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _TarjetaProgresoGrande(
              progress: progress,
              approved: approved,
              totalPlan: total,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.check_circle_rounded,
                    label: 'Aprobadas',
                    value: '$approved',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgress',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.task_alt_rounded,
                    label: 'Disponibles',
                    value: '$available',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TarjetaMetrica(
                    icon: Icons.lock_rounded,
                    label: 'No disponibles',
                    value: '$blocked',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TarjetaVidrio(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagn\u00f3stico breve',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _progressDiagnosis(
                      student: payload.student,
                      approved: approved,
                      available: available,
                      blocked: blocked,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final year in [1, 2, 3, 4]) ...[
              if (entries.any((entry) => entry.materia.anio == year))
                _TarjetaProgresoAnio(
                  year: year,
                  entries: entries
                      .where((entry) => entry.materia.anio == year)
                      .toList(growable: false),
                ),
              if (entries.any((entry) => entry.materia.anio == year))
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalendarioAcademicoEstudiantePantalla extends StatefulWidget {
  const _CalendarioAcademicoEstudiantePantalla({
    required this.payload,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<_CurriculumEntry> entries;

  @override
  State<_CalendarioAcademicoEstudiantePantalla> createState() =>
      _CalendarioAcademicoEstudiantePantallaState();
}

class _CalendarioAcademicoEstudiantePantallaState
    extends State<_CalendarioAcademicoEstudiantePantalla> {
  late final List<_EventoCalendarioAcademico> _events;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = _buildAcademicCalendarEvents(
      widget.payload.history,
      widget.entries,
    );
    final latestDate = _events.isEmpty
        ? DateTime.now()
        : _events.map((event) => event.date).reduce(
              (a, b) => a.isAfter(b) ? a : b,
            );
    _visibleMonth = DateTime(latestDate.year, latestDate.month);
    _selectedDay = _dateOnly(latestDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthEvents = _events
        .where(
          (event) =>
              event.date.year == _visibleMonth.year &&
              event.date.month == _visibleMonth.month,
        )
        .toList(growable: false);
    final eventsByDay = <DateTime, List<_EventoCalendarioAcademico>>{};
    for (final event in monthEvents) {
      final key = _dateOnly(event.date);
      eventsByDay.putIfAbsent(key, () => []).add(event);
    }
    final selectedEvents =
        eventsByDay[_selectedDay] ?? const <_EventoCalendarioAcademico>[];
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekdayOffset =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday - 1;
    final totalCells = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Calendario acad\u00e9mico'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _TarjetaVidrio(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleMonth = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month - 1,
                            );
                            _selectedDay = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month,
                              1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          _etiquetaMes(_visibleMonth),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleMonth = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month + 1,
                            );
                            _selectedDay = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month,
                              1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      _CeldaDiaSemanaCalendario(label: 'L'),
                      _CeldaDiaSemanaCalendario(label: 'M'),
                      _CeldaDiaSemanaCalendario(label: 'M'),
                      _CeldaDiaSemanaCalendario(label: 'J'),
                      _CeldaDiaSemanaCalendario(label: 'V'),
                      _CeldaDiaSemanaCalendario(label: 'S'),
                      _CeldaDiaSemanaCalendario(label: 'D'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalCells,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final dayNumber = index - firstWeekdayOffset + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month,
                        dayNumber,
                      );
                      final dayEvents = eventsByDay[_dateOnly(date)] ??
                          const <_EventoCalendarioAcademico>[];
                      final isSelected = _isSameDay(date, _selectedDay);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              setState(() => _selectedDay = _dateOnly(date)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.26)
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.16),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: [
                                    for (final event in dayEvents.take(3))
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: event.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                if (dayEvents.length > 3) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '+${dayEvents.length - 3}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TarjetaVidrio(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos del ${_selectedDay.day.toString().padLeft(2, '0')}/${_selectedDay.month.toString().padLeft(2, '0')}/${_selectedDay.year}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedEvents.isEmpty)
                    Text(
                      'No hay movimientos o acreditaciones guardadas para este d\u00eda.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final event in selectedEvents) ...[
                          _BaldosaEventoCalendarioAcademico(
                            event: event,
                            allEntries: widget.entries,
                            history: widget.payload.history,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BarraInferiorDetalle(
          onTap: () => Navigator.of(context).pop(),
          label: 'Cerrar y volver',
        ),
      ),
    );
  }
}

class _ItemProximoPaso {
  const _ItemProximoPaso({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
}

class _TarjetaProximoPaso extends StatelessWidget {
  const _TarjetaProximoPaso({required this.item});

  final _ItemProximoPaso item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _TarjetaVidrio(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
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

class _TarjetaProgresoAnio extends StatelessWidget {
  const _TarjetaProgresoAnio({
    required this.year,
    required this.entries,
  });

  final int year;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectApproved(current);
    }).length;
    final inProgress = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectInProgress(current);
    }).length;
    final available = entries
        .where((entry) => entry.current == null && entry.available)
        .length;
    final total = entries.length;

    return _TarjetaVidrio(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_etiquetaAnio(year)} a\u00f1o',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _PildoraSeccion(label: '$approved/$total aprobadas'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$inProgress cursando \u00b7 $available disponibles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CeldaDiaSemanaCalendario extends StatelessWidget {
  const _CeldaDiaSemanaCalendario({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _BaldosaEventoCalendarioAcademico extends StatelessWidget {
  const _BaldosaEventoCalendarioAcademico({
    required this.event,
    required this.allEntries,
    required this.history,
  });

  final _EventoCalendarioAcademico event;
  final List<_CurriculumEntry> allEntries;
  final List<EntradaHistorialEstudiante> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: event.entry == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _DetalleMateriaEstudiantePantalla(
                      entry: event.entry!,
                      allEntries: allEntries,
                      history: history,
                    ),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: event.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: event.color.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(event.icon, color: event.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.detail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (event.entry != null) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.42),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EventoCalendarioAcademico {
  const _EventoCalendarioAcademico({
    required this.date,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    this.entry,
  });

  final DateTime date;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final _CurriculumEntry? entry;
}
