import 'package:correlativas_historia/features/examenes/examenes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/callout_examenes.dart';

import '../../../shared/providers/app_state.dart';
import '../filters_bar.dart';
import '../visualization_grid.dart';

import 'utils/layout_mapa.dart';
import 'utils/decoraciones_mapa.dart';

import 'widgets/banner_colapsable_mapa.dart';
import 'widgets/tarjeta_presentacion_mapa.dart';
import 'widgets/tarjeta_regimen_correlatividades.dart';
import 'widgets/tarjeta_leyenda_mapa.dart';
import 'widgets/tarjeta_autor_mapa.dart';
import 'widgets/barra_controles_una_linea.dart';
import 'widgets/selector_carrera_standalone.dart';
import 'widgets/tablero_anios_desktop.dart';

class CascadaScreen extends ConsumerWidget {
  const CascadaScreen({super.key});

  static const kPageBgLight = Color(0xFFF5F7FA);

  static const double kMaxWGeneral = 1400;
  static const double kColsFactor = 1.18;
  static const double kColsSidePadding = 12.0;

  void _openExamenes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExamenesScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final topInset = MediaQuery.of(context).viewPadding.top;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1180;
    final isWindowsDesktop = LayoutMapa.isWindowsDesktop();

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      floatingActionButton: (!isDesktop)
          ? FloatingActionButton.extended(
        onPressed: () => _openExamenes(context),
        icon: const Icon(Icons.calendar_month),
        label: const Text('Exámenes'),
      )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: BannerColapsableMapa(topInset: topInset),
          ),
          SliverToBoxAdapter(
            child: LayoutMapa.pageContainer(
              context,
              maxW: kMaxWGeneral,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDesktop && isWindowsDesktop) ...[
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: TarjetaPresentacionMapa()),
                          SizedBox(width: 12),
                          Expanded(child: TarjetaRegimenCorrelatividades()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BarraControlesUnaLinea(
                        inputDecorationBuilder: DecoracionesMapa.inputDecoration,
                      ),
                    ] else ...[
                      const TarjetaPresentacionMapa(),
                      const SizedBox(height: 12),

                      if (isDesktop) ...[
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: TarjetaRegimenCorrelatividades()),
                            SizedBox(width: 12),
                            Expanded(child: SelectorCarreraStandalone()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CalloutExamenes(onTap: () => _openExamenes(context)),
                        const SizedBox(height: 12),
                        const FiltersBar(),
                      ] else ...[
                        const TarjetaRegimenCorrelatividades(),
                        const SizedBox(height: 12),

                        // ✅ acá: el aviso ANTES del selector
                        CalloutExamenes(onTap: () => _openExamenes(context)),
                        const SizedBox(height: 12),

                        const SelectorCarreraStandalone(),
                        const SizedBox(height: 12),

                        const FiltersBar(),
                      ],
                    ],
                    const SizedBox(height: 12),
                    if (!isDesktop) const VisualizationGrid(),
                  ],
                ),
              ),
            ),
          ),
          if (isDesktop)
            SliverToBoxAdapter(
              child: LayoutMapa.columnsContainer(
                context,
                maxWGeneral: kMaxWGeneral,
                colsFactor: kColsFactor,
                colsSidePadding: kColsSidePadding,
                child: const TableroAniosDesktop(),
              ),
            ),
          SliverToBoxAdapter(
            child: LayoutMapa.pageContainer(
              context,
              maxW: kMaxWGeneral,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TarjetaLeyendaMapa(),
                    const SizedBox(height: 12),
                    const TarjetaAutorMapa(),
                    const SizedBox(height: 24),
                    planAsync.when(
                      data: (_) => const SizedBox.shrink(),
                      loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text(
                        'Error cargando plan: $e',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}