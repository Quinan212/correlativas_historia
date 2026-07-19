import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modelos/evento_examen.dart';
import '../../../../modelos/materia.dart';
import '../../pantalla/logica_examenes.dart';
import '../../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../../compartido/supabase/supabase.dart';
import '../../proveedores/repositorio_analiticas_navegacion_examenes.dart';
import 'componentes_hoja_examenes.dart';

class PaginaHojaExamenes extends ConsumerStatefulWidget {
  const PaginaHojaExamenes({
    super.key,
    required this.careerId,
    required this.materia,
    required this.llamado1Eventos,
    required this.llamado2Eventos,
    required this.coloquioEventos,
    required this.detalleInicial,
    required this.mapaPlan,
  });

  final String careerId;
  final String materia;
  final List<EventoExamen> llamado1Eventos;
  final List<EventoExamen> llamado2Eventos;
  final List<EventoExamen> coloquioEventos;
  final DetalleArgs? detalleInicial;
  final Map<String, Materia> mapaPlan;

  @override
  ConsumerState<PaginaHojaExamenes> createState() => _PaginaHojaExamenesState();
}

class _PaginaHojaExamenesState extends ConsumerState<PaginaHojaExamenes>
    with TickerProviderStateMixin {
  static const _sheetRadius = BorderRadius.all(Radius.circular(22));

  double _dragDy = 0.0;
  AnimationController? _settleCtrl;
  late String _activeTabId;
  String? _activeDivisionId;
  final RepositorioAnaliticasNavegacionExamenes _analytics =
      const RepositorioAnaliticasNavegacionExamenes();

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
    required DatosTabInstancia tab,
    required DatosOpcionDivision? option,
  }) async {
    final client = ref.read(proveedorClienteSupabase);
    final deviceId = await ref.read(proveedorIdDispositivo.future);
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
    required DatosTabInstancia sourceTab,
    required DatosOpcionDivision? sourceOption,
    required DatosTabInstancia targetTab,
    required DatosOpcionDivision? targetOption,
  }) async {
    final client = ref.read(proveedorClienteSupabase);
    final deviceId = await ref.read(proveedorIdDispositivo.future);
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

  DatosOpcionDivision? _optionFor(DatosTabInstancia tab, String? optionId) {
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

  Widget _buildDesktopPanel(
    BuildContext context, {
    required Animation<double> curved,
    required ThemeData theme,
    required ColorScheme cs,
    required bool isDark,
    required double panelWidth,
    required double panelHeight,
    required List<DatosTabInstancia> tabs,
    required String activeId,
    required DatosTabInstancia activeTab,
    required String? activeDivisionId,
    required DatosOpcionDivision? activeDivision,
  }) {
    final panelBg = isDark ? cs.surface : const Color(0xFFF5F7FA);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black.withValues(alpha: 0.48 * curved.value),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Opacity(
              opacity: curved.value,
              child: Transform.translate(
                offset: Offset((1.0 - curved.value) * 42, 0),
                child: SizedBox(
                  width: panelWidth,
                  height: panelHeight,
                  child: Material(
                    color: panelBg,
                    elevation: 10,
                    shadowColor: Colors.black.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        bottomLeft: Radius.circular(28),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? cs.outlineVariant
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          decoration: BoxDecoration(
                            color: isDark ? cs.surface : Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? cs.outlineVariant
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.materia,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton.filledTonal(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              20,
                            ),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOutCubic,
                              alignment: Alignment.topCenter,
                              child: _contentReady
                                  ? PanelExamenMateria(
                                      careerId: widget.careerId,
                                      materia: widget.materia,
                                      tabs: tabs,
                                      activeTabId: activeId,
                                      activeDivisionId: activeDivisionId,
                                      mapaPlan: widget.mapaPlan,
                                      onTabChanged: (id) {
                                        if (id == _activeTabId) return;
                                        final sourceTab = activeTab;
                                        final sourceOption = _optionFor(
                                          activeTab,
                                          activeDivisionId,
                                        );
                                        final targetTab = tabs.firstWhere(
                                          (t) => t.id == id,
                                          orElse: () => tabs.first,
                                        );
                                        final targetOption = _optionFor(
                                          targetTab,
                                          null,
                                        );
                                        setState(() {
                                          _activeTabId = id;
                                          _activeDivisionId = targetOption?.id;
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
                                        final sourceOption = _optionFor(
                                          activeTab,
                                          activeDivisionId,
                                        );
                                        final targetOption = _optionFor(
                                          activeTab,
                                          id,
                                        );
                                        setState(() => _activeDivisionId = id);
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
                                          vertical: 48,
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.materia,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurfaceVariant,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
    final screenSize = MediaQuery.sizeOf(context);
    final isDesktop = screenSize.width >= 1000;

    final maxH = MediaQuery.sizeOf(context).height * 0.90;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    const lift = 1.0;
    final sheetMaxWidth =
        isDesktop ? math.min(screenSize.width - 56.0, 1320.0) : double.infinity;
    final sheetMaxHeight = isDesktop ? screenSize.height * 0.88 : maxH;

    final panelBg = isDark ? cs.surface : const Color(0xFFF5F7FA);
    final tabs = <DatosTabInstancia>[
      if (widget.llamado1Eventos.isNotEmpty)
        DatosTabInstancia.fromEventos(
          id: 'llamado_1',
          label: 'Llamado 1',
          materia: widget.materia,
          eventos: widget.llamado1Eventos,
        ),
      if (widget.llamado2Eventos.isNotEmpty)
        DatosTabInstancia.fromEventos(
          id: 'llamado_2',
          label: 'Llamado 2',
          materia: widget.materia,
          eventos: widget.llamado2Eventos,
        ),
      if (widget.coloquioEventos.isNotEmpty)
        DatosTabInstancia.fromEventos(
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
          if (isDesktop) {
            final panelWidth =
                math.min(screenSize.width * 0.58, 980.0).clamp(760.0, 980.0);
            final panelHeight = screenSize.height * 0.92;
            return _buildDesktopPanel(
              context,
              curved: curved,
              theme: theme,
              cs: cs,
              isDark: isDark,
              panelWidth: panelWidth,
              panelHeight: panelHeight,
              tabs: tabs,
              activeId: activeId,
              activeTab: activeTab,
              activeDivisionId: activeDivisionId,
              activeDivision: activeDivision,
            );
          }

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
                          alpha: (isDesktop ? 0.48 : 0.65) * t * focus,
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
                alignment:
                    isDesktop ? Alignment.center : Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, sheetOffset),
                  child: Opacity(
                    opacity: t,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 28 : 12,
                        isDesktop ? 24 : 12,
                        isDesktop ? 28 : 12,
                        isDesktop ? 24 : 12 + bottomInset + lift,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: sheetMaxWidth,
                          maxHeight: sheetMaxHeight,
                        ),
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
                                            duration: const Duration(
                                                milliseconds: 250),
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
                                                    mapaPlan: widget.mapaPlan,
                                                    onTabChanged: (id) {
                                                      if (id == _activeTabId) {
                                                        return;
                                                      }
                                                      final sourceTab =
                                                          activeTab;
                                                      final sourceOption =
                                                          _optionFor(activeTab,
                                                              activeDivisionId);
                                                      final targetTab =
                                                          tabs.firstWhere(
                                                        (t) => t.id == id,
                                                        orElse: () =>
                                                            tabs.first,
                                                      );
                                                      final targetOption =
                                                          _optionFor(
                                                              targetTab, null);
                                                      setState(() {
                                                        _activeTabId = id;
                                                        _activeDivisionId =
                                                            targetOption?.id;
                                                      });
                                                      unawaited(
                                                        _trackTransition(
                                                          sourceTab: sourceTab,
                                                          sourceOption:
                                                              sourceOption,
                                                          targetTab: targetTab,
                                                          targetOption:
                                                              targetOption,
                                                        ),
                                                      );
                                                    },
                                                    onDivisionChanged: (id) {
                                                      if (id ==
                                                          _activeDivisionId) {
                                                        return;
                                                      }
                                                      final sourceOption =
                                                          _optionFor(activeTab,
                                                              activeDivisionId);
                                                      final targetOption =
                                                          _optionFor(
                                                              activeTab, id);
                                                      setState(() =>
                                                          _activeDivisionId =
                                                              id);
                                                      unawaited(
                                                        _trackTransition(
                                                          sourceTab: activeTab,
                                                          sourceOption:
                                                              sourceOption,
                                                          targetTab: activeTab,
                                                          targetOption:
                                                              targetOption,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      minHeight:
                                                          _estimateHeight(),
                                                      minWidth: double.infinity,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 48),
                                                      child: Center(
                                                        child: Text(
                                                          widget.materia,
                                                          style: theme.textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: cs
                                                                .onSurfaceVariant,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
