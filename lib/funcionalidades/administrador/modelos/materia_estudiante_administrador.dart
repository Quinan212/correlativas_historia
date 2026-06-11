class MateriaEstudianteAdministrador {
  const MateriaEstudianteAdministrador({
    this.id,
    required this.studentId,
    required this.careerId,
    required this.subjectId,
    required this.subjectName,
    this.subjectYear,
    required this.status,
    required this.conditionStatus,
    this.detailStatus,
    this.creditType,
    this.academicPeriod,
    this.sourceDate,
    this.grade,
    this.conditionDeadline,
    this.notes,
    this.adminNote,
  });

  final String? id;
  final String studentId;
  final String careerId;
  final String subjectId;
  final String subjectName;
  final int? subjectYear;
  final String status;
  final String conditionStatus;
  final String? detailStatus;
  final String? creditType;
  final String? academicPeriod;
  final DateTime? sourceDate;
  final double? grade;
  final DateTime? conditionDeadline;
  final String? notes;
  final String? adminNote;

  bool get isApproved => status == 'aprobada';
  bool get isRegular => status == 'regular' || isApproved;

  factory MateriaEstudianteAdministrador.fromRow(Map<String, dynamic> row) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.'));
    }

    DateTime? parseDate(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    return MateriaEstudianteAdministrador(
      id: row['id']?.toString(),
      studentId: (row['student_id'] ?? '').toString(),
      careerId: (row['career_id'] ?? '').toString(),
      subjectId: (row['subject_id'] ?? '').toString(),
      subjectName: (row['subject_name'] ?? '').toString(),
      subjectYear: parseInt(row['subject_year']),
      status: (row['status'] ?? 'cursando').toString(),
      conditionStatus: (row['condition_status'] ?? 'habilitada').toString(),
      detailStatus: _emptyToNull(row['detail_status']),
      creditType: _emptyToNull(row['credit_type']),
      academicPeriod: _emptyToNull(row['academic_period']) ??
          _emptyToNull(row['source_period']),
      sourceDate: parseDate(row['source_date']),
      grade: parseDouble(row['grade']),
      conditionDeadline: parseDate(row['condition_deadline']),
      notes: _emptyToNull(row['notes']),
      adminNote: _emptyToNull(row['admin_note']),
    );
  }
}

class BorradorMateriaEstudianteAdministrador {
  const BorradorMateriaEstudianteAdministrador({
    this.id,
    required this.studentId,
    required this.careerId,
    required this.subjectId,
    required this.subjectName,
    this.subjectYear,
    required this.status,
    required this.conditionStatus,
    this.detailStatus,
    this.creditType,
    this.academicPeriod,
    this.sourceDate,
    this.grade,
    this.conditionDeadline,
    this.notes,
    this.adminNote,
  });

  final String? id;
  final String studentId;
  final String careerId;
  final String subjectId;
  final String subjectName;
  final int? subjectYear;
  final String status;
  final String conditionStatus;
  final String? detailStatus;
  final String? creditType;
  final String? academicPeriod;
  final DateTime? sourceDate;
  final double? grade;
  final DateTime? conditionDeadline;
  final String? notes;
  final String? adminNote;

  Map<String, dynamic> toPayload() {
    return {
      if (id != null) 'id': id,
      'student_id': studentId,
      'career_id': careerId,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_year': subjectYear,
      'status': status,
      'condition_status': conditionStatus,
      'detail_status': _blankToNull(detailStatus),
      'credit_type': _blankToNull(creditType),
      'academic_period': _blankToNull(academicPeriod),
      'source_date': _dateToSql(sourceDate),
      'grade': grade,
      'condition_deadline': _dateToSql(conditionDeadline),
      'notes': _blankToNull(notes),
      'admin_note': _blankToNull(adminNote),
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

String? _dateToSql(DateTime? value) {
  if (value == null) return null;
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
