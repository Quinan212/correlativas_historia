import 'package:flutter/material.dart';

import '../modelos/modelos_resenas_opiniones.dart';
import '../utilidades/etiquetas_referencias.dart';
import 'barra_balance_referencias.dart';

class CajaResenaMateriaPropia extends StatelessWidget {
  const CajaResenaMateriaPropia({super.key, required this.review});

  final ResenaMateria review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu referencia actual',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          BarraBalanceReferencias(
            average: review.rating.toDouble(),
            votes: 1,
            showVotes: false,
          ),
          if (review.tags.isNotEmpty && review.dimensions.isEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.tags
                  .map((tag) => Chip(label: Text(etiquetaTagMateria(tag))))
                  .toList(growable: false),
            ),
          ],
          if (review.dimensions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.dimensions.entries
                  .where((entry) => entry.value > 0)
                  .map(
                    (entry) => Chip(
                      label: Text(
                        '${etiquetaDimensionMateria(entry.key)} · ${etiquetaEscalaDimensionMateria(entry.key, entry.value)}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if ((review.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${review.comment!.trim()}"',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
