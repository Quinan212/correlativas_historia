class PerfilAccesoEstudiante {
  const PerfilAccesoEstudiante({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.careerId,
    required this.isDemo,
    this.cohortYear,
    this.currentYear,
    this.division,
    required this.isNewStudent,
    required this.isRepeating,
    required this.enrollmentStatus,
    this.contactPhone,
    this.contactEmail,
    this.notes,
  });

  final String id;
  final String dni;
  final String firstName;
  final String lastName;
  final String careerId;
  final bool isDemo;
  final int? cohortYear;
  final int? currentYear;
  final String? division;
  final bool isNewStudent;
  final bool isRepeating;
  final String enrollmentStatus;
  final String? contactPhone;
  final String? contactEmail;
  final String? notes;

  String get fullName => '$lastName, $firstName';

  String get yearLabel => switch (currentYear ?? 1) {
    1 => '1er año',
    2 => '2do año',
    3 => '3er año',
    4 => '4to año',
    _ => '1er año',
  };

  factory PerfilAccesoEstudiante.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return PerfilAccesoEstudiante(
      id: (json['id'] ?? '').toString(),
      dni: (json['dni'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      careerId: (json['career_id'] ?? 'artes_visuales').toString(),
      isDemo: json['is_demo'] == true,
      cohortYear: parseInt(json['cohort_year']),
      currentYear: parseInt(json['current_year']),
      division: _emptyToNull(json['division']),
      isNewStudent: json['is_new_student'] != false,
      isRepeating: json['is_repeating'] == true,
      enrollmentStatus: (json['enrollment_status'] ?? 'active').toString(),
      contactPhone: _emptyToNull(json['contact_phone']),
      contactEmail: _emptyToNull(json['contact_email']),
      notes: _emptyToNull(json['notes']),
    );
  }
}

class MateriaEstudiante {
  const MateriaEstudiante({
    required this.subjectId,
    required this.subjectName,
    required this.subjectYear,
    required this.status,
    required this.academicPeriod,
    this.sourceDate,
    this.grade,
    this.detailStatus,
  });

  final String subjectId;
  final String subjectName;
  final int? subjectYear;
  final String status;
  final String academicPeriod;
  final DateTime? sourceDate;
  final num? grade;
  final String? detailStatus;

  factory MateriaEstudiante.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      return num.tryParse(value.toString());
    }

    return MateriaEstudiante(
      subjectId: (json['subject_id'] ?? '').toString(),
      subjectName: (json['subject_name'] ?? '').toString(),
      subjectYear: parseInt(json['subject_year']),
      status: (json['status'] ?? 'cursando').toString(),
      academicPeriod: (json['academic_period'] ?? 'regular').toString(),
      sourceDate: DateTime.tryParse((json['source_date'] ?? '').toString()),
      grade: parseNum(json['grade']),
      detailStatus: _emptyToNull(json['detail_status']),
    );
  }
}

class EntradaHistorialEstudiante {
  const EntradaHistorialEstudiante({
    required this.eventType,
    required this.createdAt,
    required this.payload,
  });

  final String eventType;
  final DateTime? createdAt;
  final Map<String, dynamic> payload;

  factory EntradaHistorialEstudiante.fromJson(Map<String, dynamic> json) {
    return EntradaHistorialEstudiante(
      eventType: (json['event_type'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      payload:
          (json['payload'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
  }
}

class DatosAccesoEstudiante {
  const DatosAccesoEstudiante({
    required this.student,
    required this.subjects,
    required this.history,
    this.selfSubjects = const [],
  });

  final PerfilAccesoEstudiante student;
  final List<MateriaEstudiante> subjects;
  final List<EntradaHistorialEstudiante> history;
  final List<MateriaEstudiante> selfSubjects;

  List<MateriaEstudiante> get combinedSubjects {
    final selfIds = selfSubjects.map((s) => s.subjectId).toSet();
    final filteredOfficial = subjects
        .where((s) => !selfIds.contains(s.subjectId))
        .toList();
    return [...filteredOfficial, ...selfSubjects];
  }

  factory DatosAccesoEstudiante.fromJson(Map<String, dynamic> json) {
    return DatosAccesoEstudiante(
      student: PerfilAccesoEstudiante.fromJson(
        (json['student'] as Map).cast<String, dynamic>(),
      ),
      subjects: (json['subjects'] as List? ?? const [])
          .whereType<Map>()
          .map((row) => MateriaEstudiante.fromJson(row.cast<String, dynamic>()))
          .toList(growable: false),
      history: (json['history'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (row) => EntradaHistorialEstudiante.fromJson(
              row.cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      selfSubjects: (json['self_subjects'] as List? ?? const [])
          .whereType<Map>()
          .map((row) => MateriaEstudiante.fromJson(row.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

String? _emptyToNull(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

String nombreMesAcademico(DateTime date) => const <String>[
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
][date.month - 1];
