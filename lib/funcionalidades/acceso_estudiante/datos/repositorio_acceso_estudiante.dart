import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
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
    String? guestCareerId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(client);

    try {
      final response = await client.functions.invoke(
        'student-access',
        body: {
          'action': 'load',
          'first_name': ?guestFirstName,
          'career_id': ?guestCareerId,
        },
      );

      final data = response.data as Map?;
      if (data?['ok'] != true) {
        throw StateError(
          data?['error']?.toString() ?? 'No se pudo cargar la trayectoria',
        );
      }

      final json = data!.cast<String, dynamic>();
      await prefs.setString(cacheKey, jsonEncode(json));
      return DatosAccesoEstudiante.fromJson(json);
    } catch (error) {
      if (!_isNetworkError(error)) rethrow;

      final cached = prefs.getString(cacheKey);
      if (cached == null) rethrow;

      try {
        return DatosAccesoEstudiante.fromJson(
          (jsonDecode(cached) as Map).cast<String, dynamic>(),
        );
      } catch (_) {
        rethrow;
      }
    }
  }

  String _cacheKey(SupabaseClient client) {
    final userId = client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('No hay una sesión de estudiante activa.');
    }
    return 'student_access_cache_v1_$userId';
  }

  bool _isNetworkError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('socket') ||
        message.contains('connection') ||
        message.contains('failed host lookup') ||
        message.contains('network') ||
        message.contains('clientexception');
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
          'first_name': ?firstName,
          'last_name': ?lastName,
          'dni': ?dni,
          'career_id': ?careerId,
          'division': ?division,
          'current_year': ?currentYear,
          'cohort_year': ?cohortYear,
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
        'id': ?id,
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

    return (data?['subject'] as Map<String, dynamic>?) ??
        (() => throw StateError('No se pudo guardar la materia'))();
  }

  Future<void> deleteSelfSubject({
    required SupabaseClient client,
    required String subjectId,
  }) async {
    final response = await client.functions.invoke(
      'student-access',
      body: {'action': 'delete_self_subject', 'subject_id': subjectId},
    );

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo eliminar la materia',
      );
    }
  }
}
