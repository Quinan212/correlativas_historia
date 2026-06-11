enum TipoRegistroDispositivo {
  real,
  demo,
  emulator,
  tester,
  unknown;

  static TipoRegistroDispositivo desdeValor(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'real':
        return TipoRegistroDispositivo.real;
      case 'demo':
        return TipoRegistroDispositivo.demo;
      case 'emulator':
        return TipoRegistroDispositivo.emulator;
      case 'tester':
        return TipoRegistroDispositivo.tester;
      default:
        return TipoRegistroDispositivo.unknown;
    }
  }

  bool get isVisibleInHistories =>
      this == TipoRegistroDispositivo.real ||
      this == TipoRegistroDispositivo.demo;
}

class EntradaRegistroDispositivo {
  const EntradaRegistroDispositivo({
    required this.deviceId,
    required this.tipoDispositivo,
    required this.lifecycleStatus,
    required this.label,
    this.notes,
    this.lastActiveAt,
  });

  final String deviceId;
  final TipoRegistroDispositivo tipoDispositivo;
  final String lifecycleStatus;
  final String label;
  final String? notes;
  final DateTime? lastActiveAt;

  bool get isVisibleInHistories => tipoDispositivo.isVisibleInHistories;
  bool get isVisibleInAdminPanels =>
      !shouldHideDeviceFromAdminPanels(deviceId: deviceId, label: label);

  factory EntradaRegistroDispositivo.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String key) {
      final raw = map[key]?.toString().trim() ?? '';
      if (raw.isEmpty) return null;
      return DateTime.tryParse(raw)?.toLocal();
    }

    return EntradaRegistroDispositivo(
      deviceId: (map['device_id'] ?? '').toString(),
      tipoDispositivo:
          TipoRegistroDispositivo.desdeValor(map['device_kind']?.toString()),
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
