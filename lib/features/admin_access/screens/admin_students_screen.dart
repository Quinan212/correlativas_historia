import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/admin_student.dart';
import '../models/admin_student_history_entry.dart';
import '../models/admin_subject_roster_item.dart';
import '../models/admin_student_subject.dart';
import '../providers/admin_students_providers.dart';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<AdminStudentsScreen> createState() =>
      _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  static const double _desktopPaneDividerWidth = 12;
  static const double _minLeftPaneWidth = 340;
  static const double _minMiddlePaneWidth = 420;
  static const double _minRightPaneWidth = 420;

  final _dniCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _cohortCtrl =
      TextEditingController(text: DateTime.now().year.toString());
  final _divisionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _bulkCtrl = TextEditingController();

  String _careerId = 'artes_visuales';
  int? _currentYear = 1;
  bool _isNewStudent = true;
  bool _isRepeating = false;
  bool _busy = false;
  AdminStudent? _selectedStudent;
  double _leftPaneWidth = 430;
  double _middlePaneWidth = 620;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _cohortCtrl.dispose();
    _divisionCtrl.dispose();
    _notesCtrl.dispose();
    _bulkCtrl.dispose();
    super.dispose();
  }

  void _syncDesktopPaneWidths(double maxWidth) {
    final availableWidth = maxWidth - (_desktopPaneDividerWidth * 2);
    final maxLeft =
        availableWidth - _minMiddlePaneWidth - _minRightPaneWidth;
    final maxMiddle =
        availableWidth - _minLeftPaneWidth - _minRightPaneWidth;
    if (maxLeft <= _minLeftPaneWidth || maxMiddle <= _minMiddlePaneWidth) {
      _leftPaneWidth = _minLeftPaneWidth;
      _middlePaneWidth = _minMiddlePaneWidth;
      return;
    }
    _leftPaneWidth =
        _leftPaneWidth.clamp(_minLeftPaneWidth, maxLeft).toDouble();
    _middlePaneWidth =
        _middlePaneWidth.clamp(_minMiddlePaneWidth, maxMiddle).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final studentsAsync =
        ref.watch(adminStudentsProvider(widget.adminDeviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumnos y trayectorias'),
        actions: [
          IconButton(
            onPressed: _busy
                ? null
                : () =>
                    ref.invalidate(adminStudentsProvider(widget.adminDeviceId)),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!isDesktop) {
              return Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                      children: [
                        Text(
                          'Carga administrativa',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Primer módulo del sistema académico: crear usuarios alumnos por DNI para Artes Visuales y Música.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _CareerSelector(
                          value: _careerId,
                          onChanged: _busy
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _careerId = value;
                                    if (value == 'artes_visuales') {
                                      _divisionCtrl.text = 'A';
                                    }
                                  });
                                  ref
                                      .read(
                                          adminStudentsCareerFilterProvider
                                              .notifier)
                                      .state = value;
                                },
                        ),
                        const SizedBox(height: 12),
                  _StudentFormCard(
                    busy: _busy,
                    careerId: _careerId,
                    dniCtrl: _dniCtrl,
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                          cohortCtrl: _cohortCtrl,
                          divisionCtrl: _divisionCtrl,
                          notesCtrl: _notesCtrl,
                          currentYear: _currentYear,
                          isNewStudent: _isNewStudent,
                          isRepeating: _isRepeating,
                          onYearChanged: (value) =>
                              setState(() => _currentYear = value),
                          onNewChanged: (value) =>
                              setState(() => _isNewStudent = value),
                          onRepeatingChanged: (value) =>
                              setState(() => _isRepeating = value),
                          onSave: _saveSingle,
                        ),
                        const SizedBox(height: 12),
                        _BulkLoadCard(
                          busy: _busy,
                          controller: _bulkCtrl,
                          onLoad: _saveBulk,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            _syncDesktopPaneWidths(constraints.maxWidth);
            final leftWidth = _leftPaneWidth;
            final middleWidth = _middlePaneWidth;
            final availableWidth = constraints.maxWidth -
                (_desktopPaneDividerWidth * 2);
            final rightWidth = availableWidth - leftWidth - middleWidth;
            final remainingWidth =
                availableWidth - leftWidth - _desktopPaneDividerWidth;

            return Row(
              children: [
                SizedBox(
                  width: leftWidth,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                    children: [
                      Text(
                        'Carga administrativa',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Primer módulo del sistema académico: crear usuarios alumnos por DNI para Artes Visuales y Música.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                        _CareerSelector(
                          value: _careerId,
                          onChanged: _busy
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _careerId = value;
                                    if (value == 'artes_visuales') {
                                      _divisionCtrl.text = 'A';
                                    }
                                  });
                                  ref
                                      .read(
                                          adminStudentsCareerFilterProvider
                                              .notifier)
                                    .state = value;
                              },
                      ),
                      const SizedBox(height: 12),
                      _StudentFormCard(
                        busy: _busy,
                        careerId: _careerId,
                        dniCtrl: _dniCtrl,
                        firstNameCtrl: _firstNameCtrl,
                        lastNameCtrl: _lastNameCtrl,
                        cohortCtrl: _cohortCtrl,
                        divisionCtrl: _divisionCtrl,
                        notesCtrl: _notesCtrl,
                        currentYear: _currentYear,
                        isNewStudent: _isNewStudent,
                        isRepeating: _isRepeating,
                        onYearChanged: (value) =>
                            setState(() => _currentYear = value),
                        onNewChanged: (value) =>
                            setState(() => _isNewStudent = value),
                        onRepeatingChanged: (value) =>
                            setState(() => _isRepeating = value),
                        onSave: _saveSingle,
                      ),
                      const SizedBox(height: 12),
                      _BulkLoadCard(
                        busy: _busy,
                        controller: _bulkCtrl,
                        onLoad: _saveBulk,
                      ),
                    ],
                  ),
                ),
                _PaneResizeHandle(
                  width: _desktopPaneDividerWidth,
                  onDragUpdate: (delta) {
                    setState(() {
                      _leftPaneWidth += delta;
                      _middlePaneWidth -= delta;
                    });
                  },
                ),
                studentsAsync.when(
                  loading: () => SizedBox(
                    width: remainingWidth,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => SizedBox(
                    width: remainingWidth,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('No se pudieron cargar alumnos: $error'),
                      ),
                    ),
                  ),
                  data: (students) {
                    final selectedId = _selectedStudent?.id;
                    final effectiveSelected = selectedId == null
                        ? _selectedStudent
                        : _findStudentById(students, selectedId);
                    return Row(
                      children: [
                        SizedBox(
                          width: middleWidth,
                          child: _StudentsTable(
                            students: students,
                            selectedStudentId: effectiveSelected?.id,
                            onSelect: (student) =>
                                setState(() => _selectedStudent = student),
                          ),
                        ),
                        _PaneResizeHandle(
                          width: _desktopPaneDividerWidth,
                          onDragUpdate: (delta) {
                            setState(() {
                              _middlePaneWidth += delta;
                            });
                          },
                        ),
                        SizedBox(
                          width: rightWidth,
                          child: effectiveSelected == null
                              ? const _NoStudentSelected()
                              : _StudentAcademicPanel(
                                  adminDeviceId: widget.adminDeviceId,
                                  student: effectiveSelected,
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveSingle() async {
    final draft = _buildDraft();
    if (draft == null) return;
    await _runSave(() async {
      final client = ref.read(supabaseClientProvider);
      if (client == null) throw StateError('Supabase no está disponible');
      final repo = ref.read(adminStudentsRepositoryProvider);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      _dniCtrl.clear();
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _divisionCtrl.clear();
      _notesCtrl.clear();
      _isNewStudent = true;
      _isRepeating = false;
    }, success: 'Alumno guardado con contraseña inicial Correlativas.2026');
  }

  Future<void> _saveBulk() async {
    final drafts = _parseBulkRows();
    if (drafts.isEmpty) {
      _showMessage('Pegá al menos una fila para cargar.');
      return;
    }
    await _runSave(() async {
      final client = ref.read(supabaseClientProvider);
      if (client == null) throw StateError('Supabase no está disponible');
      final repo = ref.read(adminStudentsRepositoryProvider);
      await repo.bulkUpsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        drafts: drafts,
      );
      _bulkCtrl.clear();
    }, success: '${drafts.length} alumnos cargados o actualizados.');
  }

  Future<void> _runSave(
    Future<void> Function() action, {
    required String success,
  }) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(adminStudentsProvider(widget.adminDeviceId));
      if (!mounted) return;
      setState(() {});
      _showMessage(success);
    } catch (error) {
      if (!mounted) return;
      _showMessage('No se pudo guardar: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  AdminStudentDraft? _buildDraft() {
    final dni = _dniCtrl.text.replaceAll(RegExp(r'\D'), '');
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    if (dni.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showMessage('DNI, nombre y apellido son obligatorios.');
      return null;
    }
    return AdminStudentDraft(
      dni: dni,
      firstName: firstName,
      lastName: lastName,
      careerId: _careerId,
      cohortYear: int.tryParse(_cohortCtrl.text.trim()),
      currentYear: _currentYear,
      division: _careerId == 'artes_visuales' ? 'A' : _divisionCtrl.text,
      isNewStudent: _isNewStudent,
      isRepeating: _isRepeating,
      notes: _notesCtrl.text,
    );
  }

  List<AdminStudentDraft> _parseBulkRows() {
    final rows = <AdminStudentDraft>[];
    final lines = _bulkCtrl.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      final parts = line.split(RegExp(r'[;\t,]')).map((e) => e.trim()).toList();
      if (parts.length < 3) continue;
      rows.add(
        AdminStudentDraft(
          dni: parts[0].replaceAll(RegExp(r'\D'), ''),
          lastName: parts[1],
          firstName: parts[2],
          careerId: parts.length > 3 && parts[3].isNotEmpty
              ? _normalizeCareer(parts[3])
              : _careerId,
          currentYear: parts.length > 4 ? int.tryParse(parts[4]) : _currentYear,
          division: _normalizeDivision(parts.length > 5 ? parts[5] : null),
          isNewStudent: parts.length > 6 ? !_truthy(parts[6]) : true,
          isRepeating: parts.length > 6 ? _truthy(parts[6]) : false,
          cohortYear: int.tryParse(_cohortCtrl.text.trim()),
        ),
      );
    }
    return rows;
  }

  String _normalizeCareer(String value) {
    final text = value.toLowerCase();
    if (text.contains('mus')) return 'musica';
    return 'artes_visuales';
  }

  String? _normalizeDivision(String? value) {
    final text = value?.trim() ?? '';
    if (_careerId == 'artes_visuales') return 'A';
    return text.isEmpty ? null : text;
  }

  bool _truthy(String value) {
    final text = value.toLowerCase().trim();
    return text == 'si' ||
        text == 'sí' ||
        text == 'true' ||
        text == '1' ||
        text.contains('recursa');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  AdminStudent? _findStudentById(List<AdminStudent> students, String id) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }
}

class _CareerSelector extends StatelessWidget {
  const _CareerSelector({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Carrera'),
      items: const [
        DropdownMenuItem(
          value: 'artes_visuales',
          child: Text('Profesorado en Artes Visuales'),
        ),
        DropdownMenuItem(
          value: 'musica',
          child: Text('Profesorado en Música'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _StudentFormCard extends StatelessWidget {
  const _StudentFormCard({
    required this.busy,
    required this.careerId,
    required this.dniCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.cohortCtrl,
    required this.divisionCtrl,
    required this.notesCtrl,
    required this.currentYear,
    required this.isNewStudent,
    required this.isRepeating,
    required this.onYearChanged,
    required this.onNewChanged,
    required this.onRepeatingChanged,
    required this.onSave,
  });

  final bool busy;
  final String careerId;
  final TextEditingController dniCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController cohortCtrl;
  final TextEditingController divisionCtrl;
  final TextEditingController notesCtrl;
  final int? currentYear;
  final bool isNewStudent;
  final bool isRepeating;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<bool> onNewChanged;
  final ValueChanged<bool> onRepeatingChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alta individual',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dniCtrl,
            enabled: !busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'DNI'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: lastNameCtrl,
                  enabled: !busy,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: firstNameCtrl,
                  enabled: !busy,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
              child: DropdownButtonFormField<int?>(
                  initialValue: currentYear ?? 1,
                  decoration: const InputDecoration(labelText: 'Año actual'),
                  items: const [
                    DropdownMenuItem<int?>(value: 1, child: Text('1er año')),
                    DropdownMenuItem<int?>(value: 2, child: Text('2do año')),
                    DropdownMenuItem<int?>(value: 3, child: Text('3er año')),
                    DropdownMenuItem<int?>(value: 4, child: Text('4to año')),
                  ],
                  onChanged: busy ? null : (value) => onYearChanged(value ?? 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cohortCtrl,
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cohorte'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: divisionCtrl,
            enabled: !busy && careerId != 'artes_visuales',
            decoration: InputDecoration(
              labelText: careerId == 'artes_visuales'
                  ? 'División fija'
                  : 'Curso/división',
            ),
          ),
          if (careerId == 'artes_visuales') ...[
            const SizedBox(height: 6),
            Text(
              'En Artes Visuales la división queda fija en A.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            value: isNewStudent,
            onChanged: busy ? null : onNewChanged,
            title: const Text('Nuevo en la carrera'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: isRepeating,
            onChanged: busy ? null : onRepeatingChanged,
            title: const Text('Está recursando'),
            contentPadding: EdgeInsets.zero,
          ),
          TextField(
            controller: notesCtrl,
            enabled: !busy,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : onSave,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(busy ? 'Guardando...' : 'Crear usuario alumno'),
          ),
          const SizedBox(height: 8),
          Text(
            'Contraseña inicial: ${AdminStudentDraft.defaultPassword}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BulkLoadCard extends StatelessWidget {
  const _BulkLoadCard({
    required this.busy,
    required this.controller,
    required this.onLoad,
  });

  final bool busy;
  final TextEditingController controller;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carga masiva',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Formato: DNI; Apellido; Nombre; Carrera; Año; División; Recursa',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: !busy,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText:
                  '40111222; Pérez; Ana; artes; 1; A; no\n38999888; Gómez; Luis; artes; 2; B; si',
              alignLabelWithHint: true,
              labelText: 'Pegar lista',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : onLoad,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(busy ? 'Cargando...' : 'Cargar lista'),
          ),
        ],
      ),
    );
  }
}

class _StudentsTable extends StatelessWidget {
  const _StudentsTable({
    required this.students,
    required this.onSelect,
    this.selectedStudentId,
  });

  final List<AdminStudent> students;
  final String? selectedStudentId;
  final ValueChanged<AdminStudent> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (students.isEmpty) {
      return Center(
        child: Text(
          'Todavía no hay alumnos cargados para esta carrera.',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    final groupedStudents = <int?, List<AdminStudent>>{
      1: <AdminStudent>[],
      2: <AdminStudent>[],
      3: <AdminStudent>[],
      4: <AdminStudent>[],
    };
    for (final student in students) {
      groupedStudents[student.currentYear ?? 1]?.add(student);
    }

    final sections = <({int? year, String label})>[
      (year: 1, label: '1° año'),
      (year: 2, label: '2° año'),
      (year: 3, label: '3° año'),
      (year: 4, label: '4° año'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: sections.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            '${students.length} alumnos cargados',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          );
        }
        final section = sections[index - 1];
        final sectionStudents =
            groupedStudents[section.year] ?? const <AdminStudent>[];
        return _StudentsYearSection(
          key: PageStorageKey<String>('students-${section.year ?? 'sin-ano'}'),
          title: section.label,
          count: sectionStudents.length,
          students: sectionStudents,
          selectedStudentId: selectedStudentId,
          onSelect: onSelect,
        );
      },
    );
  }

}

class _StudentsYearSection extends StatelessWidget {
  const _StudentsYearSection({
    super.key,
    required this.title,
    required this.count,
    required this.students,
    required this.selectedStudentId,
    required this.onSelect,
  });

  final String title;
  final int count;
  final List<AdminStudent> students;
  final String? selectedStudentId;
  final ValueChanged<AdminStudent> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text('$count alumnos'),
      children: [
        for (var i = 0; i < students.length; i++) ...[
          _StudentRow(
            student: students[i],
            selected: students[i].id == selectedStudentId,
            onSelect: onSelect,
          ),
          if (i != students.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.selected,
    required this.onSelect,
  });

  final AdminStudent student;
  final bool selected;
  final ValueChanged<AdminStudent> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.10)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onSelect(student),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'DNI ${student.dni}'
                      '${student.cohortYear == null ? '' : ' · Cohorte ${student.cohortYear}'}',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 104,
                child: Text(
                  _careerLabel(student.careerId),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  student.currentYear == null ? '-' : '${student.currentYear}°',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 26,
                child: Text(
                  student.division ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 108,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _StudentStatusChip(student: student),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _careerLabel(String careerId) {
    return careerId == 'musica' ? 'Música' : 'Artes Visuales';
  }
}

class _StudentStatusChip extends StatelessWidget {
  const _StudentStatusChip({required this.student});

  final AdminStudent student;

  @override
  Widget build(BuildContext context) {
    if (student.isRepeating) {
      return const Chip(label: Text('Recursa'));
    }
    if (student.isNewStudent &&
        student.currentYear == 1 &&
        student.academicProgressCount == 0) {
      return const Chip(label: Text('Nuevo'));
    }
    return const Chip(label: Text('Regular'));
  }
}

class _PaneResizeHandle extends StatelessWidget {
  const _PaneResizeHandle({
    required this.width,
    required this.onDragUpdate,
  });

  final double width;
  final ValueChanged<double> onDragUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) =>
            onDragUpdate(details.delta.dx),
        child: SizedBox(
          width: width,
          child: Center(
            child: Container(
              width: 1,
              height: double.infinity,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoStudentSelected extends StatelessWidget {
  const _NoStudentSelected();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Seleccioná un alumno para cargar su trayectoria.',
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}

class _StudentAcademicPanel extends ConsumerStatefulWidget {
  const _StudentAcademicPanel({
    required this.adminDeviceId,
    required this.student,
  });

  final String adminDeviceId;
  final AdminStudent student;

  @override
  ConsumerState<_StudentAcademicPanel> createState() =>
      _StudentAcademicPanelState();
}

class _StudentAcademicPanelState extends ConsumerState<_StudentAcademicPanel> {
  final Set<String> _selectedForEnrollment = {};
  final Set<String> _selectedRosterStudentIds = {};
  bool _savingEnrollment = false;
  bool _savingMassAction = false;
  bool _savingStudentYear = false;
  int _selectedMassYear = 1;
  int? _editableStudentYear;
  String? _selectedMassSubjectId;
  String _massPeriod = 'diciembre';
  String _massCreditType = 'mesa_final';
  String _massFailureDetail = 'desaprobo';
  int? _massGrade = 10;
  DateTime _massDate = DateTime.now();

  bool get _studentHasAcademicProgress =>
      widget.student.academicProgressCount > 0;

  @override
  void didUpdateWidget(covariant _StudentAcademicPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.id != widget.student.id) {
      _selectedForEnrollment.clear();
      _selectedRosterStudentIds.clear();
      _savingEnrollment = false;
      _savingMassAction = false;
      _savingStudentYear = false;
      _selectedMassYear = 1;
      _editableStudentYear = widget.student.currentYear;
      _selectedMassSubjectId = null;
      _massPeriod = 'diciembre';
      _massCreditType = 'mesa_final';
      _massFailureDetail = 'desaprobo';
      _massGrade = 10;
      _massDate = DateTime.now();
    } else if (oldWidget.student.currentYear != widget.student.currentYear) {
      _editableStudentYear = widget.student.currentYear;
    }
  }

  @override
  void initState() {
    super.initState();
    _editableStudentYear = widget.student.currentYear;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectsAsync = ref.watch(
      adminStudentSubjectsProvider((
        adminDeviceId: widget.adminDeviceId,
        studentId: widget.student.id ?? '',
      )),
    );
    final planAsync =
        ref.watch(adminCareerPlanProvider(widget.student.careerId));

    return planAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('No se pudo cargar plan: $error')),
      data: (materias) {
        return subjectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('No se pudo cargar trayectoria: $error')),
          data: (subjects) {
            final bySubjectId = {
              for (final subject in subjects) subject.subjectId: subject,
            };
            final historyAsync = ref.watch(
              adminStudentHistoryProvider((
                adminDeviceId: widget.adminDeviceId,
                studentId: widget.student.id ?? '',
              )),
            );
            final massSubjects = materias
                .where((materia) => materia.anio == _selectedMassYear)
                .toList()
              ..sort((a, b) => a.displayNombre.compareTo(b.displayNombre));
            final effectiveMassSubjectId = _selectedMassSubjectId ??
                (massSubjects.isEmpty ? '' : massSubjects.first.id);
            final selectedMassMateria = massSubjects
                .where((materia) => materia.id == effectiveMassSubjectId)
                .fold<Materia?>(
                    null, (selected, materia) => selected ?? materia);
            final rosterAsync = ref.watch(
              adminSubjectRosterProvider((
                adminDeviceId: widget.adminDeviceId,
                careerId: widget.student.careerId,
                subjectId: effectiveMassSubjectId,
              )),
            );
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DNI ${widget.student.dni} · ${_careerLabel(widget.student.careerId)} · ${_yearLabel(widget.student.currentYear)}'
                          '${widget.student.cohortYear == null ? '' : ' · Cohorte ${widget.student.cohortYear}'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<int?>(
                                initialValue: _editableStudentYear,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Año actual',
                                ),
                                items: const [
                                  DropdownMenuItem<int?>(
                                    value: 1,
                                    child: Text('1er año'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 2,
                                    child: Text('2do año'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 3,
                                    child: Text('3er año'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 4,
                                    child: Text('4to año'),
                                  ),
                                ],
                                onChanged: _savingStudentYear
                                    ? null
                                    : (value) => setState(() {
                                          _editableStudentYear = value ?? 1;
                                        }),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _savingStudentYear
                                  ? null
                                  : _saveStudentYear,
                              icon: _savingStudentYear
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.school_rounded),
                              label: Text(
                                _savingStudentYear
                                    ? 'Guardando...'
                                    : 'Guardar año',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Trayectoria'),
                            Tab(text: 'Por materia'),
                            Tab(text: 'Historial'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TrajectoryTab(
                          materias: materias,
                          savedBySubjectId: bySubjectId,
                          selectedSubjectIds: _selectedForEnrollment,
                          savingEnrollment: _savingEnrollment,
                          onClearSelection: _selectedForEnrollment.isEmpty
                              ? null
                              : () => setState(_selectedForEnrollment.clear),
                          onSaveSelection: _selectedForEnrollment.isEmpty ||
                                  _savingEnrollment
                              ? null
                              : () => _saveEnrollmentSelection(
                                    context,
                                    materias,
                                    subjects,
                                  ),
                          onToggleEnrollment: _toggleEnrollment,
                          onSelectYear: _selectYear,
                          onClearYear: _clearYear,
                          onEdit: (materia) => _openSubjectEditor(
                            context,
                            materia: materia,
                            existing: bySubjectId[materia.id],
                            allSaved: subjects,
                          ),
                        ),
                        _MassSubjectTab(
                          year: _selectedMassYear,
                          selectedSubjectId: effectiveMassSubjectId,
                          selectedMateria: selectedMassMateria,
                          materias: massSubjects,
                          selectedRosterStudentIds: _selectedRosterStudentIds,
                          saving: _savingMassAction,
                          period: _massPeriod,
                          creditType: _massCreditType,
                          failureDetail: _massFailureDetail,
                          grade: _massGrade,
                          date: _massDate,
                          rosterAsync: rosterAsync,
                          onYearChanged: (value) => setState(() {
                            _selectedMassYear = value;
                            _selectedMassSubjectId = null;
                            _selectedRosterStudentIds.clear();
                          }),
                          onSubjectChanged: (value) => setState(() {
                            _selectedMassSubjectId = value;
                            _selectedRosterStudentIds.clear();
                          }),
                          onPeriodChanged: (value) =>
                              setState(() => _massPeriod = value),
                          onCreditTypeChanged: (value) =>
                              setState(() => _massCreditType = value),
                          onFailureDetailChanged: (value) =>
                              setState(() => _massFailureDetail = value),
                          onGradeChanged: (value) =>
                              setState(() => _massGrade = value),
                          onDateChanged: (value) =>
                              setState(() => _massDate = value),
                          onToggleStudent: _toggleRosterStudent,
                          onSelectAllRoster: _selectAllRoster,
                          onClearRoster: _clearRoster,
                          onApplyApproved: () => _applyMassSubjectAction(
                            context,
                            rosterAsync,
                            status: 'aprobada',
                          ),
                          onApplyFailed: () => _applyMassSubjectAction(
                            context,
                            rosterAsync,
                            status: 'no_regularizada',
                          ),
                          onApplyRegular: () => _applyMassSubjectAction(
                            context,
                            rosterAsync,
                            status: 'regular',
                          ),
                          onApplyCursando: () => _applyMassSubjectAction(
                            context,
                            rosterAsync,
                            status: 'cursando',
                          ),
                        ),
                        _HistoryTab(historyAsync: historyAsync),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openSubjectEditor(
    BuildContext context, {
    required Materia materia,
    required AdminStudentSubject? existing,
    required List<AdminStudentSubject> allSaved,
  }) async {
    final initialCondition = _suggestCondition(materia, allSaved);
    final draft = await showDialog<AdminStudentSubjectDraft>(
      context: context,
      builder: (_) => _SubjectEditorDialog(
        student: widget.student,
        materia: materia,
        existing: existing,
        suggestedCondition: initialCondition,
      ),
    );
    if (draft == null) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null || widget.student.id == null) return;
    final repo = ref.read(adminStudentsRepositoryProvider);
    try {
      await repo.upsertSubject(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(
        adminStudentSubjectsProvider((
          adminDeviceId: widget.adminDeviceId,
          studentId: widget.student.id!,
        )),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${materia.displayNombre} actualizado.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar materia: $error')),
      );
    }
  }

  Future<void> _saveStudentYear() async {
    final client = ref.read(supabaseClientProvider);
    final studentId = widget.student.id;
    if (client == null || studentId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _savingStudentYear = true);
    try {
      final repo = ref.read(adminStudentsRepositoryProvider);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: AdminStudentDraft(
          id: studentId,
          dni: widget.student.dni,
          firstName: widget.student.firstName,
          lastName: widget.student.lastName,
          careerId: widget.student.careerId,
          isDemo: widget.student.isDemo,
          cohortYear: widget.student.cohortYear,
          currentYear: _editableStudentYear,
          division: widget.student.division,
          isNewStudent: _editableStudentYear == 1 &&
              !_studentHasAcademicProgress &&
              !widget.student.isRepeating,
          isRepeating: widget.student.isRepeating,
          enrollmentStatus: widget.student.enrollmentStatus,
          initialPassword: widget.student.initialPassword,
          mustChangePassword: widget.student.mustChangePassword,
          notes: widget.student.notes,
        ),
      );
      ref.invalidate(adminStudentsProvider(widget.adminDeviceId));
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Año actual actualizado.')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo guardar el año: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingStudentYear = false);
    }
  }

  void _toggleEnrollment(Materia materia, bool selected) {
    setState(() {
      if (selected) {
        _selectedForEnrollment.add(materia.id);
      } else {
        _selectedForEnrollment.remove(materia.id);
      }
    });
  }

  void _selectYear(List<Materia> materias) {
    setState(() {
      _selectedForEnrollment.addAll(materias.map((materia) => materia.id));
    });
  }

  void _clearYear(List<Materia> materias) {
    final ids = materias.map((materia) => materia.id).toSet();
    setState(() {
      _selectedForEnrollment.removeWhere(ids.contains);
    });
  }

  Future<void> _saveEnrollmentSelection(
    BuildContext context,
    List<Materia> materias,
    List<AdminStudentSubject> allSaved,
  ) async {
    final studentId = widget.student.id;
    final client = ref.read(supabaseClientProvider);
    if (studentId == null || client == null) return;

    final savedBySubjectId = {
      for (final subject in allSaved) subject.subjectId: subject,
    };
    final selected = materias
        .where((materia) => _selectedForEnrollment.contains(materia.id))
        .where((materia) => !savedBySubjectId.containsKey(materia.id))
        .toList()
      ..sort((a, b) {
        final year = a.anio.compareTo(b.anio);
        if (year != 0) return year;
        return a.displayNombre.compareTo(b.displayNombre);
      });

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay materias nuevas seleccionadas para inscribir.'),
        ),
      );
      return;
    }

    setState(() => _savingEnrollment = true);
    final repo = ref.read(adminStudentsRepositoryProvider);
    try {
      final drafts = [
        for (final materia in selected)
          AdminStudentSubjectDraft(
            studentId: studentId,
            careerId: widget.student.careerId,
            subjectId: materia.id,
            subjectName: materia.displayNombre,
            subjectYear: materia.anio,
            status: 'cursando',
            conditionStatus: _suggestCondition(materia, allSaved),
            academicPeriod: 'regular',
            sourceDate: DateTime.now(),
            notes: 'Inscripción administrativa',
            adminNote: _suggestCondition(materia, allSaved) == 'condicional'
                ? 'Inscripción condicional: revisar correlativas pendientes.'
                : null,
          ),
      ];

      final count = await repo.bulkUpsertSubjects(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        drafts: drafts,
      );
      ref.invalidate(
        adminStudentSubjectsProvider((
          adminDeviceId: widget.adminDeviceId,
          studentId: studentId,
        )),
      );
      if (!context.mounted) return;
      setState(() {
        _selectedForEnrollment.removeAll(selected.map((materia) => materia.id));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count materias inscriptas.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar inscripción: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingEnrollment = false);
    }
  }

  void _toggleRosterStudent(String studentId, bool selected) {
    setState(() {
      if (selected) {
        _selectedRosterStudentIds.add(studentId);
      } else {
        _selectedRosterStudentIds.remove(studentId);
      }
    });
  }

  void _selectAllRoster(List<AdminSubjectRosterItem> roster) {
    setState(() {
      _selectedRosterStudentIds
        ..clear()
        ..addAll(roster.map((item) => item.studentId));
    });
  }

  void _clearRoster() {
    setState(_selectedRosterStudentIds.clear);
  }

  Future<void> _applyMassSubjectAction(
    BuildContext context,
    AsyncValue<List<AdminSubjectRosterItem>> rosterAsync, {
    required String status,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null || _selectedRosterStudentIds.isEmpty) return;
    final roster = rosterAsync.valueOrNull ?? const <AdminSubjectRosterItem>[];
    final selected = roster
        .where((item) => _selectedRosterStudentIds.contains(item.studentId))
        .toList(growable: false);
    if (selected.isEmpty) return;

    setState(() => _savingMassAction = true);
    final repo = ref.read(adminStudentsRepositoryProvider);
    try {
      final drafts = selected.map((item) {
        final current = item.subject;
        return AdminStudentSubjectDraft(
          id: current.id,
          studentId: current.studentId,
          careerId: current.careerId,
          subjectId: current.subjectId,
          subjectName: current.subjectName,
          subjectYear: current.subjectYear,
          status: status,
          conditionStatus: status == 'no_regularizada'
              ? current.conditionStatus
              : 'habilitada',
          detailStatus: switch (status) {
            'aprobada' => _massCreditType,
            'no_regularizada' => _massFailureDetail,
            _ => null,
          },
          creditType: status == 'aprobada' ? _massCreditType : null,
          academicPeriod: _massPeriod,
          sourceDate: _massDate,
          grade: status == 'aprobada' || status == 'no_regularizada'
              ? _massGrade?.toDouble()
              : null,
          notes: current.notes,
          adminNote: switch (status) {
            'aprobada' => 'Actualizacion masiva por materia',
            'regular' => 'Regularizacion masiva',
            'cursando' => 'Reapertura de cursada',
            'no_regularizada' => 'Resultado masivo de mesa/instancia',
            _ => current.adminNote,
          },
        );
      }).toList(growable: false);

      final count = await repo.bulkUpsertSubjects(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        drafts: drafts,
      );
      for (final draft in drafts) {
        ref.invalidate(
          adminStudentSubjectsProvider((
            adminDeviceId: widget.adminDeviceId,
            studentId: draft.studentId,
          )),
        );
        ref.invalidate(
          adminStudentHistoryProvider((
            adminDeviceId: widget.adminDeviceId,
            studentId: draft.studentId,
          )),
        );
      }
      ref.invalidate(
        adminSubjectRosterProvider((
          adminDeviceId: widget.adminDeviceId,
          careerId: widget.student.careerId,
          subjectId: drafts.first.subjectId,
        )),
      );
      if (!context.mounted) return;
      setState(_selectedRosterStudentIds.clear);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count registros actualizados.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo aplicar la carga masiva: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingMassAction = false);
    }
  }

  String _suggestCondition(
    Materia materia,
    List<AdminStudentSubject> allSaved,
  ) {
    if (materia.correlativasDetalladas.isEmpty) return 'habilitada';
    final byId = {for (final subject in allSaved) subject.subjectId: subject};
    var hasMissing = false;
    for (final req in materia.correlativasDetalladas) {
      if (req.isSpecial) {
        hasMissing = true;
        continue;
      }
      final saved = byId[req.id];
      if (req.type == 'A') {
        if (saved?.isApproved != true) hasMissing = true;
      } else {
        if (saved?.isRegular != true) hasMissing = true;
      }
    }
    return hasMissing ? 'condicional' : 'habilitada';
  }

  String _careerLabel(String careerId) {
    return careerId == 'musica' ? 'Música' : 'Artes Visuales';
  }
}

class _TrajectoryTab extends StatelessWidget {
  const _TrajectoryTab({
    required this.materias,
    required this.savedBySubjectId,
    required this.selectedSubjectIds,
    required this.savingEnrollment,
    required this.onClearSelection,
    required this.onSaveSelection,
    required this.onToggleEnrollment,
    required this.onSelectYear,
    required this.onClearYear,
    required this.onEdit,
  });

  final List<Materia> materias;
  final Map<String, AdminStudentSubject> savedBySubjectId;
  final Set<String> selectedSubjectIds;
  final bool savingEnrollment;
  final VoidCallback? onClearSelection;
  final VoidCallback? onSaveSelection;
  final void Function(Materia materia, bool selected) onToggleEnrollment;
  final ValueChanged<List<Materia>> onSelectYear;
  final ValueChanged<List<Materia>> onClearYear;
  final ValueChanged<Materia> onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        _EnrollmentSummaryCard(
          selectedCount: selectedSubjectIds.length,
          saving: savingEnrollment,
          onClear: onClearSelection,
          onSave: onSaveSelection,
        ),
        const SizedBox(height: 12),
        for (final year in [1, 2, 3, 4]) ...[
          _YearSubjectsBlock(
            year: year,
            materias: materias.where((m) => m.anio == year).toList(),
            savedBySubjectId: savedBySubjectId,
            selectedSubjectIds: selectedSubjectIds,
            saving: savingEnrollment,
            onToggleEnrollment: onToggleEnrollment,
            onSelectYear: onSelectYear,
            onClearYear: onClearYear,
            onEdit: onEdit,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MassSubjectTab extends StatelessWidget {
  const _MassSubjectTab({
    required this.year,
    required this.selectedSubjectId,
    required this.selectedMateria,
    required this.materias,
    required this.selectedRosterStudentIds,
    required this.saving,
    required this.period,
    required this.creditType,
    required this.failureDetail,
    required this.grade,
    required this.date,
    required this.rosterAsync,
    required this.onYearChanged,
    required this.onSubjectChanged,
    required this.onPeriodChanged,
    required this.onCreditTypeChanged,
    required this.onFailureDetailChanged,
    required this.onGradeChanged,
    required this.onDateChanged,
    required this.onToggleStudent,
    required this.onSelectAllRoster,
    required this.onClearRoster,
    required this.onApplyApproved,
    required this.onApplyFailed,
    required this.onApplyRegular,
    required this.onApplyCursando,
  });

  final int year;
  final String selectedSubjectId;
  final Materia? selectedMateria;
  final List<Materia> materias;
  final Set<String> selectedRosterStudentIds;
  final bool saving;
  final String period;
  final String creditType;
  final String failureDetail;
  final int? grade;
  final DateTime date;
  final AsyncValue<List<AdminSubjectRosterItem>> rosterAsync;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onCreditTypeChanged;
  final ValueChanged<String> onFailureDetailChanged;
  final ValueChanged<int?> onGradeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(String studentId, bool selected) onToggleStudent;
  final ValueChanged<List<AdminSubjectRosterItem>> onSelectAllRoster;
  final VoidCallback onClearRoster;
  final VoidCallback onApplyApproved;
  final VoidCallback onApplyFailed;
  final VoidCallback onApplyRegular;
  final VoidCallback onApplyCursando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (materias.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: const [
          _PanelCard(
            child: Text('No hay materias del plan cargadas para este año.'),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        _PanelCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final fieldWidth = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2;
              final smallFieldWidth = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 3;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carga masiva por materia',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: narrow ? fieldWidth : 180,
                        child: _Dropdown(
                          label: 'Año',
                          value: '$year',
                          items: const {
                            '1': '1er año',
                            '2': '2do año',
                            '3': '3er año',
                            '4': '4to año',
                          },
                          onChanged: (value) => onYearChanged(int.parse(value)),
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : constraints.maxWidth - 190,
                        child: _Dropdown(
                          label: 'Materia',
                          value: selectedSubjectId.isEmpty && materias.isNotEmpty
                              ? materias.first.id
                              : selectedSubjectId,
                          items: {
                            for (final materia in materias)
                              materia.id: materia.displayNombre,
                          },
                          onChanged: onSubjectChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : smallFieldWidth,
                        child: _Dropdown(
                          label: 'Período',
                          value: period,
                          items: const {
                            'febrero': 'Febrero',
                            'mayo_extraordinaria': 'Mayo extraordinaria',
                            'julio': 'Julio',
                            'diciembre': 'Diciembre',
                            'regular': 'Regular',
                            'tif': 'TIF',
                            'equivalencia': 'Equivalencia',
                            'ajuste': 'Ajuste',
                          },
                          onChanged: onPeriodChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : smallFieldWidth,
                        child: _Dropdown(
                          label: 'Acreditación',
                          value: creditType,
                          items: const {
                            'mesa_final': 'Mesa final',
                            'promocion_directa': 'Promoción directa',
                            'equivalencia': 'Equivalencia',
                            'coloquio_tif': 'Coloquio/TIF',
                          },
                          onChanged: onCreditTypeChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : smallFieldWidth,
                        child: _Dropdown(
                          label: 'No aprobada',
                          value: failureDetail,
                          items: const {
                            'desaprobo': 'Desaprobó',
                            'libre': 'Libre',
                            'abandono': 'Abandono',
                            'no_continuo': 'No continuó',
                            'rechazo_equivalencia': 'Rechazo equivalencia',
                          },
                          onChanged: onFailureDetailChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : 130,
                        child: _NullableDropdown(
                          label: 'Nota',
                          value: grade?.toString(),
                          items: {
                            for (final item in List<int>.generate(10, (i) => i + 1))
                              '$item': '$item',
                          },
                          onChanged: (value) => onGradeChanged(
                            value == null ? null : int.tryParse(value),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : 180,
                        child: _DateButton(
                          label: 'Fecha',
                          value: date,
                          onPick: (value) {
                            if (value != null) onDateChanged(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        rosterAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _PanelCard(
            child: Text('No se pudo cargar la lista por materia: $error'),
          ),
          data: (roster) => _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedMateria == null
                      ? 'Sin materia seleccionada'
                      : '${selectedMateria!.displayNombre} · ${roster.length} inscriptos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: saving || roster.isEmpty
                          ? null
                          : () => onSelectAllRoster(roster),
                      child: const Text('Seleccionar todos'),
                    ),
                    TextButton(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onClearRoster,
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyApproved,
                      child: const Text('Aprobar'),
                    ),
                    FilledButton.tonal(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyRegular,
                      child: const Text('Regularizar'),
                    ),
                    FilledButton.tonal(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyFailed,
                      child: const Text('Desaprobar'),
                    ),
                    OutlinedButton(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyCursando,
                      child: const Text('Volver a cursando'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (roster.isEmpty)
                  const Text(
                      'Todavia no hay alumnos inscriptos en esta materia.')
                  else
                  ...roster.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: CheckboxListTile(
                        value: selectedRosterStudentIds.contains(item.studentId),
                        onChanged: saving
                            ? null
                            : (value) => onToggleStudent(
                                  item.studentId,
                                  value ?? false,
                                ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Text(
                          item.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'DNI ${item.dni} · ${_yearLabel(item.currentYear)}${item.division == null ? '' : ' · ${item.division}'} · ${_statusLabel(item.subject.status)}${item.subject.grade == null ? '' : ' · Nota ${item.subject.grade!.toStringAsFixed(0)}'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.historyAsync});

  final AsyncValue<List<AdminStudentHistoryEntry>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No se pudo cargar historial: $error'),
        ),
      ),
      data: (history) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial del alumno',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  const Text('Todavia no hay movimientos guardados.')
                else
                  ...history.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_historyTitle(entry)),
                      subtitle: Text(_historySubtitle(entry)),
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

class _EnrollmentSummaryCard extends StatelessWidget {
  const _EnrollmentSummaryCard({
    required this.selectedCount,
    required this.saving,
    required this.onClear,
    required this.onSave,
  });

  final int selectedCount;
  final bool saving;
  final VoidCallback? onClear;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final description = selectedCount == 0
              ? 'Marcá materias por año para inscribirlas como cursando en período regular.'
              : '$selectedCount materias seleccionadas para inscripción regular.';
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.assignment_add,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inscripción rápida por materias',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 3,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: saving ? null : onClear,
                      child: const Text('Limpiar'),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        icon: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_alt_rounded),
                        label: Text(
                          saving ? 'Guardando...' : 'Guardar seleccionadas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Icon(
                Icons.assignment_add,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inscripción rápida por materias',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: saving ? null : onClear,
                child: const Text('Limpiar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt_rounded),
                label: Text(saving ? 'Guardando...' : 'Guardar seleccionadas'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _YearSubjectsBlock extends StatelessWidget {
  const _YearSubjectsBlock({
    required this.year,
    required this.materias,
    required this.savedBySubjectId,
    required this.selectedSubjectIds,
    required this.saving,
    required this.onToggleEnrollment,
    required this.onSelectYear,
    required this.onClearYear,
    required this.onEdit,
  });

  final int year;
  final List<Materia> materias;
  final Map<String, AdminStudentSubject> savedBySubjectId;
  final Set<String> selectedSubjectIds;
  final bool saving;
  final void Function(Materia materia, bool selected) onToggleEnrollment;
  final ValueChanged<List<Materia>> onSelectYear;
  final ValueChanged<List<Materia>> onClearYear;
  final ValueChanged<Materia> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (materias.isEmpty) return const SizedBox.shrink();
    final enrollable = materias
        .where((materia) => !savedBySubjectId.containsKey(materia.id))
        .toList(growable: false);
    final selectedInYear = enrollable
        .where((materia) => selectedSubjectIds.contains(materia.id))
        .length;
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$year° año',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: saving || enrollable.isEmpty
                    ? null
                    : () => onSelectYear(enrollable),
                child: const Text('Inscribir año completo'),
              ),
              TextButton(
                onPressed: saving || selectedInYear == 0
                    ? null
                    : () => onClearYear(enrollable),
                child: const Text('Limpiar'),
              ),
            ],
          ),
          Text(
            '$selectedInYear seleccionadas · ${enrollable.length} disponibles',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...materias.map((materia) {
            final saved = savedBySubjectId[materia.id];
            final canEnroll = saved == null;
            final selected = selectedSubjectIds.contains(materia.id);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: canEnroll
                  ? Checkbox(
                      value: selected,
                      onChanged: saving
                          ? null
                          : (value) => onToggleEnrollment(
                                materia,
                                value ?? false,
                              ),
                    )
                  : Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                    ),
              title: Text(
                materia.displayNombre,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(_subjectSubtitle(saved, materia)),
              trailing: FilledButton.tonal(
                onPressed: () => onEdit(materia),
                child: Text(saved == null ? 'Cargar' : 'Editar'),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _subjectSubtitle(AdminStudentSubject? saved, Materia materia) {
    final reqs = materia.correlativasDetalladas.length;
    if (saved == null) {
      return reqs == 0 ? 'Sin correlativas' : '$reqs correlativas';
    }
    final parts = [
      _statusLabel(saved.status),
      _conditionLabel(saved.conditionStatus),
      if (saved.detailStatus != null) _detailLabel(saved.detailStatus!),
      if (saved.academicPeriod != null) _periodLabel(saved.academicPeriod!),
      if (saved.grade != null) 'Nota ${saved.grade}',
    ];
    return parts.join(' · ');
  }
}

class _SubjectEditorDialog extends StatefulWidget {
  const _SubjectEditorDialog({
    required this.student,
    required this.materia,
    required this.existing,
    required this.suggestedCondition,
  });

  final AdminStudent student;
  final Materia materia;
  final AdminStudentSubject? existing;
  final String suggestedCondition;

  @override
  State<_SubjectEditorDialog> createState() => _SubjectEditorDialogState();
}

class _SubjectEditorDialogState extends State<_SubjectEditorDialog> {
  late String _status;
  late String _condition;
  String? _detail;
  String? _creditType;
  String? _period;
  DateTime? _date;
  DateTime? _deadline;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _adminNoteCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _status = existing?.status ?? 'cursando';
    _condition = existing?.conditionStatus ?? widget.suggestedCondition;
    _detail = existing?.detailStatus;
    _creditType = existing?.creditType;
    _period = existing?.academicPeriod;
    _date = existing?.sourceDate;
    _deadline = existing?.conditionDeadline;
    _gradeCtrl = TextEditingController(text: existing?.grade?.toString() ?? '');
    _noteCtrl = TextEditingController(text: existing?.notes ?? '');
    _adminNoteCtrl = TextEditingController(text: existing?.adminNote ?? '');
  }

  @override
  void dispose() {
    _gradeCtrl.dispose();
    _noteCtrl.dispose();
    _adminNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.materia.displayNombre),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.suggestedCondition == 'condicional')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Atención: no cumple todas las correlativas. Se sugiere cargar como condicional con aclaración.',
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _Dropdown(
                      label: 'Estado',
                      value: _status,
                      items: const {
                        'cursando': 'Cursando',
                        'regular': 'Regular',
                        'aprobada': 'Aprobada',
                        'no_regularizada': 'No regularizada',
                      },
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Dropdown(
                      label: 'Condición',
                      value: _condition,
                      items: const {
                        'habilitada': 'Habilitada',
                        'condicional': 'Condicional',
                        'bloqueada': 'Bloqueada',
                      },
                      onChanged: (value) => setState(() => _condition = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NullableDropdown(
                      label: 'Detalle',
                      value: _detail,
                      items: const {
                        'promocion_directa': 'Promoción directa',
                        'mesa_final': 'Mesa final',
                        'equivalencia': 'Equivalencia',
                        'coloquio_tif': 'Coloquio/TIF',
                        'desaprobo': 'Desaprobó',
                        'libre': 'Libre',
                        'abandono': 'Abandono',
                        'no_continuo': 'No continuó',
                        'rechazo_equivalencia': 'Rechazo equivalencia',
                      },
                      onChanged: (value) => setState(() => _detail = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NullableDropdown(
                      label: 'Acreditación',
                      value: _creditType,
                      items: const {
                        'mesa_final': 'Mesa final',
                        'promocion_directa': 'Promoción directa',
                        'equivalencia': 'Equivalencia',
                        'coloquio_tif': 'Coloquio/TIF',
                      },
                      onChanged: (value) => setState(() => _creditType = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NullableDropdown(
                      label: 'Período',
                      value: _period,
                      items: const {
                        'febrero': 'Febrero',
                        'mayo_extraordinaria': 'Mayo extraordinaria',
                        'julio': 'Julio',
                        'diciembre': 'Diciembre',
                        'regular': 'Regular',
                        'cursada': 'Cursada',
                        'tif': 'TIF',
                        'equivalencia': 'Equivalencia',
                        'ajuste': 'Ajuste',
                      },
                      onChanged: (value) => setState(() => _period = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _gradeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nota'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'Fecha',
                      value: _date,
                      onPick: (value) => setState(() => _date = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateButton(
                      label: 'Límite condición',
                      value: _deadline,
                      onPick: (value) => setState(() => _deadline = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observación'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _adminNoteCtrl,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Aclaración administrativa'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _save() {
    final studentId = widget.student.id;
    if (studentId == null) return;
    Navigator.of(context).pop(
      AdminStudentSubjectDraft(
        id: widget.existing?.id,
        studentId: studentId,
        careerId: widget.student.careerId,
        subjectId: widget.materia.id,
        subjectName: widget.materia.displayNombre,
        subjectYear: widget.materia.anio,
        status: _status,
        conditionStatus: _condition,
        detailStatus: _detail,
        creditType: _creditType,
        academicPeriod: _period,
        sourceDate: _date,
        grade: double.tryParse(_gradeCtrl.text.trim().replaceAll(',', '.')),
        conditionDeadline: _deadline,
        notes: _noteCtrl.text,
        adminNote: _adminNoteCtrl.text,
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items.entries
          .map((entry) =>
              DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _NullableDropdown extends StatelessWidget {
  const _NullableDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text(
            'Sin detalle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...items.entries.map(
          (entry) => DropdownMenuItem<String?>(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) onPick(picked);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value == null ? label : '$label: ${_formatDate(value!)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

String _statusLabel(String value) {
  return switch (value) {
    'regular' => 'Regular',
    'aprobada' => 'Aprobada',
    'no_regularizada' => 'No regularizada',
    _ => 'Cursando',
  };
}

String _conditionLabel(String value) {
  return switch (value) {
    'condicional' => 'Condicional',
    'bloqueada' => 'Bloqueada',
    _ => 'Habilitada',
  };
}

String _yearLabel(int? year) {
  return switch (year ?? 1) {
    1 => '1er año',
    2 => '2do año',
    3 => '3er año',
    4 => '4to año',
    _ => '1er año',
  };
}

String _detailLabel(String value) {
  return switch (value) {
    'promocion_directa' => 'Promoción directa',
    'mesa_final' => 'Mesa final',
    'equivalencia' => 'Equivalencia',
    'coloquio_tif' => 'Coloquio/TIF',
    'desaprobo' => 'Desaprobó',
    'libre' => 'Libre',
    'abandono' => 'Abandono',
    'no_continuo' => 'No continuó',
    'rechazo_equivalencia' => 'Rechazo equivalencia',
    _ => value,
  };
}

String _periodLabel(String value) {
  return switch (value) {
    'mayo_extraordinaria' => 'Mayo extraordinaria',
    'regular' => 'Regular',
    'cursada' => 'Cursada',
    'tif' => 'TIF',
    'equivalencia' => 'Equivalencia',
    'ajuste' => 'Ajuste',
    _ => value[0].toUpperCase() + value.substring(1),
  };
}

String _historyTitle(AdminStudentHistoryEntry entry) {
  final subjectName = entry.payload['subject_name']?.toString().trim() ?? '';
  if (subjectName.isNotEmpty) {
    final status = entry.payload['status']?.toString().trim() ?? '';
    final statusLabel = status.isEmpty ? '' : ' · ${_statusLabel(status)}';
    return '$subjectName$statusLabel';
  }
  return switch (entry.eventType) {
    'student_upsert' => 'Actualizacion de alumno',
    'student_bulk_upsert' => 'Carga masiva de alumno',
    'subject_upsert' => 'Actualizacion de materia',
    'subjects_bulk_upsert' => 'Actualizacion masiva por materia',
    _ => entry.eventType,
  };
}

String _historySubtitle(AdminStudentHistoryEntry entry) {
  final parts = <String>[
    if (entry.createdAt != null)
      '${entry.createdAt!.day.toString().padLeft(2, '0')}/${entry.createdAt!.month.toString().padLeft(2, '0')}/${entry.createdAt!.year}',
    if ((entry.payload['academic_period'] ?? '').toString().trim().isNotEmpty)
      _periodLabel(entry.payload['academic_period'].toString()),
    if ((entry.payload['detail_status'] ?? '').toString().trim().isNotEmpty)
      _detailLabel(entry.payload['detail_status'].toString()),
    if ((entry.payload['grade'] ?? '').toString().trim().isNotEmpty)
      'Nota ${entry.payload['grade']}',
  ];
  return parts.isEmpty ? entry.eventType : parts.join(' · ');
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}





