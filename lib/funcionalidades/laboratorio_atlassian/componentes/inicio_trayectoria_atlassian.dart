import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../compartido/media/widgets_media_remota.dart';
import '../tema/tema_atlassian.dart';
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
    final offset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;
    final next = (offset / 72).clamp(0.0, 1.0).toDouble();
    if ((next - _progress).abs() < 0.01 || !mounted) return;
    setState(() => _progress = next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = Curves.easeOutCubic.transform(_progress);
    final actionsOpacity = (1 - progress * 1.2).clamp(0.0, 1.0).toDouble();
    final titleOpacity = (1 - progress * 1.35).clamp(0.0, 1.0).toDouble();
    final nombre = primerNombreAtlassian(widget.nombreEstudiante);
    final sincronizada = nombre.isNotEmpty;

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
                    child: Row(
                      children: [
                        if (!sincronizada) ...[
                          const _MascotaBienvenidaAtlassian(),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                saludoAtlassian(widget.nombreEstudiante),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Trayectoria',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IgnorePointer(
                          ignoring: actionsOpacity < 0.4,
                          child: Opacity(
                            opacity: actionsOpacity,
                            child: Row(
                              children: [
                                BotonIconoAtlassian(
                                  icon: Icons.search_rounded,
                                  tooltip: 'Buscar materias',
                                  onPressed: widget.onSearch,
                                ),
                                if (widget.onExit != null) ...[
                                  const SizedBox(width: 4),
                                  BotonIconoAtlassian(
                                    icon: Icons.close_rounded,
                                    tooltip: 'Cerrar laboratorio',
                                    onPressed: widget.onExit!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: progress < 0.12,
                  child: Opacity(
                    opacity: progress,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - progress)),
                      child: AccesoBusquedaAtlassian(onTap: widget.onSearch),
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
  static const double _sectionTopPadding = 16.0;
  static const double _sectionHeaderHeight = 72.0;
  static const double _sectionHeaderGap = 24.0;
  static const double _bottomPadding = 16.0;
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

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(color: theme.scaffoldBackgroundColor),
        ),
        ...List<Widget>.generate(_items.length, (int index) {
          final _SugerenciaApiladaData item = _items[index];
          final double top = _topFor(index, scroll);
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
          top: _headerTop,
          child: const _InicioSugerenciasAtlassian(
            height: _sectionHeaderHeight,
          ),
        ),
      ],
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
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Sugerencias',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
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
