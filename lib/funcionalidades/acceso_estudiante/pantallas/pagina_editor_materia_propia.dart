import 'package:flutter/material.dart';

import '../../../modelos/materia.dart';
import '../modelos/modelos_acceso_estudiante.dart';
import 'detalle_materia_estudiante_pantalla.dart';

class PaginaEditorMateriaPropia extends StatefulWidget {
  const PaginaEditorMateriaPropia({
    super.key,
    required this.careerId,
    required this.plan,
    this.existing,
    required this.existingSubjectIds,
    required this.allSubjects,
    required this.studentYear,
    required this.canDelete,
  });

  final String careerId;
  final List<Materia> plan;
  final MateriaEstudiante? existing;
  final Set<String> existingSubjectIds;
  final List<MateriaEstudiante> allSubjects;
  final int studentYear;
  final bool canDelete;

  @override
  State<PaginaEditorMateriaPropia> createState() =>
      _PaginaEditorMateriaPropiaState();
}

class _PaginaEditorMateriaPropiaState extends State<PaginaEditorMateriaPropia> {
  int _step = 0;
  Materia? _selectedMateria;

  late final TextEditingController _searchCtrl;
  late final FocusNode _searchFocus;
  List<Materia> _filteredResults = const [];

  late final TextEditingController _gradeCtrl;
  late String _status;
  late String _period;
  late int _year;
  DateTime? _date;

  @override
  void initState() {
    super.initState();

    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();
    final num? existingGrade = widget.existing?.grade;
    _gradeCtrl = TextEditingController(
      text: existingGrade == null
          ? ''
          : existingGrade % 1 == 0
          ? existingGrade.toInt().toString()
          : existingGrade.toString(),
    );
    _status = widget.existing?.status ?? 'cursando';
    _period = (widget.existing?.academicPeriod.isNotEmpty == true)
        ? widget.existing!.academicPeriod
        : 'cursada';
    _year = widget.existing?.subjectYear ?? widget.studentYear;
    _date = widget.existing?.sourceDate;

    if (widget.existing != null) {
      _resolveExistingSubject();
      _step = 1;
    }

    _searchCtrl.addListener(_onSearchChanged);
  }

  void _resolveExistingSubject() {
    final existing = widget.existing;
    if (existing == null || widget.plan.isEmpty) return;
    final id = existing.subjectId;
    final name = existing.subjectName;
    _selectedMateria = widget.plan.cast<Materia?>().firstWhere(
      (m) =>
          m!.id == id ||
          m.nombre == id ||
          m.displayNombre == id ||
          m.displayNombre == name,
      orElse: () => null,
    );
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResults = _selectedMateria != null
            ? [_selectedMateria!]
            : const [];
      } else {
        _filteredResults =
            widget.plan.where((m) {
              final name = m.displayNombre.toLowerCase();
              return name.contains(query);
            }).toList()..sort((a, b) {
              final byYear = a.anio.compareTo(b.anio);
              if (byYear != 0) return byYear;
              return a.displayNombre.compareTo(b.displayNombre);
            });
        if (_selectedMateria != null &&
            !_filteredResults.any((m) => m.id == _selectedMateria!.id)) {
          _selectedMateria = null;
        }
      }
    });
  }

  // ---- Correlatividades helpers (misma lógica que acceso_estudiante_pantalla.dart) ----
  static String _norm(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _cumpleCorrelativas(Materia materia) {
    final subjects = widget.allSubjects;
    final reqs = materia.correlativasDetalladas.isNotEmpty
        ? materia.correlativasDetalladas
        : materia.correlativas
              .map((id) => CorrelativaDetallada(id: id, type: 'A', nombre: id))
              .toList();

    final byId = <String, MateriaEstudiante>{};
    for (final s in subjects) {
      final k = _norm(s.subjectId);
      if (k.isNotEmpty) byId[k] = s;
    }

    for (final req in reqs) {
      final ref = byId[_norm(req.id)];
      final status = ref == null
          ? null
          : (ref.status.toLowerCase().trim() == 'aprobada'
                ? 'aprobada'
                : ref.status.toLowerCase().trim());
      final ok = switch (req.type.toUpperCase()) {
        'R' => status == 'regular' || status == 'aprobada',
        _ => status == 'aprobada',
      };
      if (!ok) return false;
    }
    return true;
  }

  void _showCorrelativasInfo(BuildContext context) {
    final materia = _selectedMateria;
    if (materia == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleMateriaEstudiantePantalla(
          materia: materia,
          allSubjects: widget.allSubjects,
          history: const [],
          plan: widget.plan,
        ),
      ),
    );
  }

  void _selectMateria(Materia m) {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.text = m.displayNombre;
    setState(() {
      _selectedMateria = m;
      _year = m.anio;
      _filteredResults = [m];
    });
    _searchFocus.unfocus();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _continueToForm() {
    if (_selectedMateria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buscá y seleccioná una materia.')),
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _save() {
    final materia = _selectedMateria!;
    Navigator.of(context).pop({
      'subject_id': materia.id,
      'subject_name': materia.displayNombre,
      'subject_year': _year,
      'status': _status,
      'academic_period': _period,
      'source_date': _date != null
          ? '${_date!.year.toString().padLeft(4, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'
          : null,
      'grade': double.tryParse(_gradeCtrl.text.trim().replaceAll(',', '.')),
      'row_id': null,
    });
  }

  Future<void> _requestDelete() async {
    final existing = widget.existing;
    if (!widget.canDelete || existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text(
          '¿Querés eliminar "${existing.subjectName}" de tu registro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(<String, dynamic>{'delete': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existing != null;
    const primaryBlue = Color(0xFF0E5E86);

    final examOutline = isDark
        ? const Color(0xFF263448)
        : const Color(0xFFD2DCE8);
    final examSurface = isDark
        ? const Color(0xFF0D1726)
        : const Color(0xFFF8FAFC);
    final examInputTheme = InputDecorationTheme(
      filled: true,
      fillColor: examSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: examOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: examOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFF9FB0C6) : const Color(0xFF64748B),
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF9FB0C6) : const Color(0xFF94A3B8),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          isEditing ? 'Editar materia' : 'Agregar materia',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            if (_step == 1 && !isEditing) {
              setState(() => _step = 0);
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            _step == 1 && !isEditing
                ? Icons.arrow_back_rounded
                : Icons.close_rounded,
          ),
        ),
      ),
      body: Theme(
        data: theme.copyWith(inputDecorationTheme: examInputTheme),
        child: _step == 0 && !isEditing
            ? _buildSearchStep(theme, isDark)
            : _buildFormStep(theme, isDark),
      ),
    );
  }

  Widget _buildSearchStep(ThemeData theme, bool isDark) {
    final cs = theme.colorScheme;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscá una materia del plan...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _filteredResults = const []);
                          _selectedMateria = null;
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredResults.isEmpty && _searchCtrl.text.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No encontramos materias con ese nombre.\nProbá con otro término.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      final m = _filteredResults[index];
                      final isSelected = _selectedMateria?.id == m.id;
                      final yaAgregada = widget.existingSubjectIds.contains(
                        m.id,
                      );
                      final noCumple = !yaAgregada && !_cumpleCorrelativas(m);
                      final bloqueada = yaAgregada || noCumple;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: bloqueada ? null : () => _selectMateria(m),
                            borderRadius: BorderRadius.circular(14),
                            child: Opacity(
                              opacity: bloqueada ? 0.55 : 1.0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected && !bloqueada
                                      ? const Color(
                                          0xFF0E5E86,
                                        ).withValues(alpha: 0.08)
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: bloqueada
                                        ? cs.outlineVariant.withValues(
                                            alpha: 0.4,
                                          )
                                        : isSelected
                                        ? const Color(0xFF0E5E86)
                                        : const Color(
                                            0xFFD2DCE8,
                                          ).withValues(alpha: 0.5),
                                    width: isSelected && !bloqueada ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected && !bloqueada
                                            ? const Color(
                                                0xFF0E5E86,
                                              ).withValues(alpha: 0.15)
                                            : cs.surfaceContainerHighest
                                                  .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${m.anio}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            color: isSelected && !bloqueada
                                                ? const Color(0xFF0E5E86)
                                                : cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.displayNombre,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.2,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (yaAgregada) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Ya agregada',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                          if (noCumple) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'No cumple correlativas',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFFDC2626,
                                                    ).withValues(alpha: 0.65),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isSelected && !bloqueada)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF0E5E86),
                                        size: 22,
                                      ),
                                    if (bloqueada)
                                      Icon(
                                        yaAgregada
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.lock_outline_rounded,
                                        color: cs.onSurfaceVariant.withValues(
                                          alpha: 0.3,
                                        ),
                                        size: 22,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedMateria != null ? _continueToForm : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continuar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: cs.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormStep(ThemeData theme, bool isDark) {
    final cs = theme.colorScheme;
    final isEditing = widget.existing != null;
    final materia = _selectedMateria!;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                if (!isEditing) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E5E86).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0E5E86).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0E5E86,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF0E5E86),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                materia.displayNombre,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${materia.anio}° año',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _step = 0;
                              _searchCtrl.clear();
                              _filteredResults = const [];
                            });
                          },
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Cambiar materia',
                          color: const Color(0xFF0E5E86),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (isEditing) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E5E86).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0E5E86).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0E5E86,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.edit_rounded,
                              color: Color(0xFF0E5E86),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Editando: ${materia.displayNombre}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        borderRadius: BorderRadius.circular(12),
                        itemHeight: 56,
                        dropdownColor: theme.colorScheme.surface,
                        decoration: const InputDecoration(labelText: 'Estado'),
                        items: const [
                          DropdownMenuItem(
                            value: 'cursando',
                            child: Text('Cursando'),
                          ),
                          DropdownMenuItem(
                            value: 'regular',
                            child: Text('Regular'),
                          ),
                          DropdownMenuItem(
                            value: 'aprobada',
                            child: Text('Aprobada'),
                          ),
                          DropdownMenuItem(
                            value: 'no_regularizada',
                            child: Text('No regularizada'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                            if (_status == 'cursando') _gradeCtrl.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _gradeCtrl,
                        enabled: _status != 'cursando',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Nota',
                          hintText: _status == 'cursando' ? '—' : '7',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCorrelativasInfo(context),
                    icon: const Icon(Icons.account_tree_rounded, size: 18),
                    label: const Text('Ver correlativas'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha'),
                    child: Text(
                      _date == null
                          ? 'Sin fecha'
                          : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                if (widget.canDelete) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _requestDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Guardar materia'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
