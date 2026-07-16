import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../datos/repositorio_examenes.dart';

String _norm(String s) =>
    sanitizeLowerNoAccents(s).replaceAll(RegExp(r'\s+'), ' ').trim();

final proveedorPlanMapaMaterias =
    FutureProvider.family<Map<String, Materia>, String>((ref, carreraId) async {
  Future<DatosPlan> load;
  switch (carreraId) {
    case 'geografia':
      load = cargarPlanDesdeGeografiaHtml();
      break;
    case 'politica':
      load = cargarPlanDesdePoliticaHtml();
      break;
    case 'historia':
    default:
      load = cargarPlanDesdeHistoriaHtml();
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
