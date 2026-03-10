import 'dart:async';

import 'package:flutter/material.dart';

class AutoScrollText extends StatefulWidget {
  const AutoScrollText(
    this.text, {
    super.key,
    this.style,
    this.pixelsPerSecond = 22,
    this.edgePause = const Duration(milliseconds: 900),
  });

  final String text;
  final TextStyle? style;
  final double pixelsPerSecond;
  final Duration edgePause;

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _pauseTimer;
  Completer<void>? _pauseCompleter;
  double _overflow = 0;
  int _runToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _runToken++;
    _cancelPause();
    _controller.dispose();
    super.dispose();
  }

  void _cancelPause() {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    final completer = _pauseCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _pauseCompleter = null;
  }

  Future<void> _pause(Duration duration) {
    _cancelPause();
    final completer = Completer<void>();
    _pauseCompleter = completer;
    _pauseTimer = Timer(duration, () {
      _pauseTimer = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (identical(_pauseCompleter, completer)) {
        _pauseCompleter = null;
      }
    });
    return completer.future;
  }

  Future<void> _runBounce(double overflow) async {
    final token = ++_runToken;
    while (mounted && token == _runToken && overflow > 0) {
      _controller.value = 0;
      await _pause(widget.edgePause);
      if (!mounted || token != _runToken) return;
      await _controller.animateTo(1, curve: Curves.easeInOut);
      if (!mounted || token != _runToken) return;
      await _pause(widget.edgePause);
      if (!mounted || token != _runToken) return;
      await _controller.animateBack(0, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = widget.style ?? DefaultTextStyle.of(context).style;
        final textDirection = Directionality.of(context);
        final maxWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;

        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 1,
          textDirection: textDirection,
        )..layout(maxWidth: double.infinity);

        final textWidth = textPainter.width;
        final overflow = textWidth - maxWidth;

        if (maxWidth <= 0 || overflow <= 2) {
          if (_overflow != 0) {
            _overflow = 0;
            _runToken++;
            _cancelPause();
            _controller.stop();
            _controller.value = 0;
          }
          return Text(
            widget.text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        final seconds = (overflow / widget.pixelsPerSecond).clamp(2.8, 8.0);
        final duration = Duration(milliseconds: (seconds * 1000).round());
        if (_controller.duration != duration) {
          _controller.duration = duration;
        }
        if ((_overflow - overflow).abs() > 1) {
          _overflow = overflow;
          _cancelPause();
          _controller.stop();
          _controller.value = 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _runBounce(overflow);
          });
        } else if (!_controller.isAnimating && _controller.value == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _runBounce(overflow);
          });
        }

        return SizedBox(
          width: maxWidth,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final offset = -overflow * _controller.value;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: textWidth,
                maxWidth: textWidth,
                child: Text(
                  widget.text,
                  style: style,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
