import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../../examenes/models/examen_event.dart';
import '../../examenes/providers/examenes_providers.dart';
import '../data/opiniones_catalog_repository.dart';
import '../models/opiniones_catalog.dart';
import '../models/opiniones_rating.dart';
import '../state/opiniones_store.dart';

final opinionesCatalogRepositoryProvider =
    Provider<OpinionesCatalogRepository>(
  (ref) => const OpinionesCatalogRepository(),
);

final opinionesCatalogoProvider = FutureProvider<OpinionesCatalogo>((ref) async {
  final repo = ref.watch(opinionesCatalogRepositoryProvider);
  final plan = await ref.watch(planProvider.future);
  final examenesRepo = ref.watch(examenesRepoProvider);
  final careerId = ref.watch(selectedCareerInfoProvider).id;

  final results = await Future.wait([
    examenesRepo.loadLlamado1(),
    examenesRepo.loadLlamado2(),
    examenesRepo.loadColoquios(),
  ]);

  final eventos = <Object>[...results[0], ...results[1], ...results[2]]
      .whereType<ExamenEvent>()
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
  final store = ref.watch(opinionesStoreProvider);
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

  final store = ref.watch(opinionesStoreProvider);
  final opiniones = store.docentes[docenteId] ?? const <DocenteOpinion>[];

  final aspectos = <String, RatingResumen>{};
  for (final key in kDocenteAspectos) {
    final values = opiniones
        .map((e) => e.aspectos[key])
        .whereType<int>();
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
