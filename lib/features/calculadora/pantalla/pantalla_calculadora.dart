import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/providers/app_state.dart';
import '../evaluation_panel.dart';
import 'utils/iterables.dart';
import 'widgets/banner_colapsable_calculadora.dart';
import 'widgets/bloque_autor_calculadora.dart';
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

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: BannerColapsableCalculadora(
              topInset: topInset,
              subtitle: '¿Puedo Cursar?',
            ),
          ),
          SliverToBoxAdapter(
            child: planAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
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

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TarjetaHeroCalculadora(),
                      const SizedBox(height: 12),
                      const TarjetaPasoCalculadora(
                        numero: 1,
                        titulo: 'Seleccioná la Carrera',
                        subtitulo:
                            'Elegí primero la carrera (p. ej., Profesorado en Geografía o Profesorado de Historia).',
                      ),
                      const SizedBox(height: 12),
                      const TarjetaPasoCalculadora(
                        numero: 2,
                        titulo: 'Seleccioná el Año',
                        subtitulo:
                            'Elegí el año de la materia que querés saber si podés cursar.',
                      ),
                      const SizedBox(height: 12),
                      const TarjetaPasoCalculadora(
                        numero: 3,
                        titulo: 'Seleccioná la Materia',
                        subtitulo:
                            'Ahora, elegí la materia específica que te interesa.',
                      ),
                      const SizedBox(height: 16),
                      BloqueSelectoresCalculadora(materiasYear: materiasYear),
                      const SizedBox(height: 16),
                      if (course == null)
                        TarjetaPlaceholderCalculadora(
                          texto: hasSelectedCareer
                              ? 'Selecciona un año y una materia para ver tus opciones de cursada.'
                              : 'Selecciona una carrera para habilitar el resto de la calculadora.',
                        )
                      else ...[
                        ResumenMateriaCalculadora(materia: course),
                        const SizedBox(height: 12),
                        const EvaluationPanel(),
                      ],
                      const SizedBox(height: 24),
                      const BloqueAutorCalculadora(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
