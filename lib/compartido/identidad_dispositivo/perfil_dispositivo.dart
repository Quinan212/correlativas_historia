enum ModoPublicoPerfilDispositivo {
  anonymous,
  alias;

  static ModoPublicoPerfilDispositivo desdeValor(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'alias':
        return ModoPublicoPerfilDispositivo.alias;
      default:
        return ModoPublicoPerfilDispositivo.anonymous;
    }
  }

  String get value => switch (this) {
        ModoPublicoPerfilDispositivo.anonymous => 'anonymous',
        ModoPublicoPerfilDispositivo.alias => 'alias',
      };
}

class PerfilDispositivo {
  const PerfilDispositivo({
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
  final ModoPublicoPerfilDispositivo publicMode;
  final String? publicAlias;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get needsReferenceName => (referenceName ?? '').trim().isEmpty;

  String get adminDisplayLabel {
    final name = _cleanDisplayText(referenceName);
    final label = _cleanDisplayText(deviceLabel);
    if (name.isNotEmpty && label.isNotEmpty) return '$name - $label';
    if (name.isNotEmpty) return name;
    if (label.isNotEmpty) return label;
    return deviceId;
  }

  String get publicDisplayLabel {
    if (publicMode == ModoPublicoPerfilDispositivo.alias) {
      final alias = _cleanDisplayText(publicAlias);
      if (alias.isNotEmpty) return alias;
    }
    return 'Referencia anonima';
  }

  factory PerfilDispositivo.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return PerfilDispositivo(
      deviceId: (map['device_id'] ?? '').toString(),
      deviceLabel: (map['device_label'] ?? '').toString(),
      referenceName: map['reference_name']?.toString(),
      publicMode: ModoPublicoPerfilDispositivo.desdeValor(
        map['public_mode']?.toString(),
      ),
      publicAlias: map['public_alias']?.toString(),
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
    );
  }

  static String _cleanDisplayText(String? value) {
    final cleaned = (value ?? '').trim();
    if (cleaned.isEmpty) return '';
    final normalized = cleaned.toLowerCase();
    if (normalized == 'undefined' || normalized == 'null') return '';
    return cleaned;
  }
}
