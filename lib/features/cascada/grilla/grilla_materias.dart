import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../../../models/materia.dart';

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
                  ? maxW * 0.3
                  : (isDesktopLike ? 360 : maxW * 0.6);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final y in years) ...[
                    if (widget.showYearHeaders)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        child: Row(
                          children: [
                            Text(
                              '$y° Año',
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
                                '${byYear[y]!.length} materias',
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
                        children: () {
                          final yearMaterias = byYear[y]!;
                          final List<Widget> children = [
                            const SizedBox(width: 4),
                          ];

                          int? lastCuatri;
                          for (final m in yearMaterias) {
                            if (m.cuatri != lastCuatri) {
                              children.add(
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
                                ),
                              );
                              lastCuatri = m.cuatri;
                            }

                            children.add(
                              SizedBox(
                                width: cardW,
                                child: TarjetaMateriaGrilla(
                                  m,
                                  borderless: widget.borderless,
                                ),
                              ),
                            );
                            children.add(const SizedBox(width: 12));
                          }

                          children.add(const SizedBox(width: 4));
                          return children;
                        }(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}