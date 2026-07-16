import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../modelos/evento_examen_administrador.dart';
import '../proveedores/proveedores_eventos_examen_administrador.dart';
import 'editor_evento_examen.dart';

part 'src/eventos_examen_administrador_escritorio/barra_lateral_escritorio.dart';
part 'src/eventos_examen_administrador_escritorio/encabezado_escritorio.dart';
part 'src/eventos_examen_administrador_escritorio/lista_examenes_escritorio.dart';
part 'src/eventos_examen_administrador_escritorio/panel_editor_escritorio.dart';

class EventosExamenAdministradorEscritorio extends ConsumerStatefulWidget {
  const EventosExamenAdministradorEscritorio({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<EventosExamenAdministradorEscritorio> createState() =>
      _EventosExamenAdministradorEscritorioState();
}

class _EventosExamenAdministradorEscritorioState
    extends ConsumerState<EventosExamenAdministradorEscritorio> {
  String _selectedCareerId = 'all';
  String _scope = 'mesas';
  int? _selectedYear;
  String _searchQuery = '';
  bool _busy = false;

  EventoExamenAdministrador? _editingEvent;
  bool _showEditor = false;

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final eventsAsync = ref.watch(proveedorEventosExamenAdministrador);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('No se pudieron cargar mesas y coloquios: $error'),
      ),
      data: (items) {
        final visible = _applyFilters(items);
        final stats = _EstadisticasEventosExamen.from(items);

        return Row(
          children: [
            _BarraLateralEscritorio(
              selectedCareerId: _selectedCareerId,
              stats: stats,
              onCareerChanged: (value) => setState(() {
                _selectedCareerId = value;
                _selectedYear = null;
              }),
            ),
            Expanded(
              child: Container(
                color:
                    isDark ? const Color(0xFF070C15) : const Color(0xFFF5F7FA),
                child: Column(
                  children: [
                    _EncabezadoEscritorio(
                      scope: _scope,
                      selectedCareerName: _etiquetaCarrera(_selectedCareerId),
                      selectedYear: _selectedYear,
                      searchCtrl: _searchCtrl,
                      busy: _busy,
                      stats: stats,
                      visibleCount: visible.length,
                      onScopeChanged: (value) => setState(() {
                        _scope = value;
                        if (_editingEvent == null) _showEditor = false;
                      }),
                      onYearChanged: (value) =>
                          setState(() => _selectedYear = value),
                      onSearchChanged: (value) =>
                          setState(() => _searchQuery = value),
                      onRefresh: () =>
                          ref.invalidate(proveedorEventosExamenAdministrador),
                      onNew: () => setState(() {
                        _editingEvent = null;
                        _showEditor = true;
                      }),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? _EstadoVacio(
                              query: _searchQuery,
                              scope: _scope,
                              careerName: _etiquetaCarrera(_selectedCareerId),
                              year: _selectedYear,
                              onNew: _busy
                                  ? null
                                  : () => setState(() {
                                        _editingEvent = null;
                                        _showEditor = true;
                                      }),
                            )
                          : _ListaExamenesEscritorio(
                              events: visible,
                              busy: _busy,
                              selectedEventId: _editingEvent?.id,
                              onEdit: (event) => setState(() {
                                _editingEvent = event;
                                _showEditor = true;
                              }),
                              onCloseEditor: () => setState(() {
                                _editingEvent = null;
                                _showEditor = false;
                              }),
                              onDelete: (event) => _deleteEvent(context, event),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showEditor)
              _PanelEditor(
                busy: _busy,
                scope: _scope,
                editingEvent: _editingEvent,
                onClose: () => setState(() => _showEditor = false),
                onSave: _handleSave,
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave(BorradorEventoExamenAdministrador draft) async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay conexión con Supabase.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioEventosExamenAdministrador);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(proveedorEventosExamenAdministrador);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _showEditor = false;
        _editingEvent = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            draft.instancia == 'coloquio'
                ? 'Coloquio guardado.'
                : 'Mesa guardada.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    }
  }

  List<EventoExamenAdministrador> _applyFilters(
      List<EventoExamenAdministrador> items) {
    return items.where((event) {
      final passesScope =
          _scope == 'mesas' ? !event.isColoquio : event.isColoquio;
      if (!passesScope) return false;

      if (_selectedCareerId != 'all' && event.careerId != _selectedCareerId) {
        return false;
      }

      if (_selectedYear != null && event.anio != _selectedYear) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final inMateria = event.materia.toLowerCase().contains(query);
        final inDocentes = event.docentes
            .any((docente) => docente.toLowerCase().contains(query));
        final inCareer =
            _etiquetaCarrera(event.careerId).toLowerCase().contains(query);
        if (!inMateria && !inDocentes && !inCareer) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final dateComp = _dateSortValue(a).compareTo(_dateSortValue(b));
        if (dateComp != 0) return dateComp;
        final yearComp = (a.anio ?? 99).compareTo(b.anio ?? 99);
        if (yearComp != 0) return yearComp;
        return a.materia.compareTo(b.materia);
      });
  }

  int _dateSortValue(EventoExamenAdministrador event) {
    final date = event.fecha;
    if (date == null) return 99999999;
    return date.year * 10000 + date.month * 100 + date.day;
  }

  Future<void> _deleteEvent(
      BuildContext context, EventoExamenAdministrador event) async {
    final typeLabel = event.isColoquio ? 'coloquio' : 'mesa';
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Eliminar $typeLabel'),
            content: Text(
              'Vas a eliminar "${event.materia}". Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null || event.id == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioEventosExamenAdministrador);
      await repo.delete(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        id: event.id!,
      );
      ref.invalidate(proveedorEventosExamenAdministrador);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_capitalize(typeLabel)} eliminado.')),
      );
      if (mounted && _editingEvent?.id == event.id) {
        setState(() {
          _editingEvent = null;
          _showEditor = false;
        });
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _EstadisticasEventosExamen {
  const _EstadisticasEventosExamen({
    required this.totalMesas,
    required this.totalColoquios,
    required this.withoutDate,
    required this.mesasByCareer,
    required this.coloquiosByCareer,
  });

  final int totalMesas;
  final int totalColoquios;
  final int withoutDate;
  final Map<String, int> mesasByCareer;
  final Map<String, int> coloquiosByCareer;

  factory _EstadisticasEventosExamen.from(
      List<EventoExamenAdministrador> items) {
    var totalMesas = 0;
    var totalColoquios = 0;
    var withoutDate = 0;
    final mesasByCareer = <String, int>{};
    final coloquiosByCareer = <String, int>{};

    for (final event in items) {
      if (event.fecha == null) withoutDate++;
      if (event.isColoquio) {
        totalColoquios++;
        coloquiosByCareer.update(event.careerId, (value) => value + 1,
            ifAbsent: () => 1);
      } else {
        totalMesas++;
        mesasByCareer.update(event.careerId, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }

    return _EstadisticasEventosExamen(
      totalMesas: totalMesas,
      totalColoquios: totalColoquios,
      withoutDate: withoutDate,
      mesasByCareer: mesasByCareer,
      coloquiosByCareer: coloquiosByCareer,
    );
  }
}

  List<CareerInfo> get _adminCareers => kCareers
    .where(
      (career) =>
          career.id == 'historia' ||
          career.id == 'geografia' ||
          career.id == 'politica',
    )
    .toList(growable: false);

String _etiquetaCarrera(String careerId) {
  if (careerId == 'all') return 'Todas las carreras';
  for (final career in kCareers) {
    if (career.id == careerId) return career.nombre;
  }
  return careerId;
}

String _etiquetaAnio(int? year) {
  return switch (year ?? 1) {
    1 => '1er año',
    2 => '2do año',
    3 => '3er año',
    4 => '4to año',
    _ => '1er año',
  };
}

String _etiquetaInstancia(String instancia) {
  return switch (instancia) {
    'llamado_1' => 'Mesa extraordinaria',
    'llamado_2' => 'Segundo llamado',
    _ => instancia,
  };
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
