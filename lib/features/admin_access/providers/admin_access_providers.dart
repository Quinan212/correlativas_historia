import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/admin_device_status.dart';

final adminDeviceStatusProvider = FutureProvider<AdminDeviceStatus>((ref) async {
  final deviceId = await ref.watch(deviceIdProvider.future);
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  final client = ref.watch(supabaseClientProvider);

  if (!bootstrap.isReady || client == null) {
      return AdminDeviceStatus(
        deviceId: deviceId,
        isAdmin: false,
        message:
            'Supabase todavia no esta listo. Copia este device_id y guardalo despues en admin_devices.',
      );
  }

  try {
    final row = await client
        .from('admin_devices')
        .select('device_id, enabled, label')
        .eq('device_id', deviceId)
        .maybeSingle();

    if (row == null) {
      return AdminDeviceStatus(
        deviceId: deviceId,
        isAdmin: false,
        message:
            'Este dispositivo todavia no tiene acceso admin. Agrega el device_id en admin_devices y toca refrescar.',
      );
    }

    final enabled = row['enabled'] == true;
    final label = (row['label'] as String?)?.trim();

    return AdminDeviceStatus(
      deviceId: deviceId,
      isAdmin: enabled,
      adminLabel: label,
      message: enabled
          ? 'Este dispositivo tiene acceso admin habilitado.'
          : 'Este dispositivo figura en admin_devices, pero esta deshabilitado.',
    );
  } on PostgrestException catch (error) {
    return AdminDeviceStatus(
      deviceId: deviceId,
      isAdmin: false,
      message:
          'No se pudo leer admin_devices. Crea la tabla y habilita SELECT con RLS. Detalle: ${error.message}',
    );
  } catch (error) {
    return AdminDeviceStatus(
      deviceId: deviceId,
      isAdmin: false,
      message: 'Fallo la comprobacion de acceso admin: $error',
    );
  }
});
