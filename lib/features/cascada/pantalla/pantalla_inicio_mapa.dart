import 'package:correlativas_historia/features/examenes/examenes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import 'widgets/banner_colapsable_mapa.dart';
import 'widgets/callout_examenes.dart';
import 'widgets/tarjeta_autor_mapa.dart';
import 'widgets/tarjeta_leyenda_mapa.dart';
import 'widgets/tarjeta_presentacion_mapa.dart';
import 'widgets/tarjeta_regimen_correlatividades.dart';

class InicioMapaScreen extends ConsumerWidget {
  const InicioMapaScreen({super.key});

  static const Color kPageBgLight = Color(0xFFF5F7FA);
  static const double kMaxWGeneral = 1400;

  void _openExamenes(BuildContext context, WidgetRef ref) {
    prewarmExamenesData(ref);
    Navigator.of(
      context,
    ).push(buildExamenesRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1180;

    final items = <Widget>[
      _PanelInicio(
        onOpenMapa: () => ref.read(routerIndexProvider.notifier).state = 1,
        onOpenCalculadora: () =>
            ref.read(routerIndexProvider.notifier).state = 2,
      ),
      _PresentacionRegimenBlock(isDesktop: isDesktop),
      CalloutExamenes(onTap: () => _openExamenes(context, ref)),
      const TarjetaLeyendaMapa(),
      const TarjetaAutorMapa(),
    ];

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      body: CustomScrollView(
        cacheExtent: 200, // Ajustado para ahorrar RAM en dispositivos gama baja
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: BannerColapsableMapa(topInset: topInset),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final child = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: child, // El SliverList ya gestiona RepaintBoundaries si se lo pedimos abajo
                  );
                },
                childCount: items.length,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true, // Crucial para que el CPU no trabaje de más
              ),
            ),
          ),
        ],
      ),
    );

  }
}

class _PresentacionRegimenBlock extends ConsumerWidget {
  const _PresentacionRegimenBlock({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelectedCareer = ref.watch(hasSelectedCareerProvider);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: TarjetaPresentacionMapa()),
          if (hasSelectedCareer) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: TarjetaRegimenCorrelatividades(compact: true),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TarjetaPresentacionMapa(),
        if (hasSelectedCareer) ...[
          const SizedBox(height: 12),
          const TarjetaRegimenCorrelatividades(compact: true),
        ],
      ],
    );
  }
}

class _PanelInicio extends StatelessWidget {
  const _PanelInicio({
    required this.onOpenMapa,
    required this.onOpenCalculadora,
  });

  final VoidCallback onOpenMapa;
  final VoidCallback onOpenCalculadora;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFDCE3EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 16, // Reducido de 24 para mejor performance
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Inicio del mapa',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.18),
                  ),
                ),
                child: Icon(
                  Icons.space_dashboard_outlined,
                  size: 18,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Una lectura situada del recorrido de cursada',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Desde aca podes ubicarte en el plan, leer la referencia normativa que acompana cada carrera y entrar a las herramientas principales con mas contexto.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact(); // Feedback háptico
                  onOpenMapa();
                },
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.map_rounded, size: 20),
                label: const Text('Abrir mapa'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact(); // Feedback háptico
                  onOpenCalculadora();
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: cs.outlineVariant, width: 1.5),
                ),
                icon: const Icon(Icons.calculate_rounded, size: 20),
                label: const Text('Abrir calculadora'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
