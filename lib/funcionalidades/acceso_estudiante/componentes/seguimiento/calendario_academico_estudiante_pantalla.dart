part of '../../pantallas/acceso_estudiante_pantalla.dart';

enum _VistaCalendarioAcademico { mes, semana, dia }

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
  static const int _monthGridRows = 6;
  static const double _monthGridSpacing = 8;
  static const double _monthCellMinHeight = 56;
  static const double _monthCellMaxHeight = 72;
  static const double _detailSectionEmptyMinHeight = 42;
  static const double _detailSectionContentMinHeight = 96;
  static const double _monthSectionMinHeight = 700;
  static const double _weekSectionMinHeight = 620;
  static const double _daySectionMinHeight = 150;

  late final List<_EventoCalendarioAcademico> _events;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  _VistaCalendarioAcademico _view = _VistaCalendarioAcademico.mes;
  int _transitionDirection = 1;

  @override
  void initState() {
    super.initState();
    _events = _buildAcademicCalendarEvents(widget.entries);
    final latestDate = _events.isEmpty
        ? DateTime.now()
        : _events.map((event) => event.date).reduce(
              (a, b) => a.isAfter(b) ? a : b,
            );
    _visibleMonth = DateTime(latestDate.year, latestDate.month);
    _selectedDay = _dateOnly(latestDate);
  }

  DateTime get _weekStart => _selectedDay.subtract(
        Duration(days: _selectedDay.weekday - DateTime.monday),
      );

  void _movePeriod(int direction) {
    setState(() {
      _transitionDirection = direction;
      switch (_view) {
        case _VistaCalendarioAcademico.mes:
          _visibleMonth = DateTime(
            _visibleMonth.year,
            _visibleMonth.month + direction,
          );
          _selectedDay = DateTime(
            _visibleMonth.year,
            _visibleMonth.month,
            1,
          );
        case _VistaCalendarioAcademico.semana:
          _selectedDay = _dateOnly(
            _selectedDay.add(Duration(days: 7 * direction)),
          );
          _visibleMonth = DateTime(_selectedDay.year, _selectedDay.month);
        case _VistaCalendarioAcademico.dia:
          _selectedDay = _dateOnly(
            _selectedDay.add(Duration(days: direction)),
          );
          _visibleMonth = DateTime(_selectedDay.year, _selectedDay.month);
      }
    });
  }

  void _goToday() {
    final today = _dateOnly(DateTime.now());
    setState(() {
      _transitionDirection = today.isBefore(_selectedDay) ? -1 : 1;
      _selectedDay = today;
      _visibleMonth = DateTime(today.year, today.month);
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null || velocity.abs() < 250) return;
    _movePeriod(velocity < 0 ? 1 : -1);
  }

  String _periodAnimationKey() {
    return switch (_view) {
      _VistaCalendarioAcademico.mes =>
        'mes-${_visibleMonth.year}-${_visibleMonth.month}',
      _VistaCalendarioAcademico.semana =>
        'semana-${_weekStart.year}-${_weekStart.month}-${_weekStart.day}',
      _VistaCalendarioAcademico.dia =>
        'dia-${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}',
    };
  }

  double _contentMinHeightForView(bool hasSelectedEvents) {
    switch (_view) {
      case _VistaCalendarioAcademico.mes:
        return _monthSectionMinHeight;
      case _VistaCalendarioAcademico.semana:
        return _weekSectionMinHeight;
      case _VistaCalendarioAcademico.dia:
        return hasSelectedEvents
            ? _daySectionMinHeight
            : _detailSectionEmptyMinHeight + 88;
    }
  }

  String _periodLabel() {
    switch (_view) {
      case _VistaCalendarioAcademico.mes:
        return _etiquetaMes(_visibleMonth);
      case _VistaCalendarioAcademico.semana:
        final end = _weekStart.add(const Duration(days: 6));
        if (_weekStart.month == end.month) {
          return '${_weekStart.day}\u2013${end.day} ${_shortMonth(end)} ${end.year}';
        }
        return '${_weekStart.day} ${_shortMonth(_weekStart)} \u2013 ${end.day} ${_shortMonth(end)}';
      case _VistaCalendarioAcademico.dia:
        return '${_weekdayName(_selectedDay)}, ${_selectedDay.day} de ${_monthName(_selectedDay)}';
    }
  }

  String _weekdayName(DateTime value) => const <String>[
        'lunes',
        'martes',
        'mi\u00e9rcoles',
        'jueves',
        'viernes',
        's\u00e1bado',
        'domingo',
      ][value.weekday - 1];

  String _monthName(DateTime value) => const <String>[
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ][value.month - 1];

  String _shortMonth(DateTime value) => _monthName(value).substring(0, 3);

  Widget _buildMonthEventIndicator(
    BuildContext context,
    List<_EventoCalendarioAcademico> dayEvents,
    bool isSelected,
  ) {
    if (dayEvents.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    if (dayEvents.length <= 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final event in dayEvents) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: event.color,
                shape: BoxShape.circle,
              ),
            ),
            if (event != dayEvents.last) const SizedBox(width: 3),
          ],
        ],
      );
    }

    final accentColor =
        isSelected ? theme.colorScheme.primary : dayEvents.first.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '+${dayEvents.length}',
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9.5,
          height: 1,
          fontWeight: FontWeight.w800,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _buildCalendarModeIcon(_VistaCalendarioAcademico view) {
    switch (view) {
      case _VistaCalendarioAcademico.mes:
        return const _IconoModoCalendario(filas: 2, columnas: 2);
      case _VistaCalendarioAcademico.semana:
        return const _IconoModoCalendario(filas: 1, columnas: 3);
      case _VistaCalendarioAcademico.dia:
        return const _IconoModoDiaCalendario();
    }
  }

  Widget _buildCalendarModeLabel(
    String text,
    _VistaCalendarioAcademico view,
  ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCalendarModeIcon(view),
          const SizedBox(width: 7),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDay(
    BuildContext context,
    DateTime day,
    List<_EventoCalendarioAcademico> events,
  ) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(day, DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _selectedDay = _dateOnly(day);
                _visibleMonth = DateTime(day.year, day.month);
                _view = _VistaCalendarioAcademico.dia;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        color: isToday
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_weekdayName(day)} \u00b7 ${_monthName(day)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  Text(
                    events.isEmpty ? 'Sin eventos' : '${events.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ),
          if (events.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final event in events) ...[
              _BaldosaEventoCalendarioAcademico(
                event: event,
                allEntries: widget.entries,
                history: widget.payload.history,
              ),
              const SizedBox(height: 8),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 2),
              child: Text(
                'No hay movimientos acad\u00e9micos.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsByDay = <DateTime, List<_EventoCalendarioAcademico>>{};
    for (final event in _events) {
      final key = _dateOnly(event.date);
      eventsByDay.putIfAbsent(key, () => []).add(event);
    }
    final selectedEvents =
        eventsByDay[_selectedDay] ?? const <_EventoCalendarioAcademico>[];
    final weekDays = List<DateTime>.generate(
      7,
      (index) => _weekStart.add(Duration(days: index)),
    );
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekdayOffset =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday - 1;
    const totalCells = 42;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Calendario acad\u00e9mico'),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _TarjetaVidrio(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<_VistaCalendarioAcademico>(
                        segments: <ButtonSegment<_VistaCalendarioAcademico>>[
                          ButtonSegment<_VistaCalendarioAcademico>(
                            value: _VistaCalendarioAcademico.mes,
                            label: _buildCalendarModeLabel(
                              'Mes',
                              _VistaCalendarioAcademico.mes,
                            ),
                          ),
                          ButtonSegment<_VistaCalendarioAcademico>(
                            value: _VistaCalendarioAcademico.semana,
                            label: _buildCalendarModeLabel(
                              'Semana',
                              _VistaCalendarioAcademico.semana,
                            ),
                          ),
                          ButtonSegment<_VistaCalendarioAcademico>(
                            value: _VistaCalendarioAcademico.dia,
                            label: _buildCalendarModeLabel(
                              'D\u00eda',
                              _VistaCalendarioAcademico.dia,
                            ),
                          ),
                        ],
                        selected: <_VistaCalendarioAcademico>{_view},
                        showSelectedIcon: false,
                        onSelectionChanged: (selection) {
                          setState(() => _view = selection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Anterior',
                          onPressed: () => _movePeriod(-1),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Text(
                            _periodLabel(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _goToday,
                          child: const Text('Hoy'),
                        ),
                        IconButton(
                          tooltip: 'Siguiente',
                          onPressed: () => _movePeriod(1),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  reverseDuration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: _contentMinHeightForView(
                        selectedEvents.isNotEmpty,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      reverseDuration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: Offset(_transitionDirection * 0.12, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<String>(_periodAnimationKey()),
                        children: [
                          const SizedBox(height: 12),
                          if (_view == _VistaCalendarioAcademico.mes)
                            _TarjetaVidrio(
                              child: Column(
                                children: [
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
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double cellWidth =
                                          (constraints.maxWidth -
                                                  (_monthGridSpacing * 6)) /
                                              7;
                                      final double cellHeight = cellWidth
                                          .clamp(
                                            _monthCellMinHeight,
                                            _monthCellMaxHeight,
                                          )
                                          .toDouble();
                                      final double gridHeight =
                                          (cellHeight * _monthGridRows) +
                                              (_monthGridSpacing *
                                                  (_monthGridRows - 1));

                                      return SizedBox(
                                        height: gridHeight,
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: totalCells,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 7,
                                            mainAxisSpacing: _monthGridSpacing,
                                            crossAxisSpacing: _monthGridSpacing,
                                            childAspectRatio:
                                                cellWidth / cellHeight,
                                          ),
                                          itemBuilder: (context, index) {
                                            final dayNumber =
                                                index - firstWeekdayOffset + 1;
                                            if (dayNumber < 1 ||
                                                dayNumber > daysInMonth) {
                                              return const SizedBox.shrink();
                                            }
                                            final date = DateTime(
                                              _visibleMonth.year,
                                              _visibleMonth.month,
                                              dayNumber,
                                            );
                                            final dayEvents = eventsByDay[
                                                    _dateOnly(date)] ??
                                                const <_EventoCalendarioAcademico>[];
                                            final isSelected =
                                                _isSameDay(date, _selectedDay);

                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                onTap: () => setState(() =>
                                                    _selectedDay =
                                                        _dateOnly(date)),
                                                child: Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                    4,
                                                    5,
                                                    4,
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? theme
                                                            .colorScheme.primary
                                                            .withValues(
                                                                alpha: 0.12)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? theme.colorScheme
                                                              .primary
                                                              .withValues(
                                                                  alpha: 0.26)
                                                          : theme.colorScheme
                                                              .outline
                                                              .withValues(
                                                                  alpha: 0.16),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        '$dayNumber',
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.clip,
                                                        style: theme.textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: isSelected
                                                              ? theme
                                                                  .colorScheme
                                                                  .primary
                                                              : theme
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      SizedBox(
                                                        height: 18,
                                                        child: Center(
                                                          child:
                                                              _buildMonthEventIndicator(
                                                            context,
                                                            dayEvents,
                                                            isSelected,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (_view == _VistaCalendarioAcademico.semana) ...[
                            _TarjetaVidrio(
                              child: Column(
                                children: [
                                  for (final day in weekDays)
                                    _buildWeekDay(
                                      context,
                                      day,
                                      eventsByDay[_dateOnly(day)] ??
                                          const <_EventoCalendarioAcademico>[],
                                    ),
                                ],
                              ),
                            ),
                          ],
                          if (_view != _VistaCalendarioAcademico.semana) ...[
                            const SizedBox(height: 16),
                            _TarjetaVidrio(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Eventos del ${_selectedDay.day.toString().padLeft(2, '0')}/${_selectedDay.month.toString().padLeft(2, '0')}/${_selectedDay.year}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: selectedEvents.isEmpty
                                          ? _detailSectionEmptyMinHeight
                                          : _detailSectionContentMinHeight,
                                    ),
                                    child: AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      reverseDuration:
                                          const Duration(milliseconds: 180),
                                      curve: Curves.easeInOutCubic,
                                      alignment: Alignment.topCenter,
                                      child: AnimatedCrossFade(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        reverseDuration:
                                            const Duration(milliseconds: 180),
                                        sizeCurve: Curves.easeInOutCubic,
                                        firstCurve: Curves.easeOutCubic,
                                        secondCurve: Curves.easeOutCubic,
                                        alignment: Alignment.topLeft,
                                        crossFadeState: selectedEvents.isEmpty
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        firstChild: Align(
                                          alignment: Alignment.topLeft,
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              'No hay movimientos o acreditaciones guardadas para este d\u00eda.',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontSize: 14,
                                                height: 1.2,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                        secondChild: KeyedSubtree(
                                          key: ValueKey<String>(
                                            'detalle-${_view.index}-${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}-${selectedEvents.length}',
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (final event
                                                  in selectedEvents) ...[
                                                _BaldosaEventoCalendarioAcademico(
                                                  event: event,
                                                  allEntries: widget.entries,
                                                  history:
                                                      widget.payload.history,
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconoModoCalendario extends StatelessWidget {
  const _IconoModoCalendario({
    required this.filas,
    required this.columnas,
  });

  final int filas;
  final int columnas;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? Colors.black87;
    return SizedBox(
      width: 20,
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var row = 0; row < filas; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var column = 0; column < columnas; column++) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1.4),
                    ),
                  ),
                  if (column != columnas - 1) const SizedBox(width: 2),
                ],
              ],
            ),
            if (row != filas - 1) const SizedBox(height: 2),
          ],
        ],
      ),
    );
  }
}

class _IconoModoDiaCalendario extends StatelessWidget {
  const _IconoModoDiaCalendario();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? Colors.black87;
    return SizedBox(
      width: 20,
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 17,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.4),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 17,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.4),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 11,
            height: 4,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.4),
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
