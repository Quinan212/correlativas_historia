import 'package:supabase_flutter/supabase_flutter.dart';

import '../../examenes/modelos/evento_examen.dart';
import '../modelos/evento_examen_administrador.dart';

class RepositorioEventosExamenAdministrador {
  const RepositorioEventosExamenAdministrador();

  Future<List<EventoExamenAdministrador>> fetchAll({
    required SupabaseClient client,
  }) async {
    final rows = await client
        .from('exam_events')
        .select(
          'id, career_id, anio, fecha, hora, materia, instancia, docentes, '
          'acta_url, legacy, suspendido, estado, titulo_estado, mensaje_estado, '
          'fecha_reprogramada, hora_reprogramada, acta_habilitada, visible, '
          'updated_at, updated_by_device_id',
        )
        .order('instancia')
        .order('career_id')
        .order('anio')
        .order('fecha')
        .order('materia');

    return rows
        .cast<Map<String, dynamic>>()
        .map(EventoExamenAdministrador.fromRow)
        .toList(growable: false);
  }

  Future<void> upsert({
    required SupabaseClient client,
    required String adminDeviceId,
    required BorradorEventoExamenAdministrador draft,
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

  Future<void> updateQuickControls({
    required SupabaseClient client,
    required String adminDeviceId,
    required String id,
    required EstadoEventoExamen currentStatus,
    required EstadoEventoExamen status,
    required bool actEnabled,
    required String? actUrl,
  }) async {
    final normalizedActUrl = actUrl?.trim();
    final eventPayload = <String, dynamic>{
      'id': id,
      'estado': status.valorBaseDatos,
      'acta_habilitada': actEnabled,
      if (normalizedActUrl != null && normalizedActUrl.isNotEmpty)
        'acta_url': normalizedActUrl,
    };

    if (status != currentStatus) {
      eventPayload['titulo_estado'] = null;
      eventPayload['mensaje_estado'] = null;
    }

    final response = await client.functions.invoke(
      'admin-exam-events',
      body: {
        'device_id': adminDeviceId,
        'action': 'upsert',
        'event': eventPayload,
      },
    );

    if ((response.data as Map?)?['ok'] != true) {
      throw StateError(
        (response.data as Map?)?['error']?.toString() ??
            'No se pudo actualizar el estado de la mesa',
      );
    }
  }

  Future<void> updateScheduleAndTeachers({
    required SupabaseClient client,
    required String adminDeviceId,
    required EventoExamen event,
    required DateTime date,
    required String time,
    required List<String> teachers,
  }) async {
    final id = event.id?.trim() ?? '';
    if (id.isEmpty) {
      throw StateError('La mesa no tiene un identificador remoto válido');
    }

    final eventPayload = <String, dynamic>{'id': id, 'docentes': teachers};

    if (event.estado == EstadoEventoExamen.reprogramada) {
      eventPayload['fecha_reprogramada'] = _formatDate(date);
      eventPayload['hora_reprogramada'] = time;
    } else {
      eventPayload['fecha'] = _formatDate(date);
      eventPayload['hora'] = time;
    }

    final response = await client.functions.invoke(
      'admin-exam-events',
      body: {
        'device_id': adminDeviceId,
        'action': 'upsert',
        'event': eventPayload,
      },
    );

    if ((response.data as Map?)?['ok'] != true) {
      throw StateError(
        (response.data as Map?)?['error']?.toString() ??
            'No se pudieron actualizar la fecha, hora y docentes',
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
      body: {'device_id': adminDeviceId, 'action': 'delete', 'id': id},
    );

    if ((response.data as Map?)?['ok'] != true) {
      throw StateError(
        (response.data as Map?)?['error']?.toString() ??
            'No se pudo borrar el examen',
      );
    }
  }
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
