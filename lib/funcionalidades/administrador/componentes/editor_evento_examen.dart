import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../examenes/modelos/evento_examen.dart';
import '../modelos/evento_examen_administrador.dart';
import 'componentes_administrador_atlassian.dart';
import '../proveedores/proveedores_materias_administrador.dart';

class EditorEventoExamenAdministrador extends ConsumerStatefulWidget {
  const EditorEventoExamenAdministrador({
    super.key,
    required this.title,
    required this.coloquioMode,
    this.initialEvent,
    required this.onSave,
    required this.onCancel,
    this.busy = false,
  });

  final String title;
  final bool coloquioMode;
  final EventoExamenAdministrador? initialEvent;
  final ValueChanged<BorradorEventoExamenAdministrador> onSave;
  final VoidCallback onCancel;
  final bool busy;

  @override
  ConsumerState<EditorEventoExamenAdministrador> createState() =>
      _EditorEventoExamenAdministradorState();
}

class _EditorEventoExamenAdministradorState
    extends ConsumerState<EditorEventoExamenAdministrador> {
  late final TextEditingController _docente1Ctrl;
  late final TextEditingController _docente2Ctrl;
  late final TextEditingController _docente3Ctrl;
  late final TextEditingController _docente4Ctrl;
  late final TextEditingController _actaUrlCtrl;
  late final TextEditingController _tituloEstadoCtrl;
  late final TextEditingController _mensajeEstadoCtrl;
  late String _careerId;
  late String _instancia;
  late EstadoEventoExamen _estado;
  late bool _actaHabilitada;
  late bool _visible;
  int _anio = 1;
  String? _materiaSeleccionada;
  DateTime? _fecha;
  TimeOfDay? _hora;
  DateTime? _fechaReprogramada;
  TimeOfDay? _horaReprogramada;

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    _docente1Ctrl = TextEditingController(
      text: event != null && event.docentes.isNotEmpty ? event.docentes[0] : '',
    );
    _docente2Ctrl = TextEditingController(
      text: event != null && event.docentes.length > 1 ? event.docentes[1] : '',
    );
    _docente3Ctrl = TextEditingController(
      text: event != null && event.docentes.length > 2 ? event.docentes[2] : '',
    );
    _docente4Ctrl = TextEditingController(
      text: event != null && event.docentes.length > 3 ? event.docentes[3] : '',
    );
    _actaUrlCtrl = TextEditingController(text: event?.actaUrl ?? '');
    _tituloEstadoCtrl = TextEditingController(text: event?.tituloEstado ?? '');
    _mensajeEstadoCtrl = TextEditingController(
      text: event?.mensajeEstado ?? '',
    );
    _careerId = event?.careerId.isNotEmpty == true
        ? event!.careerId
        : 'historia';
    _instancia = widget.coloquioMode
        ? 'coloquio'
        : (event?.instancia.isNotEmpty == true
              ? event!.instancia
              : 'llamado_1');
    _anio = event?.anio ?? 1;
    _materiaSeleccionada = event?.materia;
    _fecha = event?.fecha ?? DateTime.now();
    _hora = _parseHora(event?.hora) ?? const TimeOfDay(hour: 18, minute: 30);
    _estado = event?.estado ?? EstadoEventoExamen.activa;
    _fechaReprogramada = event?.fechaReprogramada;
    _horaReprogramada = _parseHora(event?.horaReprogramada);
    _actaHabilitada = event?.actaHabilitada ?? true;
    _visible = event?.visible ?? true;
  }

  @override
  void dispose() {
    _docente1Ctrl.dispose();
    _docente2Ctrl.dispose();
    _docente3Ctrl.dispose();
    _docente4Ctrl.dispose();
    _actaUrlCtrl.dispose();
    _tituloEstadoCtrl.dispose();
    _mensajeEstadoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final careers = kCareers
        .where(
          (career) =>
              career.id == 'historia' ||
              career.id == 'geografia' ||
              career.id == 'politica',
        )
        .toList(growable: false);

    final materiasAsync = ref.watch(
      proveedorMateriasPorAnioAdministrador((careerId: _careerId, year: _anio)),
    );

    final statusTitle = _estado == EstadoEventoExamen.activa
        ? 'Mesa activa'
        : (_tituloEstadoCtrl.text.trim().isEmpty
              ? _estado.tituloPredeterminado
              : _tituloEstadoCtrl.text.trim());
    final statusMessage = _estado == EstadoEventoExamen.activa
        ? 'La mesa se muestra con su fecha y horario vigentes.'
        : (_mensajeEstadoCtrl.text.trim().isEmpty
              ? _estado.mensajePredeterminado
              : _mensajeEstadoCtrl.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(widget.title, style: theme.textTheme.titleLarge),
            ),
            IconButton(
              onPressed: widget.busy ? null : widget.onCancel,
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cerrar',
            ),
          ],
        ),
        const SizedBox(height: 16),
        PanelAdministradorAtlassian(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datos de la mesa', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _careerId,
                decoration: _inputDecoration('Carrera'),
                items: careers
                    .map(
                      (career) => DropdownMenuItem<String>(
                        value: career.id,
                        child: Text(career.nombre),
                      ),
                    )
                    .toList(growable: false),
                onChanged: widget.busy
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _careerId = value;
                          _materiaSeleccionada = null;
                        });
                      },
              ),
              if (!widget.coloquioMode) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _instancia,
                  decoration: _inputDecoration('Mesa'),
                  items: const [
                    DropdownMenuItem(
                      value: 'llamado_1',
                      child: Text('Mesa extraordinaria'),
                    ),
                    DropdownMenuItem(
                      value: 'llamado_2',
                      child: Text('Segundo llamado'),
                    ),
                  ],
                  onChanged: widget.busy
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _instancia = value);
                        },
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _anio,
                decoration: _inputDecoration('Año'),
                items: const [
                  DropdownMenuItem<int>(value: 1, child: Text('1er año')),
                  DropdownMenuItem<int>(value: 2, child: Text('2do año')),
                  DropdownMenuItem<int>(value: 3, child: Text('3er año')),
                  DropdownMenuItem<int>(value: 4, child: Text('4to año')),
                ],
                onChanged: widget.busy
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _anio = value;
                          _materiaSeleccionada = null;
                        });
                      },
              ),
              const SizedBox(height: 10),
              materiasAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 3),
                error: (error, _) => Text('Error: $error'),
                data: (materias) {
                  if (materias.isEmpty) {
                    return const Text(
                      'No hay materias cargadas para este año.',
                    );
                  }
                  final effectiveValue =
                      materias.contains(_materiaSeleccionada?.trim())
                      ? _materiaSeleccionada?.trim()
                      : null;

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: effectiveValue,
                    decoration: _inputDecoration('Materia'),
                    items: materias
                        .toSet()
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name.trim(),
                            child: Text(name.trim()),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: widget.busy
                        ? null
                        : (value) => setState(
                            () => _materiaSeleccionada = value?.trim(),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PanelAdministradorAtlassian(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Docentes y acta', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _docente1Ctrl,
                enabled: !widget.busy,
                decoration: _inputDecoration('Docente 1', vertical: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _docente2Ctrl,
                enabled: !widget.busy,
                decoration: _inputDecoration('Docente 2', vertical: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _docente3Ctrl,
                enabled: !widget.busy,
                decoration: _inputDecoration('Docente 3', vertical: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _docente4Ctrl,
                enabled: !widget.busy,
                decoration: _inputDecoration('Docente 4', vertical: 10),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _actaUrlCtrl,
                enabled: !widget.busy,
                decoration: _inputDecoration(
                  'Acta URL',
                  hintText: 'Link Drive',
                  vertical: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PanelAdministradorAtlassian(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha y horario', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _FilaSeleccion(
                label: 'Fecha original',
                value: _fecha == null ? 'Sin fecha' : _formatDate(_fecha!),
                onPressed: widget.busy ? null : _pickDate,
              ),
              const SizedBox(height: 8),
              _FilaSeleccion(
                label: 'Hora original',
                value: _hora == null ? 'Sin hora' : _formatTime(_hora!),
                onPressed: widget.busy ? null : _pickTime,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PanelAdministradorAtlassian(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado público', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<EstadoEventoExamen>(
                isExpanded: true,
                initialValue: _estado,
                decoration: _inputDecoration('Estado'),
                items: EstadoEventoExamen.values
                    .map(
                      (estado) => DropdownMenuItem<EstadoEventoExamen>(
                        value: estado,
                        child: Text(_labelEstado(estado)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: widget.busy ? null : _changeStatus,
              ),
              if (_estado != EstadoEventoExamen.activa) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _tituloEstadoCtrl,
                  enabled: !widget.busy,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                    'Título del aviso',
                    hintText: _estado.tituloPredeterminado,
                    vertical: 10,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _mensajeEstadoCtrl,
                  enabled: !widget.busy,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                    'Mensaje público',
                    hintText: _estado.mensajePredeterminado,
                    vertical: 12,
                  ),
                ),
              ],
              if (_estado == EstadoEventoExamen.reprogramada) ...[
                const SizedBox(height: 10),
                _FilaSeleccion(
                  label: 'Nueva fecha',
                  value: _fechaReprogramada == null
                      ? 'Sin fecha'
                      : _formatDate(_fechaReprogramada!),
                  onPressed: widget.busy ? null : _pickRescheduledDate,
                ),
                const SizedBox(height: 8),
                _FilaSeleccion(
                  label: 'Nueva hora',
                  value: _horaReprogramada == null
                      ? 'Sin hora'
                      : _formatTime(_horaReprogramada!),
                  onPressed: widget.busy ? null : _pickRescheduledTime,
                ),
              ],
              const SizedBox(height: 12),
              AvisoAdministradorAtlassian(
                icon: _iconoEstado(_estado),
                title: statusTitle,
                message: statusMessage,
                level: _nivelEstado(_estado),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PanelAdministradorAtlassian(
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Permitir abrir acta'),
                value: _actaHabilitada,
                onChanged: widget.busy
                    ? null
                    : (value) => setState(() => _actaHabilitada = value),
              ),
              Divider(color: theme.colorScheme.outlineVariant),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible en la app'),
                value: _visible,
                onChanged: widget.busy
                    ? null
                    : (value) => setState(() => _visible = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.busy ? null : widget.onCancel,
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.busy ? null : _handleSave,
                icon: widget.busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(widget.busy ? 'Guardando...' : 'Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  NivelAvisoAdministrador _nivelEstado(EstadoEventoExamen value) {
    return switch (value) {
      EstadoEventoExamen.activa => NivelAvisoAdministrador.success,
      EstadoEventoExamen.suspendida => NivelAvisoAdministrador.warning,
      EstadoEventoExamen.cancelada => NivelAvisoAdministrador.danger,
      EstadoEventoExamen.reprogramada => NivelAvisoAdministrador.discovery,
    };
  }

  IconData _iconoEstado(EstadoEventoExamen value) {
    return switch (value) {
      EstadoEventoExamen.activa => Icons.check_circle_outline_rounded,
      EstadoEventoExamen.suspendida => Icons.warning_amber_rounded,
      EstadoEventoExamen.cancelada => Icons.cancel_outlined,
      EstadoEventoExamen.reprogramada => Icons.event_repeat_rounded,
    };
  }

  InputDecoration _inputDecoration(
    String label, {
    String? hintText,
    double vertical = 8,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vertical),
    );
  }

  void _changeStatus(EstadoEventoExamen? next) {
    if (next == null) return;
    final previous = _estado;
    final currentTitle = _tituloEstadoCtrl.text.trim();
    final currentMessage = _mensajeEstadoCtrl.text.trim();
    setState(() {
      _estado = next;
      if (next == EstadoEventoExamen.activa) {
        _actaHabilitada = true;
        return;
      }
      if (currentTitle.isEmpty ||
          currentTitle == previous.tituloPredeterminado) {
        _tituloEstadoCtrl.text = next.tituloPredeterminado;
      }
      if (currentMessage.isEmpty ||
          currentMessage == previous.mensajePredeterminado) {
        _mensajeEstadoCtrl.text = next.mensajePredeterminado;
      }
      _actaHabilitada = next == EstadoEventoExamen.reprogramada;
      if (next == EstadoEventoExamen.reprogramada) {
        _fechaReprogramada ??= _fecha;
        _horaReprogramada ??= _hora;
      }
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035, 12, 31),
    );
    if (selected != null) setState(() => _fecha = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 18, minute: 30),
    );
    if (selected != null) setState(() => _hora = selected);
  }

  Future<void> _pickRescheduledDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fechaReprogramada ?? _fecha ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035, 12, 31),
    );
    if (selected != null) setState(() => _fechaReprogramada = selected);
  }

  Future<void> _pickRescheduledTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
          _horaReprogramada ?? _hora ?? const TimeOfDay(hour: 18, minute: 30),
    );
    if (selected != null) setState(() => _horaReprogramada = selected);
  }

  void _handleSave() {
    if (_materiaSeleccionada == null || _materiaSeleccionada!.isEmpty) {
      _showValidation('Seleccioná una materia.');
      return;
    }
    if (_fecha == null || _hora == null) {
      _showValidation('Seleccioná la fecha y la hora originales.');
      return;
    }
    if (_estado == EstadoEventoExamen.reprogramada &&
        (_fechaReprogramada == null || _horaReprogramada == null)) {
      _showValidation('Seleccioná la nueva fecha y la nueva hora.');
      return;
    }

    final docentes = [
      _docente1Ctrl.text.trim(),
      _docente2Ctrl.text.trim(),
      _docente3Ctrl.text.trim(),
      _docente4Ctrl.text.trim(),
    ].where((d) => d.isNotEmpty).toList(growable: false);

    final hasPublicStatus = _estado != EstadoEventoExamen.activa;
    final title = _tituloEstadoCtrl.text.trim();
    final message = _mensajeEstadoCtrl.text.trim();

    widget.onSave(
      BorradorEventoExamenAdministrador(
        id: widget.initialEvent?.id,
        careerId: _careerId,
        anio: _anio,
        fecha: _fecha,
        hora: _hora,
        materia: _materiaSeleccionada!,
        instancia: widget.coloquioMode ? 'coloquio' : _instancia,
        docentes: docentes,
        actaUrl: _actaUrlCtrl.text.trim().isEmpty
            ? null
            : _actaUrlCtrl.text.trim(),
        estado: _estado,
        tituloEstado: hasPublicStatus
            ? (title.isEmpty ? _estado.tituloPredeterminado : title)
            : null,
        mensajeEstado: hasPublicStatus
            ? (message.isEmpty ? _estado.mensajePredeterminado : message)
            : null,
        fechaReprogramada: _estado == EstadoEventoExamen.reprogramada
            ? _fechaReprogramada
            : null,
        horaReprogramada: _estado == EstadoEventoExamen.reprogramada
            ? _horaReprogramada
            : null,
        actaHabilitada: _actaHabilitada,
        visible: _visible,
        updatedAt: widget.initialEvent?.updatedAt,
      ),
    );
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _labelEstado(EstadoEventoExamen value) => switch (value) {
    EstadoEventoExamen.activa => 'Activa',
    EstadoEventoExamen.suspendida => 'Suspendida',
    EstadoEventoExamen.cancelada => 'Cancelada',
    EstadoEventoExamen.reprogramada => 'Reprogramada',
  };

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseHora(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class _FilaSeleccion extends StatelessWidget {
  const _FilaSeleccion({
    required this.label,
    required this.value,
    this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          OutlinedButton(onPressed: onPressed, child: const Text('Elegir')),
        ],
      ),
    );
  }
}
