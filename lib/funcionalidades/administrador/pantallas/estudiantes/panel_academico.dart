import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../modelos/materia.dart';
import '../../../../compartido/supabase/supabase.dart';
import '../../modelos/estudiante_administrador.dart';
import '../../modelos/materia_estudiante_administrador.dart';
import '../../modelos/item_nomina_materia_administrador.dart';
import '../../proveedores/proveedores_estudiantes_administrador.dart';
import 'utilidades_administrador.dart';
import 'editor_materia_estudiante.dart';
import 'historial_estudiante.dart';

class PanelAcademicoEstudiante extends ConsumerStatefulWidget {
  const PanelAcademicoEstudiante({
    super.key,
    required this.adminDeviceId,
    required this.student,
  });

  final String adminDeviceId;
  final EstudianteAdministrador student;

  @override
  ConsumerState<PanelAcademicoEstudiante> createState() =>
      _PanelAcademicoEstudianteState();
}

class _PanelAcademicoEstudianteState
    extends ConsumerState<PanelAcademicoEstudiante> {
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
  void didUpdateWidget(covariant PanelAcademicoEstudiante oldWidget) {
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
      proveedorMateriasEstudianteAdministrador((
        adminDeviceId: widget.adminDeviceId,
        studentId: widget.student.id ?? '',
      )),
    );
    final planAsync =
        ref.watch(proveedorPlanCarreraAdministrador(widget.student.careerId));

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
              proveedorHistorialEstudianteAdministrador((
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
              proveedorNominaMateriaAdministrador((
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
                          'DNI ${widget.student.dni} · ${etiquetaCarrera(widget.student.careerId)} · ${etiquetaAnio(widget.student.currentYear)}'
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
                                      value: 1, child: Text('1er año')),
                                  DropdownMenuItem<int?>(
                                      value: 2, child: Text('2do año')),
                                  DropdownMenuItem<int?>(
                                      value: 3, child: Text('3er año')),
                                  DropdownMenuItem<int?>(
                                      value: 4, child: Text('4to año')),
                                ],
                                onChanged: _savingStudentYear
                                    ? null
                                    : (value) => setState(() {
                                          _editableStudentYear = value ?? 1;
                                        }),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed:
                                  _savingStudentYear ? null : _saveStudentYear,
                              icon: _savingStudentYear
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.school_rounded),
                              label: Text(_savingStudentYear
                                  ? 'Guardando...'
                                  : 'Guardar año'),
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
                        TabTrayectoria(
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
                                  context, materias, subjects),
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
                        TabMateriaMasiva(
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
                              context, rosterAsync,
                              status: 'aprobada'),
                          onApplyFailed: () => _applyMassSubjectAction(
                              context, rosterAsync,
                              status: 'no_regularizada'),
                          onApplyRegular: () => _applyMassSubjectAction(
                              context, rosterAsync,
                              status: 'regular'),
                          onApplyCursando: () => _applyMassSubjectAction(
                              context, rosterAsync,
                              status: 'cursando'),
                        ),
                        TabHistorial(historyAsync: historyAsync),
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
    required MateriaEstudianteAdministrador? existing,
    required List<MateriaEstudianteAdministrador> allSaved,
  }) async {
    final initialCondition = _suggestCondition(materia, allSaved);
    final draft = await showDialog<BorradorMateriaEstudianteAdministrador>(
      context: context,
      builder: (_) => DialogoEditorMateria(
        student: widget.student,
        materia: materia,
        existing: existing,
        suggestedCondition: initialCondition,
      ),
    );
    if (draft == null) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null || widget.student.id == null) return;
    final repo = ref.read(proveedorRepositorioEstudiantesAdministrador);
    try {
      await repo.upsertSubject(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(
        proveedorMateriasEstudianteAdministrador((
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
    final client = ref.read(proveedorClienteSupabase);
    final studentId = widget.student.id;
    if (client == null || studentId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _savingStudentYear = true);
    try {
      final repo = ref.read(proveedorRepositorioEstudiantesAdministrador);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: BorradorEstudianteAdministrador(
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
      ref.invalidate(proveedorEstudiantesAdministrador(widget.adminDeviceId));
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
    List<MateriaEstudianteAdministrador> allSaved,
  ) async {
    final studentId = widget.student.id;
    final client = ref.read(proveedorClienteSupabase);
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
    final repo = ref.read(proveedorRepositorioEstudiantesAdministrador);
    try {
      final drafts = [
        for (final materia in selected)
          BorradorMateriaEstudianteAdministrador(
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
        proveedorMateriasEstudianteAdministrador((
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

  void _selectAllRoster(List<ItemNominaMateriaAdministrador> roster) {
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
    AsyncValue<List<ItemNominaMateriaAdministrador>> rosterAsync, {
    required String status,
  }) async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null || _selectedRosterStudentIds.isEmpty) return;
    final roster =
        rosterAsync.valueOrNull ?? const <ItemNominaMateriaAdministrador>[];
    final selected = roster
        .where((item) => _selectedRosterStudentIds.contains(item.studentId))
        .toList(growable: false);
    if (selected.isEmpty) return;

    setState(() => _savingMassAction = true);
    final repo = ref.read(proveedorRepositorioEstudiantesAdministrador);
    try {
      final drafts = selected.map((item) {
        final current = item.subject;
        return BorradorMateriaEstudianteAdministrador(
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
          proveedorMateriasEstudianteAdministrador((
            adminDeviceId: widget.adminDeviceId,
            studentId: draft.studentId,
          )),
        );
        ref.invalidate(
          proveedorHistorialEstudianteAdministrador((
            adminDeviceId: widget.adminDeviceId,
            studentId: draft.studentId,
          )),
        );
      }
      ref.invalidate(
        proveedorNominaMateriaAdministrador((
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
    List<MateriaEstudianteAdministrador> allSaved,
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
}

// ── Tab Trayectoria ────────────────────────────────────────

class TabTrayectoria extends StatelessWidget {
  const TabTrayectoria({
    super.key,
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
  final Map<String, MateriaEstudianteAdministrador> savedBySubjectId;
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
        TarjetaResumenInscripcion(
          selectedCount: selectedSubjectIds.length,
          saving: savingEnrollment,
          onClear: onClearSelection,
          onSave: onSaveSelection,
        ),
        const SizedBox(height: 12),
        for (final year in [1, 2, 3, 4]) ...[
          BloqueMateriasAnio(
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

// ── Tab Materia Masiva ─────────────────────────────────────

class TabMateriaMasiva extends StatelessWidget {
  const TabMateriaMasiva({
    super.key,
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
  final AsyncValue<List<ItemNominaMateriaAdministrador>> rosterAsync;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onCreditTypeChanged;
  final ValueChanged<String> onFailureDetailChanged;
  final ValueChanged<int?> onGradeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(String studentId, bool selected) onToggleStudent;
  final ValueChanged<List<ItemNominaMateriaAdministrador>> onSelectAllRoster;
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
          TarjetaPanel(
            child: Text('No hay materias del plan cargadas para este año.'),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        TarjetaPanel(
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
                        child: SelectorDropdown(
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
                        child: SelectorDropdown(
                          label: 'Materia',
                          value:
                              selectedSubjectId.isEmpty && materias.isNotEmpty
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
                        child: SelectorDropdown(
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
                        child: SelectorDropdown(
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
                        child: SelectorDropdown(
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
                        child: SelectorNuloDropdown(
                          label: 'Nota',
                          value: grade?.toString(),
                          items: {
                            for (final item
                                in List<int>.generate(10, (i) => i + 1))
                              '$item': '$item',
                          },
                          onChanged: (value) => onGradeChanged(
                              value == null ? null : int.tryParse(value)),
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : 180,
                        child: BotonFecha(
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
          error: (error, _) => TarjetaPanel(
            child: Text('No se pudo cargar la lista por materia: $error'),
          ),
          data: (roster) => TarjetaPanel(
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
                        value:
                            selectedRosterStudentIds.contains(item.studentId),
                        onChanged: saving
                            ? null
                            : (value) =>
                                onToggleStudent(item.studentId, value ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Text(
                          item.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'DNI ${item.dni} · ${etiquetaAnio(item.currentYear)}${item.division == null ? '' : ' · ${item.division}'} · ${etiquetaEstado(item.subject.status)}${item.subject.grade == null ? '' : ' · Nota ${item.subject.grade!.toStringAsFixed(0)}'}',
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

// ── Resumen Inscripción ────────────────────────────────────

class TarjetaResumenInscripcion extends StatelessWidget {
  const TarjetaResumenInscripcion({
    super.key,
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
    return TarjetaPanel(
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
                    Icon(Icons.assignment_add,
                        color: theme.colorScheme.primary),
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
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Icon(Icons.assignment_add, color: theme.colorScheme.primary),
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

// ── Bloque Materias Año ────────────────────────────────────

class BloqueMateriasAnio extends StatelessWidget {
  const BloqueMateriasAnio({
    super.key,
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
  final Map<String, MateriaEstudianteAdministrador> savedBySubjectId;
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
    return TarjetaPanel(
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
                          : (value) =>
                              onToggleEnrollment(materia, value ?? false),
                    )
                  : Icon(Icons.check_circle_rounded,
                      color: theme.colorScheme.primary),
              title: Text(
                materia.displayNombre,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(_subtituloMateria(saved, materia)),
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

  String _subtituloMateria(
      MateriaEstudianteAdministrador? saved, Materia materia) {
    final reqs = materia.correlativasDetalladas.length;
    if (saved == null) {
      return reqs == 0 ? 'Sin correlativas' : '$reqs correlativas';
    }
    final parts = [
      etiquetaEstado(saved.status),
      etiquetaCondicion(saved.conditionStatus),
      if (saved.detailStatus != null) etiquetaDetalle(saved.detailStatus!),
      if (saved.academicPeriod != null) etiquetaPeriodo(saved.academicPeriod!),
      if (saved.grade != null) 'Nota ${saved.grade}',
    ];
    return parts.join(' · ');
  }
}
