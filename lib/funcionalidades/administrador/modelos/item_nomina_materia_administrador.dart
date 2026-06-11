import 'materia_estudiante_administrador.dart';

class ItemNominaMateriaAdministrador {
  const ItemNominaMateriaAdministrador({
    required this.studentId,
    required this.dni,
    required this.firstName,
    required this.lastName,
    this.currentYear,
    this.division,
    required this.subject,
  });

  final String studentId;
  final String dni;
  final String firstName;
  final String lastName;
  final int? currentYear;
  final String? division;
  final MateriaEstudianteAdministrador subject;

  String get fullName => '$lastName, $firstName';

  factory ItemNominaMateriaAdministrador.fromRow(Map<String, dynamic> row) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    final student =
        (row['academic_students'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};

    return ItemNominaMateriaAdministrador(
      studentId: (row['student_id'] ?? '').toString(),
      dni: (student['dni'] ?? '').toString(),
      firstName: (student['first_name'] ?? '').toString(),
      lastName: (student['last_name'] ?? '').toString(),
      currentYear: parseInt(student['current_year']),
      division: _emptyToNull(student['division']),
      subject: MateriaEstudianteAdministrador.fromRow(row),
    );
  }
}

String? _emptyToNull(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
