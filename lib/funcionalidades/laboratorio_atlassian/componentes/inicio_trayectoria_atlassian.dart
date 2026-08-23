import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../compartido/media/widgets_media_remota.dart';
import 'componentes_atlassian.dart';

class EncabezadoTrayectoriaAtlassian extends StatefulWidget {
  const EncabezadoTrayectoriaAtlassian({
    super.key,
    required this.scrollController,
    required this.onSearch,
    this.onExit,
    this.nombreEstudiante,
  });

  final ScrollController scrollController;
  final VoidCallback onSearch;
  final VoidCallback? onExit;
  final String? nombreEstudiante;

  @override
  State<EncabezadoTrayectoriaAtlassian> createState() =>
      _EncabezadoTrayectoriaAtlassianState();
}

class _EncabezadoTrayectoriaAtlassianState
    extends State<EncabezadoTrayectoriaAtlassian> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant EncabezadoTrayectoriaAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) return;
    oldWidget.scrollController.removeListener(_handleScroll);
    widget.scrollController.addListener(_handleScroll);
    _handleScroll();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;
    final offset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;
    final next = (offset / 72).clamp(0.0, 1.0).toDouble();
    if ((next - _progress).abs() < 0.01) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (_progress - next).abs() >= 0.01) {
        setState(() => _progress = next);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = Curves.easeOutCubic.transform(_progress);
    final actionsOpacity = (1 - progress * 1.2).clamp(0.0, 1.0).toDouble();
    final titleOpacity = (1 - progress * 1.35).clamp(0.0, 1.0).toDouble();
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: titleOpacity,
                  child: Transform.translate(
                    offset: Offset(-18 * progress, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Título absolutamente centrado
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                saludoAtlassian(widget.nombreEstudiante),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Trayectoria',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        // Acciones y mascota ancladas a la derecha
                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _MascotaBienvenidaAtlassian(),
                              if (widget.onExit != null) ...[
                                const SizedBox(width: 8),
                                IgnorePointer(
                                  ignoring: actionsOpacity < 0.4,
                                  child: Opacity(
                                    opacity: actionsOpacity,
                                    child: BotonIconoAtlassian(
                                      icon: Icons.close_rounded,
                                      tooltip: 'Cerrar laboratorio',
                                      onPressed: widget.onExit!,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _MascotaBienvenidaAtlassian extends StatefulWidget {
  const _MascotaBienvenidaAtlassian();

  @override
  State<_MascotaBienvenidaAtlassian> createState() =>
      _MascotaBienvenidaAtlassianState();
}

class _MascotaBienvenidaAtlassianState
    extends State<_MascotaBienvenidaAtlassian>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reducirMovimiento = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: 'Bienvenida',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final onda = reducirMovimiento
              ? 0.0
              : math.sin(_controller.value * math.pi * 2);
          return Transform.translate(
            offset: Offset(0, -1.8 * onda),
            child: Transform.rotate(
              angle: reducirMovimiento ? 0 : 0.045 * onda,
              child: child,
            ),
          );
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
          ),
          child: Icon(
            Icons.sentiment_very_satisfied_rounded,
            size: 24,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

enum AccionSugerenciaAtlassian { examenes, escenarios, materias, calendario }

class SugerenciasApiladasAtlassianDelegate
    extends SliverPersistentHeaderDelegate {
  static const List<_SugerenciaApiladaData> _items = <_SugerenciaApiladaData>[
    _SugerenciaApiladaData(
      assetPath: 'assets/banners/historia/recorrido/01.jpg',
      eyebrow: 'Mesas de julio',
      title: 'Prepará tus finales y revisá las fechas de cada mesa',
      cta: 'Ver mesas',
      alignment: Alignment.center,
      action: AccionSugerenciaAtlassian.examenes,
    ),
    _SugerenciaApiladaData(
      assetPath: 'assets/banners/historia/recorrido/02.jpg',
      eyebrow: 'Después de rendir',
      title: 'Comprobá qué materias se habilitan para tu próximo año',
      cta: 'Consultar correlativas',
      alignment: Alignment.center,
      action: AccionSugerenciaAtlassian.escenarios,
    ),
    _SugerenciaApiladaData(
      assetPath: 'assets/banners/historia/recorrido/03.jpg',
      eyebrow: 'Actualizá tu trayectoria',
      title: 'Cargá tus materias aprobadas y tus notas finales',
      cta: 'Actualizar registro',
      alignment: Alignment.center,
      action: AccionSugerenciaAtlassian.materias,
    ),
    _SugerenciaApiladaData(
      assetPath: 'assets/banners/historia/recorrido/04.jpg',
      eyebrow: 'Próximas fechas',
      title: 'Consultá fechas, eventos y próximos vencimientos',
      cta: 'Ver calendario',
      alignment: Alignment.topCenter,
      action: AccionSugerenciaAtlassian.calendario,
    ),
  ];

  SugerenciasApiladasAtlassianDelegate({
    required this.viewportHeight,
    required this.onOpenExams,
    required this.onOpenScenarios,
    required this.onOpenSubjects,
    required this.onOpenCalendar,
  });

  final double viewportHeight;
  final VoidCallback onOpenExams;
  final VoidCallback onOpenScenarios;
  final VoidCallback onOpenSubjects;
  final VoidCallback onOpenCalendar;

  static const double _cardHeight = 340.0;
  static const double _cardGap = 28.0;
  static const double _stackedSpread = 5.0;
  static const double _horizontalPadding = 16.0;
  static const double _mobileStackMaxWidth = 420.0;
  static const double _sectionTopPadding = 16.0;
  static const double _sectionHeaderHeight = 72.0;
  static const double _sectionHeaderGap = 24.0;
  static const double _bottomPadding = 16.0;

  // El botón flotante móvil vive en el shell Atlassian con SafeArea, top 16
  // y 45 px de alto. Al quedar fijada la sección, alineamos el centro del
  // título con ese botón sin alterar la separación natural entre secciones.
  static const double _mobileMenuTop = 16.0;
  static const double _mobileMenuSize = 45.0;
  static const double _pinTravel = 24.0;

  static const double _fullSpread = _cardHeight + _cardGap;

  double get _cardsStartTop =>
      _sectionTopPadding + _sectionHeaderHeight + _sectionHeaderGap;

  double get _headerTop => _sectionTopPadding;

  double get _stackScrollExtent =>
      (_items.length - 1) * (_fullSpread - _stackedSpread);

  double get _stackedHeight =>
      _cardsStartTop +
      _cardHeight +
      ((_items.length - 1) * _stackedSpread) +
      _bottomPadding;

  @override
  double get maxExtent => _stackedHeight + _pinTravel + _stackScrollExtent;

  @override
  double get minExtent => _stackedHeight;

  double _naturalTopFor(int index) => _cardsStartTop + (index * _fullSpread);

  double _stackedTopFor(int index) => _cardsStartTop + (index * _stackedSpread);

  double _topFor(int index, double scroll) {
    final double naturalTop = _naturalTopFor(index);
    final double stackedTop = _stackedTopFor(index);
    return math.max(stackedTop, naturalTop - scroll);
  }

  double _progressFor(int index, double scroll) {
    if (index >= _items.length - 1) return 0;
    final double top = _topFor(index, scroll);
    final double nextTop = _topFor(index + 1, scroll);
    final double distance = nextTop - top;
    final double progress = 1 - (distance / _cardHeight);
    return progress.clamp(0.0, 1.0);
  }

  double _depthFor(int index, double scroll) {
    if (index == _items.length - 1) return 0;
    final double naturalTop = _naturalTopFor(index);
    final double stackedTop = _stackedTopFor(index);
    final double travel = naturalTop - stackedTop;
    if (travel <= 0) return 0;
    final double currentTop = _topFor(index, scroll);
    return ((currentTop - stackedTop) / travel).clamp(0.0, 1.0);
  }

  double _mobileAlignmentOffset(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= 600) return 0;

    final double safeTop = MediaQuery.paddingOf(context).top;
    final double menuCenter = safeTop + _mobileMenuTop + (_mobileMenuSize / 2);
    final double headerCenterAtBase =
        _sectionTopPadding + (_sectionHeaderHeight / 2);
    return math.max(menuCenter - headerCenterAtBase, 0.0);
  }

  double _cardsPinnedAlignmentOffset(
    BuildContext context,
    double shrinkOffset,
  ) {
    final double targetOffset = _mobileAlignmentOffset(context);
    if (targetOffset == 0) return 0;

    final double collapseRange = math.max(maxExtent - minExtent, 1.0);
    final double collapseProgress = (shrinkOffset / collapseRange)
        .clamp(0.0, 1.0)
        .toDouble();

    return targetOffset * Curves.easeOutCubic.transform(collapseProgress);
  }

  VoidCallback _callbackFor(AccionSugerenciaAtlassian action) {
    switch (action) {
      case AccionSugerenciaAtlassian.examenes:
        return onOpenExams;
      case AccionSugerenciaAtlassian.escenarios:
        return onOpenScenarios;
      case AccionSugerenciaAtlassian.materias:
        return onOpenSubjects;
      case AccionSugerenciaAtlassian.calendario:
        return onOpenCalendar;
    }
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double scroll = math
        .max(shrinkOffset - _pinTravel, 0.0)
        .clamp(0.0, _stackScrollExtent);

    final ThemeData theme = Theme.of(context);
    final double cardsPinnedAlignmentOffset = _cardsPinnedAlignmentOffset(
      context,
      shrinkOffset,
    );
    final double fixedHeaderAlignmentOffset = _mobileAlignmentOffset(context);

    final Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(color: theme.scaffoldBackgroundColor),
        ),
        ...List<Widget>.generate(_items.length, (int index) {
          final _SugerenciaApiladaData item = _items[index];
          final double top =
              _topFor(index, scroll) + cardsPinnedAlignmentOffset;
          return Positioned(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: top,
            child: _TarjetaSugerenciaApiladaAtlassian(
              item: item,
              collisionProgress: _progressFor(index, scroll),
              depthProgress: _depthFor(index, scroll),
              cardHeight: _cardHeight,
              onTap: _callbackFor(item.action),
            ),
          );
        }),
        Positioned(
          left: _horizontalPadding,
          right: _horizontalPadding,
          top: _headerTop + fixedHeaderAlignmentOffset,
          child: const _InicioSugerenciasAtlassian(
            height: _sectionHeaderHeight,
          ),
        ),
      ],
    );

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double centeredWidth = screenWidth >= 600
        ? math.min(screenWidth, 1000.0)
        : math.min(screenWidth - 32.0, _mobileStackMaxWidth);

    return Center(
      child: SizedBox(width: math.max(centeredWidth, 0.0), child: content),
    );
  }

  @override
  bool shouldRebuild(
    covariant SugerenciasApiladasAtlassianDelegate oldDelegate,
  ) {
    return oldDelegate.viewportHeight != viewportHeight ||
        oldDelegate.onOpenExams != onOpenExams ||
        oldDelegate.onOpenScenarios != onOpenScenarios ||
        oldDelegate.onOpenSubjects != onOpenSubjects ||
        oldDelegate.onOpenCalendar != onOpenCalendar;
  }
}


/// Variante experimental para comparar, debajo del stack original, el
/// comportamiento de React Bits `Stack` adaptado a Flutter.
///
/// La sección original [SugerenciasApiladasAtlassianDelegate] no se modifica.
/// Esta variante usa un único conjunto de tarjetas: a medida que cada tarjeta
/// se aproxima a su tope, la composición adopta progresivamente la rotación y
/// escala del Stack de React Bits. Al completarse el apilado, el mismo layout
/// habilita drag, send-to-back y autoplay sin cambiar de representación.
class SugerenciasStackReactBitsAtlassianDelegate
    extends SliverPersistentHeaderDelegate {
  SugerenciasStackReactBitsAtlassianDelegate({
    required this.viewportHeight,
    required this.onOpenExams,
    required this.onOpenScenarios,
    required this.onOpenSubjects,
    required this.onOpenCalendar,
  });

  final double viewportHeight;
  final VoidCallback onOpenExams;
  final VoidCallback onOpenScenarios;
  final VoidCallback onOpenSubjects;
  final VoidCallback onOpenCalendar;

  static const double _cardHeight =
      SugerenciasApiladasAtlassianDelegate._cardHeight;
  static const double _cardGap =
      SugerenciasApiladasAtlassianDelegate._cardGap;
  static const double _stackedSpread =
      SugerenciasApiladasAtlassianDelegate._stackedSpread;
  static const double _horizontalPadding =
      SugerenciasApiladasAtlassianDelegate._horizontalPadding;
  static const double _mobileStackMaxWidth =
      SugerenciasApiladasAtlassianDelegate._mobileStackMaxWidth;
  static const double _sectionTopPadding =
      SugerenciasApiladasAtlassianDelegate._sectionTopPadding;
  static const double _sectionHeaderHeight =
      SugerenciasApiladasAtlassianDelegate._sectionHeaderHeight;
  static const double _sectionHeaderGap =
      SugerenciasApiladasAtlassianDelegate._sectionHeaderGap;
  static const double _bottomPadding =
      SugerenciasApiladasAtlassianDelegate._bottomPadding;
  static const double _mobileMenuTop =
      SugerenciasApiladasAtlassianDelegate._mobileMenuTop;
  static const double _mobileMenuSize =
      SugerenciasApiladasAtlassianDelegate._mobileMenuSize;
  static const double _pinTravel =
      SugerenciasApiladasAtlassianDelegate._pinTravel;
  static const double _fullSpread = _cardHeight + _cardGap;
  static const double _stackStep = _fullSpread - _stackedSpread;

  static const List<_SugerenciaApiladaData> _items =
      SugerenciasApiladasAtlassianDelegate._items;

  double get _cardsStartTop =>
      _sectionTopPadding + _sectionHeaderHeight + _sectionHeaderGap;

  double get _headerTop => _sectionTopPadding;

  double get _stackScrollExtent => (_items.length - 1) * _stackStep;

  double get _stackedHeight =>
      _cardsStartTop +
      _cardHeight +
      ((_items.length - 1) * _stackedSpread) +
      _bottomPadding;

  @override
  double get maxExtent => _stackedHeight + _pinTravel + _stackScrollExtent;

  @override
  double get minExtent => _stackedHeight;

  /// El stack está al final del CustomScrollView. Esta cola garantiza que el
  /// header pueda recorrer todo su rango de colapso también en teléfonos altos.
  static double trailingExtentFor(double viewportHeight) {
    final double stackedHeight =
        _sectionTopPadding +
        _sectionHeaderHeight +
        _sectionHeaderGap +
        _cardHeight +
        ((_items.length - 1) * _stackedSpread) +
        _bottomPadding;
    return math.max(144.0, viewportHeight - stackedHeight + 32.0).toDouble();
  }

  double _mobileAlignmentOffset(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= 600) return 0;

    final double safeTop = MediaQuery.paddingOf(context).top;
    final double menuCenter = safeTop + _mobileMenuTop + (_mobileMenuSize / 2);
    final double headerCenterAtBase =
        _sectionTopPadding + (_sectionHeaderHeight / 2);
    return math.max(menuCenter - headerCenterAtBase, 0.0);
  }

  double _cardsPinnedAlignmentOffset(
    BuildContext context,
    double shrinkOffset,
  ) {
    final double targetOffset = _mobileAlignmentOffset(context);
    if (targetOffset == 0) return 0;

    final double collapseRange = math.max(maxExtent - minExtent, 1.0);
    final double collapseProgress = (shrinkOffset / collapseRange)
        .clamp(0.0, 1.0)
        .toDouble();

    return targetOffset * Curves.easeOutCubic.transform(collapseProgress);
  }

  VoidCallback _callbackFor(AccionSugerenciaAtlassian action) {
    switch (action) {
      case AccionSugerenciaAtlassian.examenes:
        return onOpenExams;
      case AccionSugerenciaAtlassian.escenarios:
        return onOpenScenarios;
      case AccionSugerenciaAtlassian.materias:
        return onOpenSubjects;
      case AccionSugerenciaAtlassian.calendario:
        return onOpenCalendar;
    }
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double scroll = math
        .max(shrinkOffset - _pinTravel, 0.0)
        .clamp(0.0, _stackScrollExtent);
    final bool interactive = scroll >= (_stackScrollExtent - 0.5);

    final ThemeData theme = Theme.of(context);
    final double cardsPinnedAlignmentOffset = _cardsPinnedAlignmentOffset(
      context,
      shrinkOffset,
    );
    final double fixedHeaderAlignmentOffset = _mobileAlignmentOffset(context);

    final double lastNaturalTop = (_items.length - 1) * _fullSpread;
    final double lastStackedTop = (_items.length - 1) * _stackedSpread;
    final double lastCurrentTop = math.max(
      lastStackedTop,
      lastNaturalTop - scroll,
    );
    final double cardsVisualHeight = lastCurrentTop + _cardHeight;

    final Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(color: theme.scaffoldBackgroundColor),
        ),
        Positioned(
          left: _horizontalPadding,
          right: _horizontalPadding,
          top: _cardsStartTop + cardsPinnedAlignmentOffset,
          height: cardsVisualHeight,
          child: _ReactBitsStackSugerenciasAtlassian(
            enabled: interactive,
            items: _items,
            cardHeight: _cardHeight,
            fullSpread: _fullSpread,
            stackedSpread: _stackedSpread,
            scroll: scroll,
            onAction: _callbackFor,
          ),
        ),
        Positioned(
          left: _horizontalPadding,
          right: _horizontalPadding,
          top: _headerTop + fixedHeaderAlignmentOffset,
          child: const _InicioSugerenciasReactBitsAtlassian(
            height: _sectionHeaderHeight,
          ),
        ),
      ],
    );

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double centeredWidth = screenWidth >= 600
        ? math.min(screenWidth, 1000.0)
        : math.min(screenWidth - 32.0, _mobileStackMaxWidth);

    return Center(
      child: SizedBox(width: math.max(centeredWidth, 0.0), child: content),
    );
  }

  @override
  bool shouldRebuild(
    covariant SugerenciasStackReactBitsAtlassianDelegate oldDelegate,
  ) {
    return oldDelegate.viewportHeight != viewportHeight ||
        oldDelegate.onOpenExams != onOpenExams ||
        oldDelegate.onOpenScenarios != onOpenScenarios ||
        oldDelegate.onOpenSubjects != onOpenSubjects ||
        oldDelegate.onOpenCalendar != onOpenCalendar;
  }
}

class _InicioSugerenciasReactBitsAtlassian extends StatelessWidget {
  const _InicioSugerenciasReactBitsAtlassian({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.10)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              'Sugerencias',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.onSurface,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'STACK NUEVO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactBitsStackSugerenciasAtlassian extends StatefulWidget {
  const _ReactBitsStackSugerenciasAtlassian({
    required this.enabled,
    required this.items,
    required this.cardHeight,
    required this.fullSpread,
    required this.stackedSpread,
    required this.scroll,
    required this.onAction,
  });

  final bool enabled;
  final List<_SugerenciaApiladaData> items;
  final double cardHeight;
  final double fullSpread;
  final double stackedSpread;
  final double scroll;
  final VoidCallback Function(AccionSugerenciaAtlassian action) onAction;

  @override
  State<_ReactBitsStackSugerenciasAtlassian> createState() =>
      _ReactBitsStackSugerenciasAtlassianState();
}

class _ReactBitsStackSugerenciasAtlassianState
    extends State<_ReactBitsStackSugerenciasAtlassian> {
  static const Duration _autoplayDelay = Duration(seconds: 3);
  static const List<double> _randomRotations = <double>[
    -3.6,
    2.4,
    -1.8,
    4.2,
  ];

  late List<int> _order;
  Timer? _autoplayTimer;
  bool _hovered = false;
  bool _dragging = false;

  double get _stackStep => widget.fullSpread - widget.stackedSpread;

  @override
  void initState() {
    super.initState();
    _resetOrder();
    _scheduleAutoplay();
  }

  @override
  void didUpdateWidget(
    covariant _ReactBitsStackSugerenciasAtlassian oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      _resetOrder();
    }

    if (oldWidget.enabled != widget.enabled) {
      if (!widget.enabled) {
        _resetOrder();
      }
      _scheduleAutoplay();
    }
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    super.dispose();
  }

  void _resetOrder() {
    _order = List<int>.generate(widget.items.length, (int index) => index);
  }

  void _scheduleAutoplay() {
    _autoplayTimer?.cancel();
    if (!widget.enabled ||
        _hovered ||
        _dragging ||
        widget.items.length <= 1) {
      return;
    }

    _autoplayTimer = Timer(_autoplayDelay, () {
      if (!mounted ||
          !widget.enabled ||
          _hovered ||
          _dragging ||
          _order.length <= 1) {
        return;
      }
      _sendToBack(_order.last);
    });
  }

  void _sendToBack(int itemIndex) {
    if (!widget.enabled) return;
    final int currentIndex = _order.indexOf(itemIndex);
    if (currentIndex < 0) return;

    setState(() {
      _order.removeAt(currentIndex);
      _order.insert(0, itemIndex);
    });
    _scheduleAutoplay();
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
    _scheduleAutoplay();
  }

  void _setDragging(bool dragging) {
    if (_dragging == dragging) return;
    setState(() => _dragging = dragging);
    _scheduleAutoplay();
  }

  double _randomRotationFor(int itemIndex) {
    if (_randomRotations.isEmpty) return 0;
    return _randomRotations[itemIndex % _randomRotations.length];
  }

  double _joinProgressFor(int itemIndex) {
    if (widget.items.length <= 1) return 1;

    // La primera tarjeta empieza a adoptar el Stack cuando se aproxima la
    // segunda; cada tarjeta siguiente ocupa exactamente un tramo de scroll.
    final int joiningIndex = itemIndex == 0 ? 1 : itemIndex;
    final double start = (joiningIndex - 1) * _stackStep;
    return ((widget.scroll - start) / _stackStep)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double _depthFor(int itemIndex) {
    double depth = 0;
    for (int laterIndex = itemIndex + 1;
        laterIndex < widget.items.length;
        laterIndex++) {
      depth += _joinProgressFor(laterIndex);
    }
    return depth;
  }

  double _topFor(int itemIndex, int stackIndex) {
    if (widget.enabled) {
      return stackIndex * widget.stackedSpread;
    }

    final double naturalTop = itemIndex * widget.fullSpread;
    final double stackedTop = itemIndex * widget.stackedSpread;
    return math.max(stackedTop, naturalTop - widget.scroll);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int stackIndex = 0;
              stackIndex < _order.length;
              stackIndex++)
            _ReactBitsPositionedCardAtlassian(
              key: ValueKey<String>('react-bits-card-${_order[stackIndex]}'),
              item: widget.items[_order[stackIndex]],
              top: _topFor(_order[stackIndex], stackIndex),
              cardHeight: widget.cardHeight,
              randomRotation: _randomRotationFor(_order[stackIndex]),
              membershipProgress: widget.enabled
                  ? 1
                  : _joinProgressFor(_order[stackIndex]),
              depthProgress: widget.enabled
                  ? (_order.length - stackIndex - 1).toDouble()
                  : _depthFor(_order[stackIndex]),
              enabled: widget.enabled,
              onSendToBack: () => _sendToBack(_order[stackIndex]),
              onInteractionChanged: _setDragging,
              onAction: widget.onAction(
                widget.items[_order[stackIndex]].action,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReactBitsPositionedCardAtlassian extends StatelessWidget {
  const _ReactBitsPositionedCardAtlassian({
    super.key,
    required this.item,
    required this.top,
    required this.cardHeight,
    required this.randomRotation,
    required this.membershipProgress,
    required this.depthProgress,
    required this.enabled,
    required this.onSendToBack,
    required this.onInteractionChanged,
    required this.onAction,
  });

  final _SugerenciaApiladaData item;
  final double top;
  final double cardHeight;
  final double randomRotation;
  final double membershipProgress;
  final double depthProgress;
  final bool enabled;
  final VoidCallback onSendToBack;
  final ValueChanged<bool> onInteractionChanged;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: enabled ? const Duration(milliseconds: 360) : Duration.zero,
      curve: Curves.easeOutBack,
      left: 0,
      right: 0,
      top: top,
      child: _ReactBitsDraggableCardAtlassian(
        item: item,
        cardHeight: cardHeight,
        randomRotation: randomRotation,
        membershipProgress: membershipProgress,
        depthProgress: depthProgress,
        enabled: enabled,
        onSendToBack: onSendToBack,
        onInteractionChanged: onInteractionChanged,
        onAction: onAction,
      ),
    );
  }
}

class _ReactBitsDraggableCardAtlassian extends StatefulWidget {
  const _ReactBitsDraggableCardAtlassian({
    required this.item,
    required this.cardHeight,
    required this.randomRotation,
    required this.membershipProgress,
    required this.depthProgress,
    required this.enabled,
    required this.onSendToBack,
    required this.onInteractionChanged,
    required this.onAction,
  });

  final _SugerenciaApiladaData item;
  final double cardHeight;
  final double randomRotation;
  final double membershipProgress;
  final double depthProgress;
  final bool enabled;
  final VoidCallback onSendToBack;
  final ValueChanged<bool> onInteractionChanged;
  final VoidCallback onAction;

  @override
  State<_ReactBitsDraggableCardAtlassian> createState() =>
      _ReactBitsDraggableCardAtlassianState();
}

class _ReactBitsDraggableCardAtlassianState
    extends State<_ReactBitsDraggableCardAtlassian> {
  static const double _sensitivity = 250.0;
  static const double _dragElastic = 0.6;

  Offset _gestureOffset = Offset.zero;
  Offset _visualOffset = Offset.zero;
  bool _dragging = false;

  @override
  void didUpdateWidget(
    covariant _ReactBitsDraggableCardAtlassian oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _gestureOffset = Offset.zero;
      _visualOffset = Offset.zero;
      _dragging = false;
    }
  }

  void _resetDrag() {
    if (_gestureOffset == Offset.zero &&
        _visualOffset == Offset.zero &&
        !_dragging) {
      return;
    }
    setState(() {
      _gestureOffset = Offset.zero;
      _visualOffset = Offset.zero;
      _dragging = false;
    });
  }

  void _handlePanStart(DragStartDetails _) {
    if (!widget.enabled) return;
    setState(() {
      _gestureOffset = Offset.zero;
      _visualOffset = Offset.zero;
      _dragging = true;
    });
    widget.onInteractionChanged(true);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _gestureOffset += details.delta;
      _visualOffset = _gestureOffset * _dragElastic;
    });
  }

  void _handlePanEnd(DragEndDetails _) {
    if (!widget.enabled) return;

    final bool exceededSensitivity =
        _gestureOffset.dx.abs() > _sensitivity ||
        _gestureOffset.dy.abs() > _sensitivity;

    setState(() {
      _gestureOffset = Offset.zero;
      _visualOffset = Offset.zero;
      _dragging = false;
    });
    widget.onInteractionChanged(false);

    if (exceededSensitivity) {
      widget.onSendToBack();
    }
  }

  void _handlePanCancel() {
    if (!widget.enabled) return;
    _resetDrag();
    widget.onInteractionChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final double rotateXDegrees = (-_visualOffset.dy * 0.6)
        .clamp(-60.0, 60.0)
        .toDouble();
    final double rotateYDegrees = (_visualOffset.dx * 0.6)
        .clamp(-60.0, 60.0)
        .toDouble();

    // Equivalencia progresiva del Stack de React Bits:
    // - cada tarjeta presente aporta 0.06 de escala;
    // - cada tarjeta que queda encima aporta otros 0.06 y 4 grados;
    // - la rotación aleatoria entra gradualmente con la propia tarjeta.
    final double membership = widget.membershipProgress
        .clamp(0.0, 1.0)
        .toDouble();
    final double depth = math.max(widget.depthProgress, 0.0).toDouble();
    final double rotateZDegrees =
        (depth * 4.0) + (widget.randomRotation * membership);
    final double scale = math
        .max(1 - ((membership + depth) * 0.06), 0.72)
        .toDouble();

    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(rotateXDegrees * math.pi / 180)
      ..rotateY(rotateYDegrees * math.pi / 180)
      ..rotateZ(rotateZDegrees * math.pi / 180)
      ..scaleByDouble(scale, scale, 1.0, 1.0);

    return Transform.translate(
      offset: _visualOffset,
      child: AnimatedContainer(
        duration: widget.enabled && !_dragging
            ? const Duration(milliseconds: 360)
            : Duration.zero,
        curve: Curves.easeOutBack,
        transform: transform,
        transformAlignment: Alignment.bottomRight,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.enabled ? widget.onSendToBack : null,
          onPanStart: widget.enabled ? _handlePanStart : null,
          onPanUpdate: widget.enabled ? _handlePanUpdate : null,
          onPanEnd: widget.enabled ? _handlePanEnd : null,
          onPanCancel: widget.enabled ? _handlePanCancel : null,
          child: _TarjetaSugerenciaApiladaAtlassian(
            item: widget.item,
            collisionProgress: 0,
            depthProgress: 0,
            cardHeight: widget.cardHeight,
            onTap: widget.onAction,
          ),
        ),
      ),
    );
  }
}


class _InicioSugerenciasAtlassian extends StatelessWidget {
  const _InicioSugerenciasAtlassian({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.10)),
        ),
        child: Center(
          child: Text(
            'Sugerencias',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaSugerenciaApiladaAtlassian extends StatelessWidget {
  const _TarjetaSugerenciaApiladaAtlassian({
    required this.item,
    required this.collisionProgress,
    required this.depthProgress,
    required this.cardHeight,
    required this.onTap,
  });

  final _SugerenciaApiladaData item;
  final double collisionProgress;
  final double depthProgress;
  final double cardHeight;
  final VoidCallback onTap;

  ColorFilter _brightnessFilter(double brightness) {
    return ColorFilter.matrix(<double>[
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final double stackProgress = Curves.easeOutCubic.transform(
      collisionProgress.clamp(0.0, 1.0),
    );
    final double scale = 1 - (stackProgress * 0.06);
    final double brightness = 1 - (stackProgress * 0.40);
    final double translateY = stackProgress * -6.0;
    final double shadowOpacity = 0.12 + (depthProgress * 0.10);

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: ColorFiltered(
          colorFilter: _brightnessFilter(brightness),
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowOpacity),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ColoredBox(color: scheme.surfaceContainerHighest),
                  Transform.scale(
                    scale: 1.08,
                    child: ImagenMediaRemota(
                      source: item.assetPath,
                      fit: BoxFit.cover,
                      alignment: item.alignment,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const <double>[0.0, 0.35, 0.75, 1.0],
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.06),
                          Colors.black.withValues(alpha: 0.26),
                          Colors.black.withValues(alpha: 0.64),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                        const Spacer(),

                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onTap,
                              borderRadius: BorderRadius.circular(999),
                              splashColor: Colors.white.withValues(alpha: 0.14),
                              highlightColor: Colors.white.withValues(
                                alpha: 0.07,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      item.cta,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SugerenciaApiladaData {
  const _SugerenciaApiladaData({
    required this.assetPath,
    required this.eyebrow,
    required this.title,
    required this.cta,
    required this.alignment,
    required this.action,
  });

  final String assetPath;
  final String eyebrow;
  final String title;
  final String cta;
  final Alignment alignment;
  final AccionSugerenciaAtlassian action;
}
