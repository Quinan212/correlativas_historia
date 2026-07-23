class EventoNavegacionExamenAdministrador {
  const EventoNavegacionExamenAdministrador({
    required this.id,
    required this.deviceId,
    required this.eventType,
    required this.surface,
    required this.careerId,
    required this.matterName,
    required this.tabId,
    required this.tabLabel,
    required this.createdAt,
    this.divisionId,
    this.divisionLabel,
    this.sourceCareerId,
    this.sourceTabId,
    this.sourceTabLabel,
    this.sourceDivisionId,
    this.sourceDivisionLabel,
  });

  final String id;
  final String deviceId;
  final String eventType;
  final String surface;
  final String careerId;
  final String matterName;
  final String tabId;
  final String tabLabel;
  final String? divisionId;
  final String? divisionLabel;
  final String? sourceCareerId;
  final String? sourceTabId;
  final String? sourceTabLabel;
  final String? sourceDivisionId;
  final String? sourceDivisionLabel;
  final DateTime createdAt;

  bool get isView => eventType == 'view';

  factory EventoNavegacionExamenAdministrador.fromMap(
    Map<String, dynamic> map,
  ) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    String? cleanOptional(dynamic value) {
      final text = (value ?? '').toString().trim();
      if (text.isEmpty) return null;
      final normalized = text.toLowerCase();
      if (normalized == 'undefined' || normalized == 'null') return null;
      return text;
    }

    return EventoNavegacionExamenAdministrador(
      id: (map['id'] ?? '').toString(),
      deviceId: (map['device_id'] ?? '').toString(),
      eventType: (map['event_type'] ?? '').toString(),
      surface: (map['surface'] ?? '').toString(),
      careerId: (map['career_id'] ?? '').toString(),
      matterName: (map['matter_name'] ?? '').toString(),
      tabId: (map['tab_id'] ?? '').toString(),
      tabLabel: (map['tab_label'] ?? '').toString(),
      divisionId: cleanOptional(map['division_id']),
      divisionLabel: cleanOptional(map['division_label']),
      sourceCareerId: cleanOptional(map['source_career_id']),
      sourceTabId: cleanOptional(map['source_tab_id']),
      sourceTabLabel: cleanOptional(map['source_tab_label']),
      sourceDivisionId: cleanOptional(map['source_division_id']),
      sourceDivisionLabel: cleanOptional(map['source_division_label']),
      createdAt: parseDate('created_at'),
    );
  }
}
