// componentes/controles_superiores.dart
import 'package:flutter/material.dart';

class BotonCerrarDetalle extends StatelessWidget {
  const BotonCerrarDetalle({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final bd = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final fg = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827);

    return Tooltip(
      message: 'Cerrar',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: bd),
              boxShadow: isDark
                  ? const []
                  : [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded, size: 18, color: fg),
                const SizedBox(width: 6),
                Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BarraInferiorDetalle extends StatelessWidget {
  const BarraInferiorDetalle({
    required this.onTap,
    this.label = 'Volver',
    this.icon = Icons.arrow_back_rounded,
    super.key,
  });

  final VoidCallback onTap;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111827) : Colors.white;
    final border = isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB);
    final fg = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
        ),
        child: SizedBox(
          height: 56,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: fg,
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

class AgarreDetalle extends StatelessWidget {
  const AgarreDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final base = isDark
        ? Colors.white.withOpacity(0.18)
        : Colors.black.withOpacity(0.12);

    final highlight = isDark
        ? Colors.white.withOpacity(0.22)
        : Colors.white.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Center(
        child: SizedBox(
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 7,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: cs.outlineVariant
                        .withOpacity(isDark ? 0.35 : 0.55),
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? const []
                      : [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                ),
              ),
              Positioned(
                top: 6,
                child: Container(
                  width: 52,
                  height: 2,
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(999),
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

