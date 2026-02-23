import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../models/examen_event.dart';
import '../../pantalla/logica_examenes.dart';
import 'widgets_sheet_examenes.dart';

class PaginaSheetExamenes extends StatefulWidget {
  const PaginaSheetExamenes({
    super.key,
    required this.materia,
    required this.llamado1,
    required this.llamado2,
    required this.detalleInicial,
  });

  final String materia;
  final ExamenEvent? llamado1;
  final ExamenEvent? llamado2;
  final DetalleArgs? detalleInicial;

  @override
  State<PaginaSheetExamenes> createState() => _PaginaSheetExamenesState();
}

class _PaginaSheetExamenesState extends State<PaginaSheetExamenes>
    with TickerProviderStateMixin {
  double _dragDy = 0.0;
  AnimationController? _settleCtrl;

  DetalleArgs? _detalle;

  late final AnimationController _swapCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  );

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _swapCtrl,
    curve: Curves.easeOutCubic,
  );

  late final Animation<double> _fadeOut = CurvedAnimation(
    parent: ReverseAnimation(_swapCtrl),
    curve: Curves.easeInCubic,
  );

  late final Animation<double> _scaleIn =
  Tween<double>(begin: 0.94, end: 1.0).animate(
    CurvedAnimation(parent: _swapCtrl, curve: Curves.easeOutCubic),
  );

  bool _mostrarCapaMateria = true;
  bool _mostrarCapaDetalle = false;

  @override
  void initState() {
    super.initState();
    _detalle = widget.detalleInicial;

    if (_detalle != null) {
      _mostrarCapaMateria = false;
      _mostrarCapaDetalle = true;
      _swapCtrl.value = 1.0;
    }

    _swapCtrl.addStatusListener((s) {
      if (!mounted) return;
      if (s == AnimationStatus.completed) {
        setState(() {
          if (_detalle == null) {
            _mostrarCapaDetalle = false;
            _mostrarCapaMateria = true;
          } else {
            _mostrarCapaMateria = false;
            _mostrarCapaDetalle = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _settleCtrl?.dispose();
    _swapCtrl.dispose();
    super.dispose();
  }

  void _animarVueltaDelDrag() {
    _settleCtrl?.dispose();
    _settleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
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

  void _cuandoArrastras(DragUpdateDetails d) {
    final dy = d.delta.dy;
    if (dy <= 0 && _dragDy <= 0) return;

    setState(() {
      _dragDy = math.max(0.0, _dragDy + dy);
      _dragDy = math.min(_dragDy, 520.0);
    });
  }

  void _cuandoSoltas(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (_dragDy > 160 || v > 1500) {
      Navigator.of(context).pop();
      return;
    }
    _animarVueltaDelDrag();
  }

  void _abrirDetalle(String titulo, ExamenEvent? e) {
    setState(() {
      _detalle = DetalleArgs(titulo: titulo, evento: e);
      _mostrarCapaDetalle = true;
      _mostrarCapaMateria = true;
    });
    _swapCtrl.forward(from: 0);
  }

  void _volverAMateria() {
    setState(() {
      _detalle = null;
      _mostrarCapaMateria = true;
      _mostrarCapaDetalle = true;
    });
    _swapCtrl.forward(from: 0);
  }

  void _tocarX() {
    if (_detalle != null && widget.detalleInicial == null) {
      _volverAMateria();
      return;
    }
    Navigator.of(context).pop();
  }

  void _tocarCerrar() {
    if (_detalle != null && widget.detalleInicial == null) {
      _volverAMateria();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final routeAnim = ModalRoute.of(context)!.animation!;
    final curved = CurvedAnimation(
      parent: routeAnim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    final panelBg = isDark ? cs.surface : const Color(0xFFF5F7FA);

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value;

          final dragT = (_dragDy / 300.0).clamp(0.0, 1.0);
          final focus = (1.0 - dragT);

          final blurSigma = 18.0 * t * focus;
          final dimA = 0.22 * t * focus;
          final tintA = 0.08 * t * focus;
          final vignetteA = 0.10 * t * focus;

          final sheetOffset = (1.0 - t) * 44.0 + _dragDy;

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Stack(
                    children: [
                      Container(color: Colors.black.withValues(alpha: dimA)),
                      ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: blurSigma,
                            sigmaY: blurSigma,
                          ),
                          child: Container(
                            color: Colors.black.withValues(alpha: tintA),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.00),
                                Colors.black.withValues(alpha: 0.06 * t * focus),
                                Colors.black.withValues(alpha: 0.12 * t * focus),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.0, -0.35),
                              radius: 1.05,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: vignetteA),
                              ],
                              stops: const [0.55, 1.0],
                            ),
                          ),
                          child: const SizedBox.expand(),
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
                      padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + bottomInset),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxH),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: _cuandoArrastras,
                          onVerticalDragEnd: _cuandoSoltas,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Material(
                                  color: panelBg,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        BarritaYBotonX(
                                          onTapX: _tocarX,
                                          colorX: cs.onSurfaceVariant.withValues(
                                            alpha: isDark ? 0.90 : 0.70,
                                          ),
                                          colorBarrita: cs.onSurfaceVariant.withValues(alpha: 0.35),
                                        ),
                                        const SizedBox(height: 12),
                                        ClipRect(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(child: ColoredBox(color: panelBg)),
                                              if (_mostrarCapaMateria)
                                                IgnorePointer(
                                                  ignoring: _detalle != null,
                                                  child: FadeTransition(
                                                    opacity: _detalle == null
                                                        ? kAlwaysCompleteAnimation
                                                        : _fadeOut,
                                                    child: RepaintBoundary(
                                                      child: CajaMateria(
                                                        materia: widget.materia,
                                                        llamado1: widget.llamado1,
                                                        llamado2: widget.llamado2,
                                                        onTapDetalle: _abrirDetalle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (_mostrarCapaDetalle)
                                                IgnorePointer(
                                                  ignoring: _detalle == null,
                                                  child: FadeTransition(
                                                    opacity: _detalle != null
                                                        ? _fadeIn
                                                        : kAlwaysDismissedAnimation,
                                                    child: ScaleTransition(
                                                      scale: _scaleIn,
                                                      child: RepaintBoundary(
                                                        child: CajaDetalle(
                                                          titulo: _detalle?.titulo ?? '',
                                                          materia: widget.materia,
                                                          evento: _detalle?.evento,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TarjetaCerrar(onTap: _tocarCerrar),
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