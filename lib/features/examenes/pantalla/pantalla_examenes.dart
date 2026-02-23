import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/examenes_providers.dart';
import '../providers/plan_providers.dart';

import 'logica_examenes.dart';
import 'widgets/lista_materias.dart';
import 'sheet/route_sheet_examenes.dart';

class PantallaExamenes extends ConsumerWidget {
  const PantallaExamenes({super.key});

  Future<void> _openMateriaSheet(
      BuildContext context,
      WidgetRef ref, {
        required String careerId,
        required String materia,
        required bool fromColoquios,
      }) async {
    final nav = Navigator.of(context);

    final all = await ref.read(examenesAllProvider.future);
    if (!context.mounted) return;

    final pick = prepararPickParaSheet(
      all: all,
      careerId: careerId,
      materia: materia,
      fromColoquios: fromColoquios,
    );

    await nav.push(
      RouteSheetExamenes(
        materia: materia,
        llamado1: pick.llamado1,
        llamado2: pick.llamado2,
        detalleInicial: pick.detalleInicial,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careerId = ref.watch(examenesCareerIdProvider);
    final examenesAsync = ref.watch(examenesFiltradosProvider);
    final planMapaAsync = ref.watch(planMapaMateriasProvider(careerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Exámenes próximos')),
      backgroundColor: isDark ? cs.surface : const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? cs.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                initialValue: careerId,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: isDark ? cs.surface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
                items: const ['historia', 'geografia', 'politica']
                    .map(
                      (id) => DropdownMenuItem(
                    value: id,
                    child: Text(
                      id == 'politica'
                          ? 'Ciencia Política'
                          : (id[0].toUpperCase() + id.substring(1)),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(examenesCareerIdProvider.notifier).state = v;
                },
              ),
            ),
          ),

          // ✅ key para resetear el subtree cuando cambia careerId
          Expanded(
            key: ValueKey('examenes-body-$careerId'),
            child: planMapaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error cargando plan: $e')),
              data: (mapaPlan) {
                return examenesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error cargando exámenes: $e')),
                  data: (eventos) {
                    if (eventos.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay eventos cargados para ${labelCarrera(careerId)}.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    final secciones = armarSeccionesConPlan(
                      eventos: eventos,
                      mapaPlan: mapaPlan,
                    );

                    return ListaMaterias(
                      key: ValueKey('lista-$careerId'),
                      secciones: secciones,
                      onTapMateria: (materia, fromColoquios) => _openMateriaSheet(
                        context,
                        ref,
                        careerId: careerId,
                        materia: materia,
                        fromColoquios: fromColoquios,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}