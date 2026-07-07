import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../datos/cargador_fuente_html.dart';
import '../../../modelos/materia.dart';
import '../../../compartido/supabase/supabase.dart';
import '../datos/repositorio_acceso_estudiante.dart';
import '../modelos/modelos_acceso_estudiante.dart';
import '../componentes/tarjeta_selector_anio.dart';
import 'materias_por_anio_pantalla.dart';
import 'pagina_editor_materia_propia.dart';

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

  Future<bool> _openEditor({MateriaEstudiante? existing}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => PaginaEditorMateriaPropia(
          careerId: widget.payload.student.careerId,
          plan: _plan,
          existing: existing,
          existingSubjectIds: existing != null
              ? {}
              : _allSubjects.map((s) => s.subjectId).toSet(),
          allSubjects: _allSubjects,
          studentYear: widget.payload.student.currentYear ?? 1,
          canDelete: existing != null && _isSelfReported(existing),
        ),
      ),
    );
    if (result == null) return false;
    if (result['delete'] == true && existing != null) {
      await _deleteSubject(existing);
      return true;
    }

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
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${result['subject_name']}" guardada.')),
      );
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    return false;
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
                    TarjetaSelectorAnio(
                      year: year,
                      count: grouped[year]?.length ?? 0,
                      totalInPlan: _plan.where((m) => m.anio == year).length,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => MateriasPorAnioPantalla(
                              year: year,
                              subjects: grouped[year] ?? [],
                              allSubjects: _allSubjects,
                              plan: _plan,
                              payload: widget.payload,
                              onEdit: _openEditor,
                              busy: _busy,
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
