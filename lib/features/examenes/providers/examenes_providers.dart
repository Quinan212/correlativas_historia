import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/examenes_repo.dart';
import '../models/examen_event.dart';

final examenesRepoProvider =
    Provider<ExamenesRepo>((ref) => const ExamenesRepo());

final examenesAllProvider = FutureProvider<List<ExamenEvent>>((ref) async {
  final repo = ref.watch(examenesRepoProvider);

  final results = await Future.wait<List<ExamenEvent>>([
    repo.loadLlamado1().timeout(const Duration(seconds: 10)),
    repo.loadLlamado2().timeout(const Duration(seconds: 10)),
    repo.loadColoquios().timeout(const Duration(seconds: 10)),
  ]);

  final l1 = results[0];
  final l2 = results[1];
  final col = results[2];

  final all = <ExamenEvent>[...l1, ...l2, ...col]
    ..sort((a, b) {
      final da = a.fechaHora;
      final db = b.fechaHora;

      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

  return List<ExamenEvent>.unmodifiable(all);
});

final examenesCareerIdProvider = StateProvider<String>((ref) => 'historia');
final examenesInstanciaProvider = StateProvider<String>((ref) => 'todos');

final examenesFiltradosProvider = FutureProvider<List<ExamenEvent>>((ref) async {
  final careerId = ref.watch(examenesCareerIdProvider);
  final instancia = ref.watch(examenesInstanciaProvider);

  final list = await ref.watch(examenesAllProvider.future);

  var out = list.where((e) => e.careerId == careerId).toList(growable: false);
  if (instancia != 'todos') {
    out = out.where((e) => e.instancia == instancia).toList(growable: false);
  }
  return out;
});
