import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../models/admin_exam_event.dart';
import '../providers/admin_materias_provider.dart';

class AdminExamEventEditor extends ConsumerStatefulWidget {
  const AdminExamEventEditor({
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
  final AdminExamEvent? initialEvent;
  final Function(AdminExamEventDraft) onSave;
  final VoidCallback onCancel;
  final bool busy;

  @override
  ConsumerState<AdminExamEventEditor> createState() =>
      _AdminExamEventEditorState();
}

class _AdminExamEventEditorState extends ConsumerState<AdminExamEventEditor> {
  late final TextEditingController _docente1Ctrl;
  late final TextEditingController _docente2Ctrl;
  late final TextEditingController _docente3Ctrl;
  late final TextEditingController _docente4Ctrl;
  late final TextEditingController _actaUrlCtrl;
  late String _careerId;
  late String _instancia;
  int _anio = 1;
  String? _materiaSeleccionada;
  DateTime? _fecha;
  TimeOfDay? _hora;

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
    _careerId =
        event?.careerId.isNotEmpty == true ? event!.careerId : 'historia';
    _instancia = widget.coloquioMode
        ? 'coloquio'
        : (event?.instancia.isNotEmpty == true
            ? event!.instancia
            : 'llamado_1');
    _anio = event?.anio ?? 1;
    _materiaSeleccionada = event?.materia;
    _fecha = event?.fecha ?? DateTime.now();
    _hora = _parseHora(event?.hora) ?? const TimeOfDay(hour: 18, minute: 30);
  }

  @override
  void dispose() {
    _docente1Ctrl.dispose();
    _docente2Ctrl.dispose();
    _docente3Ctrl.dispose();
    _docente4Ctrl.dispose();
    _actaUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final careers = kCareers
        .where((career) =>
            career.id == 'historia' ||
            career.id == 'geografia' ||
            career.id == 'politica')
        .toList(growable: false);

    final materiasAsync = ref.watch(
      adminMateriasByYearProvider(
        (careerId: _careerId, year: _anio),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: widget.busy ? null : widget.onCancel,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _careerId,
          decoration: const InputDecoration(
            labelText: 'Carrera',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
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
        const SizedBox(height: 10),
        if (!widget.coloquioMode) ...[
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _instancia,
            decoration: const InputDecoration(
              labelText: 'Mesa',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
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
          const SizedBox(height: 10),
        ],
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: _anio,
          decoration: const InputDecoration(
            labelText: 'Año',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
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
              return const Text('No hay materias cargadas para este año.');
            }
            final effectiveValue =
                materias.contains(_materiaSeleccionada?.trim())
                    ? _materiaSeleccionada?.trim()
                    : null;

            return DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: effectiveValue,
              decoration: const InputDecoration(
                labelText: 'Materia',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: materias
                  .toSet()
                  .map((name) => DropdownMenuItem<String>(
                        value: name.trim(),
                        child: Text(name.trim()),
                      ))
                  .toList(growable: false),
              onChanged: widget.busy
                  ? null
                  : (value) =>
                      setState(() => _materiaSeleccionada = value?.trim()),
            );
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _docente1Ctrl,
          enabled: !widget.busy,
          decoration: const InputDecoration(
            labelText: 'Docente 1',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _docente2Ctrl,
          enabled: !widget.busy,
          decoration: const InputDecoration(
            labelText: 'Docente 2',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _docente3Ctrl,
          enabled: !widget.busy,
          decoration: const InputDecoration(
            labelText: 'Docente 3',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _docente4Ctrl,
          enabled: !widget.busy,
          decoration: const InputDecoration(
            labelText: 'Docente 4',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _actaUrlCtrl,
          enabled: !widget.busy,
          decoration: const InputDecoration(
            labelText: 'Acta URL',
            hintText: 'Link Drive',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        _PickRow(
          label: 'Fecha',
          value: _fecha == null ? 'Sin fecha' : _formatDate(_fecha!),
          onPressed: widget.busy ? null : _pickDate,
        ),
        const SizedBox(height: 8),
        _PickRow(
          label: 'Hora',
          value: _hora == null ? 'Sin hora' : _formatTime(_hora!),
          onPressed: widget.busy ? null : _pickTime,
        ),
        const SizedBox(height: 24),
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
              child: FilledButton(
                onPressed: widget.busy ? null : _handleSave,
                child: Text(widget.busy ? 'Guardando...' : 'Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2025, 1, 1),
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

  void _handleSave() {
    if (_materiaSeleccionada == null || _materiaSeleccionada!.isEmpty) return;
    if (_fecha == null || _hora == null) return;

    final docentes = [
      _docente1Ctrl.text.trim(),
      _docente2Ctrl.text.trim(),
      _docente3Ctrl.text.trim(),
      _docente4Ctrl.text.trim(),
    ].where((d) => d.isNotEmpty).toList();

    widget.onSave(
      AdminExamEventDraft(
        id: widget.initialEvent?.id,
        careerId: _careerId,
        anio: _anio,
        fecha: _fecha,
        hora: _hora,
        materia: _materiaSeleccionada!,
        instancia: widget.coloquioMode ? 'coloquio' : _instancia,
        docentes: docentes,
        actaUrl:
            _actaUrlCtrl.text.trim().isEmpty ? null : _actaUrlCtrl.text.trim(),
      ),
    );
  }

  String _formatDate(DateTime value) =>
      "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
  String _formatTime(TimeOfDay value) =>
      "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";

  TimeOfDay? _parseHora(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class _PickRow extends StatelessWidget {
  const _PickRow({required this.label, required this.value, this.onPressed});
  final String label;
  final String value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
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
