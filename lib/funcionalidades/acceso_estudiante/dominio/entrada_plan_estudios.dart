part of '../pantallas/acceso_estudiante_pantalla.dart';

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

List<_CurriculumEntry> _buildCurriculumEntries(
  List<MateriaEstudiante> subjects,
  List<Materia> plan,
) {
  final subjectById = <String, MateriaEstudiante>{};
  final subjectByName = <String, MateriaEstudiante>{};
  for (final subject in subjects) {
    _addIndex(subjectById, subject.subjectId, subject);
    _addIndex(subjectByName, subject.subjectName, subject);
  }

  return [
    for (final materia in plan)
      _CurriculumEntry(
        materia: materia,
        current: _matchCurrentSubject(
          materia,
          byId: subjectById,
          byName: subjectByName,
        ),
        available: _missingCorrelativas(
          materia,
          subjects,
          plan,
        ).isEmpty,
        missing: _missingCorrelativas(materia, subjects, plan),
      ),
  ];
}

MateriaEstudiante? _matchCurrentSubject(
  Materia materia, {
  required Map<String, MateriaEstudiante> byId,
  required Map<String, MateriaEstudiante> byName,
}) {
  final key = _norm(materia.id);
  final current = byId[key] ?? byName[key];
  if (current != null) return current;

  final nameKey = _norm(materia.displayNombre);
  return byName[nameKey] ?? byId[nameKey];
}

List<String> _missingCorrelativas(
  Materia materia,
  List<MateriaEstudiante> subjects,
  List<Materia> plan,
) {
  final reqs = _resolvedRequirements(materia);

  final subjectById = <String, MateriaEstudiante>{};
  final subjectByName = <String, MateriaEstudiante>{};
  for (final subject in subjects) {
    _addIndex(subjectById, subject.subjectId, subject);
    _addIndex(subjectByName, subject.subjectName, subject);
  }

  final missing = <String>[];
  if (_isUdiMateria(materia) || _isPracticaDocenteIV(materia)) {
    missing.addAll(
      _missingPreviousYearsForUdi(
        materia,
        subjects,
        plan,
        byId: subjectById,
        byName: subjectByName,
      ),
    );
  }

  for (final req in reqs) {
    final ref = _matchRequirementSubject(
      req,
      byId: subjectById,
      byName: subjectByName,
    );
    final displayName = _displayNameForRequirement(req, plan);
    final status = ref == null ? null : _estadoMateriaParaRequisito(ref);
    final ok = switch (req.type.toUpperCase()) {
      'R' => status == 'regular' || status == 'aprobada',
      _ => status == 'aprobada',
    };
    if (!ok) missing.add(displayName);
  }
  return missing;
}

List<CorrelativaDetallada> _resolvedRequirements(Materia materia) {
  if (materia.correlativasDetalladas.isNotEmpty) {
    return materia.correlativasDetalladas;
  }
  return materia.correlativas
      .map(
        (id) => CorrelativaDetallada(
          id: id,
          type: 'A',
          nombre: id,
        ),
      )
      .toList(growable: false);
}

List<_CurriculumEntry> _subjectsUnlockedBy(
  _CurriculumEntry entry,
  List<_CurriculumEntry> allEntries,
) {
  final current = entry.materia;
  final currentKeys = <String>{
    _norm(current.id),
    _norm(current.nombre),
    _norm(current.displayNombre),
  };

  final unlocked = <_CurriculumEntry>[];
  for (final candidate in allEntries) {
    if (candidate.materia.id == current.id) continue;
    final reqs = _resolvedRequirements(candidate.materia);
    final matches = reqs.any((req) {
      final reqKey = _norm(req.id);
      return currentKeys.contains(reqKey);
    });
    if (matches) unlocked.add(candidate);
  }

  unlocked.sort((a, b) {
    final byYear = a.materia.anio.compareTo(b.materia.anio);
    if (byYear != 0) return byYear;
    return a.materia.displayNombre.compareTo(b.materia.displayNombre);
  });
  return unlocked;
}

MateriaEstudiante? _matchRequirementSubject(
  CorrelativaDetallada req, {
  required Map<String, MateriaEstudiante> byId,
  required Map<String, MateriaEstudiante> byName,
}) {
  final reqKey = _norm(req.id);
  return byId[reqKey] ?? byName[reqKey];
}

String _displayNameForRequirement(
    CorrelativaDetallada req, List<Materia> plan) {
  final reqKey = _norm(req.id);
  for (final materia in plan) {
    if (_norm(materia.id) == reqKey ||
        _norm(materia.displayNombre) == reqKey ||
        _norm(materia.nombre) == reqKey) {
      return materia.displayNombre;
    }
  }
  return req.nombre ?? req.id;
}

void _addIndex(
  Map<String, MateriaEstudiante> map,
  String raw,
  MateriaEstudiante value,
) {
  final key = _norm(raw);
  if (key.isNotEmpty) map[key] = value;
}

String _estadoMateriaParaRequisito(MateriaEstudiante subject) {
  final status = subject.status.toLowerCase().trim();
  if (status == 'aprobada') return 'aprobada';
  if (status == 'regular') return 'regular';
  if (subject.academicPeriod == 'equivalencia') return 'aprobada';
  return status;
}

String _subjectCreditDetail(MateriaEstudiante current) {
  final parts = <String>[
    'Aprobada en ${_etiquetaPeriodo(current.academicPeriod).toLowerCase()}',
  ];
  if (current.detailStatus != null) {
    parts.add(_etiquetaMetodoAcreditacion(
        current.academicPeriod, current.detailStatus!));
  }
  if (current.grade != null) {
    parts.add('Nota ${current.grade!.toStringAsFixed(0)}');
  }
  return parts.join(' · ');
}

String _subjectStateForRow(_CurriculumEntry entry) {
  if (entry.current != null) {
    final status = entry.current!.status.toLowerCase().trim();
    return switch (status) {
      'aprobada' => 'Aprobada',
      'cursando' => 'Cursando',
      'regular' => 'Regular',
      'no_regularizada' => 'No regularizada',
      _ => 'Cursando',
    };
  }
  return entry.available ? 'Disponible' : 'No disponible';
}

IconData _subjectStateIcon(_CurriculumEntry entry) {
  final current = entry.current;
  if (current != null) {
    final status = current.status.toLowerCase().trim();
    return switch (status) {
      'aprobada' => Icons.check_circle_rounded,
      'cursando' => Icons.play_circle_rounded,
      'regular' => Icons.assignment_turned_in_rounded,
      'no_regularizada' => Icons.cancel_rounded,
      _ => Icons.school_rounded,
    };
  }
  return entry.available ? Icons.task_alt_rounded : Icons.lock_rounded;
}

Color _subjectStateColor(BuildContext context, _CurriculumEntry entry) {
  final current = entry.current;
  if (current != null) {
    final status = current.status.toLowerCase().trim();
    return switch (status) {
      'aprobada' => const Color(0xFF2EAD57),
      'cursando' => const Color(0xFF1E6FDB),
      'regular' => const Color(0xFFD97706),
      'no_regularizada' => const Color(0xFFDC2626),
      _ => Theme.of(context).colorScheme.secondary,
    };
  }
  return entry.available ? const Color(0xFF0E7490) : const Color(0xFFD93025);
}

bool _isSubjectInProgress(MateriaEstudiante subject) {
  final status = subject.status.toLowerCase().trim();
  return status == 'regular' || status == 'cursando';
}

bool _isSubjectApproved(MateriaEstudiante subject) {
  return _estadoMateriaParaRequisito(subject) == 'aprobada';
}

bool _isEntryBlocked(_CurriculumEntry entry) {
  final current = entry.current;
  if (entry.available) return false;
  if (current == null) return true;
  return !_isSubjectApproved(current) && !_isSubjectInProgress(current);
}

String? _subjectCardDate(
  _CurriculumEntry entry,
  List<EntradaHistorialEstudiante> history,
) {
  final current = entry.current;
  if (current == null) return null;
  if (current.sourceDate != null) {
    return _historyDateLabel(current.sourceDate);
  }
  final steps = _subjectHistorySteps(entry, history);
  if (steps.isEmpty) return null;
  return steps.last.dateLabel;
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

    final dateLabel = _historyDateLabel(item.createdAt) ??
        _historyDateLabel(_parseHistoryDate(payload['source_date']));

    if (isEnrollment && steps.every((step) => step.label != 'Inscripción')) {
      steps.add(
        _PasoHistorialMateria(
          label: 'Inscripción',
          detail: 'Alta de la materia',
          dateLabel: dateLabel,
          color: const Color(0xFF2B6F96),
          icon: Icons.edit_note_rounded,
        ),
      );
    }

    if (isApproved) {
      approvalStep = _PasoHistorialMateria(
        label: 'Acreditación del espacio',
        detail: _historyCreditDetail(payload),
        dateLabel: dateLabel,
        color: const Color(0xFF2EAD57),
        icon: Icons.check_circle_rounded,
      );
    }
  }

  if (steps.isEmpty &&
      approvalStep == null &&
      entry.current?.status.toLowerCase().trim() == 'aprobada') {
    steps.add(
      _PasoHistorialMateria(
        label: 'Inscripción',
        detail: 'Registro inicial',
        dateLabel: _historyDateLabel(entry.current?.sourceDate),
        color: const Color(0xFF2B6F96),
        icon: Icons.edit_note_rounded,
      ),
    );
  }

  if (approvalStep == null &&
      entry.current != null &&
      entry.current!.status.toLowerCase().trim() == 'aprobada') {
    approvalStep = _PasoHistorialMateria(
      label: 'Acreditación del espacio',
      detail: _subjectCreditDetail(entry.current!),
      dateLabel: _historyDateLabel(entry.current!.sourceDate),
      color: const Color(0xFF2EAD57),
      icon: Icons.check_circle_rounded,
    );
  }

  if (approvalStep != null) {
    steps.removeWhere((step) => step.label == 'Acreditación del espacio');
    steps.add(approvalStep);
  }

  return steps;
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

List<_MovimientoEstudiante> _buildStudentMovements(
  List<EntradaHistorialEstudiante> history,
  List<_CurriculumEntry> entries,
) {
  final enrollmentsByDay = <String, List<EntradaHistorialEstudiante>>{};
  final movements = <_MovimientoEstudiante>[];

  _CurriculumEntry? findEntry(String? name) {
    if (name == null || name.isEmpty) return null;
    final normalized = _norm(name);
    return entries.cast<_CurriculumEntry?>().firstWhere(
          (e) =>
              _norm(e!.materia.id) == normalized ||
              _norm(e.materia.displayNombre) == normalized ||
              _norm(e.materia.nombre) == normalized,
          orElse: () => null,
        );
  }

  for (final entry in history) {
    final payload = entry.payload;
    final status = _norm(payload['status']?.toString() ?? '');
    final eventType = _norm(entry.eventType);
    final subjectName = payload['subject_name']?.toString().trim() ?? '';
    final dateLabel = _historyDateLabel(entry.createdAt);
    final dayKey = dateLabel ?? 'sin-fecha';
    final isApproved = status == 'aprobada' ||
        eventType.contains('aprob') ||
        eventType.contains('approve');
    final isEnrollment = !isApproved &&
        (eventType.contains('inscrip') ||
            eventType.contains('enroll') ||
            eventType.contains('upsert') ||
            status == 'cursando' ||
            status == 'regular');

    if (isEnrollment && subjectName.isNotEmpty) {
      enrollmentsByDay.putIfAbsent(dayKey, () => []).add(entry);
      continue;
    }

    if (isApproved && subjectName.isNotEmpty) {
      movements.add(
        _MovimientoEstudiante(
          title: 'Aprobó $subjectName',
          detail: _historyCreditDetail(payload),
          dateLabel: dateLabel,
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF2EAD57),
          entry: findEntry(subjectName),
        ),
      );
    }

    if (eventType.contains('contact')) {
      movements.add(
        _MovimientoEstudiante(
          title: 'Actualizó sus datos de contacto',
          detail: _contactHistoryDetail(payload),
          dateLabel: dateLabel,
          icon: Icons.contact_phone_rounded,
          color: const Color(0xFF2B6F96),
        ),
      );
    }
  }

  for (final entry in enrollmentsByDay.entries) {
    final rows = entry.value;
    rows.sort((a, b) {
      final aName = a.payload['subject_name']?.toString() ?? '';
      final bName = b.payload['subject_name']?.toString() ?? '';
      return aName.compareTo(bName);
    });
    final names = rows
        .map((row) => row.payload['subject_name']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names.isEmpty) continue;
    final extra = names.length > 2 ? ' +${names.length - 2}' : '';
    movements.add(
      _MovimientoEstudiante(
        title: names.length == 1
            ? 'Se inscribió a ${names.first}'
            : 'Se inscribió a varias materias',
        detail: '${names.take(2).join(' · ')}$extra',
        dateLabel: entry.key == 'sin-fecha' ? null : entry.key,
        icon: Icons.playlist_add_check_rounded,
        color: const Color(0xFF2B6F96),
        entry: names.length == 1 ? findEntry(names.first) : null,
      ),
    );
  }

  movements.sort((a, b) {
    final aDate = _parseDisplayDate(a.dateLabel) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = _parseDisplayDate(b.dateLabel) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });
  return movements;
}

List<_EventoCalendarioAcademico> _buildAcademicCalendarEvents(
  List<EntradaHistorialEstudiante> history,
  List<_CurriculumEntry> entries,
) {
  final events = <_EventoCalendarioAcademico>[];
  final dedupe = <String>{};

  void addEvent(_EventoCalendarioAcademico event) {
    final key =
        '${_dateOnly(event.date).toIso8601String()}|${_norm(event.title)}|${_norm(event.detail)}';
    if (dedupe.add(key)) {
      events.add(event);
    }
  }

  for (final movement in _buildStudentMovements(history, entries)) {
    final date = _parseDisplayDate(movement.dateLabel);
    if (date == null) continue;
    addEvent(
      _EventoCalendarioAcademico(
        date: date,
        title: movement.title,
        detail: movement.detail,
        icon: movement.icon,
        color: movement.color,
        entry: movement.entry,
      ),
    );
  }

  for (final entry in entries) {
    final current = entry.current;
    if (current == null || current.sourceDate == null) continue;
    if (!_isSubjectApproved(current)) continue;
    addEvent(
      _EventoCalendarioAcademico(
        date: current.sourceDate!,
        title: 'Aprob\u00f3 ${entry.materia.displayNombre}',
        detail: current.grade == null
            ? 'Materia acreditada'
            : 'Materia acreditada \u00b7 Nota ${current.grade!.toStringAsFixed(0)}',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF2EAD57),
        entry: entry,
      ),
    );
  }

  events.sort((a, b) => b.date.compareTo(a.date));
  return events;
}

String _progressDiagnosis({
  required PerfilAccesoEstudiante student,
  required int approved,
  required int available,
  required int blocked,
}) {
  if (available == 0 && blocked > 0) {
    return 'Hoy no ten\u00e9s materias nuevas habilitadas. Conviene cerrar materias en curso o revisar correlativas pendientes para destrabar el siguiente tramo.';
  }
  if (available >= 4) {
    return 'Ten\u00e9s un margen amplio para elegir cursadas. Est\u00e1s en un momento favorable para priorizar materias que ordenen mejor el resto del recorrido.';
  }
  if (approved <= 4) {
    return 'Tu trayectoria todav\u00eda est\u00e1 en una etapa inicial. Suma mucho consolidar las bases del ${student.yearLabel.toLowerCase()} antes de abrir demasiados frentes.';
  }
  return 'Tu avance est\u00e1 equilibrado. Ya hay materias acreditadas y tambi\u00e9n opciones disponibles para seguir moviendo el plan sin perder continuidad.';
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _etiquetaMes(DateTime value) {
  const months = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

String _historyCreditDetail(Map<String, dynamic> payload) {
  final parts = <String>[];
  final period = (payload['academic_period'] ?? payload['source_period'] ?? '')
      .toString()
      .trim();
  if (period.isNotEmpty) {
    parts.add('Aprobada en ${_etiquetaPeriodo(period).toLowerCase()}');
  } else {
    parts.add('Aprobada');
  }
  final detail = payload['detail_status']?.toString().trim() ?? '';
  if (detail.isNotEmpty) parts.add(_etiquetaMetodoAcreditacion(period, detail));
  final grade = payload['grade'];
  if (grade != null && grade.toString().trim().isNotEmpty) {
    final parsed = num.tryParse(grade.toString());
    parts.add(
        parsed == null ? 'Nota $grade' : 'Nota ${parsed.toStringAsFixed(0)}');
  }
  return parts.join(' · ');
}

String _contactHistoryDetail(Map<String, dynamic> payload) {
  final parts = <String>[];
  final phone = payload['contact_phone']?.toString().trim() ?? '';
  final email = payload['contact_email']?.toString().trim() ?? '';
  if (phone.isNotEmpty) parts.add('Teléfono cargado');
  if (email.isNotEmpty) parts.add('E-mail cargado');
  if (parts.isEmpty) return 'Actualización de contacto';
  return parts.join(' · ');
}

String _etiquetaMetodoAcreditacion(String period, String detail) {
  final normalizedPeriod = _norm(period);
  final normalizedDetail = _norm(detail);
  if (normalizedDetail == 'mesa_final' &&
      (normalizedPeriod == 'mayo' ||
          normalizedPeriod == 'mayo_extraordinaria' ||
          normalizedPeriod == 'mayo extraordinaria')) {
    return 'Mesa extraordinaria';
  }
  return _etiquetaDetalle(detail);
}

DateTime? _parseDisplayDate(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final parts = text.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

bool _isUdiMateria(Materia materia) {
  final name = _norm(materia.displayNombre);
  final format = _norm(materia.formato);
  return format.contains('variable') &&
      (name.contains('udi') ||
          name.contains('unidad de definicion institucional'));
}

bool _isPracticaDocenteIV(Materia materia) {
  final raw = _norm(materia.displayNombre);
  final hasPractica = raw.contains('practica');
  final hasIv = RegExp(r'\b(iv|4|cuarta)\b').hasMatch(raw);
  final docenteResid = raw.contains('docente') || raw.contains('residencia');
  return hasPractica && hasIv && docenteResid;
}

List<String> _missingPreviousYearsForUdi(
  Materia materia,
  List<MateriaEstudiante> subjects,
  List<Materia> plan, {
  required Map<String, MateriaEstudiante> byId,
  required Map<String, MateriaEstudiante> byName,
}) {
  if (materia.anio <= 1) return const [];

  final missing = <String>[];
  for (var year = 1; year < materia.anio; year++) {
    final yearMaterias = plan.where((item) => item.anio == year).toList();
    if (yearMaterias.isEmpty) continue;

    final allApproved = yearMaterias.every((yearMateria) {
      final current = _matchCurrentSubject(
        yearMateria,
        byId: byId,
        byName: byName,
      );
      if (current == null) return false;
      return _estadoMateriaParaRequisito(current) == 'aprobada';
    });

    if (!allApproved) {
      missing.add('${_etiquetaAnio(year)} año completo');
    }
  }
  return missing;
}

String _etiquetaAnio(int year) {
  return switch (year) {
    1 => '1°',
    2 => '2°',
    3 => '3°',
    4 => '4°',
    _ => '$year°',
  };
}

String _etiquetaEstadoInscripcion(String value) {
  return switch (_norm(value)) {
    'active' => 'Activo',
    'inactive' => 'Inactivo',
    'pending' => 'Pendiente',
    _ => value,
  };
}

String _careerAssetFor(String careerId) {
  return switch (careerId) {
    'historia' => 'assets/historia.html',
    'geografia' => 'assets/geografia.html',
    'politica' => 'assets/politica.html',
    'artes_visuales' => 'assets/datos/artes_visuales.json',
    'musica' => 'assets/Musica.html',
    _ => 'assets/historia.html',
  };
}

String _institutionLogoAssetFor(String careerId) {
  return switch (careerId) {
    'artes_visuales' => 'assets/career_icons/logo_artes.png',
    'historia' ||
    'geografia' ||
    'politica' =>
      'assets/career_icons/career_logo.png',
    _ => 'assets/career_icons/career_logo.png',
  };
}

String _etiquetaCarrera(String careerId) {
  return switch (careerId) {
    'artes_visuales' => 'Artes Visuales',
    'musica' => 'Música',
    'historia' => 'Historia',
    'geografia' => 'Geografía',
    'politica' => 'Ciencia Política',
    _ => careerId,
  };
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

String _norm(String value) =>
    sanitizeLowerNoAccents(value).replaceAll(RegExp(r'\s+'), ' ').trim();
