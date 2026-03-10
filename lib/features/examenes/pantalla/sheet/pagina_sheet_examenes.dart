import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/examen_event.dart';
import '../../pantalla/logica_examenes.dart';
import 'widgets_sheet_examenes.dart';

class PaginaSheetExamenes extends StatefulWidget {
  const PaginaSheetExamenes({
    super.key,
    required this.careerId,
    required this.materia,
    required this.llamado1Eventos,
    required this.llamado2Eventos,
    required this.coloquioEventos,
    required this.detalleInicial,
  });

  final String careerId;
  final String materia;
  final List<ExamenEvent> llamado1Eventos;
  final List<ExamenEvent> llamado2Eventos;
  final List<ExamenEvent> coloquioEventos;
  final DetalleArgs? detalleInicial;

  @override
  State<PaginaSheetExamenes> createState() => _PaginaSheetExamenesState();
}

class _PaginaSheetExamenesState extends State<PaginaSheetExamenes>
    with TickerProviderStateMixin {
  static const _sheetRadius = BorderRadius.all(Radius.circular(22));
  static final bool _disableBackdropBlur =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  double _dragDy = 0.0;
  AnimationController? _settleCtrl;
  late String _activeTabId;
  String? _activeDivisionId;

  @override
  void initState() {
    super.initState();
    _activeTabId = 'llamado_1';
    if (widget.detalleInicial?.tabId != null) {
      _activeTabId = widget.detalleInicial!.tabId;
    } else if (widget.llamado1Eventos.isEmpty &&
        widget.llamado2Eventos.isNotEmpty) {
      _activeTabId = 'llamado_2';
    } else if (widget.llamado1Eventos.isEmpty &&
        widget.llamado2Eventos.isEmpty &&
        widget.coloquioEventos.isNotEmpty) {
      _activeTabId = 'coloquio';
    }
  }

  @override
  void dispose() {
    _settleCtrl?.dispose();
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

    final maxH = MediaQuery.sizeOf(context).height * 0.90;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    const lift = 1.0;

    final panelBg = isDark ? cs.surface : const Color(0xFFF5F7FA);
    final tabs = <InstanciaTabData>[
      if (widget.llamado1Eventos.isNotEmpty)
        InstanciaTabData.fromEventos(
          id: 'llamado_1',
          label: 'Primer llamado',
          materia: widget.materia,
          eventos: widget.llamado1Eventos,
        ),
      if (widget.llamado2Eventos.isNotEmpty)
        InstanciaTabData.fromEventos(
          id: 'llamado_2',
          label: 'Segundo llamado',
          materia: widget.materia,
          eventos: widget.llamado2Eventos,
        ),
      if (widget.coloquioEventos.isNotEmpty)
        InstanciaTabData.fromEventos(
          id: 'coloquio',
          label: 'Coloquio',
          materia: widget.materia,
          eventos: widget.coloquioEventos,
        ),
    ];

    final activeId =
        tabs.any((t) => t.id == _activeTabId) ? _activeTabId : tabs.first.id;
    final activeTab =
        tabs.firstWhere((t) => t.id == activeId, orElse: () => tabs.first);
    final activeDivisionId =
        activeTab.options.any((o) => o.id == _activeDivisionId)
            ? _activeDivisionId
            : (activeTab.options.isEmpty ? null : activeTab.options.first.id);

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
                      if (_disableBackdropBlur)
                        Container(
                          color: Colors.black.withValues(alpha: tintA),
                        )
                      else
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
                                  Colors.black
                                      .withValues(alpha: 0.10 * t * focus),
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
                          12, 12, 12, 12 + bottomInset + lift),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxH),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: _cuandoArrastras,
                          onVerticalDragEnd: _cuandoSoltas,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: RepaintBoundary(
                                  child: Material(
                                    color: panelBg,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: _sheetRadius,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 10, 12, 14),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          BarritaYBotonX(
                                            onTapX: () =>
                                                Navigator.of(context).pop(),
                                            colorX:
                                                cs.onSurfaceVariant.withValues(
                                              alpha: isDark ? 0.90 : 0.70,
                                            ),
                                            colorBarrita: cs.onSurfaceVariant
                                                .withValues(alpha: 0.35),
                                          ),
                                          const SizedBox(height: 12),
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: SingleChildScrollView(
                                              child: PanelExamenMateria(
                                                careerId: widget.careerId,
                                                materia: widget.materia,
                                                tabs: tabs,
                                                activeTabId: activeId,
                                                activeDivisionId:
                                                    activeDivisionId,
                                                onTabChanged: (id) =>
                                                    setState(() {
                                                  _activeTabId = id;
                                                  final tab = tabs.firstWhere(
                                                    (t) => t.id == id,
                                                    orElse: () => tabs.first,
                                                  );
                                                  _activeDivisionId = tab
                                                          .options.isEmpty
                                                      ? null
                                                      : tab.options.first.id;
                                                }),
                                                onDivisionChanged: (id) =>
                                                    setState(() =>
                                                        _activeDivisionId = id),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TarjetaCerrar(
                                  onTap: () => Navigator.of(context).pop()),
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
