enum DeviceRegistryKind {
  real,
  demo,
  emulator,
  tester,
  unknown;

  static DeviceRegistryKind fromValue(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'real':
        return DeviceRegistryKind.real;
      case 'demo':
        return DeviceRegistryKind.demo;
      case 'emulator':
        return DeviceRegistryKind.emulator;
      case 'tester':
        return DeviceRegistryKind.tester;
      default:
        return DeviceRegistryKind.unknown;
    }
  }

  bool get isVisibleInHistories =>
      this == DeviceRegistryKind.real || this == DeviceRegistryKind.demo;
}

class DeviceRegistryEntry {
  const DeviceRegistryEntry({
    required this.deviceId,
    required this.deviceKind,
    required this.lifecycleStatus,
    required this.label,
    this.notes,
    this.lastActiveAt,
  });

  final String deviceId;
  final DeviceRegistryKind deviceKind;
  final String lifecycleStatus;
  final String label;
  final String? notes;
  final DateTime? lastActiveAt;

  bool get isVisibleInHistories => deviceKind.isVisibleInHistories;
  bool get isVisibleInAdminPanels =>
      !shouldHideDeviceFromAdminPanels(deviceId: deviceId, label: label);

  factory DeviceRegistryEntry.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String key) {
      final raw = map[key]?.toString().trim() ?? '';
      if (raw.isEmpty) return null;
      return DateTime.tryParse(raw)?.toLocal();
    }

    return DeviceRegistryEntry(
      deviceId: (map['device_id'] ?? '').toString(),
      deviceKind: DeviceRegistryKind.fromValue(map['device_kind']?.toString()),
      lifecycleStatus: (map['lifecycle_status'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      notes: _cleanText(map['notes']),
      lastActiveAt: parseDate('last_active_at'),
    );
  }
}

bool shouldHideDeviceFromAdminPanels({
  required String deviceId,
  String? label,
  String? notes,
}) {
  final normalizedId = deviceId.trim().toLowerCase();
  if (normalizedId.isEmpty) return true;
  if (normalizedId.startsWith('dev_')) return true;
  if (normalizedId == 'and_61fafad37df69a7e') return true;
  if (normalizedId == 'and_2bcd01d6ca700579') return true;

  final haystack = '${label ?? ''} ${notes ?? ''}'.toLowerCase();
  if (haystack.contains('windows')) return true;
  if (haystack.contains('samsung a35')) return true;
  return false;
}

String? _cleanText(dynamic value) {
  final cleaned = (value ?? '').toString().trim();
  if (cleaned.isEmpty) return null;
  final normalized = cleaned.toLowerCase();
  if (normalized == 'undefined' || normalized == 'null') return null;
  return cleaned;
}
