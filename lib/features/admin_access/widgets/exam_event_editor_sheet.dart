import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../models/admin_exam_event.dart';
import '../providers/admin_materias_provider.dart';

Future<AdminExamEventDraft?> showExamEventEditorSheet({
  required BuildContext context,
  required String title,
  required bool coloquioMode,
  AdminExamEvent? initialEvent,
}) {
  return showModalBottomSheet<AdminExamEventDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ExamEventEditorSheet(
      title: title,
      coloquioMode: coloquioMode,
      initialEvent: initialEvent,
    ),
  );
}

class _ExamEventEditorSheet extends ConsumerStatefulWidget {
  const _ExamEventEditorSheet({
    required this.title,
    required this.coloquioMode,
    this.initialEvent,
  });

  final String title;
  final bool coloquioMode;
  final AdminExamEvent? initialEvent;

  @override
  ConsumerState<_ExamEventEditorSheet> createState() =>
      _ExamEventEditorSheetState();
}

class _ExamEventEditorSheetState extends ConsumerState<_ExamEventEditorSheet> {
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
  bool _saving = false;

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
    _careerId = event?.careerId.isNotEmpty == true
        ? event!.careerId
        : _defaultCareerId();
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
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;
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

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.62,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          bottom: true,
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + bottomInset),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _careerId,
                  decoration: const InputDecoration(labelText: 'Carrera'),
                  items: careers
                      .map(
                        (career) => DropdownMenuItem<String>(
                          value: career.id,
                          child: Text(career.nombre),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _careerId = value;
                            _materiaSeleccionada = null;
                          });
                        },
                ),
                const SizedBox(height: 14),
                if (!widget.coloquioMode) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _instancia,
                    decoration: const InputDecoration(labelText: 'Mesa'),
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
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _instancia = value);
                          },
                  ),
                  const SizedBox(height: 14),
                ],
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _anio,
                  decoration: const InputDecoration(labelText: 'Año'),
                  items: const [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('1er año'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('2do año'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('3er año'),
                    ),
                    DropdownMenuItem<int>(
                      value: 4,
                      child: Text('4to año'),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _anio = value;
                            _materiaSeleccionada = null;
                          });
                        },
                ),
                const SizedBox(height: 14),
                // Selector de materia por año
                materiasAsync.when(
                  loading: () => const LinearProgressIndicator(minHeight: 3),
                  error: (error, _) => Text(
                    'Error cargando materias: $error',
                    style: theme.textTheme.bodySmall,
                  ),
                  data: (materias) {
                    if (materias.isEmpty) {
                      return Text(
                        'No hay materias cargadas para $_anio° año de esta carrera.',
                        style: theme.textTheme.bodyMedium,
                      );
                    }

                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _materiaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                      ),
                      items: materias
                          .map(
                            (name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _saving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _materiaSeleccionada = value);
                            },
                    );
                  },
                ),
                const SizedBox(height: 14),
                // 4 campos de docentes
                TextField(
                  controller: _docente1Ctrl,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Docente 1 (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _docente2Ctrl,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Docente 2 (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _docente3Ctrl,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Docente 3 (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _docente4Ctrl,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Docente 4 (opcional)',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _actaUrlCtrl,
                  enabled: !_saving,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Acta URL',
                    hintText: 'Link de Google Docs o Google Drive',
                  ),
                ),
                const SizedBox(height: 14),
                _PickRow(
                  label: 'Fecha',
                  value: _fecha == null ? 'Sin fecha' : _formatDate(_fecha!),
                  onPressed: _saving ? null : _pickDate,
                ),
                const SizedBox(height: 10),
                _PickRow(
                  label: 'Hora',
                  value: _hora == null ? 'Sin hora' : _formatTime(_hora!),
                  onPressed: _saving ? null : _pickTime,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Guardando...' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );
    if (selected == null || !mounted) return;
    setState(() => _fecha = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 18, minute: 30),
    );
    if (selected == null || !mounted) return;
    setState(() => _hora = selected);
  }

  void _save() {
    if (_materiaSeleccionada == null || _materiaSeleccionada!.isEmpty) return;

    final docentes = <String>[
      _docente1Ctrl.text.trim(),
      _docente2Ctrl.text.trim(),
      _docente3Ctrl.text.trim(),
      _docente4Ctrl.text.trim(),
    ].where((d) => d.isNotEmpty).toList(growable: false);

    if (_fecha == null || _hora == null) return;

    setState(() => _saving = true);
    Navigator.of(context).pop(
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

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    return '$d/$m/$y';
  }

  String _formatTime(TimeOfDay value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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

  String _defaultCareerId() {
    return 'historia';
  }
}

class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
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
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onPressed,
            child: const Text('Elegir'),
          ),
        ],
      ),
    );
  }
}
