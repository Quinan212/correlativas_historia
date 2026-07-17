import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/tema_liquid_glass.dart';

class SuperficieLiquidGlass extends StatelessWidget {
  const SuperficieLiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = 18,
    this.opacity = 0.12,
    this.borderOpacity = 0.28,
    this.reducedEffects = false,
    this.onTap,
    this.semanticLabel,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final bool reducedEffects;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = dark
        ? Colors.white.withValues(alpha: borderOpacity)
        : Colors.white.withValues(
            alpha: math.min(0.9, borderOpacity + 0.35).toDouble(),
          );
    final requestedOpacity = opacity.clamp(0.0, 1.0).toDouble();
    final fallbackColor = dark
        ? const Color(0xFF152138).withValues(
            alpha: reducedEffects
                ? 0.92
                : (0.50 + requestedOpacity).clamp(0.50, 0.84).toDouble(),
          )
        : Colors.white.withValues(
            alpha: reducedEffects
                ? 0.94
                : (0.44 + requestedOpacity).clamp(0.48, 0.82).toDouble(),
          );
    final effectiveBlur = reducedEffects ? 0.0 : blur;

    Widget surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? fallbackColor : null,
        gradient: gradient,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.22 : 0.08),
            blurRadius: reducedEffects ? 10 : 26,
            offset: const Offset(0, 12),
          ),
          if (!reducedEffects)
            BoxShadow(
              color: PaletaLiquidGlass.azul.withValues(
                alpha: dark ? 0.08 : 0.06,
              ),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );

    if (effectiveBlur > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: surface,
      );
    }

    surface = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: surface,
    );

    if (onTap == null) return surface;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: _EscalaPresionLiquidGlass(onTap: onTap!, child: surface),
    );
  }
}

class BotonIconoLiquidGlass extends StatelessWidget {
  const BotonIconoLiquidGlass({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.reducedEffects = false,
    this.selected = false,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool reducedEffects;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: _EscalaPresionLiquidGlass(
        onTap: onTap,
        child: SuperficieLiquidGlass(
          reducedEffects: reducedEffects,
          radius: size * 0.38,
          blur: 14,
          opacity: selected ? 0.21 : 0.10,
          padding: EdgeInsets.zero,
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.78),
                    PaletaLiquidGlass.violeta.withValues(alpha: 0.72),
                  ],
                )
              : null,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.48,
              color: selected ? Colors.white : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class BotonLiquidGlass extends StatelessWidget {
  const BotonLiquidGlass({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
    this.expanded = false,
    this.reducedEffects = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool primary;
  final bool expanded;
  final bool reducedEffects;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.48,
      child: _EscalaPresionLiquidGlass(
        onTap: enabled ? onTap : null,
        child: SuperficieLiquidGlass(
          reducedEffects: reducedEffects,
          radius: 18,
          blur: 14,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          gradient: primary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.94),
                    PaletaLiquidGlass.violeta.withValues(alpha: 0.88),
                  ],
                )
              : null,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: primary ? Colors.white : scheme.onSurface),
            child: IconTheme.merge(
              data: IconThemeData(
                color: primary ? Colors.white : scheme.onSurface,
              ),
              child: expanded
                  ? SizedBox(width: double.infinity, child: content)
                  : content,
            ),
          ),
        ),
      ),
    );
  }
}

class FondoLiquidGlass extends StatefulWidget {
  const FondoLiquidGlass({
    super.key,
    required this.child,
    this.motionEnabled = true,
  });

  final Widget child;
  final bool motionEnabled;

  @override
  State<FondoLiquidGlass> createState() => _FondoLiquidGlassState();
}

class _FondoLiquidGlassState extends State<FondoLiquidGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant FondoLiquidGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motionEnabled != widget.motionEnabled) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.motionEnabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0.18;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [
                      Color(0xFF050914),
                      Color(0xFF0A1121),
                      Color(0xFF10172A),
                    ]
                  : const [
                      Color(0xFFF6F8FF),
                      Color(0xFFECF4FF),
                      Color(0xFFF4F0FF),
                    ],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * math.pi * 2;
              return Stack(
                children: [
                  Positioned(
                    left: -90 + math.sin(t) * 34,
                    top: -70 + math.cos(t * 0.8) * 26,
                    child: _OrbeLiquidGlass(
                      size: 260,
                      colors: [
                        PaletaLiquidGlass.azul.withValues(
                          alpha: dark ? 0.34 : 0.28,
                        ),
                        PaletaLiquidGlass.turquesa.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -120 + math.cos(t * 0.7) * 42,
                    top: 160 + math.sin(t * 0.9) * 38,
                    child: _OrbeLiquidGlass(
                      size: 320,
                      colors: [
                        PaletaLiquidGlass.violeta.withValues(
                          alpha: dark ? 0.30 : 0.24,
                        ),
                        PaletaLiquidGlass.azul.withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 40 + math.cos(t * 0.55) * 60,
                    bottom: -150 + math.sin(t * 0.6) * 30,
                    child: _OrbeLiquidGlass(
                      size: 360,
                      colors: [
                        PaletaLiquidGlass.turquesa.withValues(
                          alpha: dark ? 0.24 : 0.20,
                        ),
                        PaletaLiquidGlass.verde.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        IgnorePointer(
          child: CustomPaint(painter: _BrilloFondoPainter(dark: dark)),
        ),
        widget.child,
      ],
    );
  }
}

class _OrbeLiquidGlass extends StatelessWidget {
  const _OrbeLiquidGlass({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _BrilloFondoPainter extends CustomPainter {
  const _BrilloFondoPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: dark ? 0.035 : 0.24),
          Colors.transparent,
          Colors.white.withValues(alpha: dark ? 0.012 : 0.08),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _BrilloFondoPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class BarraNavegacionLiquidGlass extends StatelessWidget {
  const BarraNavegacionLiquidGlass({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.reducedEffects,
    required this.reducedMotion,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool reducedEffects;
  final bool reducedMotion;

  static const _items = <_DestinoLiquidGlass>[
    _DestinoLiquidGlass(Icons.school_outlined, Icons.school_rounded, 'Inicio'),
    _DestinoLiquidGlass(
      Icons.assignment_outlined,
      Icons.assignment_rounded,
      'Exámenes',
    ),
    _DestinoLiquidGlass(
      Icons.account_tree_outlined,
      Icons.account_tree_rounded,
      'Plan',
    ),
    _DestinoLiquidGlass(
      Icons.list_alt_outlined,
      Icons.list_alt_rounded,
      'Materias',
    ),
    _DestinoLiquidGlass(
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Datos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, math.max(8.0, bottom).toDouble()),
      child: SuperficieLiquidGlass(
        reducedEffects: reducedEffects,
        radius: 28,
        blur: 24,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _ItemNavegacionLiquidGlass(
                  item: _items[index],
                  selected: index == selectedIndex,
                  reducedMotion: reducedMotion,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelected(index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemNavegacionLiquidGlass extends StatelessWidget {
  const _ItemNavegacionLiquidGlass({
    required this.item,
    required this.selected,
    required this.reducedMotion,
    required this.onTap,
  });

  final _DestinoLiquidGlass item;
  final bool selected;
  final bool reducedMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 280);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withValues(alpha: 0.92),
                      PaletaLiquidGlass.violeta.withValues(alpha: 0.84),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(22),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: duration,
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 21,
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinoLiquidGlass {
  const _DestinoLiquidGlass(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class IndicadorProgresoLiquidGlass extends StatelessWidget {
  const IndicadorProgresoLiquidGlass({
    super.key,
    required this.progress,
    required this.label,
    this.size = 104,
  });

  final double progress;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgresoLiquidGlassPainter(
          progress: normalized,
          trackColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(normalized * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgresoLiquidGlassPainter extends CustomPainter {
  const _ProgresoLiquidGlassPainter({
    required this.progress,
    required this.trackColor,
  });

  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - 7;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          PaletaLiquidGlass.azul,
          PaletaLiquidGlass.violeta,
          PaletaLiquidGlass.turquesa,
        ],
      ).createShader(rect);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgresoLiquidGlassPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor;
  }
}

Route<T> rutaLiquidGlass<T>({
  required WidgetBuilder builder,
  bool reducedMotion = false,
}) {
  return PageRouteBuilder<T>(
    transitionDuration: reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 420),
    reverseTransitionDuration: reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (reducedMotion) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class _EscalaPresionLiquidGlass extends StatefulWidget {
  const _EscalaPresionLiquidGlass({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_EscalaPresionLiquidGlass> createState() =>
      _EscalaPresionLiquidGlassState();
}

class _EscalaPresionLiquidGlassState extends State<_EscalaPresionLiquidGlass> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.972 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
