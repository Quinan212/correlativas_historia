import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'src/acordeon_superficie.dart';
part 'src/acordeon_item_morph.dart';
part 'src/acordeon_lite.dart';
part 'src/acordeon_utilidades_animacion.dart';

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

class AcordeonFuncionesPremium extends StatefulWidget {
  const AcordeonFuncionesPremium({
    super.key,
    required this.items,
    this.initialExpandedIndex,
    this.lightweight = false,
  });

  final List<PremiumAccordionItemData> items;
  final int? initialExpandedIndex;
  final bool lightweight;

  @override
  State<AcordeonFuncionesPremium> createState() =>
      _AcordeonFuncionesPremiumState();
}

class _AcordeonFuncionesPremiumState extends State<AcordeonFuncionesPremium>
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
  void didUpdateWidget(covariant AcordeonFuncionesPremium oldWidget) {
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
      return _LiteAcordeonFuncionesPremium(
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
