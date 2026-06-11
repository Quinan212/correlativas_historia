import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../examenes/modelos/evento_examen.dart';
import '../../examenes/proveedores/proveedores_examenes.dart';
import '../datos/repositorio_catalogo_opiniones.dart';
import '../modelos/catalogo_opiniones.dart';
import '../modelos/calificacion_opiniones.dart';
import '../estado/almacen_opiniones.dart';

final proveedorRepositorioCatalogoOpiniones =
    Provider<RepositorioCatalogoOpiniones>(
  (ref) => const RepositorioCatalogoOpiniones(),
);

final opinionesCatalogoProvider =
    FutureProvider<OpinionesCatalogo>((ref) async {
  final repo = ref.watch(proveedorRepositorioCatalogoOpiniones);
  final plan = await ref.watch(proveedorPlan.future);
  final examenesRepo = ref.watch(proveedorRepositorioExamenes);
  final careerId = ref.watch(proveedorCarreraSeleccionada).id;

  final results = await Future.wait([
    examenesRepo.loadLlamado1(),
    examenesRepo.loadLlamado2(),
    examenesRepo.loadColoquios(),
  ]);

  final eventos = <Object>[...results[0], ...results[1], ...results[2]]
      .whereType<EventoExamen>()
      .where((e) => e.careerId == careerId)
      .toList(growable: false);

  return repo.buildCatalogo(
    careerId: careerId,
    materias: plan.materias,
    eventos: eventos,
  );
});

final docentesPorMateriaProvider =
    Provider.family<List<DocenteLite>, String>((ref, materiaId) {
  final catalogo = ref.watch(opinionesCatalogoProvider).valueOrNull;
  if (catalogo == null) return const <DocenteLite>[];
  return catalogo.docentesPorMateria[materiaId] ?? const <DocenteLite>[];
});

final docenteBaseProvider =
    Provider.family<DocenteComunidadBase?, String>((ref, docenteId) {
  final catalogo = ref.watch(opinionesCatalogoProvider).valueOrNull;
  if (catalogo == null) return null;
  return catalogo.docentes[docenteId];
});

final materiaComunidadFichaProvider =
    Provider.family<MateriaComunidadFicha, String>((ref, materiaId) {
  final store = ref.watch(proveedorAlmacenOpiniones);
  final docentes = ref.watch(docentesPorMateriaProvider(materiaId));
  final opiniones = store.materias[materiaId] ?? const <MateriaOpinion>[];

  final promedio = _averageInts(opiniones.map((e) => e.rating));
  final tags = _topTags(opiniones);

  return MateriaComunidadFicha(
    materiaId: materiaId,
    rating: RatingResumen(promedio: promedio, votos: opiniones.length),
    docentes: docentes.map((e) => e.nombre).toList(growable: false),
    tagsFrecuentes: tags,
  );
});

final docenteComunidadFichaProvider =
    Provider.family<DocenteComunidadFicha?, String>((ref, docenteId) {
  final base = ref.watch(docenteBaseProvider(docenteId));
  if (base == null) return null;

  final store = ref.watch(proveedorAlmacenOpiniones);
  final opiniones = store.docentes[docenteId] ?? const <DocenteOpinion>[];

  final aspectos = <String, RatingResumen>{};
  for (final key in kDocenteAspectos) {
    final values = opiniones.map((e) => e.aspectos[key]).whereType<int>();
    aspectos[key] = RatingResumen(
      promedio: _averageInts(values),
      votos: values.length,
    );
  }

  return DocenteComunidadFicha(
    docenteId: docenteId,
    rating: DocenteRatingResumen(
      general: RatingResumen(
        promedio: _averageInts(opiniones.map((e) => e.general)),
        votos: opiniones.length,
      ),
      aspectos: aspectos,
    ),
    materias: base.materias.map((e) => e.nombre).toList(growable: false),
  );
});

double _averageInts(Iterable<int> values) {
  final list = values.toList(growable: false);
  if (list.isEmpty) return 0;
  final total = list.fold<int>(0, (sum, item) => sum + item);
  return total / list.length;
}

List<String> _topTags(List<MateriaOpinion> opiniones) {
  final counts = <String, int>{};
  for (final opinion in opiniones) {
    for (final tag in opinion.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }

  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.compareTo(b.key);
    });

  return entries.take(5).map((e) => e.key).toList(growable: false);
}
