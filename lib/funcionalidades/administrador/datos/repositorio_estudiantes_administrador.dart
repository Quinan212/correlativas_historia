import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/entrada_historial_estudiante_administrador.dart';
import '../modelos/estudiante_administrador.dart';
import '../modelos/item_nomina_materia_administrador.dart';
import '../modelos/materia_estudiante_administrador.dart';

class DniEnUsoAdministradorException implements Exception {
  const DniEnUsoAdministradorException();
}

class RepositorioEstudiantesAdministrador {
  const RepositorioEstudiantesAdministrador();

  Future<List<EstudianteAdministrador>> list({
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
        .map((row) =>
            EstudianteAdministrador.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);

    return rows;
  }

  Future<EstudianteAdministrador> upsert({
    required SupabaseClient client,
    required String adminDeviceId,
    required BorradorEstudianteAdministrador draft,
  }) async {
    late final FunctionResponse response;
    try {
      response = await client.functions.invoke(
        'admin-students',
        body: {
          'device_id': adminDeviceId,
          'action': 'upsert',
          'student': draft.toPayload(),
        },
      );
    } on FunctionException catch (error) {
      if (_isDniCollision(error.details)) {
        throw const DniEnUsoAdministradorException();
      }
      rethrow;
    }

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
          data?['error']?.toString() ?? 'No se pudo guardar alumno');
    }

    return EstudianteAdministrador.fromRow(
      (data?['student'] as Map).cast<String, dynamic>(),
    );
  }

  Future<int> bulkUpsert({
    required SupabaseClient client,
    required String adminDeviceId,
    required List<BorradorEstudianteAdministrador> drafts,
  }) async {
    late final FunctionResponse response;
    try {
      response = await client.functions.invoke(
        'admin-students',
        body: {
          'device_id': adminDeviceId,
          'action': 'bulk_upsert',
          'students': drafts.map((draft) => draft.toPayload()).toList(),
        },
      );
    } on FunctionException catch (error) {
      if (_isDniCollision(error.details)) {
        throw const DniEnUsoAdministradorException();
      }
      rethrow;
    }

    final data = response.data as Map?;
    if (data?['ok'] != true) {
      throw StateError(
        data?['error']?.toString() ?? 'No se pudo cargar la lista de alumnos',
      );
    }

    return (data?['count'] as num?)?.toInt() ?? drafts.length;
  }

  Future<List<MateriaEstudianteAdministrador>> listSubjects({
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
        .map((row) =>
            MateriaEstudianteAdministrador.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<MateriaEstudianteAdministrador> upsertSubject({
    required SupabaseClient client,
    required String adminDeviceId,
    required BorradorMateriaEstudianteAdministrador draft,
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

    return MateriaEstudianteAdministrador.fromRow(
      (data?['subject'] as Map).cast<String, dynamic>(),
    );
  }

  Future<int> bulkUpsertSubjects({
    required SupabaseClient client,
    required String adminDeviceId,
    required List<BorradorMateriaEstudianteAdministrador> drafts,
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

  Future<List<ItemNominaMateriaAdministrador>> listSubjectRoster({
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
            ItemNominaMateriaAdministrador.fromRow(row.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<List<EntradaHistorialEstudianteAdministrador>> listHistory({
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
        .map((row) => EntradaHistorialEstudianteAdministrador.fromRow(
            row.cast<String, dynamic>()))
        .toList(growable: false);
  }
}

bool _isDniCollision(dynamic details) {
  return details is Map && details['code'] == 'dni_already_exists';
}
