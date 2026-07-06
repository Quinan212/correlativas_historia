import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/modelos_acceso_estudiante.dart';

class DniEnUsoException implements Exception {
  const DniEnUsoException();
}

class RepositorioAccesoEstudiante {
  const RepositorioAccesoEstudiante();

  Future<DatosAccesoEstudiante> load({
    required SupabaseClient client,
    String? guestFirstName,
    String? guestDni,
    String? guestCareerId,
  }) async {
    final response = await client.functions.invoke(
      'student-access',
      body: {
        'action': 'load',
        if (guestFirstName != null) 'first_name': guestFirstName,
        if (guestDni != null && guestDni.isNotEmpty) 'dni': guestDni,
        if (guestCareerId != null) 'career_id': guestCareerId,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo cargar la trayectoria',
      );
    }

    return DatosAccesoEstudiante.fromJson(
      data!.cast<String, dynamic>(),
    );
  }

  Future<PerfilAccesoEstudiante> updateContact({
    required SupabaseClient client,
    required String phone,
    required String email,
    String? firstName,
    String? lastName,
    String? dni,
    String? careerId,
    String? division,
    int? currentYear,
    int? cohortYear,
  }) async {
    late final FunctionResponse response;
    try {
      response = await client.functions.invoke(
        'student-access',
        body: {
          'action': 'update_contact',
          'contact_phone': phone,
          'contact_email': email,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (dni != null) 'dni': dni,
          if (careerId != null) 'career_id': careerId,
          if (division != null) 'division': division,
          if (currentYear != null) 'current_year': currentYear,
          if (cohortYear != null) 'cohort_year': cohortYear,
        },
      );
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['code'] == 'dni_already_exists') {
        throw const DniEnUsoException();
      }
      rethrow;
    }

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo actualizar el contacto',
      );
    }

    return PerfilAccesoEstudiante.fromJson(
      (data?['student'] as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> upsertSelfSubject({
    required SupabaseClient client,
    required String subjectId,
    required String subjectName,
    int? subjectYear,
    required String status,
    String? academicPeriod,
    String? sourceDate,
    double? grade,
    String? notes,
    String? id,
  }) async {
    final response = await client.functions.invoke(
      'student-access',
      body: {
        'action': 'upsert_self_subject',
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'subject_year': subjectYear,
        'status': status,
        'academic_period': academicPeriod,
        'source_date': sourceDate,
        'grade': grade,
        'notes': notes,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo guardar la materia',
      );
    }

    return (data?['subject'] as Map).cast<String, dynamic>();
  }

  Future<void> deleteSelfSubject({
    required SupabaseClient client,
    required String subjectId,
  }) async {
    final response = await client.functions.invoke(
      'student-access',
      body: {
        'action': 'delete_self_subject',
        'subject_id': subjectId,
      },
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo eliminar la materia',
      );
    }
  }
}
