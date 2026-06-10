import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_student.dart';
import '../models/admin_student_history_entry.dart';
import '../models/admin_subject_roster_item.dart';
import '../models/admin_student_subject.dart';

class AdminStudentsRepository {
  const AdminStudentsRepository();

  Future<List<AdminStudent>> list({
    required SupabaseClient client,
    required String adminDeviceId,
    String? careerId,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'list',
        if (careerId != null && careerId.isNotEmpty) 'career_id': careerId,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
          data?['error']?.toString() ?? 'No se pudo listar alumnos');
    }

    final rows = (data?['students'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => AdminStudent.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);

    return rows;
  }

  Future<AdminStudent> upsert({
    required SupabaseClient client,
    required String adminDeviceId,
    required AdminStudentDraft draft,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'upsert',
        'student': draft.toPayload(),
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
          data?['error']?.toString() ?? 'No se pudo guardar alumno');
    }

    return AdminStudent.fromRow(
      (data?['student'] as Map).cast<String, dynamic>(),
    );
  }

  Future<int> bulkUpsert({
    required SupabaseClient client,
    required String adminDeviceId,
    required List<AdminStudentDraft> drafts,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'bulk_upsert',
        'students': drafts.map((draft) => draft.toPayload()).toList(),
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo cargar la lista de alumnos',
      );
    }

    return (data?['count'] as num?)?.toInt() ?? drafts.length;
  }

  Future<List<AdminStudentSubject>> listSubjects({
    required SupabaseClient client,
    required String adminDeviceId,
    required String studentId,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'list_subjects',
        'student_id': studentId,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudieron cargar materias',
      );
    }

    return (data?['subjects'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => AdminStudentSubject.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<AdminStudentSubject> upsertSubject({
    required SupabaseClient client,
    required String adminDeviceId,
    required AdminStudentSubjectDraft draft,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'upsert_subject',
        'subject': draft.toPayload(),
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo guardar la materia',
      );
    }

    return AdminStudentSubject.fromRow(
      (data?['subject'] as Map).cast<String, dynamic>(),
    );
  }

  Future<int> bulkUpsertSubjects({
    required SupabaseClient client,
    required String adminDeviceId,
    required List<AdminStudentSubjectDraft> drafts,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'bulk_upsert_subjects',
        'subjects': drafts.map((draft) => draft.toPayload()).toList(),
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudieron guardar materias',
      );
    }

    return (data?['count'] as num?)?.toInt() ?? drafts.length;
  }

  Future<List<AdminSubjectRosterItem>> listSubjectRoster({
    required SupabaseClient client,
    required String adminDeviceId,
    required String careerId,
    required String subjectId,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'list_subject_roster',
        'career_id': careerId,
        'subject_id': subjectId,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ??
            'No se pudo cargar el listado por materia',
      );
    }

    return (data?['roster'] as List? ?? const [])
        .whereType<Map>()
        .map((row) =>
            AdminSubjectRosterItem.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<List<AdminStudentHistoryEntry>> listHistory({
    required SupabaseClient client,
    required String adminDeviceId,
    required String studentId,
  }) async {
    final response = await client.functions.invoke(
      'admin-students',
      body: {
        'device_id': adminDeviceId,
        'action': 'list_history',
        'student_id': studentId,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo cargar el historial',
      );
    }

    return (data?['history'] as List? ?? const [])
        .whereType<Map>()
        .map((row) =>
            AdminStudentHistoryEntry.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);
  }
}
