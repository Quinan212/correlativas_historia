import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../modelos/evento_examen_administrador.dart';
import '../proveedores/proveedores_eventos_examen_administrador.dart';
import 'editor_evento_examen.dart';

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

class _BarraLateralEscritorio extends StatelessWidget {
  const _BarraLateralEscritorio({
    required this.selectedCareerId,
    required this.stats,
    required this.onCareerChanged,
  });

  final String selectedCareerId;
  final _EstadisticasEventosExamen stats;
  final ValueChanged<String> onCareerChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administración',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mesas y coloquios',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _ItemBarraLateral(
            label: 'Todas las carreras',
            detail:
                '${stats.totalMesas} mesas · ${stats.totalColoquios} coloquios',
            icon: Icons.dashboard_customize_rounded,
            selected: selectedCareerId == 'all',
            onTap: () => onCareerChanged('all'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'CARRERAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ..._adminCareers.map(
            (career) => _ItemBarraLateral(
              label: career.nombre,
              detail:
                  '${stats.mesasByCareer[career.id] ?? 0} mesas · ${stats.coloquiosByCareer[career.id] ?? 0} coloquios',
              icon: Icons.school_rounded,
              selected: selectedCareerId == career.id,
              onTap: () => onCareerChanged(career.id),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _NotaOperador(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _ItemBarraLateral extends StatelessWidget {
  const _ItemBarraLateral({
    required this.label,
    required this.detail,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? theme.colorScheme.primary : theme.hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w900 : FontWeight.w700,
                          color: selected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotaOperador extends StatelessWidget {
  const _NotaOperador({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vista pensada para preceptoría y dirección: filtrar, revisar y editar sin salir de la pantalla.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? null : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncabezadoEscritorio extends StatelessWidget {
  const _EncabezadoEscritorio({
    required this.scope,
    required this.selectedCareerName,
    required this.selectedYear,
    required this.searchCtrl,
    required this.busy,
    required this.stats,
    required this.visibleCount,
    required this.onScopeChanged,
    required this.onYearChanged,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onNew,
  });

  final String scope;
  final String selectedCareerName;
  final int? selectedYear;
  final TextEditingController searchCtrl;
  final bool busy;
  final _EstadisticasEventosExamen stats;
  final int visibleCount;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scopeLabel = scope == 'mesas' ? 'mesas' : 'coloquios';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de mesas y coloquios',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$selectedCareerName · $visibleCount $scopeLabel visibles',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: busy ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar',
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: busy ? null : onNew,
                icon: const Icon(Icons.add_rounded),
                label: Text(scope == 'mesas' ? 'Nueva mesa' : 'Nuevo coloquio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TabsAlcance(scope: scope, onChanged: onScopeChanged),
              const SizedBox(width: 12),
              _FiltroAnio(value: selectedYear, onChanged: onYearChanged),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoBusqueda(
                  controller: searchCtrl,
                  onChanged: onSearchChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _TarjetaMetrica(
                label: 'Mesas',
                value: stats.totalMesas.toString(),
                icon: Icons.event_available_outlined,
              ),
              const SizedBox(width: 10),
              _TarjetaMetrica(
                label: 'Coloquios',
                value: stats.totalColoquios.toString(),
                icon: Icons.forum_outlined,
              ),
              const SizedBox(width: 10),
              _TarjetaMetrica(
                label: 'Sin fecha',
                value: stats.withoutDate.toString(),
                icon: Icons.event_busy_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabsAlcance extends StatelessWidget {
  const _TabsAlcance({required this.scope, required this.onChanged});

  final String scope;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'mesas',
          icon: Icon(Icons.event_available_outlined),
          label: Text('Mesas'),
        ),
        ButtonSegment(
          value: 'coloquios',
          icon: Icon(Icons.forum_outlined),
          label: Text('Coloquios'),
        ),
      ],
      selected: {scope},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _FiltroAnio extends StatelessWidget {
  const _FiltroAnio({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<int?>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: 'Año',
          isDense: true,
        ),
        items: const [
          DropdownMenuItem<int?>(value: null, child: Text('Todos')),
          DropdownMenuItem<int?>(value: 1, child: Text('1er año')),
          DropdownMenuItem<int?>(value: 2, child: Text('2do año')),
          DropdownMenuItem<int?>(value: 3, child: Text('3er año')),
          DropdownMenuItem<int?>(value: 4, child: Text('4to año')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _CampoBusqueda extends StatelessWidget {
  const _CampoBusqueda({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        hintText: 'Buscar por materia, docente o carrera',
        isDense: true,
      ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaExamenesEscritorio extends StatefulWidget {
  const _ListaExamenesEscritorio({
    required this.events,
    required this.busy,
    required this.onEdit,
    required this.onCloseEditor,
    required this.onDelete,
    this.selectedEventId,
  });

  final List<EventoExamenAdministrador> events;
  final bool busy;
  final ValueChanged<EventoExamenAdministrador> onEdit;
  final VoidCallback onCloseEditor;
  final ValueChanged<EventoExamenAdministrador> onDelete;
  final String? selectedEventId;

  @override
  State<_ListaExamenesEscritorio> createState() =>
      _ListaExamenesEscritorioState();
}

class _ListaExamenesEscritorioState extends State<_ListaExamenesEscritorio> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  final Map<String, double> _widths = {
    'materia': 420,
    'carrera': 210,
    'anio': 86,
    'fecha': 118,
    'hora': 82,
    'docentes': 340,
    'acciones': 108,
  };

  late final List<_ColumnaRedimensionable> _columns = [
    _ColumnaRedimensionable(
      id: 'materia',
      label: 'Materia',
      minWidth: 240,
      maxWidth: 720,
    ),
    _ColumnaRedimensionable(
      id: 'carrera',
      label: 'Carrera',
      minWidth: 150,
      maxWidth: 320,
    ),
    _ColumnaRedimensionable(
      id: 'anio',
      label: 'Año',
      minWidth: 72,
      maxWidth: 130,
    ),
    _ColumnaRedimensionable(
      id: 'fecha',
      label: 'Fecha',
      minWidth: 96,
      maxWidth: 160,
    ),
    _ColumnaRedimensionable(
      id: 'hora',
      label: 'Hora',
      minWidth: 68,
      maxWidth: 120,
    ),
    _ColumnaRedimensionable(
      id: 'docentes',
      label: 'Docentes',
      minWidth: 230,
      maxWidth: 600,
    ),
    _ColumnaRedimensionable(
      id: 'acciones',
      label: '',
      minWidth: 104,
      maxWidth: 150,
    ),
  ];

  double get _contentWidth =>
      _columns.fold<double>(0, (sum, column) => sum + _widths[column.id]!);

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _resizeColumn(String id, double delta) {
    final column = _columns.firstWhere((item) => item.id == id);
    final current = _widths[id] ?? column.minWidth;
    final next = (current + delta).clamp(column.minWidth, column.maxWidth);
    if (next == current) return;
    setState(() => _widths[id] = next);
  }

  void _resetWidths() {
    setState(() {
      _widths
        ..['materia'] = 420
        ..['carrera'] = 210
        ..['anio'] = 86
        ..['fecha'] = 118
        ..['hora'] = 82
        ..['docentes'] = 340
        ..['acciones'] = 108;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const rowOuterPadding = 36.0;
        const rowInnerPadding = 20.0;
        const overflowGuard = 8.0;
        final tableWidth =
            _contentWidth + rowOuterPadding + rowInnerPadding + overflowGuard;

        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: tableWidth,
              child: Scrollbar(
                controller: _verticalController,
                thumbVisibility: true,
                child: ListView.separated(
                  controller: _verticalController,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  itemCount: widget.events.length + 1,
                  separatorBuilder: (_, index) => index == 0
                      ? const SizedBox(height: 8)
                      : Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _EncabezadoListaExamenes(
                        columns: _columns,
                        widths: _widths,
                        onResize: _resizeColumn,
                        onResetWidths: _resetWidths,
                      );
                    }
                    final event = widget.events[index - 1];
                    return _FilaListaExamenes(
                      event: event,
                      widths: _widths,
                      busy: widget.busy,
                      selected: widget.selectedEventId != null &&
                          event.id == widget.selectedEventId,
                      onEdit: () => widget.onEdit(event),
                      onCloseEditor: widget.onCloseEditor,
                      onDelete: () => widget.onDelete(event),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EncabezadoListaExamenes extends StatelessWidget {
  const _EncabezadoListaExamenes({
    required this.columns,
    required this.widths,
    required this.onResize,
    required this.onResetWidths,
  });

  final List<_ColumnaRedimensionable> columns;
  final Map<String, double> widths;
  final void Function(String id, double delta) onResize;
  final VoidCallback onResetWidths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final column in columns)
            _CeldaEncabezado(
              column: column,
              width: widths[column.id]!,
              theme: theme,
              onResize: (delta) => onResize(column.id, delta),
              onResetWidths: onResetWidths,
            ),
        ],
      ),
    );
  }
}

class _CeldaEncabezado extends StatelessWidget {
  const _CeldaEncabezado({
    required this.column,
    required this.width,
    required this.theme,
    required this.onResize,
    required this.onResetWidths,
  });

  final _ColumnaRedimensionable column;
  final double width;
  final ThemeData theme;
  final ValueChanged<double> onResize;
  final VoidCallback onResetWidths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 34,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              column.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Tooltip(
              message: 'Arrastrar para cambiar ancho. Doble click restaura.',
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: onResetWidths,
                  onHorizontalDragUpdate: (details) =>
                      onResize(details.delta.dx),
                  child: Container(
                    width: 10,
                    alignment: Alignment.center,
                    child: Container(
                      width: 1,
                      height: 18,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaListaExamenes extends StatelessWidget {
  const _FilaListaExamenes({
    required this.event,
    required this.widths,
    required this.busy,
    required this.selected,
    required this.onEdit,
    required this.onCloseEditor,
    required this.onDelete,
  });

  final EventoExamenAdministrador event;
  final Map<String, double> widths;
  final bool busy;
  final bool selected;
  final VoidCallback onEdit;
  final VoidCallback onCloseEditor;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : isDark
              ? const Color(0xFF0B1220)
              : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: busy ? null : onEdit,
        onDoubleTap: busy ? null : onCloseEditor,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.36)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.56),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: widths['materia'],
                child: _CeldaMateria(event: event),
              ),
              SizedBox(
                width: widths['carrera'],
                child: Text(
                  _etiquetaCarrera(event.careerId),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                  width: widths['anio'],
                  child: Text(_etiquetaAnio(event.anio))),
              SizedBox(
                width: widths['fecha'],
                child: Text(event.fecha == null
                    ? 'Sin fecha'
                    : _formatDate(event.fecha!)),
              ),
              SizedBox(width: widths['hora'], child: Text(event.hora ?? '-')),
              SizedBox(
                width: widths['docentes'],
                child: Text(
                  event.docentes.isEmpty
                      ? 'Sin docentes'
                      : event.docentes.join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: widths['acciones'],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: busy ? null : onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Eliminar',
                      color: theme.colorScheme.error,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: busy ? null : onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColumnaRedimensionable {
  const _ColumnaRedimensionable({
    required this.id,
    required this.label,
    required this.minWidth,
    required this.maxWidth,
  });

  final String id;
  final String label;
  final double minWidth;
  final double maxWidth;
}

class _CeldaMateria extends StatelessWidget {
  const _CeldaMateria({required this.event});

  final EventoExamenAdministrador event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          event.materia,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          event.isColoquio ? 'Coloquio' : _etiquetaInstancia(event.instancia),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PanelEditor extends StatelessWidget {
  const _PanelEditor({
    required this.busy,
    required this.scope,
    required this.editingEvent,
    required this.onClose,
    required this.onSave,
  });

  final bool busy;
  final String scope;
  final EventoExamenAdministrador? editingEvent;
  final VoidCallback onClose;
  final ValueChanged<BorradorEventoExamenAdministrador> onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 460,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: EditorEventoExamenAdministrador(
          key: ValueKey(
            editingEvent == null
                ? 'new-$scope'
                : 'edit-${editingEvent!.id ?? editingEvent!.materia}',
          ),
          title: editingEvent == null
              ? scope == 'mesas'
                  ? 'Nueva mesa'
                  : 'Nuevo coloquio'
              : editingEvent!.isColoquio
                  ? 'Editar coloquio'
                  : 'Editar mesa',
          coloquioMode: editingEvent?.isColoquio ?? scope == 'coloquios',
          initialEvent: editingEvent,
          busy: busy,
          onCancel: onClose,
          onSave: onSave,
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({
    required this.query,
    required this.scope,
    required this.careerName,
    required this.year,
    required this.onNew,
  });

  final String query;
  final String scope;
  final String careerName;
  final int? year;
  final VoidCallback? onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = scope == 'mesas' ? 'mesas' : 'coloquios';
    final yearText =
        year == null ? '' : ' de ${_etiquetaAnio(year).toLowerCase()}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isEmpty
                  ? Icons.event_note_outlined
                  : Icons.search_off_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              query.isEmpty
                  ? 'No hay $typeLabel$yearText en $careerName.'
                  : 'No se encontraron resultados para "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add_rounded),
              label: Text(scope == 'mesas' ? 'Cargar mesa' : 'Cargar coloquio'),
            ),
          ],
        ),
      ),
    );
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

List<dynamic> get _adminCareers => kCareers
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
