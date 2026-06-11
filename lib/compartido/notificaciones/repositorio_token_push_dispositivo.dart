import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioTokenPushDispositivo {
  const RepositorioTokenPushDispositivo();

  Future<void> upsertToken({
    required SupabaseClient client,
    required String deviceId,
    required String pushToken,
    String platform = 'android',
  }) async {
    try {
      await client.functions.invoke(
        'upsert-device-push-token',
        body: {
          'device_id': deviceId,
          'push_token': pushToken,
          'platform': platform,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('No se pudo guardar el token push: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
