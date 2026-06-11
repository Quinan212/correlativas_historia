import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../verificacion/proveedores/proveedores_verificacion.dart';
import '../datos/repositorio_resenas_opiniones.dart';
import '../modelos/publicacion_foto_materia.dart';
import '../modelos/calificacion_opiniones.dart';
import '../modelos/modelos_resenas_opiniones.dart';

final proveedorRepositorioResenasOpiniones =
    Provider<RepositorioResenasOpiniones>(
  (ref) => const RepositorioResenasOpiniones(),
);

final proveedorResenasMateria = StreamProvider.autoDispose
    .family<List<ResenaMateria>, String>((ref, matterId) async* {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    yield const <ResenaMateria>[];
    return;
  }

  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  yield* repo.watchResenaMaterias(client: client, matterId: matterId);
});

final proveedorResenaMateriaPropia = FutureProvider.autoDispose
    .family<ResenaMateria?, String>((ref, matterId) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    return null;
  }

  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  final deviceId = await ref.watch(proveedorIdDispositivo.future);
  return repo.fetchOwnResenaMateria(
    client: client,
    deviceId: deviceId,
    matterId: matterId,
  );
});

final proveedorResumenResenasMateria =
    Provider.autoDispose.family<ResumenResenasMateria, String>((ref, matterId) {
  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  final reviews = ref.watch(proveedorResenasMateria(matterId)).valueOrNull ??
      const <ResenaMateria>[];
  return repo.resumirMateria(reviews);
});

final proveedorPublicacionesFotoMateria = StreamProvider.autoDispose
    .family<List<PublicacionFotoMateria>, String>((ref, matterId) async* {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    yield const <PublicacionFotoMateria>[];
    return;
  }

  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  yield* repo.watchPublicacionFotoMaterias(client: client, matterId: matterId);
});

final proveedorResenasDocente = StreamProvider.autoDispose
    .family<List<ResenaDocente>, String>((ref, teacherId) async* {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    yield const <ResenaDocente>[];
    return;
  }

  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  yield* repo.watchResenaDocentes(client: client, teacherId: teacherId);
});

final proveedorResenasDocentePropiasPorMateria =
    FutureProvider.autoDispose.family<Map<String, ResenaDocente>, String>((
  ref,
  matterId,
) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) {
    return const <String, ResenaDocente>{};
  }

  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  final deviceId = await ref.watch(proveedorIdDispositivo.future);
  return repo.fetchOwnResenaDocentesForMatter(
    client: client,
    deviceId: deviceId,
    matterId: matterId,
  );
});

final proveedorResenaDocentePropia =
    Provider.family<AsyncValue<ResenaDocente?>, AlcanceResenaDocente>(
        (ref, scope) {
  final reviewsAsync =
      ref.watch(proveedorResenasDocentePropiasPorMateria(scope.matterId));
  return reviewsAsync.whenData((reviews) => reviews[scope.teacherId]);
});

final proveedorResumenResenasDocente =
    Provider.autoDispose.family<DocenteRatingResumen, String>((ref, teacherId) {
  final repo = ref.watch(proveedorRepositorioResenasOpiniones);
  final reviews = ref.watch(proveedorResenasDocente(teacherId)).valueOrNull ??
      const <ResenaDocente>[];
  return repo.resumirDocente(reviews);
});

final proveedorMateriaPuedeResenar =
    Provider.family<bool, String>((ref, matterId) {
  return ref.watch(proveedorEstadoVerificacionMateria(matterId)).canReview;
});
