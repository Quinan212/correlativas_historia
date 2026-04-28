import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/utils/text_sanitize.dart';
import '../data/examenes_repo.dart';

String _norm(String s) =>
    sanitizeLowerNoAccents(s).replaceAll(RegExp(r'\s+'), ' ').trim();

final planMapaMateriasProvider =
    FutureProvider.family<Map<String, Materia>, String>((ref, carreraId) async {
  Future<PlanData> load;
  switch (carreraId) {
    case 'geografia':
      load = loadPlanFromGeografiaHtml();
      break;
    case 'politica':
      load = loadPlanFromPoliticaHtml();
      break;
    case 'historia':
    default:
      load = loadPlanFromHistoriaHtml();
      break;
  }

  final plan = await load;

  final map = <String, Materia>{};
  for (final materia in plan.materias) {
    map[_norm(materia.displayNombre)] = materia;
    map[_norm(materia.nombre)] = materia;
    if (materia.codigo.trim().isNotEmpty) {
      map[_norm(materia.codigo)] = materia;
    }
  }

  return Map<String, Materia>.unmodifiable(map);
});
