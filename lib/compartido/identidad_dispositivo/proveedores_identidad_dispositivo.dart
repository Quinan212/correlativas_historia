import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../supabase/supabase.dart';
import 'entrada_registro_dispositivo.dart';
import 'perfil_dispositivo.dart';
import 'repositorio_perfil_dispositivo.dart';
import 'servicio_identidad_dispositivo.dart';

final proveedorServicioIdentidadDispositivo =
    Provider<ServicioIdentidadDispositivo>(
  (ref) => const ServicioIdentidadDispositivo(),
);

final proveedorIdDispositivo = FutureProvider<String>((ref) async {
  final service = ref.watch(proveedorServicioIdentidadDispositivo);
  return service.getOrCreateDeviceId();
});

final proveedorEtiquetaDispositivo = FutureProvider<String>((ref) async {
  final service = ref.watch(proveedorServicioIdentidadDispositivo);
  return service.getCurrentDeviceLabel();
});

final proveedorRepositorioPerfilDispositivo =
    Provider<RepositorioPerfilDispositivo>(
  (ref) => const RepositorioPerfilDispositivo(),
);

final ownPerfilDispositivoProvider =
    FutureProvider<PerfilDispositivo?>((ref) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) return null;

  final repo = ref.watch(proveedorRepositorioPerfilDispositivo);
  final deviceId = await ref.watch(proveedorIdDispositivo.future);
  return repo.fetchProfile(client: client, deviceId: deviceId);
});

String serializeDeviceIds(Iterable<String> deviceIds) {
  final ids = deviceIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet()
    ..remove('');
  final sorted = ids.toList(growable: false)..sort();
  return sorted.join('|');
}

final proveedorPerfilesDispositivoPorIds = FutureProvider.family<Map<String, PerfilDispositivo>, String>((ref, key) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null || key.trim().isEmpty) {
    return const <String, PerfilDispositivo>{};
  }

  final ids =
      key.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  if (ids.isEmpty) return const <String, PerfilDispositivo>{};

  final repo = ref.watch(proveedorRepositorioPerfilDispositivo);
  return repo.fetchProfilesByIds(client: client, deviceIds: ids);
}, isAutoDispose: true);

final proveedorEntradasRegistroDispositivoPorIds = FutureProvider.family<Map<String, EntradaRegistroDispositivo>, String>((ref, key) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null || key.trim().isEmpty) {
    return const <String, EntradaRegistroDispositivo>{};
  }

  final ids =
      key.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  if (ids.isEmpty) return const <String, EntradaRegistroDispositivo>{};

  final rows = await client
      .from('device_registry')
      .select(
          'device_id, device_kind, lifecycle_status, label, notes, last_active_at')
      .inFilter('device_id', ids.toList(growable: false));

  final entries = rows
      .cast<Map<String, dynamic>>()
      .map(EntradaRegistroDispositivo.fromMap)
      .toList(growable: false);
  return {for (final entry in entries) entry.deviceId: entry};
}, isAutoDispose: true);
