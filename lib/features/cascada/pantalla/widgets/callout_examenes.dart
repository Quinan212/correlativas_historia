import 'dart:math' as math;

import 'package:flutter/material.dart';

const bool kEnableCalloutExamenesMotion = false;

class CalloutExamenes extends StatefulWidget {
  const CalloutExamenes({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<CalloutExamenes> createState() => _CalloutExamenesState();
}

class _CalloutExamenesState extends State<CalloutExamenes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _wave(double t, double phase) {
    final s = math.sin((t * math.pi * 2) + phase);
    final v = (s + 1) * 0.5;
    return v * v * (3 - 2 * v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? cs.surface : Colors.white;
    final border = isDark ? cs.outlineVariant : const Color(0xFFE5E7EB);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final lift = kEnableCalloutExamenesMotion
            ? (math.sin(t * math.pi) * 4.0)
            : 0.0;

        return Transform.translate(
          offset: Offset(0, -lift),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
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
                      Text(
                        'Examenes y llamados',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Consulta fechas, horarios y materias con mesas publicadas en este turno.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant.withValues(
                            alpha: isDark ? 0.86 : 0.82,
                          ),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                                  Icon(Icons.calendar_month, color: cs.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Abrir examenes',
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
                                _WaveArrow(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: cs.primary,
                                  alpha: 0.20 + 0.75 * _wave(t, 0.0),
                                ),
                                const SizedBox(width: 2),
                                _WaveArrow(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: cs.primary,
                                  alpha: 0.20 + 0.75 * _wave(t, -0.8),
                                ),
                                const SizedBox(width: 2),
                                _WaveArrow(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: cs.primary,
                                  alpha: 0.20 + 0.75 * _wave(t, -1.6),
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
      },
    );
  }
}

class _WaveArrow extends StatelessWidget {
  const _WaveArrow({
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
