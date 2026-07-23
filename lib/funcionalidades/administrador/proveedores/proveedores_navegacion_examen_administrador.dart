import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/supabase/supabase.dart';
import '../modelos/evento_navegacion_examen_administrador.dart';

class ResumenDispositivoNavegacionExamenAdministrador {
  const ResumenDispositivoNavegacionExamenAdministrador({
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

class ResumenNavegacionExamenAdministrador {
  const ResumenNavegacionExamenAdministrador({
    required this.events,
    required this.deviceSummaries,
  });

  final List<EventoNavegacionExamenAdministrador> events;
  final List<ResumenDispositivoNavegacionExamenAdministrador> deviceSummaries;
}

final proveedorResumenNavegacionExamenAdministrador =
    FutureProvider<ResumenNavegacionExamenAdministrador>((ref) async {
      final client = ref.watch(proveedorClienteSupabase);
      if (client == null) {
        return const ResumenNavegacionExamenAdministrador(
          events: <EventoNavegacionExamenAdministrador>[],
          deviceSummaries: <ResumenDispositivoNavegacionExamenAdministrador>[],
        );
      }

      final eventRows = await client
          .from('exam_navigation_events')
          .select()
          .order('created_at', ascending: false);
      final events = eventRows
          .cast<Map<String, dynamic>>()
          .map(EventoNavegacionExamenAdministrador.fromMap)
          .toList(growable: false);

      if (events.isEmpty) {
        return const ResumenNavegacionExamenAdministrador(
          events: <EventoNavegacionExamenAdministrador>[],
          deviceSummaries: <ResumenDispositivoNavegacionExamenAdministrador>[],
        );
      }

      final deviceIds = events
          .map((event) => event.deviceId.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false);

      final registryMap = deviceIds.isEmpty
          ? const <String, EntradaRegistroDispositivo>{}
          : await ref.read(
              proveedorEntradasRegistroDispositivoPorIds(
                serializeDeviceIds(deviceIds),
              ).future,
            );
      final profileMap = deviceIds.isEmpty
          ? const <String, PerfilDispositivo>{}
          : await ref.read(
              proveedorPerfilesDispositivoPorIds(
                serializeDeviceIds(deviceIds),
              ).future,
            );

      final perDevice = <String, _DeviceCounters>{};
      for (final event in events) {
        final registry = registryMap[event.deviceId];
        if (registry == null ||
            !registry.isVisibleInHistories ||
            !registry.isVisibleInAdminPanels) {
          continue;
        }
        final counters = perDevice.putIfAbsent(
          event.deviceId,
          _DeviceCounters.new,
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

      final summaries =
          perDevice.entries
              .map((entry) {
                final deviceId = entry.key;
                final counters = entry.value;
                final profile = profileMap[deviceId];
                final resolvedLabel = _etiquetaDispositivoResuelta(
                  deviceId: deviceId,
                  profile: profile,
                );
                return ResumenDispositivoNavegacionExamenAdministrador(
                  deviceId: deviceId,
                  label: resolvedLabel,
                  views: counters.views,
                  transitions: counters.transitions,
                  lastSeenAt: counters.lastSeenAt,
                );
              })
              .toList(growable: false)
            ..sort((a, b) {
              final aSeen = a.lastSeenAt;
              final bSeen = b.lastSeenAt;
              if (aSeen == null && bSeen == null)
                return a.label.compareTo(b.label);
              if (aSeen == null) return 1;
              if (bSeen == null) return -1;
              return bSeen.compareTo(aSeen);
            });

      return ResumenNavegacionExamenAdministrador(
        events: events,
        deviceSummaries: summaries,
      );
    }, isAutoDispose: true);

final proveedorEventosNavegacionExamenPorDispositivoAdministrador =
    Provider.family<List<EventoNavegacionExamenAdministrador>, String>((
      ref,
      deviceId,
    ) {
      final events =
          ref
              .watch(proveedorResumenNavegacionExamenAdministrador)
              .value
              ?.events ??
          const <EventoNavegacionExamenAdministrador>[];
      final visibleDeviceIds =
          ref
              .watch(proveedorResumenNavegacionExamenAdministrador)
              .value
              ?.deviceSummaries
              .map((summary) => summary.deviceId)
              .toSet() ??
          const <String>{};
      return events
          .where((event) => visibleDeviceIds.contains(event.deviceId))
          .where((event) => event.deviceId == deviceId)
          .toList(growable: false);
    }, isAutoDispose: true);

class _DeviceCounters {
  int total = 0;
  int views = 0;
  int transitions = 0;
  DateTime? lastSeenAt;
}

String _etiquetaDispositivoResuelta({
  required String deviceId,
  required PerfilDispositivo? profile,
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
  if (cleaned.isEmpty) return 'Equipo técnico';
  final suffix = cleaned.length <= 4
      ? cleaned.toUpperCase()
      : cleaned.substring(cleaned.length - 4).toUpperCase();
  return 'Equipo técnico $suffix';
}
