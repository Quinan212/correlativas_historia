part of '../acordeon_funciones_premium.dart';

class _MorphAccordionItem extends StatefulWidget {
  const _MorphAccordionItem({
    required this.data,
    required this.index,
    required this.progress,
    required this.onTap,
    required this.onClosedSizeChanged,
    required this.onOpenSizeChanged,
    this.forcedWidth,
  });

  final PremiumAccordionItemData data;
  final int index;
  final double progress;
  final VoidCallback? onTap;
  final ValueChanged<Size> onClosedSizeChanged;
  final ValueChanged<Size> onOpenSizeChanged;
  final double? forcedWidth;

  @override
  State<_MorphAccordionItem> createState() => _MorphAccordionItemState();
}

class _MorphAccordionItemState extends State<_MorphAccordionItem>
    with SingleTickerProviderStateMixin {
  static const _contentRevealDuration = Duration(milliseconds: 465);
  static const _contentRevealDelay = Duration.zero;
  static const _contentRevealCurve = Cubic(0.22, 0.0, 0.18, 1.0);

  Size? _closedSize;
  Size? _openSize;
  double? _measuredWidth;
  bool _isClosing = false;
  Timer? _contentRevealTimer;
  late final AnimationController _contentRevealController;
  late final Animation<double> _contentReveal;

  double? get _resolvedWidth {
    final progress = widget.progress.clamp(0.0, 1.0);
    if (_closedSize != null && _openSize != null) {
      return ui.lerpDouble(_closedSize!.width, _openSize!.width, progress);
    }
    if (progress <= 0) return _closedSize?.width;
    if (progress >= 1) return _openSize?.width;
    return null;
  }

  double? get _resolvedHeight {
    final progress = widget.progress.clamp(0.0, 1.0);
    if (_closedSize != null && _openSize != null) {
      return ui.lerpDouble(_closedSize!.height, _openSize!.height, progress);
    }
    if (progress <= 0) return _closedSize?.height;
    if (progress >= 1) return _openSize?.height;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _contentRevealController = AnimationController(
      vsync: this,
      duration: _contentRevealDuration,
      value: widget.progress <= 0.001 || widget.progress >= 0.999 ? 1 : 0,
    );
    _contentReveal = CurvedAnimation(
      parent: _contentRevealController,
      curve: _contentRevealCurve,
    );
  }

  void _resetContentReveal() {
    _contentRevealTimer?.cancel();
    _contentRevealTimer = null;
    if (_contentRevealController.value != 0) {
      _contentRevealController
        ..stop()
        ..value = 0;
    }
  }

  void _scheduleContentReveal() {
    _contentRevealTimer?.cancel();
    _contentRevealTimer = Timer(_contentRevealDelay, () {
      if (!mounted) return;
      final settled = widget.progress <= 0.001 || widget.progress >= 0.999;
      if (!settled) return;
      _contentRevealController.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(covariant _MorphAccordionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final progressDelta = widget.progress - oldWidget.progress;
    if (progressDelta.abs() > 0.0001) {
      _isClosing = progressDelta < 0;
    }
    final hadExpandedContent = oldWidget.progress >= 0.999;
    final hasExpandedContent = widget.progress >= 0.999;
    final hadCollapsedTitle = oldWidget.progress <= 0.001;
    final hasCollapsedTitle = widget.progress <= 0.001;

    if (!hasExpandedContent && !hasCollapsedTitle) {
      _resetContentReveal();
      return;
    }

    if (hasExpandedContent && !hadExpandedContent) {
      _resetContentReveal();
      _scheduleContentReveal();
      return;
    }

    if (!hadCollapsedTitle && hasCollapsedTitle) {
      _resetContentReveal();
      _scheduleContentReveal();
    }
  }

  @override
  void dispose() {
    _contentRevealTimer?.cancel();
    _contentRevealController.dispose();
    super.dispose();
  }

  void _updateClosedSize(Size size) {
    if (_closedSize == size) return;
    setState(() {
      _closedSize = size;
    });
    widget.onClosedSizeChanged(size);
  }

  void _updateOpenSize(Size size) {
    if (_openSize == size) return;
    setState(() {
      _openSize = size;
    });
    widget.onOpenSizeChanged(size);
  }

  BoxConstraints _openMeasurementConstraints(double? maxWidth) {
    if (maxWidth == null) {
      return const BoxConstraints();
    }
    return BoxConstraints.tightFor(width: maxWidth);
  }

  Widget _measuredSurface({
    required double progress,
    required ValueChanged<Size> onChange,
    required double? effectiveWidth,
    required bool forceTightWidth,
  }) {
    final child = _MeasureSize(
      onChange: onChange,
      child: _AccordionSurface(
        data: widget.data,
        progress: progress,
        contentRevealProgress: 1,
        isClosing: false,
        onTap: null,
      ),
    );
    if (effectiveWidth == null) {
      return Offstage(
        offstage: true,
        child: progress <= 0
            ? Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: child,
              )
            : child,
      );
    }

    if (forceTightWidth && progress > 0.001) {
      return Offstage(
        offstage: true,
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: effectiveWidth),
          child: child,
        ),
      );
    }

    return Offstage(
      offstage: true,
      child: progress <= 0
          ? Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: effectiveWidth),
                child: child,
              ),
            )
          : ConstrainedBox(
              constraints: _openMeasurementConstraints(effectiveWidth),
              child: child,
            ),
    );
  }

  Widget _collapsedVisibleSurface({
    required Widget child,
    required double? effectiveWidth,
    required bool forceTightWidth,
  }) {
    if (effectiveWidth == null) return child;
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveWidth),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutMaxWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : null;
        final forceTightWidth = widget.forcedWidth != null;
        final effectiveWidth =
            layoutMaxWidth == null || widget.forcedWidth == null
                ? (widget.forcedWidth ?? layoutMaxWidth)
                : math.min(layoutMaxWidth, widget.forcedWidth!);

        if (effectiveWidth != null &&
            (_measuredWidth == null ||
                (_measuredWidth! - effectiveWidth).abs() > 0.5)) {
          _measuredWidth = effectiveWidth;
          _closedSize = null;
          _openSize = null;
        }

        final needsMeasurement = _closedSize == null || _openSize == null;
        final shouldRefreshClosed = widget.progress <= 0.001;
        final resolvedWidth = _resolvedWidth;
        final width = widget.progress <= 0.001
            ? resolvedWidth
            : (effectiveWidth ?? resolvedWidth);
        final height = _resolvedHeight;

        Widget visibleSurface = AnimatedBuilder(
          animation: _contentReveal,
          builder: (context, _) {
            return RepaintBoundary(
              child: _AccordionSurface(
                data: widget.data,
                progress: widget.progress,
                contentRevealProgress: _contentReveal.value,
                isClosing: _isClosing,
                onTap: widget.onTap,
              ),
            );
          },
        );

        if (width != null || height != null) {
          visibleSurface = SizedBox(
            width: width,
            height: height,
            child: visibleSurface,
          );
        } else if (effectiveWidth != null && widget.progress > 0.001) {
          visibleSurface = ConstrainedBox(
            constraints: _openMeasurementConstraints(effectiveWidth),
            child: visibleSurface,
          );
        } else if (widget.progress <= 0.001) {
          visibleSurface = _collapsedVisibleSurface(
            child: visibleSurface,
            effectiveWidth: effectiveWidth,
            forceTightWidth: forceTightWidth,
          );
        }

        if (widget.progress > 0.001 &&
            widget.progress < 0.999 &&
            effectiveWidth != null &&
            resolvedWidth != null &&
            effectiveWidth > 0) {
          final widthFactor = (resolvedWidth / effectiveWidth).clamp(0.0, 1.0);
          visibleSurface = Transform.scale(
            alignment: Alignment.centerLeft,
            scaleX: widthFactor,
            scaleY: 1,
            child: visibleSurface,
          );
        }

        if (widget.progress > 0.001 &&
            widget.progress < 0.999 &&
            resolvedWidth != null &&
            effectiveWidth != null &&
            resolvedWidth < effectiveWidth) {
          visibleSurface = ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: resolvedWidth,
              maxWidth: effectiveWidth,
              fit: OverflowBoxFit.deferToChild,
              child: visibleSurface,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needsMeasurement)
              _measuredSurface(
                progress: 0,
                onChange: _updateClosedSize,
                effectiveWidth: effectiveWidth,
                forceTightWidth: forceTightWidth,
              ),
            if (needsMeasurement)
              _measuredSurface(
                progress: 1,
                onChange: _updateOpenSize,
                effectiveWidth: effectiveWidth,
                forceTightWidth: forceTightWidth,
              ),
            if (shouldRefreshClosed && !needsMeasurement)
              _measuredSurface(
                progress: 0,
                onChange: _updateClosedSize,
                effectiveWidth: effectiveWidth,
                forceTightWidth: forceTightWidth,
              ),
            Align(
              alignment: Alignment.centerLeft,
              widthFactor:
                  widget.progress <= 0.001 && !forceTightWidth ? 1 : null,
              child: ClipRect(child: visibleSurface),
            ),
          ],
        );
      },
    );
  }
}
