import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../supabase/supabase.dart';
import 'device_profile.dart';
import 'device_profile_repository.dart';
import 'device_identity_service.dart';

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

final deviceProfilesByIdsProvider =
    FutureProvider.autoDispose.family<Map<String, DeviceProfile>, String>((ref, key) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || key.trim().isEmpty) {
    return const <String, DeviceProfile>{};
  }

  final ids = key
      .split('|')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();
  if (ids.isEmpty) return const <String, DeviceProfile>{};

  final repo = ref.watch(deviceProfileRepositoryProvider);
  return repo.fetchProfilesByIds(client: client, deviceIds: ids);
});
