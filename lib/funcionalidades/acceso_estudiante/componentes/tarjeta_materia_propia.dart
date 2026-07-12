import 'package:flutter/material.dart';

import '../modelos/modelos_acceso_estudiante.dart';

class TarjetaMateriaPropia extends StatelessWidget {
  const TarjetaMateriaPropia({
    super.key,
    required this.subject,
    this.onEdit,
    required this.busy,
  });

  final MateriaEstudiante subject;
  final VoidCallback? onEdit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final statusColor = switch (subject.status) {
      'aprobada' => const Color(0xFF2EAD57),
      'regular' => const Color(0xFFD97706),
      'no_regularizada' => const Color(0xFFDC2626),
      _ => const Color(0xFF1E6FDB),
    };

    final statusIcon = switch (subject.status) {
      'aprobada' => Icons.check_circle_rounded,
      'regular' => Icons.assignment_turned_in_rounded,
      'no_regularizada' => Icons.cancel_rounded,
      _ => Icons.play_circle_rounded,
    };

    final statusLabel = switch (subject.status) {
      'aprobada' => 'Aprobada',
      'regular' => 'Regular',
      'no_regularizada' => 'No regularizada',
      _ => 'Cursando',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy || onEdit == null ? null : onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.subjectName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _EtiquetaMini(
                                label: statusLabel, color: statusColor),
                            if (subject.grade != null)
                              _EtiquetaMini(
                                label:
                                    'Nota ${subject.grade!.toStringAsFixed(0)}',
                                color: const Color(0xFF7C3AED),
                              ),
                            if (subject.sourceDate != null ||
                                (subject.academicPeriod.isNotEmpty &&
                                    subject.academicPeriod != 'regular'))
                              _EtiquetaMini(
                                label: subject.sourceDate != null
                                    ? nombreMesAcademico(subject.sourceDate!)
                                    : _etiquetaPeriodo(
                                        subject.academicPeriod,
                                      ),
                                color: const Color(0xFF0E7490),
                              ),
                            if (subject.subjectYear != null)
                              _EtiquetaMini(
                                label: '${subject.subjectYear}° año',
                                color: cs.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _etiquetaPeriodo(String value) {
    return switch (value) {
      'mayo_extraordinaria' => 'Mayo ext.',
      'febrero' => 'Febrero',
      'julio' => 'Julio',
      'diciembre' => 'Diciembre',
      'cursada' => 'Cursada',
      'tif' => 'TIF',
      'equivalencia' => 'Equivalencia',
      'ajuste' => 'Ajuste',
      _ => value,
    };
  }
}

class _EtiquetaMini extends StatelessWidget {
  const _EtiquetaMini({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
      ),
    );
  }
}
