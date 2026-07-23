import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/supabase/supabase.dart';
import '../datos/repositorio_limpieza_masiva_administrador.dart';
import '../modelos/estado_dispositivo_administrador.dart';

class DispositivoObservadoAdministrador {
  const DispositivoObservadoAdministrador({
    required this.deviceId,
    required this.label,
    required this.lastSeenAt,
    this.notes,
  });

  final String deviceId;
  final String label;
  final DateTime? lastSeenAt;
  final String? notes;
}

final proveedorRepositorioLimpiezaMasivaAdministrador =
    Provider<RepositorioLimpiezaMasivaAdministrador>((ref) {
      return const RepositorioLimpiezaMasivaAdministrador();
    });

final proveedorEstadoDispositivoAdministrador = FutureProvider<EstadoDispositivoAdministrador>((
  ref,
) async {
  final deviceId = await ref.watch(proveedorIdDispositivo.future);
  final bootstrap = ref.watch(proveedorArranqueSupabase);
  final client = ref.watch(proveedorClienteSupabase);

  if (!bootstrap.isReady || client == null) {
    return EstadoDispositivoAdministrador(
      deviceId: deviceId,
      isAdmin: false,
      message:
          'Supabase todavia no esta listo. Cuando termine de conectar, vas a poder comprobar el acceso admin de este dispositivo.',
    );
  }

  try {
    final row = await client
        .from('admin_devices')
        .select('device_id, enabled, label')
        .eq('device_id', deviceId)
        .maybeSingle();

    if (row == null) {
      return EstadoDispositivoAdministrador(
        deviceId: deviceId,
        isAdmin: false,
        message:
            'Este dispositivo todavia no tiene acceso admin. Si lo habilitas en admin_devices, despues toca refrescar.',
      );
    }

    final enabled = row['enabled'] == true;
    final label = (row['label'] as String?)?.trim();

    return EstadoDispositivoAdministrador(
      deviceId: deviceId,
      isAdmin: enabled,
      adminLabel: label,
      message: enabled
          ? 'Este dispositivo tiene acceso admin habilitado.'
          : 'Este dispositivo figura en admin_devices, pero esta deshabilitado.',
    );
  } on PostgrestException catch (error) {
    return EstadoDispositivoAdministrador(
      deviceId: deviceId,
      isAdmin: false,
      message:
          'No se pudo leer admin_devices. Crea la tabla y habilita SELECT con RLS. Detalle: ${error.message}',
    );
  } catch (error) {
    return EstadoDispositivoAdministrador(
      deviceId: deviceId,
      isAdmin: false,
      message: 'Fallo la comprobacion de acceso admin: $error',
    );
  }
});

final proveedorDispositivosObservadosAdministrador =
    FutureProvider<List<DispositivoObservadoAdministrador>>((ref) async {
      final bootstrap = ref.watch(proveedorArranqueSupabase);
      final client = ref.watch(proveedorClienteSupabase);

      if (!bootstrap.isReady || client == null) {
        return const <DispositivoObservadoAdministrador>[];
      }

      final registryRows = await client
          .from('device_registry')
          .select('device_id, label, notes, last_active_at')
          .eq('lifecycle_status', 'active')
          .order('label');

      final registry = registryRows
          .cast<Map<String, dynamic>>()
          .where((row) {
            final deviceId = (row['device_id'] ?? '').toString().trim();
            final label = (row['label'] ?? '').toString().trim();
            final notes = (row['notes'] ?? '').toString().trim();
            return !shouldHideDeviceFromAdminPanels(
              deviceId: deviceId,
              label: label,
              notes: notes,
            );
          })
          .toList(growable: false);
      if (registry.isEmpty) return const <DispositivoObservadoAdministrador>[];

      final deviceIds = registry
          .map((row) => (row['device_id'] ?? '').toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

      final tokenRows = await client
          .from('device_push_tokens')
          .select('device_id, enabled, last_seen_at, updated_at')
          .inFilter('device_id', deviceIds);

      final profileRows = await client
          .from('device_profiles')
          .select('device_id, device_label, public_alias, reference_name')
          .inFilter('device_id', deviceIds);

      final profileByDevice = <String, Map<String, dynamic>>{};
      for (final row in profileRows.cast<Map<String, dynamic>>()) {
        final deviceId = (row['device_id'] ?? '').toString().trim();
        if (deviceId.isEmpty) continue;
        profileByDevice[deviceId] = row;
      }

      final latestSeenByDevice = <String, DateTime?>{};
      for (final raw in tokenRows.cast<Map<String, dynamic>>()) {
        final deviceId = (raw['device_id'] ?? '').toString().trim();
        if (deviceId.isEmpty) continue;
        final enabled = raw['enabled'] == true;
        if (!enabled) continue;
        final seenRaw = raw['last_seen_at'] ?? raw['updated_at'];
        final parsed = seenRaw == null
            ? null
            : DateTime.tryParse(seenRaw.toString());
        final current = latestSeenByDevice[deviceId];
        if (parsed == null) {
          latestSeenByDevice.putIfAbsent(deviceId, () => current);
          continue;
        }
        if (current == null || parsed.isAfter(current)) {
          latestSeenByDevice[deviceId] = parsed;
        }
      }

      final items =
          registry
              .map((row) {
                final deviceId = (row['device_id'] ?? '').toString().trim();
                final profile = profileByDevice[deviceId];
                final deviceLabel = _cleanDisplayText(profile?['device_label']);
                final alias = _cleanDisplayText(profile?['public_alias']);
                final referenceName = _cleanDisplayText(
                  profile?['reference_name'],
                );
                final registryLabel = _cleanDisplayText(row['label']);

                final resolvedLabel = deviceLabel.isNotEmpty
                    ? deviceLabel
                    : alias.isNotEmpty
                    ? alias
                    : referenceName.isNotEmpty
                    ? referenceName
                    : registryLabel.isNotEmpty
                    ? registryLabel
                    : _friendlyDeviceFallback(deviceId);

                return DispositivoObservadoAdministrador(
                  deviceId: deviceId,
                  label: resolvedLabel,
                  lastSeenAt:
                      DateTime.tryParse(
                        (row['last_active_at'] ?? '').toString(),
                      ) ??
                      latestSeenByDevice[deviceId],
                  notes: (row['notes'] as String?)?.trim(),
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

      return items;
    });

final proveedorCantidadEstudiantesDemoAdministrador = FutureProvider<int>((
  ref,
) async {
  final bootstrap = ref.watch(proveedorArranqueSupabase);
  final client = ref.watch(proveedorClienteSupabase);

  if (!bootstrap.isReady || client == null) {
    return 0;
  }

  final rows = await client
      .from('academic_students')
      .select('id')
      .eq('is_demo', true);
  return rows.length;
});

String _cleanDisplayText(dynamic value) {
  final cleaned = (value ?? '').toString().trim();
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
