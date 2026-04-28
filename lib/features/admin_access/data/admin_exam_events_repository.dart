import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_exam_event.dart';

class AdminExamEventsRepository {
  const AdminExamEventsRepository();

  Future<List<AdminExamEvent>> fetchAll({
    required SupabaseClient client,
  }) async {
    final rows = await client
        .from('exam_events')
        .select(
          'id, career_id, anio, fecha, hora, materia, instancia, docentes, acta_url',
        )
        .order('instancia')
        .order('career_id')
        .order('anio')
        .order('fecha')
        .order('materia');

    return rows
        .cast<Map<String, dynamic>>()
        .map(AdminExamEvent.fromRow)
        .toList(growable: false);
  }

  Future<void> upsert({
    required SupabaseClient client,
    required String adminDeviceId,
    required AdminExamEventDraft draft,
  }) async {
    final response = await client.functions.invoke(
      'admin-exam-events',
      body: {
        'device_id': adminDeviceId,
        'action': 'upsert',
        'event': draft.toModel().toRowPayload(),
      },
    );

    if ((response.data as Map?)?['ok'] != true) {
      throw StateError(
        (response.data as Map?)?['error']?.toString() ??
            'No se pudo guardar el examen',
      );
    }
  }

  Future<void> delete({
    required SupabaseClient client,
    required String adminDeviceId,
    required String id,
  }) async {
    final response = await client.functions.invoke(
      'admin-exam-events',
      body: {
        'device_id': adminDeviceId,
        'action': 'delete',
        'id': id,
      },
    );

    if ((response.data as Map?)?['ok'] != true) {
      throw StateError(
        (response.data as Map?)?['error']?.toString() ??
            'No se pudo borrar el examen',
      );
    }
  }
}
