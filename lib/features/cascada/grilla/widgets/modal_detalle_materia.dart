import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../../detail_panel.dart';

Future<void> mostrarModalDetalleMateria({
  required BuildContext context,
  required WidgetRef ref,
  required String heroId,
}) async {
  await Navigator.of(context).push(_DetalleMateriaRoute(heroId: heroId));
  ref.read(selectedMateriaIdProvider.notifier).state = null;
}

class _DetalleMateriaRoute extends PageRoute<void> {
  _DetalleMateriaRoute({required this.heroId});

  final String heroId;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => 'Detalle';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return _DetalleMateriaPage(key: ValueKey('det_$heroId'));
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child;
  }
}

class _DetalleMateriaPage extends ConsumerStatefulWidget {
  const _DetalleMateriaPage({super.key});

  @override
  ConsumerState<_DetalleMateriaPage> createState() => _DetalleMateriaPageState();
}

class _DetalleMateriaPageState extends ConsumerState<_DetalleMateriaPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();

  double _dragDy = 0.0;
  AnimationController? _settleCtrl;

  @override
  void dispose() {
    _settleCtrl?.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _animateDragBack() {
    _settleCtrl?.dispose();
    _settleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    final start = _dragDy;
    final anim = Tween<double>(begin: start, end: 0).animate(
      CurvedAnimation(parent: _settleCtrl!, curve: Curves.easeOutCubic),
    );

    _settleCtrl!.addListener(() {
      setState(() => _dragDy = anim.value);
    });

    _settleCtrl!.forward();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_scrollCtrl.hasClients && _scrollCtrl.offset > 0) return;

    final dy = d.delta.dy;
    if (dy <= 0 && _dragDy <= 0) return;

    setState(() {
      _dragDy = math.max(0.0, _dragDy + dy);
      _dragDy = math.min(_dragDy, 420.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (_dragDy > 140 || v > 1400) {
      Navigator.of(context).pop();
      return;
    }
    _animateDragBack();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedMateriaIdProvider, (prev, next) {
      if (prev == next) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
    });

    final routeAnim = ModalRoute.of(context)!.animation!;
    final curved = CurvedAnimation(
      parent: routeAnim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // un toque más alto, más "flotante"
    final maxH = MediaQuery.sizeOf(context).height * 0.90;
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
    const lift = 1.0;

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value;

          final dragT = (_dragDy / 260.0).clamp(0.0, 1.0);
          final focus = (1.0 - dragT);

          final blurSigma = 14.0 * t * focus;
          final dimA = 0.28 * t * focus;
          final tintA = 0.10 * t * focus;

          // entra desde un poco menos abajo
          final sheetOffset = (1.0 - t) * 26.0 + _dragDy;

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Stack(
                    children: [
                      Container(color: Colors.black.withValues(alpha: dimA)),
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: blurSigma,
                          sigmaY: blurSigma,
                        ),
                        child: Container(
                          color: Colors.black.withValues(alpha: tintA),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: IgnorePointer(
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(
                                    alpha: 0.10 * t * focus,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, sheetOffset),
                  child: Opacity(
                    opacity: t,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        12 + bottomSafe + lift,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxH),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: _onDragUpdate,
                          onVerticalDragEnd: _onDragEnd,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Material(
                                    color: isDark
                                        ? const Color(0xFF1F2937)
                                        : Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 6),
                                        const _PremiumGrabHandle(),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: SingleChildScrollView(
                                            controller: _scrollCtrl,
                                            padding: EdgeInsets.zero,
                                            child: const RepaintBoundary(
                                              child: DetailPanel(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Material(
                                  color: isDark
                                      ? const Color(0xFF111827)
                                      : Colors.white,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      height: 54,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Cerrar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFFE5E7EB)
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PremiumGrabHandle extends StatelessWidget {
  const _PremiumGrabHandle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final base = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.12);

    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 10),
      child: Center(
        child: SizedBox(
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 7,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(
                      alpha: isDark ? 0.35 : 0.55,
                    ),
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? const []
                      : [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 6,
                child: Container(
                  width: 52,
                  height: 2,
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}