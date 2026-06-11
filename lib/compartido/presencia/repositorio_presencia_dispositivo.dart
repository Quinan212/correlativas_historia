import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioPresenciaDispositivo {
  const RepositorioPresenciaDispositivo();

  Future<void> markActive({
    required SupabaseClient client,
    required String deviceId,
  }) async {
    try {
      await client.functions.invoke(
        'heartbeat-device-presence',
        body: {
          'device_id': deviceId,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('No se pudo marcar actividad del dispositivo: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
