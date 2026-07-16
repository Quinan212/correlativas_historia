import 'package:flutter/material.dart';

import '../../../../../modelos/materia.dart';
import '../../../modelos/materia_estudiante_administrador.dart';
import '../utilidades_administrador.dart';

class BloqueMateriasAnio extends StatelessWidget {
  const BloqueMateriasAnio({
    super.key,
    required this.year,
    required this.materias,
    required this.savedBySubjectId,
    required this.selectedSubjectIds,
    required this.saving,
    required this.onToggleEnrollment,
    required this.onSelectYear,
    required this.onClearYear,
    required this.onEdit,
  });

  final int year;
  final List<Materia> materias;
  final Map<String, MateriaEstudianteAdministrador> savedBySubjectId;
  final Set<String> selectedSubjectIds;
  final bool saving;
  final void Function(Materia materia, bool selected) onToggleEnrollment;
  final ValueChanged<List<Materia>> onSelectYear;
  final ValueChanged<List<Materia>> onClearYear;
  final ValueChanged<Materia> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (materias.isEmpty) return const SizedBox.shrink();
    final enrollable = materias
        .where((materia) => !savedBySubjectId.containsKey(materia.id))
        .toList(growable: false);
    final selectedInYear = enrollable
        .where((materia) => selectedSubjectIds.contains(materia.id))
        .length;
    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$year° año',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: saving || enrollable.isEmpty
                    ? null
                    : () => onSelectYear(enrollable),
                child: const Text('Inscribir año completo'),
              ),
              TextButton(
                onPressed: saving || selectedInYear == 0
                    ? null
                    : () => onClearYear(enrollable),
                child: const Text('Limpiar'),
              ),
            ],
          ),
          Text(
            '$selectedInYear seleccionadas · ${enrollable.length} disponibles',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...materias.map((materia) {
            final saved = savedBySubjectId[materia.id];
            final canEnroll = saved == null;
            final selected = selectedSubjectIds.contains(materia.id);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: canEnroll
                  ? Checkbox(
                      value: selected,
                      onChanged: saving
                          ? null
                          : (value) =>
                              onToggleEnrollment(materia, value ?? false),
                    )
                  : Icon(Icons.check_circle_rounded,
                      color: theme.colorScheme.primary),
              title: Text(
                materia.displayNombre,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(_subtituloMateria(saved, materia)),
              trailing: FilledButton.tonal(
                onPressed: () => onEdit(materia),
                child: Text(saved == null ? 'Cargar' : 'Editar'),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _subtituloMateria(
      MateriaEstudianteAdministrador? saved, Materia materia) {
    final reqs = materia.correlativasDetalladas.length;
    if (saved == null) {
      return reqs == 0 ? 'Sin correlativas' : '$reqs correlativas';
    }
    final parts = [
      etiquetaEstado(saved.status),
      etiquetaCondicion(saved.conditionStatus),
      if (saved.detailStatus != null) etiquetaDetalle(saved.detailStatus!),
      if (saved.academicPeriod != null) etiquetaPeriodo(saved.academicPeriod!),
      if (saved.grade != null) 'Nota ${saved.grade}',
    ];
    return parts.join(' · ');
  }
}
