import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/supabase/supabase.dart';
import '../datos/repositorio_estudiantes_administrador.dart';
import '../modelos/estudiante_administrador.dart';
import '../proveedores/proveedores_estudiantes_administrador.dart';
import 'estudiantes/carga_masiva_estudiantes.dart';
import 'estudiantes/formulario_estudiante.dart';
import 'estudiantes/panel_academico.dart';
import 'estudiantes/selector_carrera.dart';
import 'estudiantes/tabla_alumnos.dart';
import 'estudiantes/utilidades_administrador.dart';

class EstudiantesAdministradorPantalla extends ConsumerStatefulWidget {
  const EstudiantesAdministradorPantalla({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<EstudiantesAdministradorPantalla> createState() =>
      _EstudiantesAdministradorPantallaState();
}

class _EstudiantesAdministradorPantallaState
    extends ConsumerState<EstudiantesAdministradorPantalla> {
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
  EstudianteAdministrador? _selectedStudent;
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
    final maxLeft = availableWidth - _minMiddlePaneWidth - _minRightPaneWidth;
    final maxMiddle = availableWidth - _minLeftPaneWidth - _minRightPaneWidth;
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
        ref.watch(proveedorEstudiantesAdministrador(widget.adminDeviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumnos y trayectorias'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _busy
                ? null
                : () => ref.invalidate(
                    proveedorEstudiantesAdministrador(widget.adminDeviceId)),
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
                        SelectorCarreraAdministrador(
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
                                          proveedorFiltroCarreraEstudiantesAdministrador
                                              .notifier)
                                      .state = value;
                                },
                        ),
                        const SizedBox(height: 12),
                        TarjetaFormularioEstudiante(
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
                        TarjetaCargaMasivaEstudiantes(
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
            final availableWidth =
                constraints.maxWidth - (_desktopPaneDividerWidth * 2);
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
                      SelectorCarreraAdministrador(
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
                                        proveedorFiltroCarreraEstudiantesAdministrador
                                            .notifier)
                                    .state = value;
                              },
                      ),
                      const SizedBox(height: 12),
                      TarjetaFormularioEstudiante(
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
                      TarjetaCargaMasivaEstudiantes(
                        busy: _busy,
                        controller: _bulkCtrl,
                        onLoad: _saveBulk,
                      ),
                    ],
                  ),
                ),
                ManijaRedimensionPanel(
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
                          child: TablaAlumnosAdministrador(
                            students: students,
                            selectedStudentId: effectiveSelected?.id,
                            onSelect: (student) =>
                                setState(() => _selectedStudent = student),
                          ),
                        ),
                        ManijaRedimensionPanel(
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
                              ? const SinEstudianteSeleccionado()
                              : PanelAcademicoEstudiante(
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
      final client = ref.read(proveedorClienteSupabase);
      if (client == null) throw StateError('Supabase no está disponible');
      final repo = ref.read(proveedorRepositorioEstudiantesAdministrador);
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
      final client = ref.read(proveedorClienteSupabase);
      if (client == null) throw StateError('Supabase no está disponible');
      final repo = ref.read(proveedorRepositorioEstudiantesAdministrador);
      await repo.bulkUpsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        drafts: drafts,
      );
      _bulkCtrl.clear();
    }, success: '${drafts.length} alumnos cargados.');
  }

  Future<void> _runSave(
    Future<void> Function() action, {
    required String success,
  }) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(proveedorEstudiantesAdministrador(widget.adminDeviceId));
      if (!mounted) return;
      setState(() {});
      _showMessage(success);
    } on DniEnUsoAdministradorException {
      if (!mounted) return;
      await _mostrarDniEnUso();
    } catch (error) {
      if (!mounted) return;
      _showMessage('No se pudo guardar: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _mostrarDniEnUso() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('DNI ya registrado'),
        content: const Text(
          'Ese DNI pertenece a otro usuario. No se creó ni modificó ningún registro.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  BorradorEstudianteAdministrador? _buildDraft() {
    final dni = _dniCtrl.text.replaceAll(RegExp(r'\D'), '');
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    if (dni.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showMessage('DNI, nombre y apellido son obligatorios.');
      return null;
    }
    return BorradorEstudianteAdministrador(
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

  List<BorradorEstudianteAdministrador> _parseBulkRows() {
    final rows = <BorradorEstudianteAdministrador>[];
    final lines = _bulkCtrl.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      final parts = line.split(RegExp(r'[;\t,]')).map((e) => e.trim()).toList();
      if (parts.length < 3) continue;
      rows.add(
        BorradorEstudianteAdministrador(
          dni: parts[0].replaceAll(RegExp(r'\D'), ''),
          lastName: parts[1],
          firstName: parts[2],
          careerId: parts.length > 3 && parts[3].isNotEmpty
              ? _normalizeCareer(parts[3])
              : _careerId,
          currentYear: parts.length > 4 ? int.tryParse(parts[4]) : _currentYear,
          division: _normalizeDivision(parts.length > 5 ? parts[5] : null),
          isNewStudent: parts.length <= 6 || !_truthy(parts[6]),
          isRepeating: parts.length > 6 && _truthy(parts[6]),
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

  EstudianteAdministrador? _findStudentById(
      List<EstudianteAdministrador> students, String id) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }
}
