part of '../../eventos_examen_administrador_escritorio.dart';

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
