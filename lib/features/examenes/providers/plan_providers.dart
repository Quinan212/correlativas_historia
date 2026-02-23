import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../data/examenes_repo.dart';

String _norm(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

// ✅ autoDispose + timeout por carrera
final planMapaMateriasProvider =
FutureProvider.autoDispose.family<Map<String, Materia>, String>(
        (ref, carreraId) async {
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

      // ✅ si política se cuelga, esto corta y pasa a error
      final plan = await load.timeout(const Duration(seconds: 10));

      final map = <String, Materia>{};
      for (final m in plan.materias) {
        map[_norm(m.displayNombre)] = m;
        map[_norm(m.nombre)] = m;
        if (m.codigo.trim().isNotEmpty) {
          map[_norm(m.codigo)] = m;
        }
      }
      return map;
    });