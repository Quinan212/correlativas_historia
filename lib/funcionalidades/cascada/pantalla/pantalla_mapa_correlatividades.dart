import 'package:correlativas_historia/funcionalidades/examenes/examenes_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../panel_detalle_materia.dart';
import '../filters_bar.dart';
import '../visualization_grid.dart';
import 'utilidades/decoraciones_mapa.dart';
import 'utilidades/layout_mapa.dart';
import 'componentes/banner_colapsable_mapa.dart';
import 'componentes/barra_controles_una_linea.dart';
import 'componentes/selector_carrera_independiente.dart';
import 'componentes/tablero_anios_escritorio.dart';
import 'componentes/tarjeta_regimen_correlatividades.dart';

class PantallaMapaCorrelatividades extends ConsumerWidget {
  const PantallaMapaCorrelatividades({super.key});

  static const Color kPageBgLight = Color(0xFFF5F7FA);
  static const double kMaxWGeneral = 1400;
  static const double kColsFactor = 1.18;
  static const double kColsSidePadding = 12.0;

  void _openExamenes(BuildContext context, WidgetRef ref) {
    prewarmExamenesData(ref);
    Navigator.of(context).push(buildExamenesRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(proveedorPlan);
    final topInset = MediaQuery.of(context).viewPadding.top;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isWindowsDesktop = LayoutMapa.isWindowsDesktop();
    final hasSelectedCareer = ref.watch(proveedorTieneCarreraSeleccionada);

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              heroTag: 'fab_examenes_cascada',
              onPressed: () => _openExamenes(context, ref),
              tooltip: 'Examenes',
              child: const Icon(Icons.calendar_month),
            )
          : null,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    floating: false,
                    delegate: BannerColapsableMapa(
                      topInset: topInset,
                      expandedTitle: 'Mapa de Correlatividades',
                      collapsedTitle: 'MAPA DE CORRELATIVIDADES',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: LayoutMapa.pageContainer(
                      context,
                      maxW: kMaxWGeneral,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            if (isDesktop && isWindowsDesktop) ...[
                              BarraControlesUnaLinea(
                                inputDecorationBuilder:
                                    DecoracionesMapa.inputDecoration,
                              ),
                            ] else ...[
                              if (isDesktop) ...[
                                const SelectorCarreraIndependiente(),
                                const SizedBox(height: 8),
                              ] else ...[
                                const SizedBox(height: 12),
                                const SelectorCarreraIndependiente(),
                              ],
                            ],
                            if (hasSelectedCareer) ...[
                              const SizedBox(height: 12),
                              const TarjetaRegimenCorrelatividades(),
                              if (!(isDesktop && isWindowsDesktop)) ...[
                                const SizedBox(height: 12),
                                const FiltersBar(),
                              ],
                              const SizedBox(height: 12),
                            ],
                            if (!isDesktop && hasSelectedCareer)
                              const GrillaVisualizacion(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isDesktop && hasSelectedCareer)
                    SliverToBoxAdapter(
                      child: LayoutMapa.columnsContainer(
                        context,
                        maxWGeneral: kMaxWGeneral,
                        colsFactor: kColsFactor,
                        colsSidePadding: kColsSidePadding,
                        child: const TableroAniosEscritorio(),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: LayoutMapa.pageContainer(
                      context,
                      maxW: kMaxWGeneral,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 24),
                        child: planAsync.when(
                          data: (_) => const SizedBox.shrink(),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text(
                            'Error cargando plan: $e',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop && ref.watch(proveedorIdMateriaSeleccionada) != null)
              const _PanelLateralEscritorio(),
          ],
        ),
      ),
    );
  }
}

class _PanelLateralEscritorio extends ConsumerWidget {
  const _PanelLateralEscritorio();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 450,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? cs.outlineVariant : const Color(0xFFDCE3EC),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          const SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: PanelDetalleMateria(),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: () {
                ref.read(proveedorIdMateriaSeleccionada.notifier).state = null;
              },
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
