import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../supabase/supabase.dart';
import 'device_profile.dart';
import 'device_profile_repository.dart';
import 'device_identity_service.dart';
import 'device_registry_entry.dart';

final deviceIdentityServiceProvider = Provider<DeviceIdentityService>(
  (ref) => const DeviceIdentityService(),
);

final deviceIdProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(deviceIdentityServiceProvider);
  return service.getOrCreateDeviceId();
});

final deviceLabelProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(deviceIdentityServiceProvider);
  return service.getCurrentDeviceLabel();
});

final deviceProfileRepositoryProvider = Provider<DeviceProfileRepository>(
  (ref) => const DeviceProfileRepository(),
);

final ownDeviceProfileProvider = FutureProvider<DeviceProfile?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;

  final repo = ref.watch(deviceProfileRepositoryProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  return repo.fetchProfile(client: client, deviceId: deviceId);
});

String serializeDeviceIds(Iterable<String> deviceIds) {
  final ids = deviceIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet()
    ..remove('');
  final sorted = ids.toList(growable: false)..sort();
  return sorted.join('|');
}

final deviceProfilesByIdsProvider = FutureProvider.autoDispose
    .family<Map<String, DeviceProfile>, String>((ref, key) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || key.trim().isEmpty) {
    return const <String, DeviceProfile>{};
  }

  final ids =
      key.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  if (ids.isEmpty) return const <String, DeviceProfile>{};

  final repo = ref.watch(deviceProfileRepositoryProvider);
  return repo.fetchProfilesByIds(client: client, deviceIds: ids);
});

final deviceRegistryEntriesByIdsProvider = FutureProvider.autoDispose
    .family<Map<String, DeviceRegistryEntry>, String>((ref, key) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || key.trim().isEmpty) {
    return const <String, DeviceRegistryEntry>{};
  }

  final ids =
      key.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  if (ids.isEmpty) return const <String, DeviceRegistryEntry>{};

  final rows = await client
      .from('device_registry')
      .select('device_id, device_kind, lifecycle_status, label, notes, last_active_at')
      .inFilter('device_id', ids.toList(growable: false));

  final entries = rows
      .cast<Map<String, dynamic>>()
      .map(DeviceRegistryEntry.fromMap)
      .toList(growable: false);
  return {for (final entry in entries) entry.deviceId: entry};
});
