import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart' show Ticker;
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

class _AutoScrollingHorizontalStrip extends StatefulWidget {
  const _AutoScrollingHorizontalStrip({
    required this.child,
  });

  final Widget child;

  @override
  State<_AutoScrollingHorizontalStrip> createState() =>
      _AutoScrollingHorizontalStripState();
}

class _AutoScrollingHorizontalStripState
    extends State<_AutoScrollingHorizontalStrip>
    with SingleTickerProviderStateMixin {
  static const double _autoScrollPixelsPerSecond = 22.0;
  static const Duration _resumeDelay = Duration(seconds: 2);

  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;

  Duration? _lastElapsed;
  bool _userPaused = false;
  double _direction = 1.0;
  DateTime? _resumeAt;
  bool _showLeadingFade = false;
  bool _showTrailingFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncEdgeFades);
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncEdgeFades());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncEdgeFades);
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncEdgeFades() {
    if (!_scrollController.hasClients) {
      if (_showLeadingFade || _showTrailingFade) {
        setState(() {
          _showLeadingFade = false;
          _showTrailingFade = false;
        });
      }
      return;
    }

    final position = _scrollController.position;
    final nextLeading = position.pixels > 2;
    final nextTrailing = position.pixels < position.maxScrollExtent - 2;

    if (nextLeading != _showLeadingFade || nextTrailing != _showTrailingFade) {
      setState(() {
        _showLeadingFade = nextLeading;
        _showTrailingFade = nextTrailing;
      });
    }
  }

  void _pauseFromUser() {
    _userPaused = true;
    _resumeAt = DateTime.now().add(_resumeDelay);
  }

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) {
      _lastElapsed = elapsed;
      return;
    }

    final position = _scrollController.position;
    if (!position.hasPixels || position.maxScrollExtent <= 0) {
      _lastElapsed = elapsed;
      return;
    }

    if (_userPaused) {
      final resumeAt = _resumeAt;
      if (resumeAt != null && DateTime.now().isAfter(resumeAt)) {
        _userPaused = false;
        _resumeAt = null;
      } else {
        _lastElapsed = elapsed;
        return;
      }
    }

    final last = _lastElapsed;
    _lastElapsed = elapsed;
    if (last == null) return;

    final dtSeconds =
        (elapsed - last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dtSeconds <= 0) return;

    final delta = _autoScrollPixelsPerSecond * dtSeconds * _direction;
    var next = position.pixels + delta;

    if (next >= position.maxScrollExtent) {
      next = position.maxScrollExtent;
      _direction = -1.0;
    } else if (next <= position.minScrollExtent) {
      next = position.minScrollExtent;
      _direction = 1.0;
    }

    if ((next - position.pixels).abs() > 0.01) {
      _scrollController.jumpTo(next);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _pauseFromUser();
    } else if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      _pauseFromUser();
    } else if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      _pauseFromUser();
    } else if (notification is ScrollEndNotification) {
      _resumeAt = DateTime.now().add(_resumeDelay);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    const fadeWidth = 34.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF111827) : Colors.white;

        return NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: ClipRect(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: widget.child,
                ),
                if (_showLeadingFade)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: fadeWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [bgColor, bgColor.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                  ),
                if (_showTrailingFade)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: fadeWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [bgColor, bgColor.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
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
  static const double _hostHorizontalInset = 16.0;
  static const double _hostVerticalInset = 16.0;

  @override
  Widget build(BuildContext context) {
    final zoom = ref.watch(zoomProvider);
    final materias = ref.watch(filteredMateriasProvider);

    final ordered = ordenarMateriasParaGrilla(materias);
    final byYear = agruparPorAnio(ordered);
    final years = aniosPresentes(byYear);

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

    final EdgeInsets hostPadding = widget.borderless
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(vertical: _hostVerticalInset);

    return Container(
      decoration: hostDeco,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
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
                  final bool isDesktop =
                      MediaQuery.of(context).size.width >= 900;

                  final double cardW = widget.borderless
                      ? maxW * 0.4
                      : (isDesktop ? double.infinity : maxW * 0.7);

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
                          horizontalInset:
                              widget.borderless ? 0 : _hostHorizontalInset,
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
    required double horizontalInset,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    int? lastCuatri;

    final List<Widget> rowChildren = [
      const SizedBox(width: 4),
    ];

    for (int i = 0; i < yearMaterias.length; i++) {
      final m = yearMaterias[i];

      if (m.cuatri != lastCuatri) {
        rowChildren.add(
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 8),
            child: Text(
              etiquetaCuatri(m.cuatri),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    isDark ? Colors.white70 : _TokensGrilla.textSecondaryLight,
              ),
            ),
          ).animate().fadeIn(delay: (i * 12).ms, duration: 180.ms).slideY(
              begin: 0.06, end: 0, delay: (i * 12).ms, duration: 220.ms),
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
        ).animate().fadeIn(delay: (i * 18).ms, duration: 220.ms).slideY(
              begin: 0.06,
              end: 0,
              delay: (i * 18).ms,
              duration: 260.ms,
              curve: Curves.easeOutCubic,
            ),
      );

      // Aumento de espacio: 16px horizontal en móvil, 20px vertical en escritorio
      rowChildren.add(SizedBox(
        width: isDesktop ? 0 : 16,
        height: isDesktop ? 20 : 0,
      ));
    }

    rowChildren.add(const SizedBox(width: 4));

    final block = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showYearHeaders)
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalInset + 4,
              8,
              horizontalInset + 4,
              8,
            ),
            child: Row(
              children: [
                Text(
                  '$year° Año',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? Colors.white : _TokensGrilla.textPrimaryLight,
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
        isDesktop
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rowChildren,
                ),
              )
            : _AutoScrollingHorizontalStrip(
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
