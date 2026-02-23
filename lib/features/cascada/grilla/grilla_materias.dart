import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/app_state.dart';
import 'utils/cuatrimestre.dart';
import 'utils/orden_materias.dart';
import 'widgets/tarjeta_materia_grilla.dart';

class _TokensGrilla {
  static const borderLight = Color(0xFFE5E7EB);
  static const textPrimaryLight = Color(0xFF111827);
  static const textSecondaryLight = Color(0xFF6B7280);
}

Color _darken(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t)!;

class VisualizationGrid extends ConsumerStatefulWidget {
  const VisualizationGrid({
    super.key,
    this.showYearHeaders = true,
    this.borderless = false,
  });

  final bool showYearHeaders;
  final bool borderless;

  @override
  ConsumerState<VisualizationGrid> createState() => _VisualizationGridState();
}

class _VisualizationGridState extends ConsumerState<VisualizationGrid> {
  @override
  Widget build(BuildContext context) {
    final zoom = ref.watch(zoomProvider);
    final materias = ref.watch(filteredMateriasProvider);

    final ordered = ordenarMateriasParaGrilla(materias);
    final byYear = agruparPorAnio(ordered);
    final years = aniosPresentes(byYear);

    // Key que cambia cuando cambia el contenido visible (carrera/filtros)
    // sin depender de providers extra.
    final gridKey = '${ordered.length}_'
        '${years.length}_'
        '${ordered.isNotEmpty ? ordered.first.id : 'none'}_'
        '${ordered.isNotEmpty ? ordered.last.id : 'none'}';

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final BoxDecoration hostDeco = BoxDecoration(
      color: widget.borderless
          ? Colors.transparent
          : (isDark ? _darken(cs.surface) : Colors.white),
      borderRadius: BorderRadius.circular(widget.borderless ? 0 : 16),
      border: widget.borderless
          ? null
          : Border.all(
        color: cs.outlineVariant,
        width: 1,
      ),
      boxShadow: widget.borderless || isDark
          ? const []
          : [
        BoxShadow(
          blurRadius: 6,
          color: theme.shadowColor.withValues(alpha: 0.07),
        )
      ],
    );

    final EdgeInsets hostPadding =
    widget.borderless ? EdgeInsets.zero : const EdgeInsets.all(16.0);

    return Container(
      decoration: hostDeco,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.00, 0.02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(gridKey),
          child: Padding(
            padding: hostPadding,
            child: Transform.scale(
              alignment: Alignment.topLeft,
              scale: zoom,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  final bool isDesktopLike = kIsWeb || maxW >= 1100;
                  final double cardW = widget.borderless
                      ? maxW * 0.4
                      : (isDesktopLike ? 360 : maxW * 0.7);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int yi = 0; yi < years.length; yi++)
                        _yearBlock(
                          context: context,
                          theme: theme,
                          isDark: isDark,
                          year: years[yi],
                          yearIndex: yi,
                          yearMaterias: byYear[years[yi]]!,
                          cardW: cardW,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _yearBlock({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required int year,
    required int yearIndex,
    required List<dynamic> yearMaterias,
    required double cardW,
  }) {
    int? lastCuatri;

    final List<Widget> rowChildren = [
      const SizedBox(width: 4),
    ];

    for (int i = 0; i < yearMaterias.length; i++) {
      final m = yearMaterias[i];

      if (m.cuatri != lastCuatri) {
        rowChildren.add(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              etiquetaCuatri(m.cuatri),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white70
                    : _TokensGrilla.textSecondaryLight,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (i * 12).ms, duration: 180.ms)
              .slideY(begin: 0.06, end: 0, delay: (i * 12).ms, duration: 220.ms),
        );
        lastCuatri = m.cuatri;
      }

      rowChildren.add(
        SizedBox(
          width: cardW,
          child: TarjetaMateriaGrilla(
            m,
            borderless: widget.borderless,
          ),
        )
            .animate()
            .fadeIn(delay: (i * 18).ms, duration: 220.ms)
            .slideY(
          begin: 0.06,
          end: 0,
          delay: (i * 18).ms,
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        ),
      );

      rowChildren.add(const SizedBox(width: 12));
    }

    rowChildren.add(const SizedBox(width: 4));

    final block = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showYearHeaders)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Row(
              children: [
                Text(
                  '$year° Año',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white
                        : _TokensGrilla.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF4B5563)
                        : _TokensGrilla.borderLight,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : _TokensGrilla.borderLight,
                    ),
                  ),
                  child: Text(
                    '${yearMaterias.length} materias',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : _TokensGrilla.textSecondaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );

    return block
        .animate()
        .fadeIn(delay: (yearIndex * 40).ms, duration: 220.ms)
        .slideY(
      begin: 0.05,
      end: 0,
      delay: (yearIndex * 40).ms,
      duration: 260.ms,
      curve: Curves.easeOutCubic,
    );
  }
}