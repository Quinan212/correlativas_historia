// panel_detalle_materia.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:correlativas_historia/modelos/materia.dart';
import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:correlativas_historia/funcionalidades/opiniones/componentes/seccion_comunidad_materia.dart';

import 'utilidades/reglas_practicas_detalle.dart';

import 'secciones/correlativas_requeridas.dart';
import 'secciones/materias_que_habilita.dart';
import 'interfaz/etiquetas_detalle.dart';
import 'componentes/controles_superiores.dart';

class PanelDetalleMateria extends ConsumerWidget {
  const PanelDetalleMateria({
    super.key,
    this.showHeaderCloseButton = true,
    this.initialMateriaId,
  });

  final bool showHeaderCloseButton;
  final String? initialMateriaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(proveedorPlan);
    final plan = planAsync.value;
    final selectedId =
        ref.watch(proveedorIdMateriaSeleccionada) ?? initialMateriaId;
    if (selectedId == null) {
      debugPrint('PanelDetalleMateria: selectedId null');
      return const _DeferredSectionPlaceholder(
        title: 'Detalle de materia',
        body: 'No pudimos recuperar la materia seleccionada.',
      );
    }
    if (plan == null) {
      debugPrint('PanelDetalleMateria: plan null for selectedId=$selectedId');
      return const _DeferredSectionPlaceholder(
        title: 'Detalle de materia',
        body: 'Cargando correlativas, comunidad y referencias...',
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final all = plan.materias;
    Materia? selectedMateria;
    for (final materia in all) {
      if (materia.id == selectedId) {
        selectedMateria = materia;
        break;
      }
    }
    if (selectedMateria == null) {
      debugPrint(
        'PanelDetalleMateria: materia $selectedId no encontrada en plan (len=${all.length})',
      );
      return const _DeferredSectionPlaceholder(
        title: 'Detalle de materia',
        body: 'No encontramos esa materia en el plan cargado.',
      );
    }
    final m = selectedMateria;
    final careerId = ref.watch(proveedorCarreraSeleccionada).id;

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
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderBox(
            title: nombreDetalleMateria(m),
            showCloseButton: showHeaderCloseButton,
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
              ref.read(proveedorIdMateriaSeleccionada.notifier).state = null;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  body,
                  if (careerId == 'historia') ...[
                    const SizedBox(height: 14),
                    _DeferredMatterCommunitySection(
                      materia: m,
                      careerId: careerId,
                    ),
                  ],
                ],
              ),
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

class _DeferredMatterCommunitySection extends StatefulWidget {
  const _DeferredMatterCommunitySection({
    required this.materia,
    required this.careerId,
  });

  final Materia materia;
  final String careerId;

  @override
  State<_DeferredMatterCommunitySection> createState() =>
      _DeferredMatterCommunitySectionState();
}

class _DeferredMatterCommunitySectionState
    extends State<_DeferredMatterCommunitySection> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Esperamos 280ms para que la animación de entrada del modal (240ms)
    // termine antes de reavivar el árbol gigantesco de la comunidad
    // y evitar los tirones de compilación de Shaders.
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const RepaintBoundary(
        child: _DeferredSectionPlaceholder(
          title: 'Comunidad de la materia',
          body: 'Cargando referencias, fotos y docentes vinculados...',
        ),
      );
    }

    return RepaintBoundary(
      child: MateriaComunidadSection(
        materia: widget.materia,
        careerId: widget.careerId,
      ),
    );
  }
}

class _DeferredSectionPlaceholder extends StatelessWidget {
  const _DeferredSectionPlaceholder({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B1220) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    color: Colors.black.withValues(alpha: 0.035),
                  ),
                ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.3,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBox extends StatelessWidget {
  const _HeaderBox({
    required this.title,
    required this.showCloseButton,
    required this.chips,
    required this.onClose,
  });

  final String title;
  final bool showCloseButton;
  final Widget chips;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF111827) : Colors.white;
    final border = isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    color: Colors.black.withValues(alpha: 0.04),
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
                if (showCloseButton) ...[
                  const SizedBox(width: 10),
                  BotonCerrarDetalle(onTap: onClose),
                ],
              ],
            ),
            const SizedBox(height: 10),
            chips,
          ],
        ),
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

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    color: Colors.black.withValues(alpha: 0.035),
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
                color:
                    isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
