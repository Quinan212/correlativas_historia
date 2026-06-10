import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/providers/app_state.dart';
import '../evaluation_panel.dart';
import 'utils/iterables.dart';
import 'widgets/banner_colapsable_calculadora.dart';
import 'widgets/bloque_selectores_calculadora.dart';
import 'widgets/resumen_materia_calculadora.dart';
import 'widgets/tarjeta_hero_calculadora.dart';
import 'widgets/tarjeta_paso_calculadora.dart';
import 'widgets/tarjeta_placeholder_calculadora.dart';

class CalculadoraScreen extends ConsumerWidget {
  const CalculadoraScreen({super.key});

  static const kPageBgLight = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final hasSelectedCareer = ref.watch(hasSelectedCareerProvider);
    final year = ref.watch(evalYearProvider);
    final selectedId = ref.watch(selectedCalcMateriaIdProvider);
    final topInset = MediaQuery.of(context).viewPadding.top;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: BannerColapsableCalculadora(
                topInset: topInset,
                subtitle: 'Condiciones y posibilidades',
              ),
            ),
            SliverToBoxAdapter(
              child: planAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Center(child: Text('Error cargando plan: $e')),
                ),
                data: (plan) {
                  final materiasYear = plan.materias
                      .where((m) => m.anio == year)
                      .toList()
                    ..sort((a, b) => a.nombre.compareTo(b.nombre));

                  final Materia? course = selectedId == null
                      ? null
                      : firstWhereOrNull(
                          plan.materias, (m) => m.id == selectedId);

                  if (selectedId != null && course == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedCalcMateriaIdProvider.notifier).state =
                          null;
                      ref.read(correlativaStatusMapProvider.notifier).clear();
                    });
                  }

                  if (!isDesktop) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const TarjetaHeroCalculadora(),
                          const SizedBox(height: 12),
                          const TarjetaPasoCalculadora(
                            numero: 1,
                            titulo: 'Elegí la carrera de referencia',
                            subtitulo:
                                'La lectura cambia según el plan y la institución que tomás como referencia.',
                          ),
                          const SizedBox(height: 12),
                          const TarjetaPasoCalculadora(
                            numero: 2,
                            titulo: 'Ubica el tramo del plan',
                            subtitulo:
                                'Elegí el año donde se ubica la materia para leer sus condiciones de cursada.',
                          ),
                          const SizedBox(height: 12),
                          const TarjetaPasoCalculadora(
                            numero: 3,
                            titulo: 'Pon la materia en contexto',
                            subtitulo:
                                'Seleccioná la materia que querés revisar para ver qué escenario se abre hoy.',
                          ),
                          const SizedBox(height: 16),
                          BloqueSelectoresCalculadora(
                              materiasYear: materiasYear),
                          const SizedBox(height: 16),
                          if (course == null)
                            TarjetaPlaceholderCalculadora(
                              texto: hasSelectedCareer
                                  ? 'Seleccioná un año y una materia para leer las condiciones de cursada de ese tramo.'
                                  : 'Seleccioná una carrera para habilitar esta lectura situada del plan.',
                            )
                          else ...[
                            ResumenMateriaCalculadora(materia: course),
                            const SizedBox(height: 12),
                            const EvaluationPanel(),
                          ],
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1520),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const TarjetaHeroCalculadora(),
                                  const SizedBox(height: 16),
                                  const TarjetaPasoCalculadora(
                                    numero: 1,
                                    titulo: 'Elegí la carrera de referencia',
                                    subtitulo:
                                        'La lectura cambia según el plan y la institución que tomás como referencia.',
                                  ),
                                  const SizedBox(height: 12),
                                  const TarjetaPasoCalculadora(
                                    numero: 2,
                                    titulo: 'Ubica el tramo del plan',
                                    subtitulo:
                                        'Elegí el año donde se ubica la materia para leer sus condiciones de cursada.',
                                  ),
                                  const SizedBox(height: 12),
                                  const TarjetaPasoCalculadora(
                                    numero: 3,
                                    titulo: 'Pon la materia en contexto',
                                    subtitulo:
                                        'Seleccioná la materia que querés revisar para ver qué escenario se abre hoy.',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  BloqueSelectoresCalculadora(
                                      materiasYear: materiasYear),
                                  const SizedBox(height: 16),
                                  if (course == null)
                                    TarjetaPlaceholderCalculadora(
                                      texto: hasSelectedCareer
                                          ? 'Seleccioná un año y una materia para leer las condiciones de cursada de ese tramo.'
                                          : 'Seleccioná una carrera para habilitar esta lectura situada del plan.',
                                    )
                                  else ...[
                                    ResumenMateriaCalculadora(materia: course),
                                    const SizedBox(height: 12),
                                    const EvaluationPanel(),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
