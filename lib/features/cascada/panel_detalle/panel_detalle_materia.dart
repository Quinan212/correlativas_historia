// detail_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

import 'package:correlativas_historia/shared/providers/app_state.dart';
import 'package:correlativas_historia/models/materia.dart';

import 'utils/paleta_detalle.dart';
import 'utils/reglas_practicas_detalle.dart';

import 'secciones/correlativas_requeridas.dart';
import 'secciones/materias_que_habilita.dart';
import 'ui/chips_detalle.dart';
import 'componentes/controles_superiores.dart';

class DetailPanel extends ConsumerWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider).valueOrNull;
    final selectedId = ref.watch(selectedMateriaIdProvider);
    if (plan == null || selectedId == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final all = plan.materias;
    final m = all.firstWhere((x) => x.id == selectedId);
    final careerId = ref.watch(selectedCareerInfoProvider).id;

    final dependents = dependientesDeMateria(all, m, careerId);

    final left = _correlativasRequeridas(
      context: context,
      ref: ref,
      all: all,
      m: m,
      careerId: careerId,
    );

    final right = _materiasQueHabilita(
      context: context,
      ref: ref,
      dependents: dependents,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  nombreDetalleMateria(m),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? cs.onSurface : const Color(0xFF111827),
                  ),
                ),
              ),
              _PremiumCloseButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  ref.read(selectedMateriaIdProvider.notifier).state = null;
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tipoChip(context, m.tipo),
              _formatoChip(context, m.formato),
              _yearChip(context, m.anio),
            ],
          ),
          const SizedBox(height: 16),

          // SOLO el cuerpo cambia con animación (no el header ni el botón)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            reverseDuration: const Duration(milliseconds: 160),
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, anim) {
              final isIncoming = anim.status != AnimationStatus.reverse;

              if (isIncoming) {
                final inAnim = CurvedAnimation(
                  parent: anim,
                  curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
                );

                return FadeTransition(
                  opacity: inAnim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).animate(inAnim),
                    child: child,
                  ),
                );
              }

              final outT = CurvedAnimation(
                parent: ReverseAnimation(anim),
                curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
              );

              return FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(outT),
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(m.id),
              child: LayoutBuilder(
                builder: (_, c) {
                  final twoCols = c.maxWidth >= 760;
                  if (twoCols) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: 16),
                        Expanded(child: right),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      left,
                      const SizedBox(height: 16),
                      right,
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // delega a archivos separados (misma salida, menos ruido acá)
  Widget _correlativasRequeridas({
    required BuildContext context,
    required WidgetRef ref,
    required List<Materia> all,
    required Materia m,
    required String careerId,
  }) {
    return seccionCorrelativasRequeridas(
      context: context,
      ref: ref,
      all: all,
      m: m,
      careerId: careerId,
    );
  }

  Widget _materiasQueHabilita({
    required BuildContext context,
    required WidgetRef ref,
    required List<Materia> dependents,
  }) {
    return seccionMateriasQueHabilita(
      context: context,
      ref: ref,
      dependents: dependents,
    );
  }

  Widget _tipoChip(BuildContext context, String tipo) => chipTipoDetalle(context, tipo);
  Widget _formatoChip(BuildContext context, String formato) => chipFormatoDetalle(context, formato);
  Widget _yearChip(BuildContext context, int anio) => chipAnioDetalle(context, anio);
}

class _PremiumCloseButton extends StatelessWidget {
  const _PremiumCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BotonCerrarDetalle(onTap: onTap);
}

class _PremiumGrabHandle extends StatelessWidget {
  const _PremiumGrabHandle();

  @override
  Widget build(BuildContext context) => const AgarreDetalle();
}