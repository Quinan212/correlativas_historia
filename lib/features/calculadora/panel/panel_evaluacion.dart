import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';

import 'panel_estilos.dart';
import 'panel_pd_especiales.dart';
import 'panel_requisitos.dart';
import 'panel_resultado.dart';

class EvaluationPanel extends ConsumerWidget {
  const EvaluationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan =
        ref.watch(planProvider).maybeWhen(data: (p) => p, orElse: () => null);
    final selId = ref.watch(selectedCalcMateriaIdProvider);
    final statusMap = ref.watch(correlativaStatusMapProvider);

    if (plan == null || selId == null) return const SizedBox.shrink();

    final careerId = ref.watch(selectedCareerInfoProvider).id;

    final base = plan.materias.firstWhere((m) => m.id == selId);
    final course = PdEspeciales.prepararCurso(
      course0: base,
      careerId: careerId,
      all: plan.materias,
    );

    final reqBlock = PanelRequisitos.build(
      context: context,
      ref: ref,
      course: course,
      all: plan.materias,
      status: statusMap,
    );

    final res = evaluateCourse(course, statusMap, plan.materias);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reqBlock != null) ...[
          EstilosPanel.panelCard(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EstilosPanel.sectionHeader(context, 'Materias'),
                const SizedBox(height: 10),
                reqBlock,
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        EstilosPanel.panelCard(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EstilosPanel.sectionHeader(context, 'Escenario actual'),
              const SizedBox(height: 10),
              PanelResultado.build(context, res),
            ],
          ),
        ),
      ],
    );
  }
}
