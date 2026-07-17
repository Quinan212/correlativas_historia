import 'dart:async';

import 'package:flutter/material.dart';

import '../../examenes/datos/repositorio_examenes.dart';
import '../../examenes/modelos/evento_examen.dart';
import '../componentes/componentes_atlassian.dart';
import '../tema/tema_atlassian.dart';
import 'pantalla_examenes_atlassian.dart';
import 'utilidades_atlassian.dart';

class PantallaCalendarioAtlassian extends StatefulWidget {
  const PantallaCalendarioAtlassian({
    super.key,
    required this.careerId,
    this.initialDate,
  });

  final String careerId;
  final DateTime? initialDate;

  @override
  State<PantallaCalendarioAtlassian> createState() =>
      _PantallaCalendarioAtlassianState();
}

class _PantallaCalendarioAtlassianState
    extends State<PantallaCalendarioAtlassian> {
  static const _repository = RepositorioExamenes();
  late Future<List<EventoExamen>> _future;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    _visibleMonth = DateTime(base.year, base.month);
    _selectedDay = DateTime(base.year, base.month, base.day);
    _future = _load();
  }

  Future<List<EventoExamen>> _load() async {
    final data = await Future.wait<List<EventoExamen>>([
      _repository.loadLlamado1(),
      _repository.loadLlamado2(),
      _repository.loadColoquios(),
    ]);
    final events = <EventoExamen>[
      ...data[0],
      ...data[1],
      ...data[2],
    ].where((item) => item.careerId == widget.careerId).toList();
    events.sort((first, second) {
      final firstDate = first.fechaHora;
      final secondDate = second.fechaHora;
      if (firstDate == null && secondDate == null) {
        return first.materia.compareTo(second.materia);
      }
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;
      return firstDate.compareTo(secondDate);
    });
    return List<EventoExamen>.unmodifiable(events);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          EncabezadoPaginaAtlassian(
            title: 'Calendario',
            subtitle: 'Mesas, coloquios y fechas publicadas',
            leading: BotonIconoAtlassian(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              BotonIconoAtlassian(
                icon: Icons.today_outlined,
                tooltip: 'Ir a hoy',
                onPressed: _goToday,
              ),
              BotonIconoAtlassian(
                icon: Icons.refresh_rounded,
                tooltip: 'Actualizar',
                onPressed: () => unawaited(_refresh()),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<EventoExamen>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return EstadoVacioAtlassian(
                    icon: Icons.error_outline_rounded,
                    title: 'No se pudo cargar el calendario',
                    message: snapshot.error.toString(),
                    action: BotonAtlassian(
                      label: 'Reintentar',
                      icon: Icons.refresh_rounded,
                      primary: true,
                      onPressed: () => unawaited(_refresh()),
                    ),
                  );
                }

                final events = snapshot.data ?? const <EventoExamen>[];
                final datedEvents = events
                    .where((item) => item.fecha != null)
                    .toList(growable: false);
                final byDay = <DateTime, List<EventoExamen>>{};
                for (final event in datedEvents) {
                  final key = _dayKey(event.fecha!);
                  byDay.putIfAbsent(key, () => <EventoExamen>[]).add(event);
                }
                final selectedEvents =
                    byDay[_dayKey(_selectedDay)] ?? const <EventoExamen>[];
                final upcoming = datedEvents
                    .where((event) {
                      final date = event.fecha!;
                      final today = _dayKey(DateTime.now());
                      return !_dayKey(date).isBefore(today);
                    })
                    .toList(growable: false);

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _ResumenCalendarioAtlassian(
                        total: events.length,
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
                              onSelected: (day) {
                                setState(() => _selectedDay = day);
                              },
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
                              'No hay mesas ni coloquios publicados para esta fecha.',
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
                                  onTap: () {
                                    Navigator.of(context).push<void>(
                                      rutaAtlassian<void>(
                                        builder: (_) =>
                                            PantallaDetalleExamenAtlassian(
                                              event: selectedEvents[index],
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                if (index != selectedEvents.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                      if (events.isEmpty) ...[
                        const SizedBox(height: 16),
                        const MensajeSeccionAtlassian(
                          title: 'Sin fechas publicadas',
                          message:
                              'Todavía no hay eventos disponibles para esta carrera.',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ],
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
  final EventoExamen? next;

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
                      nextEvent.materia,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatoFechaHoraAtlassian(
                        nextEvent.fecha,
                        nextEvent.hora,
                      ),
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
  final Map<DateTime, List<EventoExamen>> eventsByDay;
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

  final EventoExamen event;
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
                event.instancia == 'coloquio'
                    ? Icons.groups_2_outlined
                    : Icons.event_note_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.materia,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatoFechaHoraAtlassian(event.fecha, event.hora),
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
