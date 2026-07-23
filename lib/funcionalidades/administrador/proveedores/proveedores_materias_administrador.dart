import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../datos/cargador_fuente_html.dart';

/// Provider que dada una carrera y un año, devuelve la lista de materias disponibles.
final proveedorMateriasPorAnioAdministrador =
    FutureProvider.family<List<String>, ({String careerId, int year})>((
      ref,
      params,
    ) async {
      final assetPath = 'assets/data/${params.careerId}.json';
      final plan = await cargarPlanDesdeAssetHtml(assetPath);

      final byYear = <int, List<String>>{};
      for (final materia in plan.materias) {
        final year = materia.anio;
        byYear.putIfAbsent(year, () => <String>[]).add(materia.nombre);
      }

      final yearMaterias = byYear[params.year] ?? <String>[];
      yearMaterias.sort();
      return yearMaterias;
    });
