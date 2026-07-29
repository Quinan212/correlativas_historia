import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../examenes/modelos/evento_examen.dart';
import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../../laboratorio_atlassian/pantallas/utilidades_atlassian.dart';
import '../componentes/dialogo_actualizacion_mesas_excel.dart';
import '../controladores/controlador_mesas_excel.dart';
import 'pantalla_detalle_examen_excel_atlassian.dart';

class PantallaCalendarioExcelAtlassian extends StatefulWidget {
  const PantallaCalendarioExcelAtlassian({
    super.key,
    required this.controller,
    this.careerId = 'historia',
    this.initialDate,
  });

  final ControladorMesasExcel controller;
  final String careerId;
  final DateTime? initialDate;

  @override
  State<PantallaCalendarioExcelAtlassian> createState() =>
      _PantallaCalendarioExcelAtlassianState();
}

class _PantallaCalendarioExcelAtlassianState
    extends State<PantallaCalendarioExcelAtlassian> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  late String _careerId;

  @override
  void initState() {
    super.initState();
    _careerId = widget.careerId;
    final base = widget.initialDate ?? DateTime.now();
    _visibleMonth = DateTime(base.year, base.month);
    _selectedDay = DateTime(base.year, base.month, base.day);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PantallaCalendarioExcelAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  List<EventoExamen> get _events =>
      widget.controller.eventos
          .map((item) => item.evento)
          .where(
            (event) =>
                event.visible && !event.legacy && event.careerId == _careerId,
          )
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
    if (selected == null || !mounted || selected == _careerId) return;
    setState(() => _careerId = selected);
  }

  Future<void> _refresh() => widget.controller.actualizar(force: true);

  Future<void> _refreshConDialogo() => mostrarDialogoActualizacionMesasExcel(
    context: context,
    controller: widget.controller,
  );

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      final now = DateTime.now();
      final isCurrent =
          now.year == _visibleMonth.year && now.month == _visibleMonth.month;
      _selectedDay = isCurrent
          ? DateTime(now.year, now.month, now.day)
          : DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  List<_EntradaCalendarioAtlassian> _crearEntradas(List<EventoExamen> events) {
    final entries = <_EntradaCalendarioAtlassian>[
      for (final event in events)
        if (event.fecha != null) _EntradaCalendarioAtlassian.examen(event),
    ];
    entries.sort(
      (first, second) => first.fechaOrden.compareTo(second.fechaOrden),
    );
    return List<_EntradaCalendarioAtlassian>.unmodifiable(entries);
  }

  void _abrirEntrada(_EntradaCalendarioAtlassian entry) {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) =>
            PantallaDetalleExamenExcelAtlassian(event: entry.examen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          EncabezadoPaginaAtlassian(
            title: 'Calendario',
            subtitle: 'Mesas, coloquios y aprobaciones',
            centerTitle: true,
            leading: BotonIconoAtlassian(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              BotonIconoAtlassian(
                icon: Icons.today_rounded,
                tooltip: 'Ir a hoy',
                onPressed: _goToday,
              ),
              BotonIconoAtlassian(
                icon: Icons.refresh_rounded,
                tooltip: 'Actualizar Excel',
                onPressed: widget.controller.estaComprobando
                    ? null
                    : () => unawaited(_refreshConDialogo()),
              ),
            ],
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (widget.controller.estaComprobando) {
                  return _EsqueletoCalendarioAtlassian(
                    careerId: _careerId,
                    visibleMonth: _visibleMonth,
                    selectedDay: _selectedDay,
                    onChooseCareer: () {},
                  );
                }
                if (!widget.controller.tieneDatos && events.isEmpty) {
                  return EstadoVacioAtlassian(
                    icon: Icons.event_busy_rounded,
                    title: 'Calendario temporalmente no disponible',
                    message:
                        widget.controller.mensajeError ??
                        'La fuente institucional no pudo validarse.',
                    action: BotonAtlassian(
                      label: 'Reintentar',
                      icon: Icons.refresh_rounded,
                      primary: true,
                      onPressed: () => unawaited(_refreshConDialogo()),
                    ),
                  );
                }

                final entries = _crearEntradas(events);
                final byDay = <DateTime, List<_EntradaCalendarioAtlassian>>{};
                for (final entry in entries) {
                  final key = _dayKey(entry.fecha);
                  byDay
                      .putIfAbsent(key, () => <_EntradaCalendarioAtlassian>[])
                      .add(entry);
                }
                final selectedEvents =
                    byDay[_dayKey(_selectedDay)] ??
                    const <_EntradaCalendarioAtlassian>[];
                final today = _dayKey(DateTime.now());
                final upcoming = entries
                    .where((entry) => !_dayKey(entry.fecha).isBefore(today))
                    .toList(growable: false);

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      120 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      _SelectorCarreraCalendarioAtlassian(
                        careerId: _careerId,
                        onChooseCareer: _chooseCareer,
                      ),
                      const SizedBox(height: 12),
                      _ResumenCalendarioAtlassian(
                        total: entries.length,
                        upcoming: upcoming.length,
                        next: upcoming.isEmpty ? null : upcoming.first,
                      ),
                      const SizedBox(height: 12),
                      PanelAtlassian(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                BotonIconoAtlassian(
                                  icon: Icons.chevron_left_rounded,
                                  tooltip: 'Mes anterior',
                                  onPressed: () => _changeMonth(-1),
                                ),
                                Expanded(
                                  child: Text(
                                    _monthTitle(_visibleMonth),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                BotonIconoAtlassian(
                                  icon: Icons.chevron_right_rounded,
                                  tooltip: 'Mes siguiente',
                                  onPressed: () => _changeMonth(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const _WeekdayHeaderAtlassian(),
                            const SizedBox(height: 4),
                            _MonthGridAtlassian(
                              month: _visibleMonth,
                              selectedDay: _selectedDay,
                              eventsByDay: byDay,
                              onSelected: (day) =>
                                  setState(() => _selectedDay = day),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SeparadorTituloAtlassian(
                        title: _selectedDayTitle(_selectedDay),
                        subtitle: selectedEvents.isEmpty
                            ? 'Sin eventos'
                            : '${selectedEvents.length} eventos',
                      ),
                      const SizedBox(height: 8),
                      if (selectedEvents.isEmpty)
                        const MensajeSeccionAtlassian(
                          title: 'Día libre',
                          message:
                              'No hay mesas, coloquios ni aprobaciones para esta fecha.',
                          icon: Icons.event_available_outlined,
                        )
                      else
                        PanelAtlassian(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < selectedEvents.length;
                                index++
                              ) ...[
                                _CalendarEventRowAtlassian(
                                  event: selectedEvents[index],
                                  onTap: () =>
                                      _abrirEntrada(selectedEvents[index]),
                                ),
                                if (index != selectedEvents.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                      if (entries.isEmpty) ...[
                        const SizedBox(height: 16),
                        const MensajeSeccionAtlassian(
                          title: 'Sin fechas publicadas',
                          message:
                              'Todavía no hay eventos disponibles para esta carrera.',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenCalendarioAtlassian extends StatelessWidget {
  const _ResumenCalendarioAtlassian({
    required this.total,
    required this.upcoming,
    required this.next,
  });

  final int total;
  final int upcoming;
  final _EntradaCalendarioAtlassian? next;

  @override
  Widget build(BuildContext context) {
    return PanelAtlassian(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final nextEvent = next;
          final metrics = Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _CalendarMetricAtlassian(label: 'Publicados', value: '$total'),
              _CalendarMetricAtlassian(label: 'Próximos', value: '$upcoming'),
            ],
          );
          final nextWidget = nextEvent == null
              ? Text(
                  'Sin próximos eventos',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próxima fecha',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nextEvent.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextEvent.subtitulo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [metrics, const SizedBox(height: 16), nextWidget],
            );
          }
          return Row(
            children: [
              metrics,
              const SizedBox(width: 28),
              Expanded(child: nextWidget),
            ],
          );
        },
      ),
    );
  }
}

class _CalendarMetricAtlassian extends StatelessWidget {
  const _CalendarMetricAtlassian({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WeekdayHeaderAtlassian extends StatelessWidget {
  const _WeekdayHeaderAtlassian();

  @override
  Widget build(BuildContext context) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}

class _MonthGridAtlassian extends StatelessWidget {
  const _MonthGridAtlassian({
    required this.month,
    required this.selectedDay,
    required this.eventsByDay,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<_EntradaCalendarioAtlassian>> eventsByDay;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final firstOffset = first.weekday - DateTime.monday;
    final start = first.subtract(Duration(days: firstOffset));
    final today = _dayKey(DateTime.now());
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 48,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemBuilder: (context, index) {
        final day = start.add(Duration(days: index));
        final key = _dayKey(day);
        final selected = key == _dayKey(selectedDay);
        final currentMonth = day.month == month.month;
        final isToday = key == today;
        final eventCount = eventsByDay[key]?.length ?? 0;
        final scheme = Theme.of(context).colorScheme;
        return Semantics(
          button: true,
          selected: selected,
          label:
              '${day.day} de ${_monthTitle(day)}'
              '${eventCount == 0 ? '' : ', $eventCount eventos'}',
          child: InkWell(
            onTap: () => onSelected(day),
            borderRadius: BorderRadius.circular(RadioAtlassian.medium),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary
                    : isToday
                    ? scheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                border: isToday && !selected
                    ? Border.all(color: scheme.primary)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? Colors.white
                          : currentMonth
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                      fontWeight: selected || isToday
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (eventCount > 0)
                    Container(
                      width: eventCount > 1 ? 14 : 5,
                      height: 4,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : scheme.primary,
                        borderRadius: BorderRadius.circular(
                          RadioAtlassian.pill,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarEventRowAtlassian extends StatelessWidget {
  const _CalendarEventRowAtlassian({required this.event, required this.onTap});

  final _EntradaCalendarioAtlassian event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
              ),
              child: Icon(
                event.icono,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.titulo,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.subtitulo,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _EntradaCalendarioAtlassian {
  const _EntradaCalendarioAtlassian._({
    required this.fecha,
    required this.fechaOrden,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.examen,
  });

  factory _EntradaCalendarioAtlassian.examen(EventoExamen event) {
    final date = event.fecha!;
    return _EntradaCalendarioAtlassian._(
      fecha: date,
      fechaOrden: event.fechaHora ?? date,
      titulo: event.materia,
      subtitulo: formatoFechaHoraAtlassian(event.fecha, event.hora),
      icono: event.instancia == 'coloquio'
          ? Icons.groups_2_outlined
          : Icons.event_note_outlined,
      examen: event,
    );
  }

  final DateTime fecha;
  final DateTime fechaOrden;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final EventoExamen examen;
}

DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

String _monthTitle(DateTime date) {
  const months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _selectedDayTitle(DateTime date) {
  const weekdays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  return '${weekdays[date.weekday - 1]} ${date.day}';
}

class _SelectorCarreraCalendarioAtlassian extends StatelessWidget {
  const _SelectorCarreraCalendarioAtlassian({
    required this.careerId,
    required this.onChooseCareer,
  });

  final String careerId;
  final VoidCallback onChooseCareer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PanelAtlassian(
      onTap: onChooseCareer,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(RadioAtlassian.medium),
            ),
            child: Icon(Icons.school_rounded, color: scheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrera seleccionada',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _nombreCarrera(careerId),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Icon(
            Icons.expand_more_rounded,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }

  static String _nombreCarrera(String id) {
    switch (id) {
      case 'geografia':
        return 'Geografía';
      case 'politica':
        return 'Ciencia Política';
      case 'artes_visuales':
        return 'Artes Visuales';
      case 'musica':
        return 'Música';
      case 'historia':
      default:
        return 'Historia';
    }
  }
}

class _EsqueletoCalendarioAtlassian extends StatelessWidget {
  const _EsqueletoCalendarioAtlassian({
    required this.careerId,
    required this.visibleMonth,
    required this.selectedDay,
    required this.onChooseCareer,
  });

  final String careerId;
  final DateTime visibleMonth;
  final DateTime selectedDay;
  final VoidCallback onChooseCareer;

  @override
  Widget build(BuildContext context) {
    final firstEvent = _EntradaCalendarioAtlassian.examen(
      EventoExamen(
        careerId: careerId,
        anio: 1,
        fecha: selectedDay,
        hora: '19:00',
        materia: 'Psicología Educacional',
        instancia: 'llamado_1',
        docentes: const ['Docente de la mesa'],
        actaUrl: null,
      ),
    );
    final secondEvent = _EntradaCalendarioAtlassian.examen(
      EventoExamen(
        careerId: careerId,
        anio: 2,
        fecha: selectedDay,
        hora: '19:00',
        materia: 'P.S.P.E. y C. del Feudalismo y la Modernidad',
        instancia: 'llamado_2',
        docentes: const ['Docente de la mesa'],
        actaUrl: null,
      ),
    );
    final markerDay = _dayKey(selectedDay);
    final eventsByDay = <DateTime, List<_EntradaCalendarioAtlassian>>{
      markerDay: <_EntradaCalendarioAtlassian>[firstEvent, secondEvent],
      markerDay.subtract(const Duration(days: 2)):
          <_EntradaCalendarioAtlassian>[firstEvent],
      markerDay.add(const Duration(days: 1)): <_EntradaCalendarioAtlassian>[
        secondEvent,
      ],
      markerDay.add(const Duration(days: 3)): <_EntradaCalendarioAtlassian>[
        firstEvent,
      ],
    };

    return Skeletonizer(
      enabled: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          120 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _SelectorCarreraCalendarioAtlassian(
            careerId: careerId,
            onChooseCareer: onChooseCareer,
          ),
          const SizedBox(height: 12),
          _ResumenCalendarioAtlassian(
            total: 51,
            upcoming: 18,
            next: firstEvent,
          ),
          const SizedBox(height: 12),
          PanelAtlassian(
            child: Column(
              children: [
                Row(
                  children: [
                    BotonIconoAtlassian(
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Mes anterior',
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Text(
                        _monthTitle(visibleMonth),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    BotonIconoAtlassian(
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Mes siguiente',
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _WeekdayHeaderAtlassian(),
                const SizedBox(height: 4),
                _MonthGridAtlassian(
                  month: visibleMonth,
                  selectedDay: selectedDay,
                  eventsByDay: eventsByDay,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SeparadorTituloAtlassian(
            title: _selectedDayTitle(selectedDay),
            subtitle: '2 eventos',
          ),
          const SizedBox(height: 8),
          PanelAtlassian(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _CalendarEventRowAtlassian(event: firstEvent, onTap: () {}),
                const Divider(height: 1),
                _CalendarEventRowAtlassian(event: secondEvent, onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
