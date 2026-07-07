import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../configuracion/visibilidad_opiniones.dart';
import '../modelos/catalogo_opiniones.dart';
import '../modelos/modelos_resenas_opiniones.dart';
import '../proveedores/proveedores_resenas_opiniones.dart';
import 'barra_balance_referencias.dart';
import 'hoja_detalle_docente.dart';

class MiniStateInsignia extends StatelessWidget {
  const MiniStateInsignia({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class DocenteTile extends ConsumerWidget {
  const DocenteTile({
    super.key,
    required this.docente,
    required this.matter,
    required this.careerId,
  });

  final DocenteLite docente;
  final Materia matter;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kShowOpinionUi) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final summary = ref.watch(proveedorResumenResenasDocente(docente.id));
    final ownReview = ref
        .watch(
          proveedorResenaDocentePropia(
            AlcanceResenaDocente(
              teacherId: docente.id,
              matterId: matter.id,
              careerId: careerId,
            ),
          ),
        )
        .valueOrNull;

    return InkWell(
      onTap: () {
        mostrarHojaDetalleDocente(
          context: context,
          ref: ref,
          docente: docente,
          matterId: matter.id,
          matterName: matter.displayNombre,
          careerId: careerId,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF111827)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF243041)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docente.nombre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ReferenciasBalanceInsignia(
                        average: summary.general.promedio,
                        votes: summary.general.votos,
                      ),
                      Text(
                        summary.general.votos == 0
                            ? 'Todavia sin referencias'
                            : '${summary.general.votos} referencias',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${docente.apariciones} apariciones',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (ownReview != null)
                        Text(
                          'Ya dejaste una referencia',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
