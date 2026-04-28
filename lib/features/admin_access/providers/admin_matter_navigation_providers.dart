import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';

class AdminMatterNavigationEvent {
  const AdminMatterNavigationEvent({
    required this.id,
    required this.deviceId,
    required this.eventType,
    required this.surface,
    required this.careerId,
    required this.matterId,
    required this.matterName,
    required this.createdAt,
    this.sourceCareerId,
    this.sourceMatterId,
    this.sourceMatterName,
  });

  final String id;
  final String deviceId;
  final String eventType;
  final String surface;
  final String careerId;
  final String matterId;
  final String matterName;
  final String? sourceCareerId;
  final String? sourceMatterId;
  final String? sourceMatterName;
  final DateTime createdAt;

  factory AdminMatterNavigationEvent.fromMap(Map<String, dynamic> map) {
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

    return AdminMatterNavigationEvent(
      id: (map['id'] ?? '').toString(),
      deviceId: (map['device_id'] ?? '').toString(),
      eventType: (map['event_type'] ?? '').toString(),
      surface: (map['surface'] ?? '').toString(),
      careerId: (map['career_id'] ?? '').toString(),
      matterId: (map['matter_id'] ?? '').toString(),
      matterName: (map['matter_name'] ?? '').toString(),
      sourceCareerId: cleanOptional(map['source_career_id']),
      sourceMatterId: cleanOptional(map['source_matter_id']),
      sourceMatterName: cleanOptional(map['source_matter_name']),
      createdAt: parseDate('created_at'),
    );
  }
}

class AdminMatterNavigationDeviceSummary {
  const AdminMatterNavigationDeviceSummary({
    required this.deviceId,
    required this.label,
    required this.views,
    required this.transitions,
    required this.lastSeenAt,
  });

  final String deviceId;
  final String label;
  final int views;
  final int transitions;
  final DateTime? lastSeenAt;
}

class AdminMatterNavigationOverview {
  const AdminMatterNavigationOverview({
    required this.events,
    required this.deviceSummaries,
  });

  final List<AdminMatterNavigationEvent> events;
  final List<AdminMatterNavigationDeviceSummary> deviceSummaries;
}

final adminMatterNavigationOverviewProvider =
    FutureProvider.autoDispose<AdminMatterNavigationOverview>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return const AdminMatterNavigationOverview(
      events: <AdminMatterNavigationEvent>[],
      deviceSummaries: <AdminMatterNavigationDeviceSummary>[],
    );
  }

  final eventRows = await client
      .from('matter_navigation_events')
      .select()
      .order('created_at', ascending: false);
  final events = eventRows
      .cast<Map<String, dynamic>>()
      .map(AdminMatterNavigationEvent.fromMap)
      .toList(growable: false);

  if (events.isEmpty) {
    return const AdminMatterNavigationOverview(
      events: <AdminMatterNavigationEvent>[],
      deviceSummaries: <AdminMatterNavigationDeviceSummary>[],
    );
  }

  final deviceIds = events
      .map((event) => event.deviceId.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);

  final profileMap = deviceIds.isEmpty
      ? const <String, DeviceProfile>{}
      : await ref.read(
          deviceProfilesByIdsProvider(serializeDeviceIds(deviceIds)).future,
        );

  final perDevice = <String, _DeviceCounters>{};
  for (final event in events) {
    final counters = perDevice.putIfAbsent(
      event.deviceId,
      () => _DeviceCounters(),
    );
    counters.total += 1;
    if (event.eventType == 'view') {
      counters.views += 1;
    } else {
      counters.transitions += 1;
    }
    if (counters.lastSeenAt == null ||
        event.createdAt.isAfter(counters.lastSeenAt!)) {
      counters.lastSeenAt = event.createdAt;
    }
  }

  final summaries = perDevice.entries.map((entry) {
    final deviceId = entry.key;
    final counters = entry.value;
    final profile = profileMap[deviceId];
    final resolvedLabel = _resolvedDeviceLabel(
      deviceId: deviceId,
      profile: profile,
    );
    return AdminMatterNavigationDeviceSummary(
      deviceId: deviceId,
      label: resolvedLabel,
      views: counters.views,
      transitions: counters.transitions,
      lastSeenAt: counters.lastSeenAt,
    );
  }).toList(growable: false)
    ..sort((a, b) {
      final aSeen = a.lastSeenAt;
      final bSeen = b.lastSeenAt;
      if (aSeen == null && bSeen == null) return a.label.compareTo(b.label);
      if (aSeen == null) return 1;
      if (bSeen == null) return -1;
      return bSeen.compareTo(aSeen);
    });

  return AdminMatterNavigationOverview(
    events: events,
    deviceSummaries: summaries,
  );
});

final adminMatterNavigationEventsByDeviceProvider =
    Provider.autoDispose.family<List<AdminMatterNavigationEvent>, String>(
  (ref, deviceId) {
    final events =
        ref.watch(adminMatterNavigationOverviewProvider).valueOrNull?.events ??
            const <AdminMatterNavigationEvent>[];
    return events
        .where((event) => event.deviceId == deviceId)
        .toList(growable: false);
  },
);

class _DeviceCounters {
  int total = 0;
  int views = 0;
  int transitions = 0;
  DateTime? lastSeenAt;
}

String _resolvedDeviceLabel({
  required String deviceId,
  required DeviceProfile? profile,
}) {
  final candidates = <String>[
    profile?.adminDisplayLabel ?? '',
    profile?.publicDisplayLabel ?? '',
    profile?.deviceLabel ?? '',
  ];
  for (final candidate in candidates) {
    final cleaned = _cleanDisplayText(candidate);
    if (cleaned.isNotEmpty) return cleaned;
  }
  return _friendlyDeviceFallback(deviceId);
}

String _cleanDisplayText(String? value) {
  final cleaned = (value ?? '').trim();
  if (cleaned.isEmpty) return '';
  final normalized = cleaned.toLowerCase();
  if (normalized == 'undefined' || normalized == 'null') return '';
  return cleaned;
}

String _friendlyDeviceFallback(String deviceId) {
  final cleaned = deviceId.trim();
  if (cleaned.isEmpty) return 'Dispositivo';
  final suffix = cleaned.length <= 4
      ? cleaned.toUpperCase()
      : cleaned.substring(cleaned.length - 4).toUpperCase();
  return 'Dispositivo $suffix';
}
