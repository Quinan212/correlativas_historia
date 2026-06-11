class EstudianteAdministrador {
  const EstudianteAdministrador({
    this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.careerId,
    required this.isDemo,
    this.cohortYear,
    this.currentYear,
    this.academicProgressCount = 0,
    this.division,
    required this.isNewStudent,
    required this.isRepeating,
    required this.enrollmentStatus,
    required this.initialPassword,
    required this.mustChangePassword,
    this.notes,
  });

  final String? id;
  final String dni;
  final String firstName;
  final String lastName;
  final String careerId;
  final bool isDemo;
  final int? cohortYear;
  final int? currentYear;
  final int academicProgressCount;
  final String? division;
  final bool isNewStudent;
  final bool isRepeating;
  final String enrollmentStatus;
  final String initialPassword;
  final bool mustChangePassword;
  final String? notes;

  String get fullName => '$lastName, $firstName';

  factory EstudianteAdministrador.fromRow(Map<String, dynamic> row) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return EstudianteAdministrador(
      id: row['id']?.toString(),
      dni: (row['dni'] ?? '').toString(),
      firstName: (row['first_name'] ?? '').toString(),
      lastName: (row['last_name'] ?? '').toString(),
      careerId: (row['career_id'] ?? 'artes_visuales').toString(),
      isDemo: row['is_demo'] == true,
      cohortYear: parseInt(row['cohort_year']),
      currentYear: parseInt(row['current_year']),
      academicProgressCount: parseInt(row['academic_progress_count']) ?? 0,
      division: _emptyToNull(row['division']),
      isNewStudent: row['is_new_student'] != false,
      isRepeating: row['is_repeating'] == true,
      enrollmentStatus: (row['enrollment_status'] ?? 'active').toString(),
      initialPassword: (row['initial_password'] ??
              BorradorEstudianteAdministrador.defaultPassword)
          .toString(),
      mustChangePassword: row['must_change_password'] != false,
      notes: _emptyToNull(row['notes']),
    );
  }
}

class BorradorEstudianteAdministrador {
  const BorradorEstudianteAdministrador({
    this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.careerId,
    this.isDemo = false,
    this.cohortYear,
    this.currentYear,
    this.academicProgressCount = 0,
    this.division,
    required this.isNewStudent,
    required this.isRepeating,
    this.enrollmentStatus = 'active',
    this.initialPassword = defaultPassword,
    this.mustChangePassword = true,
    this.notes,
  });

  static const defaultPassword = 'Correlativas.2026';

  final String? id;
  final String dni;
  final String firstName;
  final String lastName;
  final String careerId;
  final bool isDemo;
  final int? cohortYear;
  final int? currentYear;
  final int academicProgressCount;
  final String? division;
  final bool isNewStudent;
  final bool isRepeating;
  final String enrollmentStatus;
  final String initialPassword;
  final bool mustChangePassword;
  final String? notes;

  Map<String, dynamic> toPayload() {
    return {
      if (id != null) 'id': id,
      'dni': dni.replaceAll(RegExp(r'\D'), ''),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'career_id': careerId,
      'is_demo': isDemo,
      'cohort_year': cohortYear,
      'current_year': currentYear,
      'academic_progress_count': academicProgressCount,
      'division': _blankToNull(division),
      'is_new_student': isNewStudent,
      'is_repeating': isRepeating,
      'enrollment_status': enrollmentStatus,
      'initial_password': initialPassword.trim().isEmpty
          ? defaultPassword
          : initialPassword.trim(),
      'must_change_password': mustChangePassword,
      'notes': _blankToNull(notes),
    };
  }
}

String? _emptyToNull(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

String? _blankToNull(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? null : text;
}
