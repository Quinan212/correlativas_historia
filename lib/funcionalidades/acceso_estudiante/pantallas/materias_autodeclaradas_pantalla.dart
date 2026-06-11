import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../datos/cargador_fuente_html.dart';
import '../../../modelos/materia.dart';
import '../../../compartido/supabase/supabase.dart';
import '../datos/repositorio_acceso_estudiante.dart';
import '../modelos/modelos_acceso_estudiante.dart';
import 'detalle_materia_estudiante_pantalla.dart';

class MateriasAutodeclaradasPantalla extends ConsumerStatefulWidget {
  const MateriasAutodeclaradasPantalla({
    super.key,
    required this.payload,
  });

  final DatosAccesoEstudiante payload;

  @override
  ConsumerState<MateriasAutodeclaradasPantalla> createState() =>
      _MateriasAutodeclaradasPantallaState();
}

class _MateriasAutodeclaradasPantallaState
    extends ConsumerState<MateriasAutodeclaradasPantalla> {
  final _repo = const RepositorioAccesoEstudiante();
  bool _busy = false;
  late List<MateriaEstudiante> _allSubjects;
  List<Materia> _plan = const [];

  @override
  void initState() {
    super.initState();
    _rebuildAllSubjects();
    _loadPlan();
  }

  void _rebuildAllSubjects() {
    _allSubjects = widget.payload.combinedSubjects;
    _allSubjects.sort((a, b) {
      final year = (a.subjectYear ?? 0).compareTo(b.subjectYear ?? 0);
      if (year != 0) return year;
      return a.subjectName.compareTo(b.subjectName);
    });
  }

  Future<void> _loadPlan() async {
    final plan = await cargarPlanDesdeAssetHtml(
      _careerAssetFor(widget.payload.student.careerId),
    );
    if (!mounted) return;
    setState(() => _plan = plan.materias);
  }

  bool _isSelfReported(MateriaEstudiante subject) {
    final officialIds = widget.payload.subjects.map((s) => s.subjectId).toSet();
    return !officialIds.contains(subject.subjectId);
  }

  Future<void> _deleteSubject(MateriaEstudiante subject) async {
    if (!_isSelfReported(subject)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar materia'),
        content:
            Text('¿Querés eliminar "${subject.subjectName}" de tu registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final client = ref.read(proveedorClienteSupabase);
      if (client == null) throw StateError('Supabase no está disponible');
      await _repo.deleteSelfSubject(
        client: client,
        subjectId: subject.subjectId,
      );
      setState(() {
        _allSubjects.removeWhere((s) => s.subjectId == subject.subjectId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${subject.subjectName}" eliminada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openEditor({MateriaEstudiante? existing}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => _PaginaEditorMateriaPropia(
          careerId: widget.payload.student.careerId,
          plan: _plan,
          existing: existing,
          existingSubjectIds: existing != null
              ? {}
              : _allSubjects.map((s) => s.subjectId).toSet(),
          allSubjects: _allSubjects,
          studentYear: widget.payload.student.currentYear ?? 1,
        ),
      ),
    );
    if (result == null) return;

    setState(() => _busy = true);
    try {
      final client = ref.read(proveedorClienteSupabase);
      if (client == null) throw StateError('Supabase no está disponible');
      await _repo.upsertSelfSubject(
        client: client,
        subjectId: result['subject_id'] as String,
        subjectName: result['subject_name'] as String,
        subjectYear: result['subject_year'] as int,
        status: result['status'] as String,
        academicPeriod: result['academic_period'] as String,
        sourceDate: result['source_date'] as String?,
        grade: result['grade'] as double?,
        notes: result['notes'] as String?,
        id: existing != null ? result['row_id'] as String? : null,
      );

      setState(() {
        final idx = _allSubjects.indexWhere(
          (s) => s.subjectId == result['subject_id'],
        );
        final updated = MateriaEstudiante(
          subjectId: result['subject_id'] as String,
          subjectName: result['subject_name'] as String,
          subjectYear: result['subject_year'] as int,
          status: result['status'] as String,
          academicPeriod: result['academic_period'] as String,
          sourceDate: result['source_date'] != null
              ? DateTime.tryParse(result['source_date'] as String)
              : null,
          grade: result['grade'] as num?,
        );
        if (idx >= 0) {
          _allSubjects[idx] = updated;
        } else {
          _allSubjects.add(updated);
        }
        _allSubjects.sort((a, b) {
          final year = (a.subjectYear ?? 0).compareTo(b.subjectYear ?? 0);
          if (year != 0) return year;
          return a.subjectName.compareTo(b.subjectName);
        });
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${result['subject_name']}" guardada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const primaryBlue = Color(0xFF0E5E86);

    final grouped = <int, List<MateriaEstudiante>>{
      1: [],
      2: [],
      3: [],
      4: [],
    };
    for (final s in _allSubjects) {
      grouped[s.subjectYear ?? 1]!.add(s);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          'Mi registro personal',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF90CDF4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Acá ves todas tus materias. Tocá cualquiera para editarla.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2D3748),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy || _plan.isEmpty ? null : () => _openEditor(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar materia a mi registro'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_allSubjects.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Todavía no hay materias cargadas en tu registro.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'Elegí un año para ver sus materias',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final year in [1, 2, 3, 4]) ...[
                    _TarjetaSelectorAnio(
                      year: year,
                      count: grouped[year]?.length ?? 0,
                      totalInPlan: _plan.where((m) => m.anio == year).length,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => _MateriasPorAnioPantalla(
                              year: year,
                              subjects: grouped[year] ?? [],
                              allSubjects: _allSubjects,
                              plan: _plan,
                              payload: widget.payload,
                              onDelete: _deleteSubject,
                              onEdit: _openEditor,
                              busy: _busy,
                              isSelfReported: _isSelfReported,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _careerAssetFor(String careerId) {
    return switch (careerId) {
      'historia' => 'assets/historia.html',
      'geografia' => 'assets/geografia.html',
      'politica' => 'assets/politica.html',
      'artes_visuales' => 'assets/data/artes_visuales.json',
      'musica' => 'assets/Musica.html',
      _ => 'assets/historia.html',
    };
  }
}

class _TarjetaMateriaPropia extends StatelessWidget {
  const _TarjetaMateriaPropia({
    required this.subject,
    required this.isSelfReported,
    required this.onEdit,
    required this.onDelete,
    required this.busy,
  });

  final MateriaEstudiante subject;
  final bool isSelfReported;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final statusColor = switch (subject.status) {
      'aprobada' => const Color(0xFF2EAD57),
      'regular' => const Color(0xFFD97706),
      'no_regularizada' => const Color(0xFFDC2626),
      _ => const Color(0xFF1E6FDB),
    };

    final statusIcon = switch (subject.status) {
      'aprobada' => Icons.check_circle_rounded,
      'regular' => Icons.assignment_turned_in_rounded,
      'no_regularizada' => Icons.cancel_rounded,
      _ => Icons.play_circle_rounded,
    };

    final statusLabel = switch (subject.status) {
      'aprobada' => 'Aprobada',
      'regular' => 'Regular',
      'no_regularizada' => 'No regularizada',
      _ => 'Cursando',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy || onEdit == null ? null : onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.subjectName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _EtiquetaMini(
                                label: statusLabel, color: statusColor),
                            if (subject.grade != null)
                              _EtiquetaMini(
                                label:
                                    'Nota ${subject.grade!.toStringAsFixed(0)}',
                                color: const Color(0xFF7C3AED),
                              ),
                            if (subject.academicPeriod.isNotEmpty &&
                                subject.academicPeriod != 'regular')
                              _EtiquetaMini(
                                label: _etiquetaPeriodo(subject.academicPeriod),
                                color: const Color(0xFF0E7490),
                              ),
                            if (subject.subjectYear != null)
                              _EtiquetaMini(
                                label: '${subject.subjectYear}° año',
                                color: cs.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: busy ? null : onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: cs.error,
                      tooltip: 'Eliminar',
                      style: IconButton.styleFrom(
                        backgroundColor: cs.error.withValues(alpha: 0.08),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _etiquetaPeriodo(String value) {
    return switch (value) {
      'mayo_extraordinaria' => 'Mayo ext.',
      'febrero' => 'Febrero',
      'julio' => 'Julio',
      'diciembre' => 'Diciembre',
      'cursada' => 'Cursada',
      'tif' => 'TIF',
      'equivalencia' => 'Equivalencia',
      'ajuste' => 'Ajuste',
      _ => value,
    };
  }
}

class _EtiquetaMini extends StatelessWidget {
  const _EtiquetaMini({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _TarjetaSelectorAnio extends StatelessWidget {
  const _TarjetaSelectorAnio({
    required this.year,
    required this.count,
    required this.totalInPlan,
    required this.onTap,
  });

  final int year;
  final int count;
  final int totalInPlan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final yearColors = {
      1: const Color(0xFF2563EB),
      2: const Color(0xFF16A34A),
      3: const Color(0xFFEA580C),
      4: const Color(0xFF7C3AED),
    };
    final color = yearColors[year] ?? cs.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$year',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$year° año',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count de $totalInPlan materias cargadas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MateriasPorAnioPantalla extends StatelessWidget {
  const _MateriasPorAnioPantalla({
    required this.year,
    required this.subjects,
    required this.allSubjects,
    required this.plan,
    required this.payload,
    required this.onDelete,
    required this.onEdit,
    required this.busy,
    required this.isSelfReported,
  });

  final int year;
  final List<MateriaEstudiante> subjects;
  final List<MateriaEstudiante> allSubjects;
  final List<Materia> plan;
  final DatosAccesoEstudiante payload;
  final Future<void> Function(MateriaEstudiante) onDelete;
  final Future<void> Function({MateriaEstudiante? existing}) onEdit;
  final bool busy;
  final bool Function(MateriaEstudiante) isSelfReported;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF0E5E86);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          '$year° año',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: subjects.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No hay materias cargadas en $year° año.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    '${subjects.length} materias en $year° año',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final subject in subjects) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaMateriaPropia(
                        subject: subject,
                        isSelfReported: isSelfReported(subject),
                        onEdit: () => onEdit(existing: subject),
                        onDelete: isSelfReported(subject)
                            ? () => onDelete(subject)
                            : null,
                        busy: busy,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _PaginaEditorMateriaPropia extends StatefulWidget {
  const _PaginaEditorMateriaPropia({
    required this.careerId,
    required this.plan,
    this.existing,
    required this.existingSubjectIds,
    required this.allSubjects,
    required this.studentYear,
  });

  final String careerId;
  final List<Materia> plan;
  final MateriaEstudiante? existing;
  final Set<String> existingSubjectIds;
  final List<MateriaEstudiante> allSubjects;
  final int studentYear;

  @override
  State<_PaginaEditorMateriaPropia> createState() =>
      _PaginaEditorMateriaPropiaState();
}

class _PaginaEditorMateriaPropiaState
    extends State<_PaginaEditorMateriaPropia> {
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
    _gradeCtrl = TextEditingController();
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
        _filteredResults =
            _selectedMateria != null ? [_selectedMateria!] : const [];
      } else {
        _filteredResults = widget.plan.where((m) {
          final name = m.displayNombre.toLowerCase();
          return name.contains(query);
        }).toList()
          ..sort((a, b) {
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

  Widget _buildReqRow(
      CorrelativaDetallada req,
      Map<String, MateriaEstudiante> subjectMap,
      ThemeData theme,
      ColorScheme cs) {
    final ref = subjectMap[_norm(req.id)];
    final status = ref == null
        ? null
        : (ref.status.toLowerCase().trim() == 'aprobada'
            ? 'aprobada'
            : ref.status.toLowerCase().trim());
    final ok = switch (req.type.toUpperCase()) {
      'R' => status == 'regular' || status == 'aprobada',
      _ => status == 'aprobada',
    };
    final label = req.nombre?.isNotEmpty == true ? req.nombre! : req.id;
    final typeLabel = req.type.toUpperCase() == 'R' ? 'Regular' : 'Aprobada';

    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: ok ? const Color(0xFF2EAD57) : cs.outlineVariant,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Requiere $typeLabel',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        if (status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ok
                  ? const Color(0xFF2EAD57).withValues(alpha: 0.10)
                  : const Color(0xFFDC2626).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status == 'aprobada'
                  ? 'Aprobada'
                  : status == 'regular'
                      ? 'Regular'
                      : status,
              style: TextStyle(
                color: ok ? const Color(0xFF2EAD57) : const Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          )
        else
          Text(
            'No cursada',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existing != null;
    const primaryBlue = Color(0xFF0E5E86);

    final examOutline =
        isDark ? const Color(0xFF263448) : const Color(0xFFD2DCE8);
    final examSurface =
        isDark ? const Color(0xFF0D1726) : const Color(0xFFF8FAFC);
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
          icon: Icon(_step == 1 && !isEditing
              ? Icons.arrow_back_rounded
              : Icons.close_rounded),
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
      bottom: true,
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
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: _filteredResults.map((m) {
                      final isSelected = _selectedMateria?.id == m.id;
                      final yaAgregada =
                          widget.existingSubjectIds.contains(m.id);
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
                                      ? const Color(0xFF0E5E86)
                                          .withValues(alpha: 0.08)
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: bloqueada
                                        ? cs.outlineVariant
                                            .withValues(alpha: 0.4)
                                        : isSelected
                                            ? const Color(0xFF0E5E86)
                                            : const Color(0xFFD2DCE8)
                                                .withValues(alpha: 0.5),
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
                                            ? const Color(0xFF0E5E86)
                                                .withValues(alpha: 0.15)
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
                                                    .withValues(alpha: 0.55),
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
                                                color: const Color(0xFFDC2626)
                                                    .withValues(alpha: 0.65),
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
                                        color: cs.onSurfaceVariant
                                            .withValues(alpha: 0.3),
                                        size: 22,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
      bottom: true,
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
                            color:
                                const Color(0xFF0E5E86).withValues(alpha: 0.15),
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
                            color:
                                const Color(0xFF0E5E86).withValues(alpha: 0.15),
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
                        isDense: true,
                        itemHeight: 56,
                        dropdownColor: theme.colorScheme.surface,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'cursando', child: Text('Cursando')),
                          DropdownMenuItem(
                              value: 'regular', child: Text('Regular')),
                          DropdownMenuItem(
                              value: 'aprobada', child: Text('Aprobada')),
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
                            decimal: true),
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
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                    ),
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
            child: SizedBox(
              width: double.infinity,
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
          ),
        ],
      ),
    );
  }
}
