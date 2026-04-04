enum DeviceProfilePublicMode {
  anonymous,
  alias;

  static DeviceProfilePublicMode fromValue(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'alias':
        return DeviceProfilePublicMode.alias;
      default:
        return DeviceProfilePublicMode.anonymous;
    }
  }

  String get value => switch (this) {
        DeviceProfilePublicMode.anonymous => 'anonymous',
        DeviceProfilePublicMode.alias => 'alias',
      };
}

class DeviceProfile {
  const DeviceProfile({
    required this.deviceId,
    required this.deviceLabel,
    required this.publicMode,
    required this.createdAt,
    required this.updatedAt,
    this.referenceName,
    this.publicAlias,
  });

  final String deviceId;
  final String deviceLabel;
  final String? referenceName;
  final DeviceProfilePublicMode publicMode;
  final String? publicAlias;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get needsReferenceName => (referenceName ?? '').trim().isEmpty;

  String get adminDisplayLabel {
    final name = (referenceName ?? '').trim();
    final label = deviceLabel.trim();
    if (name.isNotEmpty && label.isNotEmpty) return '$name - $label';
    if (name.isNotEmpty) return name;
    if (label.isNotEmpty) return label;
    return deviceId;
  }

  String get publicDisplayLabel {
    if (publicMode == DeviceProfilePublicMode.alias) {
      final alias = (publicAlias ?? '').trim();
      if (alias.isNotEmpty) return alias;
    }
    return 'Referencia anonima';
  }

  factory DeviceProfile.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DeviceProfile(
      deviceId: (map['device_id'] ?? '').toString(),
      deviceLabel: (map['device_label'] ?? '').toString(),
      referenceName: map['reference_name']?.toString(),
      publicMode: DeviceProfilePublicMode.fromValue(
        map['public_mode']?.toString(),
      ),
      publicAlias: map['public_alias']?.toString(),
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
    );
  }
}

