import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/admin_exam_navigation_event.dart';

class AdminExamNavigationDeviceSummary {
  const AdminExamNavigationDeviceSummary({
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

class AdminExamNavigationOverview {
  const AdminExamNavigationOverview({
    required this.events,
    required this.deviceSummaries,
  });

  final List<AdminExamNavigationEvent> events;
  final List<AdminExamNavigationDeviceSummary> deviceSummaries;
}

final adminExamNavigationOverviewProvider =
    FutureProvider.autoDispose<AdminExamNavigationOverview>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return const AdminExamNavigationOverview(
      events: <AdminExamNavigationEvent>[],
      deviceSummaries: <AdminExamNavigationDeviceSummary>[],
    );
  }

  final eventRows = await client
      .from('exam_navigation_events')
      .select()
      .order('created_at', ascending: false);
  final events = eventRows
      .cast<Map<String, dynamic>>()
      .map(AdminExamNavigationEvent.fromMap)
      .toList(growable: false);

  if (events.isEmpty) {
    return const AdminExamNavigationOverview(
      events: <AdminExamNavigationEvent>[],
      deviceSummaries: <AdminExamNavigationDeviceSummary>[],
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
    if (event.isView) {
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
    return AdminExamNavigationDeviceSummary(
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

  return AdminExamNavigationOverview(
    events: events,
    deviceSummaries: summaries,
  );
});

final adminExamNavigationEventsByDeviceProvider =
    Provider.autoDispose.family<List<AdminExamNavigationEvent>, String>(
  (ref, deviceId) {
    final events =
        ref.watch(adminExamNavigationOverviewProvider).valueOrNull?.events ??
            const <AdminExamNavigationEvent>[];
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
