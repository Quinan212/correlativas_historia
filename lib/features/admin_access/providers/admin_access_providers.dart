import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/admin_bulk_cleanup_repository.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/admin_device_status.dart';

class AdminObservedDevice {
  const AdminObservedDevice({
    required this.deviceId,
    required this.label,
    required this.lastSeenAt,
    this.notes,
  });

  final String deviceId;
  final String label;
  final DateTime? lastSeenAt;
  final String? notes;
}

final adminBulkCleanupRepositoryProvider =
    Provider<AdminBulkCleanupRepository>((ref) {
  return const AdminBulkCleanupRepository();
});

final adminDeviceStatusProvider =
    FutureProvider<AdminDeviceStatus>((ref) async {
  final deviceId = await ref.watch(deviceIdProvider.future);
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  final client = ref.watch(supabaseClientProvider);

  if (!bootstrap.isReady || client == null) {
    return AdminDeviceStatus(
      deviceId: deviceId,
      isAdmin: false,
      message:
          'Supabase todavia no esta listo. Cuando termine de conectar, vas a poder comprobar el acceso admin de este dispositivo.',
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
            'Este dispositivo todavia no tiene acceso admin. Si lo habilitas en admin_devices, despues toca refrescar.',
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

final adminObservedDevicesProvider =
    FutureProvider<List<AdminObservedDevice>>((ref) async {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  final client = ref.watch(supabaseClientProvider);

  if (!bootstrap.isReady || client == null) {
    return const <AdminObservedDevice>[];
  }

  final registryRows = await client
      .from('device_registry')
      .select('device_id, label, notes, last_active_at')
      .eq('lifecycle_status', 'active')
      .order('label');

  final registry = registryRows.cast<Map<String, dynamic>>();
  if (registry.isEmpty) return const <AdminObservedDevice>[];

  final deviceIds = registry
      .map((row) => (row['device_id'] ?? '').toString().trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  final tokenRows = await client
      .from('device_push_tokens')
      .select('device_id, enabled, last_seen_at, updated_at')
      .inFilter('device_id', deviceIds);

  final profileRows = await client
      .from('device_profiles')
      .select('device_id, public_alias, reference_name')
      .inFilter('device_id', deviceIds);

  final profileByDevice = <String, Map<String, dynamic>>{};
  for (final row in profileRows.cast<Map<String, dynamic>>()) {
    final deviceId = (row['device_id'] ?? '').toString().trim();
    if (deviceId.isEmpty) continue;
    profileByDevice[deviceId] = row;
  }

  final latestSeenByDevice = <String, DateTime?>{};
  for (final raw in tokenRows.cast<Map<String, dynamic>>()) {
    final deviceId = (raw['device_id'] ?? '').toString().trim();
    if (deviceId.isEmpty) continue;
    final enabled = raw['enabled'] == true;
    if (!enabled) continue;
    final seenRaw = raw['last_seen_at'] ?? raw['updated_at'];
    final parsed =
        seenRaw == null ? null : DateTime.tryParse(seenRaw.toString());
    final current = latestSeenByDevice[deviceId];
    if (parsed == null) {
      latestSeenByDevice.putIfAbsent(deviceId, () => current);
      continue;
    }
    if (current == null || parsed.isAfter(current)) {
      latestSeenByDevice[deviceId] = parsed;
    }
  }

  final items = registry.map(
    (row) {
      final deviceId = (row['device_id'] ?? '').toString().trim();
      final profile = profileByDevice[deviceId];
      final alias = (profile?['public_alias'] ?? '').toString().trim();
      final referenceName =
          (profile?['reference_name'] ?? '').toString().trim();
      final registryLabel = (row['label'] ?? '').toString().trim();

      final resolvedLabel = alias.isNotEmpty
          ? alias
          : referenceName.isNotEmpty
              ? referenceName
              : registryLabel.isNotEmpty
                  ? registryLabel
                  : deviceId;

      return AdminObservedDevice(
        deviceId: deviceId,
        label: resolvedLabel,
        lastSeenAt:
            DateTime.tryParse((row['last_active_at'] ?? '').toString()) ??
                latestSeenByDevice[deviceId],
        notes: (row['notes'] as String?)?.trim(),
      );
    },
  ).toList(growable: false)
    ..sort((a, b) {
      final aSeen = a.lastSeenAt;
      final bSeen = b.lastSeenAt;
      if (aSeen == null && bSeen == null) return a.label.compareTo(b.label);
      if (aSeen == null) return 1;
      if (bSeen == null) return -1;
      return bSeen.compareTo(aSeen);
    });

  return items;
});
