import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/examen_event.dart';
import '../../pantalla/logica_examenes.dart';
import '../../../../shared/device_identity/device_identity.dart';
import '../../../../shared/supabase/supabase.dart';
import '../../providers/exam_navigation_analytics_repository.dart';
import 'widgets_sheet_examenes.dart';

class PaginaSheetExamenes extends ConsumerStatefulWidget {
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
  ConsumerState<PaginaSheetExamenes> createState() =>
      _PaginaSheetExamenesState();
}

class _PaginaSheetExamenesState extends ConsumerState<PaginaSheetExamenes>
    with TickerProviderStateMixin {
  static const _sheetRadius = BorderRadius.all(Radius.circular(22));

  double _dragDy = 0.0;
  AnimationController? _settleCtrl;
  late String _activeTabId;
  String? _activeDivisionId;
  final ExamNavigationAnalyticsRepository _analytics =
      const ExamNavigationAnalyticsRepository();

  // Carga diferida: el contenido pesado se monta DESPUÉS de la animación de entrada
  bool _contentReady = false;
  bool _initialViewTracked = false;
  Timer? _contentTimer;

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
    // Diferir el contenido pesado hasta que termine la animación de entrada
    _contentTimer = Timer(const Duration(milliseconds: 330), () {
      if (mounted) setState(() => _contentReady = true);
    });
  }

  @override
  void dispose() {
    _contentTimer?.cancel();
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

  Future<void> _trackInitialView({
    required InstanciaTabData tab,
    required DivisionOptionData? option,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final deviceId = await ref.read(deviceIdProvider.future);
    await _analytics.trackView(
      client: client,
      deviceId: deviceId,
      careerId: widget.careerId,
      matterName: widget.materia,
      tabId: tab.id,
      tabLabel: tab.label,
      divisionId: option?.id,
      divisionLabel: option?.label,
    );
  }

  Future<void> _trackTransition({
    required InstanciaTabData sourceTab,
    required DivisionOptionData? sourceOption,
    required InstanciaTabData targetTab,
    required DivisionOptionData? targetOption,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final deviceId = await ref.read(deviceIdProvider.future);
    await _analytics.trackTransition(
      client: client,
      deviceId: deviceId,
      sourceCareerId: widget.careerId,
      sourceMatterName: widget.materia,
      sourceTabId: sourceTab.id,
      sourceTabLabel: sourceTab.label,
      sourceDivisionId: sourceOption?.id,
      sourceDivisionLabel: sourceOption?.label,
      targetCareerId: widget.careerId,
      targetMatterName: widget.materia,
      targetTabId: targetTab.id,
      targetTabLabel: targetTab.label,
      targetDivisionId: targetOption?.id,
      targetDivisionLabel: targetOption?.label,
    );
  }

  DivisionOptionData? _optionFor(InstanciaTabData tab, String? optionId) {
    if (tab.options.isEmpty) return null;
    if (optionId == null) return tab.options.first;
    for (final option in tab.options) {
      if (option.id == optionId) return option;
    }
    return tab.options.first;
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

  double _estimateHeight() {
    // Estimación rápida para evitar saltos bruscos
    int items = 0;
    if (_activeTabId == 'llamado_1') {
      items = widget.llamado1Eventos.length;
    } else if (_activeTabId == 'llamado_2') {
      items = widget.llamado2Eventos.length;
    } else {
      items = widget.coloquioEventos.length;
    }

    // Cabezal/Tabs ~150px + ~95px por cada fecha de examen
    final h = 150.0 + (items * 95.0);
    return h.clamp(200.0, 520.0);
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
          label: 'Mesas extraordinarias',
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
    final activeDivision = _optionFor(activeTab, activeDivisionId);

    if (_contentReady && !_initialViewTracked) {
      _initialViewTracked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          _trackInitialView(
            tab: activeTab,
            option: activeDivisionId == null ? null : activeDivision,
          ),
        );
      });
    }

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value;

          final dragT = (_dragDy / 260.0).clamp(0.0, 1.0);
          final focus = (1.0 - dragT);

          final sheetOffset = (1.0 - t) * 26.0 + _dragDy;

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black.withValues(
                          alpha: (0.65 * t * focus).clamp(0.0, 1.0),
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
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RepaintBoundary(
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
                                          AnimatedSize(
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeInOutCubic,
                                            alignment: Alignment.topCenter,
                                            child: _contentReady
                                                ? PanelExamenMateria(
                                                    careerId: widget.careerId,
                                                    materia: widget.materia,
                                                    tabs: tabs,
                                                    activeTabId: activeId,
                                                    activeDivisionId:
                                                        activeDivisionId,
                                                    onTabChanged: (id) {
                                                      if (id == _activeTabId) return;
                                                      final sourceTab = activeTab;
                                                      final sourceOption =
                                                          _optionFor(activeTab, activeDivisionId);
                                                      final targetTab = tabs.firstWhere(
                                                        (t) => t.id == id,
                                                        orElse: () => tabs.first,
                                                      );
                                                      final targetOption =
                                                          _optionFor(targetTab, null);
                                                      setState(() {
                                                        _activeTabId = id;
                                                        _activeDivisionId =
                                                            targetOption?.id;
                                                      });
                                                      unawaited(
                                                        _trackTransition(
                                                          sourceTab: sourceTab,
                                                          sourceOption: sourceOption,
                                                          targetTab: targetTab,
                                                          targetOption: targetOption,
                                                        ),
                                                      );
                                                    },
                                                    onDivisionChanged: (id) {
                                                      if (id == _activeDivisionId) {
                                                        return;
                                                      }
                                                      final sourceOption =
                                                          _optionFor(activeTab, activeDivisionId);
                                                      final targetOption =
                                                          _optionFor(activeTab, id);
                                                      setState(() =>
                                                          _activeDivisionId = id);
                                                      unawaited(
                                                        _trackTransition(
                                                          sourceTab: activeTab,
                                                          sourceOption: sourceOption,
                                                          targetTab: activeTab,
                                                          targetOption: targetOption,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      minHeight: _estimateHeight(),
                                                      minWidth: double.infinity,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          vertical: 48),
                                                      child: Center(
                                                        child: Text(
                                                          widget.materia,
                                                          style: theme
                                                              .textTheme.titleMedium
                                                              ?.copyWith(
                                                            fontWeight: FontWeight.w700,
                                                            color:
                                                                cs.onSurfaceVariant,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow.ellipsis,
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
              ),
            ],
          );
        },
      ),
    );
  }
}
