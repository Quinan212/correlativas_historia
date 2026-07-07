import 'package:flutter/material.dart';

import '../../verificacion/modelos/estado_verificacion_materia.dart';

class ChipVerificacionMateria extends StatelessWidget {
  const ChipVerificacionMateria({super.key, required this.state});

  final EstadoVerificacionMateria state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (state.status) {
      SituacionVerificacionMateria.approved => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
        ),
      SituacionVerificacionMateria.pending => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
        ),
      SituacionVerificacionMateria.rejected => (
          const Color(0xFFFEE2E2),
          const Color(0xFF991B1B),
        ),
      SituacionVerificacionMateria.unverified => (
          const Color(0xFFE2E8F0),
          const Color(0xFF334155),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
