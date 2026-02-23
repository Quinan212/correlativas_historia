import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/examenes_repo.dart';
import '../models/examen_event.dart';

final examenesRepoProvider =
Provider<ExamenesRepo>((ref) => const ExamenesRepo());

// ✅ autoDispose + timeout para que nunca quede “loading infinito”
final examenesAllProvider =
FutureProvider.autoDispose<List<ExamenEvent>>((ref) async {
  final repo = ref.watch(examenesRepoProvider);

  final l1 = await repo
      .loadLlamado1()
      .timeout(const Duration(seconds: 10));
  final l2 = await repo
      .loadLlamado2()
      .timeout(const Duration(seconds: 10));
  final col = await repo
      .loadColoquios()
      .timeout(const Duration(seconds: 10));

  final all = <ExamenEvent>[...l1, ...l2, ...col]
    ..sort((a, b) {
      final da = a.fechaHora;
      final db = b.fechaHora;

      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

  return all;
});

final examenesCareerIdProvider = StateProvider<String>((ref) => 'historia');
final examenesInstanciaProvider = StateProvider<String>((ref) => 'todos');

// ✅ mejor como FutureProvider (evita estados pegajosos)
final examenesFiltradosProvider =
FutureProvider.autoDispose<List<ExamenEvent>>((ref) async {
  final careerId = ref.watch(examenesCareerIdProvider);
  final instancia = ref.watch(examenesInstanciaProvider);

  final list = await ref.watch(examenesAllProvider.future);

  var out = list.where((e) => e.careerId == careerId).toList();
  if (instancia != 'todos') {
    out = out.where((e) => e.instancia == instancia).toList();
  }
  return out;
});