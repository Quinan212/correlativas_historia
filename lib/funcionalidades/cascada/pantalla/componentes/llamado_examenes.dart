import 'dart:math' as math;

import 'package:flutter/material.dart';

const bool kEnableLlamadoExamenesMotion = false;

class LlamadoExamenes extends StatefulWidget {
  const LlamadoExamenes({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<LlamadoExamenes> createState() => _LlamadoExamenesState();
}

class _LlamadoExamenesState extends State<LlamadoExamenes>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  static const _staticArrowAlphaA = 0.90;
  static const _staticArrowAlphaB = 0.66;
  static const _staticArrowAlphaC = 0.42;

  @override
  void initState() {
    super.initState();
    if (!kEnableLlamadoExamenesMotion) return;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  double _wave(double t, double phase) {
    final s = math.sin((t * math.pi * 2) + phase);
    final v = (s + 1) * 0.5;
    return v * v * (3 - 2 * v);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ctrl;
    if (controller == null) {
      return _buildCard(
        context,
        lift: 0,
        arrowA: _staticArrowAlphaA,
        arrowB: _staticArrowAlphaB,
        arrowC: _staticArrowAlphaC,
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final lift = math.sin(t * math.pi) * 2.5;
        return _buildCard(
          context,
          lift: lift,
          arrowA: 0.20 + 0.75 * _wave(t, 0.0),
          arrowB: 0.20 + 0.75 * _wave(t, -0.8),
          arrowC: 0.20 + 0.75 * _wave(t, -1.6),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double lift,
    required double arrowA,
    required double arrowB,
    required double arrowC,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? cs.surface : Colors.white;
    final border = isDark ? cs.outlineVariant : const Color(0xFFE5E7EB);

    return Transform.translate(
      offset: Offset(0, -lift),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                ),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: cs.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_month,
                                  color: cs.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Ver mesas y examenes',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -52,
                        top: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _FlechaOnda(
                              icon: Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: cs.primary,
                              alpha: arrowA,
                            ),
                            const SizedBox(width: 2),
                            _FlechaOnda(
                              icon: Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: cs.primary,
                              alpha: arrowB,
                            ),
                            const SizedBox(width: 2),
                            _FlechaOnda(
                              icon: Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: cs.primary,
                              alpha: arrowC,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlechaOnda extends StatelessWidget {
  const _FlechaOnda({
    required this.icon,
    required this.size,
    required this.color,
    required this.alpha,
  });

  final IconData icon;
  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: alpha.clamp(0.0, 1.0),
      child: Icon(icon, size: size, color: color),
    );
  }
}
