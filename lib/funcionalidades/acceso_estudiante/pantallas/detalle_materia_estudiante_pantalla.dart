import 'package:flutter/material.dart';

import '../../../modelos/materia.dart';
import '../../../compartido/componentes/tarjetas_metricas.dart';
import '../modelos/modelos_acceso_estudiante.dart';

/// Pantalla pública de detalle de materia (estado, historial, correlativas)
class DetalleMateriaEstudiantePantalla extends StatelessWidget {
  const DetalleMateriaEstudiantePantalla({
    super.key,
    required this.materia,
    required this.allSubjects,
    required this.history,
    required this.plan,
  });

  final Materia materia;
  final List<MateriaEstudiante> allSubjects;
  final List<EntradaHistorialEstudiante> history;
  final List<Materia> plan;

  @override
  Widget build(BuildContext context) {
    final entry = _buildEntry();
    final current = entry.current;
    final historySteps = _subjectHistorySteps(entry, history);
    final unlocks = _subjectsUnlockedBy(entry);

    return Scaffold(
      appBar: _BannerDetalleMateria(title: materia.displayNombre),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        children: [
          _TableroEstadoMateria(entry: entry),
          _TarjetaHistorialMateria(steps: historySteps),
          const SizedBox(height: 16),
          _TarjetaVidrio(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current != null && _isSubjectApproved(current)
                      ? 'Lo que desbloquea'
                      : 'Correlativas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                if (current != null && _isSubjectApproved(current)) ...[
                  Text(
                    'Aprobar esta materia te permite avanzar en estas materias:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (unlocks.isEmpty)
                    Text(
                      'No desbloquea otras materias del plan.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  else
                    Column(
                      children: [
                        for (final unlock in unlocks.take(8)) ...[
                          _UnlockRow(title: unlock.displayNombre),
                          const SizedBox(height: 10),
                        ],
                        if (unlocks.length > 8)
                          Text(
                            '+ ${unlocks.length - 8} materias más',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                ] else if (entry.missing.isEmpty) ...[
                  Text(
                    current != null
                        ? 'Cumplís con los requisitos de correlativas.'
                        : 'Materia desbloqueada. Podés cursar o rendir.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ] else ...[
                  Text(
                    'Te faltan estas correlativas:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in entry.missing)
                        _EtiquetaEstado(label: item),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _CurriculumEntry _buildEntry() {
    final subjectById = <String, MateriaEstudiante>{};
    for (final s in allSubjects) {
      final k = _norm(s.subjectId);
      if (k.isNotEmpty) subjectById[k] = s;
    }

    final current = _matchCurrentSubject(subjectById);
    final missing = _missingCorrelativas(subjectById);

    return _CurriculumEntry(
      materia: materia,
      current: current,
      available: missing.isEmpty,
      missing: missing,
    );
  }

  MateriaEstudiante? _matchCurrentSubject(
    Map<String, MateriaEstudiante> byId,
  ) {
    final key = _norm(materia.id);
    return byId[key];
  }

  List<String> _missingCorrelativas(
    Map<String, MateriaEstudiante> byId,
  ) {
    final reqs = _resolvedRequirements(materia);
    final missing = <String>[];

    for (final req in reqs) {
      final reqKey = _norm(req.id);
      final ref = byId[reqKey];
      final status = ref == null ? null : _estadoMateriaParaRequisito(ref);
      final ok = switch (req.type.toUpperCase()) {
        'R' => status == 'regular' || status == 'aprobada',
        _ => status == 'aprobada',
      };
      if (!ok) {
        missing.add(_displayNameForRequirement(req));
      }
    }
    return missing;
  }

  List<Materia> _subjectsUnlockedBy(_CurriculumEntry entry) {
    final currentKeys = <String>{
      _norm(materia.id),
      _norm(materia.nombre),
      _norm(materia.displayNombre),
    };

    final unlocked = <Materia>[];
    for (final candidate in plan) {
      if (candidate.id == materia.id) continue;
      final reqs = _resolvedRequirements(candidate);
      final matches = reqs.any((req) => currentKeys.contains(_norm(req.id)));
      if (matches) unlocked.add(candidate);
    }

    unlocked.sort((a, b) {
      final byYear = a.anio.compareTo(b.anio);
      if (byYear != 0) return byYear;
      return a.displayNombre.compareTo(b.displayNombre);
    });
    return unlocked;
  }

  String _displayNameForRequirement(CorrelativaDetallada req) {
    final reqKey = _norm(req.id);
    for (final m in plan) {
      if (_norm(m.id) == reqKey ||
          _norm(m.displayNombre) == reqKey ||
          _norm(m.nombre) == reqKey) {
        return m.displayNombre;
      }
    }
    return req.nombre ?? req.id;
  }

  List<CorrelativaDetallada> _resolvedRequirements(Materia m) {
    if (m.correlativasDetalladas.isNotEmpty) return m.correlativasDetalladas;
    return m.correlativas
        .map((id) => CorrelativaDetallada(id: id, type: 'A', nombre: id))
        .toList(growable: false);
  }

  String _norm(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _estadoMateriaParaRequisito(MateriaEstudiante subject) {
    final status = subject.status.toLowerCase().trim();
    if (status == 'aprobada') return 'aprobada';
    if (status == 'regular') return 'regular';
    if (subject.academicPeriod == 'equivalencia') return 'aprobada';
    return status;
  }

  bool _isSubjectApproved(MateriaEstudiante subject) {
    return _estadoMateriaParaRequisito(subject) == 'aprobada';
  }

  List<_PasoHistorialMateria> _subjectHistorySteps(
    _CurriculumEntry entry,
    List<EntradaHistorialEstudiante> history,
  ) {
    final subjectKeys = <String>{
      _norm(entry.materia.id),
      _norm(entry.materia.nombre),
      _norm(entry.materia.displayNombre),
    };

    final matching = <EntradaHistorialEstudiante>[];
    for (final item in history) {
      final payload = item.payload;
      final payloadKeys = <String>{
        _norm(payload['subject_id']?.toString() ?? ''),
        _norm(payload['subject_name']?.toString() ?? ''),
        _norm(payload['subject']?.toString() ?? ''),
      };
      if (payloadKeys.any(subjectKeys.contains)) matching.add(item);
    }

    matching.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });

    final steps = <_PasoHistorialMateria>[];
    _PasoHistorialMateria? approvalStep;

    for (final item in matching) {
      final payload = item.payload;
      final status = _norm(payload['status']?.toString() ?? '');
      final eventType = _norm(item.eventType);
      final isApproved = status == 'aprobada' ||
          eventType.contains('aprob') ||
          eventType.contains('approve');
      final isEnrollment = !isApproved &&
          (eventType.contains('inscrip') ||
              eventType.contains('enroll') ||
              eventType.contains('upsert') ||
              status == 'cursando' ||
              status == 'regular');

      final historyDateLabel =
          _historyDateLabel(_parseHistoryDate(payload['source_date'])) ??
              _historyDateLabel(item.createdAt);

      if (isEnrollment && steps.every((step) => step.label != 'Inscripción')) {
        steps.add(_PasoHistorialMateria(
          label: 'Inscripción',
          detail: 'Alta de la materia',
          dateLabel: historyDateLabel,
          color: const Color(0xFF2B6F96),
          icon: Icons.edit_note_rounded,
        ));
      }

      if (isApproved) {
        final current = entry.current;
        approvalStep = _PasoHistorialMateria(
          label: 'Acreditación del espacio',
          detail: current == null
              ? _historyCreditDetail(payload)
              : _subjectCreditDetail(current),
          dateLabel: _historyDateLabel(current?.sourceDate) ?? historyDateLabel,
          color: const Color(0xFF2EAD57),
          icon: Icons.check_circle_rounded,
        );
      }
    }

    if (approvalStep != null) {
      steps.removeWhere((step) => step.label == 'Acreditación del espacio');
      steps.add(approvalStep);
    }

    return steps;
  }

  String _historyCreditDetail(Map<String, dynamic> payload) {
    final parts = <String>[];
    final period =
        (payload['academic_period'] ?? payload['source_period'] ?? '')
            .toString()
            .trim();
    if (period.isNotEmpty) {
      parts.add('Aprobada en ${_etiquetaPeriodo(period).toLowerCase()}');
    } else {
      parts.add('Aprobada');
    }
    final detail = payload['detail_status']?.toString().trim() ?? '';
    if (detail.isNotEmpty) parts.add(_etiquetaDetalle(detail));
    final grade = payload['grade'];
    if (grade != null && grade.toString().trim().isNotEmpty) {
      final parsed = num.tryParse(grade.toString());
      parts.add(
        parsed == null ? 'Nota $grade' : 'Nota ${parsed.toStringAsFixed(0)}',
      );
    }
    return parts.join(' · ');
  }

  String _subjectCreditDetail(MateriaEstudiante current) {
    final parts = <String>[
      'Aprobada en ${(current.sourceDate != null ? nombreMesAcademico(current.sourceDate!) : _etiquetaPeriodo(current.academicPeriod)).toLowerCase()}',
    ];
    if (current.detailStatus != null) {
      parts.add(_etiquetaDetalle(current.detailStatus!));
    }
    if (current.grade != null) {
      parts.add('Nota ${current.grade!.toStringAsFixed(0)}');
    }
    return parts.join(' · ');
  }

  DateTime? _parseHistoryDate(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  String? _historyDateLabel(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _etiquetaPeriodo(String value) {
    return switch (value) {
      'diciembre' => 'Diciembre',
      'febrero_marzo' => 'Febrero-marzo',
      'febrero-marzo' => 'Febrero-marzo',
      'febrero' => 'Febrero-marzo',
      'julio' => 'Julio',
      'mayo' => 'Mayo',
      'mayo_extraordinaria' => 'Mayo extraordinaria',
      'regular' => 'Regular',
      'cursada' => 'Cursada',
      'tif' => 'TIF',
      'equivalencia' => 'Equivalencia',
      'ajuste' => 'Ajuste',
      _ => value,
    };
  }

  String _etiquetaDetalle(String value) {
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
}

// ── Helpers ──────────────────────────────────────────────
ThemeData themeTextTheme(BuildContext context) => Theme.of(context);
ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;

String _etiquetaPeriodoTop(String value) {
  return switch (value) {
    'diciembre' => 'Diciembre',
    'febrero_marzo' => 'Febrero-marzo',
    'febrero-marzo' => 'Febrero-marzo',
    'febrero' => 'Febrero-marzo',
    'julio' => 'Julio',
    'mayo' => 'Mayo',
    'mayo_extraordinaria' => 'Mayo extraordinaria',
    'regular' => 'Regular',
    'cursada' => 'Cursada',
    'tif' => 'TIF',
    'equivalencia' => 'Equivalencia',
    'ajuste' => 'Ajuste',
    _ => value,
  };
}

class _CurriculumEntry {
  const _CurriculumEntry({
    required this.materia,
    required this.current,
    required this.available,
    required this.missing,
  });

  final Materia materia;
  final MateriaEstudiante? current;
  final bool available;
  final List<String> missing;
}

class _PasoHistorialMateria {
  const _PasoHistorialMateria({
    required this.label,
    required this.detail,
    required this.dateLabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final String? detail;
  final String? dateLabel;
  final Color color;
  final IconData icon;
}

// ── Banner azul ──────────────────────────────────────────
class _BannerDetalleMateria extends StatelessWidget
    implements PreferredSizeWidget {
  const _BannerDetalleMateria({required this.title});

  final String title;

  static const Color _c1 = Color(0xFF005B7F);
  static const Color _c2 = Color(0xFF004966);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _c1,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c1, _c2],
          ),
        ),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1.15,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ── UnlockRow ────────────────────────────────────────────
class _UnlockRow extends StatelessWidget {
  const _UnlockRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_open_rounded, size: 18, color: cs.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _CompactInsignia(label: 'Desbloquea', color: cs.tertiary),
        ],
      ),
    );
  }
}

// ── History Card ─────────────────────────────────────────
class _TarjetaHistorialMateria extends StatelessWidget {
  const _TarjetaHistorialMateria({required this.steps});

  final List<_PasoHistorialMateria> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _TarjetaVidrio(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movimientos de la materia',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (steps.isEmpty)
            Text(
              'Todavía no hay movimientos guardados para esta materia.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                for (final step in steps) ...[
                  _FilaHistorialMateria(step: step),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _FilaHistorialMateria extends StatelessWidget {
  const _FilaHistorialMateria({required this.step});

  final _PasoHistorialMateria step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: step.color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(step.icon, color: step.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (step.dateLabel != null)
                      Text(
                        step.dateLabel!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (step.detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.detail!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Dashboard ─────────────────────────────────────
class _TableroEstadoMateria extends StatelessWidget {
  const _TableroEstadoMateria({required this.entry});

  final _CurriculumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = entry.current;

    final bool isApproved =
        current != null && _isSubjectApprovedStatic(current);
    final bool isInProgress = current != null && _isSubjectInProgress(current);
    final bool isBlocked = !entry.available;

    final Color statusColor = isApproved
        ? const Color(0xFF2EAD57)
        : isInProgress
            ? const Color(0xFF1E6FDB)
            : isBlocked
                ? const Color(0xFFDC2626)
                : cs.onSurfaceVariant;

    final IconData statusIcon = isApproved
        ? Icons.check_circle_rounded
        : isInProgress
            ? Icons.play_circle_rounded
            : isBlocked
                ? Icons.block_rounded
                : Icons.remove_circle_outline_rounded;

    final String statusLabel = isApproved
        ? 'Aprobada'
        : isInProgress
            ? 'Cursando'
            : isBlocked
                ? 'No disponible'
                : 'Sin cursar';

    final String? noteLabel = current?.grade != null
        ? 'Nota ${current!.grade!.toStringAsFixed(0)}'
        : null;
    final bool hasSourceDate = current?.sourceDate != null;
    final noteFlex = hasSourceDate ? 3 : 4;

    const double spacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: TarjetaMetricaVidrio(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 22,
                          color: statusColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Estado actual',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revisá el estado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                flex: 2,
                child: TarjetaMetricaVidrio(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(statusIcon, size: 26, color: statusColor),
                      const Spacer(),
                      Text(
                        statusLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (current != null && noteLabel != null) ...[
          const SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: noteFlex,
                  child: TarjetaMetricaVidrio(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 22,
                          color: const Color(0xFFD97706),
                        ),
                        const Spacer(),
                        Text(
                          noteLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          current.sourceDate != null
                              ? nombreMesAcademico(current.sourceDate!)
                              : _etiquetaPeriodoTop(current.academicPeriod),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasSourceDate) ...[
                  const SizedBox(width: spacing),
                  Expanded(
                    flex: 3,
                    child: TarjetaMetricaVidrio(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 22,
                            color: Color(0xFF7C3AED),
                          ),
                          const Spacer(),
                          Text(
                            '${current.sourceDate!.year}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${current.sourceDate!.day.toString().padLeft(2, '0')}/${current.sourceDate!.month.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

bool _isSubjectApprovedStatic(MateriaEstudiante subject) {
  final status = subject.status.toLowerCase().trim();
  return status == 'aprobada' || subject.academicPeriod == 'equivalencia';
}

bool _isSubjectInProgress(MateriaEstudiante subject) {
  final status = subject.status.toLowerCase().trim();
  return status == 'regular' || status == 'cursando';
}

// ── Small widgets ────────────────────────────────────────
class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CompactInsignia extends StatelessWidget {
  const _CompactInsignia({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
      ),
    );
  }
}

class _TarjetaVidrio extends StatelessWidget {
  const _TarjetaVidrio({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1020) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? const Color(0xFF21304A) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
