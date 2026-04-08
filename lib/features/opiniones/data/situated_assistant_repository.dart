import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/situated_assistant_models.dart';

class SituatedAssistantRepository {
  const SituatedAssistantRepository();

  Future<SituatedAssistantResponse> ask({
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

    return SituatedAssistantResponse.fromMap(payload);
  }
}
