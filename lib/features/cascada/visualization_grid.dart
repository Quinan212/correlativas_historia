export 'grilla/grilla_materias.dart';

/*
import '../../shared/providers/app_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/materia.dart';
import './detail_panel.dart';

class _AppColors {
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
}

Color _darken(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t)!;

String _normalizeFormatoChip(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('práctica docente') ||
      s.contains('practica docente') ||
      s.contains('práctica profesional docente') ||
      s.contains('practica profesional docente') ||
      s.contains('residencia')) {
    return 'Seminario-Taller';
  }
  return raw;
}

int _tipoRank(String t) {
  final s = t.toLowerCase();
  if (s.contains('general')) return 0;
  if (s.contains('espec')) return 1;
  if (s.contains('práctica') || s.contains('practica')) return 2;
  return 99;
}

int _cuatriRank(Materia m) {
  final c = m.cuatri;
  if (c == null) return 99;
  return c;
}

String _cuatriLabel(int? cuatri) {
  if (cuatri == null) return 'Anuales';
  if (cuatri == 1) return '1° cuatrimestre';
  if (cuatri == 2) return '2° cuatrimestre';
  return '$cuatri° cuatrimestre';
}

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

    final ordered = [...materias]..sort((a, b) {
      final byYear = a.anio.compareTo(b.anio);
      if (byYear != 0) {
        return byYear;
      }
      final byCuatri = _cuatriRank(a).compareTo(_cuatriRank(b));
      if (byCuatri != 0) {
        return byCuatri;
      }
      final byTipo = _tipoRank(a.tipo).compareTo(_tipoRank(b.tipo));
      if (byTipo != 0) {
        return byTipo;
      }
      return a.nombre.compareTo(b.nombre);
    });

    final byYear = <int, List<Materia>>{};
    for (final m in ordered) {
      byYear.putIfAbsent(m.anio, () => []).add(m);
    }
    final years = [1, 2, 3, 4, 5].where(byYear.containsKey).toList();

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
          color: theme.shadowColor.withOpacity(0.07),
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
                                    : _AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isDark
                                    ? const Color(0xFF4B5563)
                                    : _AppColors.border,
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
                                      : _AppColors.border,
                                ),
                              ),
                              child: Text(
                                '${byYear[y]!.length} materias',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : _AppColors.textSecondary,
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
                              final label = _cuatriLabel(m.cuatri);
                              children.add(
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    label,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white70
                                          : _AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                              lastCuatri = m.cuatri;
                            }
                            children.add(
                              SizedBox(
                                width: cardW,
                                child: _MateriaCard(
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

class _MateriaCard extends ConsumerWidget {
  final Materia m;
  final bool borderless;

  const _MateriaCard(this.m, {this.borderless = false});

  Color _getTitleColor(bool isDark, String tipo) {
    final (_, fg, __) = _getTypeColors(isDark, tipo);
    return fg;
  }

  (Color bg, Color fg, Color bd) _getFormatColors(bool isDark, String fmtRaw) {
    final value = _normalizeFormatoChip(fmtRaw);
    final t = value.toLowerCase();

    if (!isDark) {
      if (t == 'asignatura') {
        return (
        const Color(0xFFDBEAFE),
        const Color(0xFF1D4ED8),
        const Color(0xFFBFDBFE),
        );
      }
      if (t == 'seminario') {
        return (
        const Color(0xFFD1FAE5),
        const Color(0xFF065F46),
        const Color(0xFFA7F3D0),
        );
      }
      if (t == 'seminario-taller') {
        return (
        const Color(0xFFEDE9FE),
        const Color(0xFF5B21B6),
        const Color(0xFFC4B5FD),
        );
      }
      if (t == 'taller') {
        return (
        const Color(0xFFFFF7ED),
        const Color(0xFFC2410C),
        const Color(0xFFFED7AA),
        );
      }
      if (t == 'electiva') {
        return (
        const Color(0xFFEFF6FF),
        const Color(0xFF1D4ED8),
        const Color(0xFFBFDBFE),
        );
      }
      if (t == 'práctica' || t == 'practica') {
        return (
        const Color(0xFFF5F3FF),
        const Color(0xFF6D28D9),
        const Color(0xFFDDD6FE),
        );
      }

      return (
      const Color(0xFFF3F4F6),
      const Color(0xFF374151),
      const Color(0xFFE5E7EB),
      );
    }

    if (t == 'asignatura') {
      return (
      _darken(const Color(0xFF223761)),
      const Color(0xFFBFD4FF),
      const Color(0xFF3E60A4),
      );
    }
    if (t == 'seminario') {
      return (
      _darken(const Color(0xFF1E4F45)),
      const Color(0xFFBFEFE0),
      const Color(0xFF2D8C78),
      );
    }
    if (t == 'seminario-taller') {
      return (
      _darken(const Color(0xFF3A2769)),
      const Color(0xFFE7D7FF),
      const Color(0xFF7351D4),
      );
    }
    if (t == 'taller') {
      return (
      _darken(const Color(0xFF7C2D12)),
      const Color(0xFFFED7AA),
      const Color(0xFFEA580C),
      );
    }
    if (t == 'electiva') {
      return (
      _darken(const Color(0xFF223761)),
      const Color(0xFFBFD4FF),
      const Color(0xFF3E60A4),
      );
    }
    if (t == 'práctica' || t == 'practica') {
      return (
      _darken(const Color(0xFF4C1D95)),
      const Color(0xFFDDD6FE),
      const Color(0xFF7C3AED),
      );
    }

    return (
    _darken(const Color(0xFF29313A)),
    const Color(0xFFE5E7EB),
    const Color(0xFF3E4753),
    );
  }

  (Color bg, Color fg, Color bd) _getTypeColors(bool isDark, String tipo) {
    final s = tipo.toLowerCase();

    final isContable = s.contains('contable');
    final isJuridica = s.contains('jurídica') || s.contains('juridica');
    final isEconomia = s.contains('economía') || s.contains('economia');
    final isAdmin = s.contains('administración') ||
        s.contains('administracion') ||
        s.contains('admin');
    final isMate =
        s.contains('matemática') || s.contains('matematica') || s.contains('mate');
    final isFlexible = s.contains('flexible');
    final isHumanistica =
        s.contains('humanística') || s.contains('humanistica') || s.contains('humani');

    final isGen = s.contains('general');
    final isEsp = s.contains('espec');
    final isPra = s.contains('práctica') ||
        s.contains('practica') ||
        s.contains('profesional');

    if (!isDark) {
      if (isContable) {
        return (
        const Color(0xFFECFDF3),
        const Color(0xFF047857),
        const Color(0xFFA7F3D0),
        );
      }
      if (isJuridica) {
        return (
        const Color(0xFFFEF2F2),
        const Color(0xFFB91C1C),
        const Color(0xFFFECACA),
        );
      }
      if (isEconomia) {
        return (
        const Color(0xFFEFF6FF),
        const Color(0xFF1D4ED8),
        const Color(0xFFBFDBFE),
        );
      }
      if (isAdmin) {
        return (
        const Color(0xFFFFF7ED),
        const Color(0xFFC2410C),
        const Color(0xFFFED7AA),
        );
      }
      if (isMate) {
        return (
        const Color(0xFFF5F3FF),
        const Color(0xFF6D28D9),
        const Color(0xFFDDD6FE),
        );
      }
      if (isFlexible) {
        return (
        const Color(0xFFECFEFF),
        const Color(0xFF0E7490),
        const Color(0xFFA5F3FC),
        );
      }
      if (isHumanistica) {
        return (
        const Color(0xFFFDF2F8),
        const Color(0xFFBE185D),
        const Color(0xFFFBCFE8),
        );
      }

      if (isGen) {
        return (
        const Color(0xFFDBEAFE),
        const Color(0xFF1D4ED8),
        const Color(0xFFBFDBFE),
        );
      }
      if (isEsp) {
        return (
        const Color(0xFFD1FAE5),
        const Color(0xFF065F46),
        const Color(0xFFA7F3D0),
        );
      }
      if (isPra) {
        return (
        const Color(0xFFEDE9FE),
        const Color(0xFF5B21B6),
        const Color(0xFFC4B5FD),
        );
      }

      return (
      const Color(0xFFF3F4F6),
      const Color(0xFF374151),
      const Color(0xFFE5E7EB),
      );
    }

    if (isContable) {
      return (
      _darken(const Color(0xFF064E3B)),
      const Color(0xFFA7F3D0),
      const Color(0xFF047857),
      );
    }
    if (isJuridica) {
      return (
      _darken(const Color(0xFF7F1D1D)),
      const Color(0xFFFECACA),
      const Color(0xFFDC2626),
      );
    }
    if (isEconomia) {
      return (
      _darken(const Color(0xFF1E3A8A)),
      const Color(0xFFBFDBFE),
      const Color(0xFF2563EB),
      );
    }
    if (isAdmin) {
      return (
      _darken(const Color(0xFF7C2D12)),
      const Color(0xFFFED7AA),
      const Color(0xFFEA580C),
      );
    }
    if (isMate) {
      return (
      _darken(const Color(0xFF4C1D95)),
      const Color(0xFFDDD6FE),
      const Color(0xFF7C3AED),
      );
    }
    if (isFlexible) {
      return (
      _darken(const Color(0xFF155E75)),
      const Color(0xFFA5F3FC),
      const Color(0xFF06B6D4),
      );
    }
    if (isHumanistica) {
      return (
      _darken(const Color(0xFF831843)),
      const Color(0xFFFBCFE8),
      const Color(0xFFDB2777),
      );
    }

    if (isGen) {
      return (
      _darken(const Color(0xFF223761)),
      const Color(0xFFBFD4FF),
      const Color(0xFF3E60A4),
      );
    }
    if (isEsp) {
      return (
      _darken(const Color(0xFF1E4F45)),
      const Color(0xFFBFEFE0),
      const Color(0xFF2D8C78),
      );
    }
    if (isPra) {
      return (
      _darken(const Color(0xFF3A2769)),
      const Color(0xFFE7D7FF),
      const Color(0xFF7351D4),
      );
    }

    return (
    _darken(const Color(0xFF29313A)),
    const Color(0xFFE5E7EB),
    const Color(0xFF3E4753),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedMateriaIdProvider);
    final isSelected = selectedId == m.id;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final plan = ref.watch(planProvider).valueOrNull;
    final codeById = {
      for (final x in (plan?.materias ?? <Materia>[])) x.id: x.codigo
    };
    String abbr =
    (codeById[m.id] ?? m.codigo).toString().trim().toUpperCase();
    if (abbr.isEmpty) {
      abbr = m.id.substring(0, 2).toUpperCase();
    }

    final bgColor = isDark ? _darken(cs.surface) : Colors.white;
    final borderColor = isSelected
        ? const Color(0xFF005B7F)
        : (isDark ? const Color(0xFF374151) : _AppColors.border);

    final (typeBg, typeFg, typeBd) = _getTypeColors(isDark, m.tipo);
    final titleColor = _getTitleColor(isDark, m.tipo);

    final normalizedFormato = _normalizeFormatoChip(m.formato);
    final (fmtBg, fmtFg, fmtBd) =
    _getFormatColors(isDark, normalizedFormato);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          ref.read(selectedMateriaIdProvider.notifier).state = m.id;

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.40,
              maxChildSize: 0.95,
              builder: (context, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: isDark
                          ? const Color(0xFF1F2937)
                          : Colors.white,
                      child: ListView(
                        controller: scrollCtrl,
                        padding: EdgeInsets.zero,
                        children: const [
                          RepaintBoundary(child: DetailPanel()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
          ref.read(selectedMateriaIdProvider.notifier).state = null;
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isDark || borderless
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      abbr,
                      style: TextStyle(
                        fontSize: 15.4,
                        fontWeight: FontWeight.w800,
                        color: titleColor.withValues(
                          alpha: isDark ? 0.9 : 0.8,
                        ),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.nombre,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: fmtBg,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: fmtBd),
                          ),
                          child: Text(
                            normalizedFormato,
                            style: TextStyle(
                              fontSize: 11.34,
                              fontWeight: FontWeight.w600,
                              color: fmtFg,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeBg,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: typeBd),
                          ),
                          child: Text(
                            m.tipo,
                            style: TextStyle(
                              fontSize: 11.34,
                              fontWeight: FontWeight.w600,
                              color: typeFg,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFFD1D5DB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
