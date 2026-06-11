import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/modelos_asistente_contextual.dart';

class RepositorioAsistenteContextual {
  const RepositorioAsistenteContextual();

  Future<RespuestaAsistenteContextual> ask({
    required SupabaseClient client,
    required String question,
    required String contextType,
    required String contextId,
    required String deviceId,
  }) async {
    final response = await client.functions.invoke(
      'ask-situated-assistant',
      body: {
        'question': question,
        'context_type': contextType,
        'context_id': contextId,
        'device_id': deviceId,
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('El asistente devolvio un formato no valido.');
    }

    final status = (payload['status'] ?? '').toString().trim().toLowerCase();
    if (status.isEmpty) {
      throw Exception('El asistente no devolvio estado.');
    }

    return RespuestaAsistenteContextual.fromMap(payload);
  }
}
