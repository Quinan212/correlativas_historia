part of '../acordeon_funciones_premium.dart';

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
            cs.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.55),
            cs.primary.withValues(alpha: isDark ? 0.42 : 0.22),
            t,
          )!,
        ),
      ),
      child: Icon(
        icon,
        size: ui.lerpDouble(14, 18, t) ?? 18,
        color: Color.lerp(
          cs.onSurfaceVariant.withValues(alpha: 0.78),
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
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.75),
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: cs.onSurface.withValues(alpha: 0.74),
      ),
    );
  }
}
