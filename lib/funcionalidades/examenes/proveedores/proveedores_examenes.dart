import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/repositorio_examenes.dart';
import '../modelos/evento_examen.dart';

final proveedorRepositorioExamenes =
    Provider<RepositorioExamenes>((ref) => const RepositorioExamenes());

enum ModoVistaExamenes {
  resumen,
  jerarquico,
}

final proveedorModoVistaExamenes =
    StateProvider<ModoVistaExamenes>((_) => ModoVistaExamenes.resumen);

enum ModoEstiloExamenes {
  clasico,
  zeus,
}

final proveedorModoEstiloExamenes =
    StateProvider<ModoEstiloExamenes>((_) => ModoEstiloExamenes.clasico);

void toggleExamenesStyle(WidgetRef ref) {
  final cur = ref.read(proveedorModoEstiloExamenes);
  ref.read(proveedorModoEstiloExamenes.notifier).state =
      cur == ModoEstiloExamenes.clasico
          ? ModoEstiloExamenes.zeus
          : ModoEstiloExamenes.clasico;
}

final proveedorTodosLosExamenes =
    FutureProvider<List<EventoExamen>>((ref) async {
  final repo = ref.watch(proveedorRepositorioExamenes);

  final results = await Future.wait<List<EventoExamen>>([
    repo.loadLlamado1(),
    repo.loadLlamado2(),
    repo.loadColoquios(),
  ]);

  final l1 = results[0];
  final l2 = results[1];
  final col = results[2];

  final all = <EventoExamen>[...l1, ...l2, ...col]..sort((a, b) {
      final da = a.fechaHora;
      final db = b.fechaHora;

      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

  return List<EventoExamen>.unmodifiable(all);
});

final proveedorIdCarreraExamenes = StateProvider<String>((ref) => 'historia');
final proveedorInstanciaExamenes = StateProvider<String>((ref) => 'todos');

final proveedorExamenesFiltrados =
    FutureProvider<List<EventoExamen>>((ref) async {
  final careerId = ref.watch(proveedorIdCarreraExamenes);
  final instancia = ref.watch(proveedorInstanciaExamenes);

  final list = await ref.watch(proveedorTodosLosExamenes.future);

  var out = list.where((e) => e.careerId == careerId).toList(growable: false);
  if (instancia != 'todos') {
    out = out.where((e) => e.instancia == instancia).toList(growable: false);
  }
  return out;
});
