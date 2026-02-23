// detail_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:correlativas_historia/shared/providers/app_state.dart';

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

    // IMPORTANTE: las secciones ya no dibujan título, porque el box lo pone.
    final left = seccionCorrelativasRequeridas(
      context: context,
      ref: ref,
      all: all,
      m: m,
      careerId: careerId,
      showTitle: false,
    );

    final right = seccionMateriasQueHabilita(
      context: context,
      ref: ref,
      dependents: dependents,
      showTitle: false,
    );

    final body = LayoutBuilder(
      builder: (_, c) {
        final twoCols = c.maxWidth >= 760;
        if (twoCols) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionBox(
                  title: 'Correlativas Requeridas',
                  child: left,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SectionBox(
                  title: 'Materias que Habilita',
                  child: right,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionBox(title: 'Correlativas Requeridas', child: left),
            const SizedBox(height: 14),
            _SectionBox(title: 'Materias que Habilita', child: right),
          ],
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderBox(
            title: nombreDetalleMateria(m),
            chips: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chipTipoDetalle(context, m.tipo),
                chipFormatoDetalle(context, m.formato),
                chipAnioDetalle(context, m.anio),
              ],
            ),
            onClose: () {
              HapticFeedback.lightImpact();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              ref.read(selectedMateriaIdProvider.notifier).state = null;
            },
          ),
          const SizedBox(height: 12),
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
              child: body,
            ),
          ),
          const SizedBox(height: 2),
          if (!isDark)
            Divider(
              height: 18,
              thickness: 1,
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
        ],
      ),
    );
  }
}

class _HeaderBox extends StatelessWidget {
  const _HeaderBox({
    required this.title,
    required this.chips,
    required this.onClose,
  });

  final String title;
  final Widget chips;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF111827) : Colors.white;
    final border = isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1),
        boxShadow: isDark
            ? const []
            : [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? cs.onSurface : const Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BotonCerrarDetalle(onTap: onClose),
            ],
          ),
          const SizedBox(height: 10),
          chips,
        ],
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  const _SectionBox({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0B1220) : Colors.white;
    final border = isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1),
        boxShadow: isDark
            ? const []
            : [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}