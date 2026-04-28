import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/html_source_loader.dart';

/// Provider que dada una carrera y un año, devuelve la lista de materias disponibles.
final adminMateriasByYearProvider =
    FutureProvider.family<List<String>, ({String careerId, int year})>(
        (ref, params) async {
  final assetPath = 'assets/data/${params.careerId}.json';
  final plan = await loadPlanFromHtmlAsset(assetPath);

  final byYear = <int, List<String>>{};
  for (final materia in plan.materias) {
    final year = materia.anio;
    byYear.putIfAbsent(year, () => <String>[]).add(materia.nombre);
  }

  final yearMaterias = byYear[params.year] ?? <String>[];
  yearMaterias.sort();
  return yearMaterias;
});
