import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../compartido/supabase/supabase.dart';
import '../../../datos/cargador_fuente_html.dart';
import '../../../modelos/materia.dart';
import '../datos/repositorio_estudiantes_administrador.dart';
import '../modelos/entrada_historial_estudiante_administrador.dart';
import '../modelos/estudiante_administrador.dart';
import '../modelos/item_nomina_materia_administrador.dart';
import '../modelos/materia_estudiante_administrador.dart';

final proveedorRepositorioEstudiantesAdministrador =
    Provider<RepositorioEstudiantesAdministrador>((ref) {
  return const RepositorioEstudiantesAdministrador();
});

final proveedorFiltroCarreraEstudiantesAdministrador =
    StateProvider<String>((_) => 'artes_visuales');

final proveedorEstudiantesAdministrador =
    FutureProvider.family<List<EstudianteAdministrador>, String>(
        (ref, adminDeviceId) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) return const <EstudianteAdministrador>[];
  final careerId = ref.watch(proveedorFiltroCarreraEstudiantesAdministrador);
  final repo = ref.watch(proveedorRepositorioEstudiantesAdministrador);
  return repo.list(
    client: client,
    adminDeviceId: adminDeviceId,
    careerId: careerId,
  );
});

final proveedorMateriasEstudianteAdministrador = FutureProvider.family<
    List<MateriaEstudianteAdministrador>,
    ({String adminDeviceId, String studentId})>((ref, args) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null) return const <MateriaEstudianteAdministrador>[];
  final repo = ref.watch(proveedorRepositorioEstudiantesAdministrador);
  return repo.listSubjects(
    client: client,
    adminDeviceId: args.adminDeviceId,
    studentId: args.studentId,
  );
});

final proveedorPlanCarreraAdministrador =
    FutureProvider.family<List<Materia>, String>((ref, careerId) async {
  final asset = switch (careerId) {
    'musica' => 'assets/Musica.html',
    _ => 'assets/data/artes_visuales.json',
  };
  final plan = await cargarPlanDesdeAssetHtml(asset);
  final materias = [...plan.materias]..sort((a, b) {
      final year = a.anio.compareTo(b.anio);
      if (year != 0) return year;
      return a.displayNombre.compareTo(b.displayNombre);
    });
  return materias;
});

final proveedorNominaMateriaAdministrador = FutureProvider.family<
    List<ItemNominaMateriaAdministrador>,
    ({
      String adminDeviceId,
      String careerId,
      String subjectId
    })>((ref, args) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null || args.subjectId.isEmpty) {
    return const <ItemNominaMateriaAdministrador>[];
  }
  final repo = ref.watch(proveedorRepositorioEstudiantesAdministrador);
  return repo.listSubjectRoster(
    client: client,
    adminDeviceId: args.adminDeviceId,
    careerId: args.careerId,
    subjectId: args.subjectId,
  );
});

final proveedorHistorialEstudianteAdministrador = FutureProvider.family<
    List<EntradaHistorialEstudianteAdministrador>,
    ({String adminDeviceId, String studentId})>((ref, args) async {
  final client = ref.watch(proveedorClienteSupabase);
  if (client == null || args.studentId.isEmpty) {
    return const <EntradaHistorialEstudianteAdministrador>[];
  }
  final repo = ref.watch(proveedorRepositorioEstudiantesAdministrador);
  return repo.listHistory(
    client: client,
    adminDeviceId: args.adminDeviceId,
    studentId: args.studentId,
  );
});
