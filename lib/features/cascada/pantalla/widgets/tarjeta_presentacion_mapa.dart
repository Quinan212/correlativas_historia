import 'package:flutter/material.dart';

class TarjetaPresentacionMapa extends StatelessWidget {
  const TarjetaPresentacionMapa({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: theme.shadowColor.withValues(alpha: 0.12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mapa de Correlatividades:\n¿Qué Me Falta?',
            style: tt.headlineSmall?.copyWith(
              height: 1.18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Con ¿Qué Me Falta? podés ver al instante qué materias te faltan para cursar o rendir. Seleccionás la materia en un mapa interactivo y el sistema te muestra sus correlativas previas y posteriores. Así sabés exactamente qué te habilita a seguir avanzando.',
            style: tt.bodyMedium?.copyWith(
              height: 1.55,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}