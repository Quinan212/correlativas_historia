import 'package:supabase_flutter/supabase_flutter.dart';

import 'device_profile.dart';

class DeviceProfileRepository {
  const DeviceProfileRepository();

  Future<DeviceProfile?> fetchProfile({
    required SupabaseClient client,
    required String deviceId,
  }) async {
    final row = await client
        .from('device_profiles')
        .select()
        .eq('device_id', deviceId)
        .maybeSingle();
    if (row == null) return null;
    return DeviceProfile.fromMap(Map<String, dynamic>.from(row));
  }

  Future<Map<String, DeviceProfile>> fetchProfilesByIds({
    required SupabaseClient client,
    required Iterable<String> deviceIds,
  }) async {
    final ids = deviceIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    if (ids.isEmpty) return const <String, DeviceProfile>{};

    final rows = await client
        .from('device_profiles')
        .select()
        .inFilter('device_id', ids.toList(growable: false));

    final profiles = rows
        .cast<Map<String, dynamic>>()
        .map(DeviceProfile.fromMap)
        .toList(growable: false);
    return {
      for (final profile in profiles) profile.deviceId: profile,
    };
  }

  Future<DeviceProfile> upsertProfile({
    required SupabaseClient client,
    required String deviceId,
    required String deviceLabel,
    required String referenceName,
    required DeviceProfilePublicMode publicMode,
    String? publicAlias,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final row = await client
        .from('device_profiles')
        .upsert({
          'device_id': deviceId,
          'device_label': deviceLabel.trim(),
          'reference_name': _nullIfBlank(referenceName),
          'public_mode': publicMode.value,
          'public_alias': publicMode == DeviceProfilePublicMode.alias
              ? _nullIfBlank(publicAlias)
              : null,
          'updated_at': now,
          'created_at': now,
        }, onConflict: 'device_id')
        .select()
        .single();

    return DeviceProfile.fromMap(Map<String, dynamic>.from(row));
  }

  Future<DeviceProfile> ensureProfileShell({
    required SupabaseClient client,
    required String deviceId,
    required String deviceLabel,
  }) async {
    final existing = await fetchProfile(client: client, deviceId: deviceId);
    if (existing != null) {
      if (existing.deviceLabel.trim().isNotEmpty) return existing;
      return upsertProfile(
        client: client,
        deviceId: deviceId,
        deviceLabel: deviceLabel,
        referenceName: existing.referenceName ?? '',
        publicMode: existing.publicMode,
        publicAlias: existing.publicAlias,
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final row = await client
        .from('device_profiles')
        .upsert({
          'device_id': deviceId,
          'device_label': deviceLabel.trim(),
          'public_mode': DeviceProfilePublicMode.anonymous.value,
          'updated_at': now,
          'created_at': now,
        }, onConflict: 'device_id')
        .select()
        .single();
    return DeviceProfile.fromMap(Map<String, dynamic>.from(row));
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
