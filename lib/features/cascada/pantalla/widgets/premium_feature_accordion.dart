import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PremiumAccordionItemData {
  const PremiumAccordionItemData({
    required this.icon,
    required this.title,
    required this.kicker,
    required this.summary,
    required this.detail,
    required this.bullets,
  });

  final IconData icon;
  final String title;
  final String kicker;
  final String summary;
  final String detail;
  final List<String> bullets;
}

class PremiumFeatureAccordion extends StatefulWidget {
  const PremiumFeatureAccordion({
    super.key,
    required this.items,
    this.initialExpandedIndex,
    this.lightweight = false,
  });

  final List<PremiumAccordionItemData> items;
  final int? initialExpandedIndex;
  final bool lightweight;

  @override
  State<PremiumFeatureAccordion> createState() =>
      _PremiumFeatureAccordionState();
}

class _PremiumFeatureAccordionState extends State<PremiumFeatureAccordion>
    with SingleTickerProviderStateMixin {
  static const _panelTransitionDuration = Duration(milliseconds: 430);
  static const _panelCurve = Cubic(0.22, 1.0, 0.36, 1.0);
  static const _itemSpacing = 10.0;

  late final AnimationController _controller;
  int? _expandedIndex;
  int? _fromIndex;
  int? _toIndex;
  final Map<int, Size> _closedItemSizes = <int, Size>{};
  final Map<int, Size> _openItemSizes = <int, Size>{};

  bool get _hasAllMeasurements =>
      _closedItemSizes.length == widget.items.length &&
      _openItemSizes.length == widget.items.length;

  double? get _lockedContainerWidth {
    if (!_hasAllMeasurements) return null;
    var maxWidth = 0.0;
    for (var i = 0; i < widget.items.length; i++) {
      final closed = _closedItemSizes[i];
      final open = _openItemSizes[i];
      if (closed == null || open == null) return null;
      maxWidth = math.max(maxWidth, math.max(closed.width, open.width));
    }
    if (maxWidth <= 0) return null;
    return maxWidth.ceilToDouble() + 1.0;
  }

  double? _containerHeightForPhase(double phase) {
    if (!_hasAllMeasurements) return null;
    var totalHeight = 0.0;
    for (var i = 0; i < widget.items.length; i++) {
      final closed = _closedItemSizes[i];
      final open = _openItemSizes[i];
      if (closed == null || open == null) return null;
      final progress = _progressForIndex(i, phase).clamp(0.0, 1.0);
      totalHeight += ui.lerpDouble(closed.height, open.height, progress) ?? 0.0;
    }
    final totalSpacing = math.max(widget.items.length - 1, 0) * _itemSpacing;
    return totalHeight + totalSpacing + 1.0;
  }

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialExpandedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: _panelTransitionDuration,
    )..addStatusListener(_handleAnimationStatus);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PremiumFeatureAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _closedItemSizes.removeWhere((index, _) => index >= widget.items.length);
      _openItemSizes.removeWhere((index, _) => index >= widget.items.length);
    }
    if (_expandedIndex != null && _expandedIndex! >= widget.items.length) {
      _expandedIndex = null;
    }
    if (_fromIndex != null && _fromIndex! >= widget.items.length) {
      _fromIndex = null;
    }
    if (_toIndex != null && _toIndex! >= widget.items.length) {
      _toIndex = null;
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() {
      _expandedIndex = _toIndex;
      _fromIndex = null;
      _toIndex = null;
    });
    _controller.value = 0;
  }

  void _recordClosedSize(int index, Size size) {
    final previous = _closedItemSizes[index];
    if (previous != null &&
        (previous.width - size.width).abs() < 0.5 &&
        (previous.height - size.height).abs() < 0.5) {
      return;
    }
    setState(() {
      _closedItemSizes[index] = size;
    });
  }

  void _recordOpenSize(int index, Size size) {
    final previous = _openItemSizes[index];
    if (previous != null &&
        (previous.width - size.width).abs() < 0.5 &&
        (previous.height - size.height).abs() < 0.5) {
      return;
    }
    setState(() {
      _openItemSizes[index] = size;
    });
  }

  void _toggleItem(int index) {
    if (_controller.isAnimating) return;

    final target = _expandedIndex == index ? null : index;
    if (target == _expandedIndex) return;

    setState(() {
      _fromIndex = _expandedIndex;
      _toIndex = target;
    });
    _controller.forward(from: 0);
  }

  double _progressForIndex(int index, double phase) {
    if (_fromIndex == null && _toIndex == null) {
      return _expandedIndex == index ? 1 : 0;
    }

    if (_fromIndex == null && _toIndex == index) {
      return phase;
    }

    if (_toIndex == null && _fromIndex == index) {
      return 1 - phase;
    }

    if (_fromIndex == index) {
      return 1 - phase;
    }

    if (_toIndex == index) {
      return phase;
    }

    return _expandedIndex == index ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.lightweight || reduceMotion) {
      return _LitePremiumFeatureAccordion(
        items: widget.items,
        initialExpandedIndex: widget.initialExpandedIndex,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.isAnimating
            ? _panelCurve.transform(_controller.value)
            : 1.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                constraints.hasBoundedWidth ? constraints.maxWidth : null;
            final targetLockedWidth = _lockedContainerWidth;
            final effectiveLockedWidth =
                availableWidth == null || targetLockedWidth == null
                    ? targetLockedWidth
                    : math.min(targetLockedWidth, availableWidth);
            final targetLockedHeight = _containerHeightForPhase(phase);

            Widget list = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.items.length; i++)
                  Padding(
                    key: ValueKey('accordion_item_$i'),
                    padding: EdgeInsets.only(
                      bottom: i == widget.items.length - 1 ? 0 : _itemSpacing,
                    ),
                    child: _MorphAccordionItem(
                      data: widget.items[i],
                      index: i,
                      progress: _progressForIndex(i, phase),
                      onTap:
                          _controller.isAnimating ? null : () => _toggleItem(i),
                      onClosedSizeChanged: (size) => _recordClosedSize(i, size),
                      onOpenSizeChanged: (size) => _recordOpenSize(i, size),
                      forcedWidth: effectiveLockedWidth,
                    ),
                  ),
              ],
            );

            if (effectiveLockedWidth != null || targetLockedHeight != null) {
              list = SizedBox(
                width: effectiveLockedWidth,
                height: targetLockedHeight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: list,
                  ),
                ),
              );
            }

            return Align(
              alignment: Alignment.topLeft,
              child: list,
            );
          },
        );
      },
    );
  }
}

class _LitePremiumFeatureAccordion extends StatefulWidget {
  const _LitePremiumFeatureAccordion({
    required this.items,
    required this.initialExpandedIndex,
  });

  final List<PremiumAccordionItemData> items;
  final int? initialExpandedIndex;

  @override
  State<_LitePremiumFeatureAccordion> createState() =>
      _LitePremiumFeatureAccordionState();
}

class _LitePremiumFeatureAccordionState
    extends State<_LitePremiumFeatureAccordion> {
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialExpandedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          _LitePremiumAccordionItem(
            data: widget.items[i],
            expanded: _expandedIndex == i,
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == i ? null : i;
              });
            },
          ),
          if (i != widget.items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LitePremiumAccordionItem extends StatelessWidget {
  const _LitePremiumAccordionItem({
    required this.data,
    required this.expanded,
    required this.onTap,
  });

  final PremiumAccordionItemData data;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111419) : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF262B33) : const Color(0xFFD8DDE3),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark
                              ? cs.surfaceContainerHighest
                                  .withOpacity(0.22)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? cs.outlineVariant.withOpacity(0.5)
                                : const Color(0xFFD0D6DE),
                          ),
                        ),
                        child: Icon(data.icon, size: 16, color: cs.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        expanded ? Icons.remove_rounded : Icons.add_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 170),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.detail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < data.bullets.length; i++) ...[
                            _AccordionBullet(text: data.bullets[i]),
                            if (i != data.bullets.length - 1)
                              const SizedBox(height: 8),
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
      ),
    );
  }
}

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

class _AccordionSurface extends StatelessWidget {
  const _AccordionSurface({
    required this.data,
    required this.progress,
    required this.contentRevealProgress,
    required this.isClosing,
    required this.onTap,
  });

  final PremiumAccordionItemData data;
  final double progress;
  final double contentRevealProgress;
  final bool isClosing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final t = progress.clamp(0.0, 1.0);
    final settledReveal = contentRevealProgress.clamp(0.0, 1.0);
    final isCollapsed = t <= 0.001;
    final expandedReveal = isClosing
        ? t
        : t >= 0.999
            ? settledReveal
            : 0.0;
    final collapsedReveal = isCollapsed ? settledReveal : 0.0;
    final collapsedHeaderDuringClose = isClosing ? (1 - t) : collapsedReveal;
    final structuralLayoutFactor = t;
    final structuralWidthFactor = ui.lerpDouble(0.9, 1, t) ?? 1.0;

    final closedTitleStyle =
        (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onSurface.withOpacity(0.92),
      height: 1.1,
      letterSpacing: -0.15,
    );
    final openTitleStyle =
        (theme.textTheme.headlineSmall ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.4,
      color: cs.onSurface,
    );

    final closedGradient = isDark
        ? const [
            Color(0xFF111419),
            Color(0xFF0E1116),
          ]
        : const [
            Color(0xFFF5F6F7),
            Color(0xFFF0F2F4),
          ];
    final openGradient = isDark
        ? const [
            Color(0xFF171B21),
            Color(0xFF10141A),
          ]
        : const [
            Color(0xFFF8F8F9),
            Color(0xFFFFFFFF),
          ];

    final radius = BorderRadius.circular(16);
    final padding = EdgeInsets.lerp(
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      const EdgeInsets.fromLTRB(18, 16, 18, 18),
      t,
    )!;
    final collapsedHeader = _CollapsedHeaderRow(
      title: data.title,
      titleStyle: closedTitleStyle,
      action: const _CircleAction(icon: Icons.add_rounded),
      glyph: _FeatureGlyph(
        icon: data.icon,
        progress: 0,
      ),
    );
    const textRevealAlignment = Alignment.topLeft;

    Widget popReveal(
      Widget child, {
      Alignment alignment = Alignment.center,
      double? visibility,
    }) {
      final progress = (visibility ?? settledReveal).clamp(0.0, 1.0);
      return Opacity(
        opacity: progress,
        child: Transform.scale(
          alignment: alignment,
          scale: ui.lerpDouble(0.9, 1, progress) ?? 1,
          child: child,
        ),
      );
    }

    Widget collapseWithPanel(
      Widget child, {
      Alignment alignment = Alignment.topLeft,
    }) {
      return ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: structuralLayoutFactor,
          child: Transform.scale(
            alignment: alignment,
            scaleX: structuralWidthFactor,
            scaleY: 1,
            child: child,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(closedGradient[0], openGradient[0], t)!,
            Color.lerp(closedGradient[1], openGradient[1], t)!,
          ],
        ),
        border: Border.all(
          color: Color.lerp(
            isDark ? const Color(0xFF262B33) : const Color(0xFFD8DDE3),
            isDark ? const Color(0xFF3A414C) : const Color(0xFFC9D0D8),
            t,
          )!,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: isCollapsed
                          ? popReveal(
                              collapsedHeader,
                              alignment: Alignment.centerLeft,
                              visibility: collapsedReveal,
                            )
                          : Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                if (isClosing)
                                  collapseWithPanel(
                                    popReveal(
                                      collapsedHeader,
                                      alignment: Alignment.centerLeft,
                                      visibility: collapsedHeaderDuringClose,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _MorphAction(
                                      progress: isClosing ? 1 : t,
                                    ),
                                    SizedBox(
                                      width: ui.lerpDouble(10, 6, t) ?? 6,
                                    ),
                                    Flexible(
                                      child: collapseWithPanel(
                                        popReveal(
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Text(
                                                  data.kicker,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    height: 1.35,
                                                    color: cs.onSurfaceVariant
                                                        .withValues(
                                                      alpha: 0.9,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                data.title,
                                                style: TextStyle.lerp(
                                                  closedTitleStyle,
                                                  openTitleStyle,
                                                  t,
                                                ),
                                              ),
                                            ],
                                          ),
                                          alignment: textRevealAlignment,
                                          visibility: expandedReveal,
                                        ),
                                        alignment: textRevealAlignment,
                                      ),
                                    ),
                                    SizedBox(
                                      width: ui.lerpDouble(8, 12, t) ?? 8,
                                    ),
                                    popReveal(
                                      _FeatureGlyph(
                                        icon: data.icon,
                                        progress: t,
                                      ),
                                      visibility: expandedReveal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                if (t > 0.001) ...[
                  SizedBox(height: 12 * t),
                  collapseWithPanel(
                    popReveal(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.summary,
                            style: theme.textTheme.titleSmall?.copyWith(
                              height: 1.32,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.detail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.58,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.06),
                          ),
                          const SizedBox(height: 12),
                          for (var i = 0; i < data.bullets.length; i++) ...[
                            _AccordionBullet(text: data.bullets[i]),
                            if (i != data.bullets.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
                      alignment: textRevealAlignment,
                      visibility: expandedReveal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedHeaderRow extends StatelessWidget {
  const _CollapsedHeaderRow({
    required this.title,
    required this.titleStyle,
    required this.action,
    required this.glyph,
  });

  final String title;
  final TextStyle titleStyle;
  final Widget action;
  final Widget glyph;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        action,
        const SizedBox(width: 10),
        Text(
          title,
          style: titleStyle,
        ),
        const SizedBox(width: 10),
        glyph,
      ],
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _previousSize;

  @override
  void performLayout() {
    super.performLayout();
    final childSize = child?.size;
    if (childSize == null || childSize == _previousSize) return;
    _previousSize = childSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(childSize);
    });
  }
}

class _MorphAction extends StatelessWidget {
  const _MorphAction({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final visibility = 1 - t;
    final width = ui.lerpDouble(34, 0, t) ?? 0;

    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Opacity(
          opacity: visibility,
          child: Transform.scale(
            scale: ui.lerpDouble(1, 0.82, t) ?? 0.82,
            child: Transform.rotate(
              angle: t * 0.78539816339,
              child: const _CircleAction(icon: Icons.add_rounded),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureGlyph extends StatelessWidget {
  const _FeatureGlyph({
    required this.icon,
    required this.progress,
  });

  final IconData icon;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = progress.clamp(0.0, 1.0);

    return Container(
      width: ui.lerpDouble(28, 34, t) ?? 34,
      height: ui.lerpDouble(28, 34, t) ?? 34,
      decoration: BoxDecoration(
        color: Color.lerp(
          isDark ? const Color(0xFF141A22) : const Color(0xFFF5F7FA),
          isDark ? const Color(0xFF182635) : const Color(0xFFE9F1FF),
          t,
        ),
        borderRadius: BorderRadius.circular(ui.lerpDouble(10, 14, t) ?? 14),
        border: Border.all(
          color: Color.lerp(
            cs.outlineVariant.withOpacity(isDark ? 0.28 : 0.55),
            cs.primary.withOpacity(isDark ? 0.42 : 0.22),
            t,
          )!,
        ),
      ),
      child: Icon(
        icon,
        size: ui.lerpDouble(14, 18, t) ?? 18,
        color: Color.lerp(
          cs.onSurfaceVariant.withOpacity(0.78),
          cs.primary,
          t,
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(isDark ? 0.35 : 0.75),
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: cs.onSurface.withOpacity(0.74),
      ),
    );
  }
}

class _AccordionBullet extends StatelessWidget {
  const _AccordionBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.88),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.48,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

