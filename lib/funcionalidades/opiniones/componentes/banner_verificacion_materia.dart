import 'package:flutter/material.dart';

import '../../verificacion/modelos/estado_verificacion_materia.dart';

class BannerVerificacionMateria extends StatelessWidget {
  const BannerVerificacionMateria({super.key, required this.state});

  final EstadoVerificacionMateria state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (bg, border, icon, title, body) = switch (state.status) {
      SituacionVerificacionMateria.approved => (
          const Color(0xFFECFDF5),
          const Color(0xFFA7F3D0),
          Icons.verified_rounded,
          'Ya podes opinar',
          'La verificacion ya fue aprobada. Desde este dispositivo podes opinar sobre esta materia y sus docentes.',
        ),
      SituacionVerificacionMateria.pending => (
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          Icons.hourglass_top_rounded,
          'Verificacion pendiente',
          'Ya enviaste la captura. Cuando la revisemos, desde este dispositivo vas a poder opinar sobre esta materia y sus docentes.',
        ),
      SituacionVerificacionMateria.rejected => (
          const Color(0xFFFEF2F2),
          const Color(0xFFFECACA),
          Icons.report_gmailerrorred_rounded,
          'Necesita nueva captura',
          'La verificacion anterior no fue valida. Podes volver a enviar una imagen mas clara del campus.',
        ),
      SituacionVerificacionMateria.unverified => (
          const Color(0xFFF8FAFC),
          const Color(0xFFE2E8F0),
          Icons.shield_outlined,
          'Todavia no verificada',
          'Subi una captura del campus para demostrar que cursas esta materia y habilitar referencias desde este dispositivo.',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
