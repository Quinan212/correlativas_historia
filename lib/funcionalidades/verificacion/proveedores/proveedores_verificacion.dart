import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../administrador/proveedores/proveedores_acceso_administrador.dart';
import '../datos/repositorio_verificacion.dart';
import '../modelos/estado_verificacion_materia.dart';
import '../modelos/solicitud_verificacion.dart';

final proveedorRepositorioVerificacion = Provider<RepositorioVerificacion>(
  (ref) => const RepositorioVerificacion(),
);

final proveedorOpcionesMateriasVerificacion =
    Provider<List<OpcionMateriaVerificacion>>(
  (ref) {
    final plan = ref.watch(proveedorPlan).valueOrNull;
    if (plan == null) return const <OpcionMateriaVerificacion>[];
    final items = plan.materias
        .map(
          (m) => OpcionMateriaVerificacion(
            id: m.id,
            name: m.displayNombre,
            year: m.anio,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byYear = a.year.compareTo(b.year);
        if (byYear != 0) return byYear;
        return a.name.compareTo(b.name);
      });
    return items;
  },
);

final proveedorSolicitudesVerificacionPropias =
    StreamProvider<List<SolicitudVerificacion>>((ref) async* {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    yield const <SolicitudVerificacion>[];
    return;
  }

  final repo = ref.watch(proveedorRepositorioVerificacion);
  final deviceId = await ref.watch(proveedorIdDispositivo.future);
  yield* repo.watchOwnRequests(client: client, deviceId: deviceId);
});

final proveedorIdsMateriasAprobadas = StreamProvider<Set<String>>((ref) async* {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    yield const <String>{};
    return;
  }

  final repo = ref.watch(proveedorRepositorioVerificacion);
  final deviceId = await ref.watch(proveedorIdDispositivo.future);
  yield* repo.watchApprovedMatterIds(client: client, deviceId: deviceId);
});

final proveedorSolicitudesVerificacionPendientes =
    StreamProvider<List<SolicitudVerificacion>>((ref) async* {
  final adminStatus =
      await ref.watch(proveedorEstadoDispositivoAdministrador.future);
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null || !adminStatus.isAdmin) {
    yield const <SolicitudVerificacion>[];
    return;
  }

  final repo = ref.watch(proveedorRepositorioVerificacion);
  yield* repo.watchPendingRequests(client: client);
});

final proveedorSolicitudesVerificacionRevisadas =
    StreamProvider<List<SolicitudVerificacion>>((ref) async* {
  final adminStatus =
      await ref.watch(proveedorEstadoDispositivoAdministrador.future);
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null || !adminStatus.isAdmin) {
    yield const <SolicitudVerificacion>[];
    return;
  }

  final repo = ref.watch(proveedorRepositorioVerificacion);
  yield* repo.watchReviewedRequests(client: client);
});

class OpcionMateriaVerificacion {
  const OpcionMateriaVerificacion({
    required this.id,
    required this.name,
    required this.year,
  });

  final String id;
  final String name;
  final int year;
}

final proveedorEstadoVerificacionMateria =
    Provider.family<EstadoVerificacionMateria, String>((ref, matterId) {
  final requests =
      ref.watch(proveedorSolicitudesVerificacionPropias).valueOrNull ??
          const <SolicitudVerificacion>[];
  final approvedMatterIds =
      ref.watch(proveedorIdsMateriasAprobadas).valueOrNull ?? const <String>{};

  if (approvedMatterIds.contains(matterId)) {
    final approvedRequest = requests
        .where((item) => item.matterId == matterId)
        .where((item) => item.status == EstadoSolicitudVerificacion.approved)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return EstadoVerificacionMateria(
      status: SituacionVerificacionMateria.approved,
      request: approvedRequest.isEmpty ? null : approvedRequest.first,
    );
  }

  final matching = requests.where((item) => item.matterId == matterId).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  SolicitudVerificacion? latest(EstadoSolicitudVerificacion status) {
    for (final item in matching) {
      if (item.status == status) return item;
    }
    return null;
  }

  final approved = latest(EstadoSolicitudVerificacion.approved);
  if (approved != null) {
    return EstadoVerificacionMateria(
      status: SituacionVerificacionMateria.approved,
      request: approved,
    );
  }

  final pending = latest(EstadoSolicitudVerificacion.pending);
  if (pending != null) {
    return EstadoVerificacionMateria(
      status: SituacionVerificacionMateria.pending,
      request: pending,
    );
  }

  final rejected = latest(EstadoSolicitudVerificacion.rejected);
  if (rejected != null) {
    return EstadoVerificacionMateria(
      status: SituacionVerificacionMateria.rejected,
      request: rejected,
    );
  }

  return const EstadoVerificacionMateria(
    status: SituacionVerificacionMateria.unverified,
  );
});
