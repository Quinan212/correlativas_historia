import 'package:flutter/material.dart';

import '../utilidades_administrador.dart';

class TarjetaResumenInscripcion extends StatelessWidget {
  const TarjetaResumenInscripcion({
    super.key,
    required this.selectedCount,
    required this.saving,
    required this.onClear,
    required this.onSave,
  });

  final int selectedCount;
  final bool saving;
  final VoidCallback? onClear;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TarjetaPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final description = selectedCount == 0
              ? 'Marcá materias por año para inscribirlas como cursando en período regular.'
              : '$selectedCount materias seleccionadas para inscripción regular.';
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.assignment_add,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inscripción rápida por materias',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: saving ? null : onClear,
                      child: const Text('Limpiar'),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        icon: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_alt_rounded),
                        label: Text(
                            saving ? 'Guardando...' : 'Guardar seleccionadas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Icon(Icons.assignment_add, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inscripción rápida por materias',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: saving ? null : onClear,
                child: const Text('Limpiar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt_rounded),
                label: Text(saving ? 'Guardando...' : 'Guardar seleccionadas'),
              ),
            ],
          );
        },
      ),
    );
  }
}
