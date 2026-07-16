import 'package:flutter/material.dart';

import '../../../../../modelos/materia.dart';
import '../../../modelos/materia_estudiante_administrador.dart';
import 'bloque_materias_anio.dart';
import 'tarjeta_resumen_inscripcion.dart';

class TabTrayectoria extends StatelessWidget {
  const TabTrayectoria({
    super.key,
    required this.materias,
    required this.savedBySubjectId,
    required this.selectedSubjectIds,
    required this.savingEnrollment,
    required this.onClearSelection,
    required this.onSaveSelection,
    required this.onToggleEnrollment,
    required this.onSelectYear,
    required this.onClearYear,
    required this.onEdit,
  });

  final List<Materia> materias;
  final Map<String, MateriaEstudianteAdministrador> savedBySubjectId;
  final Set<String> selectedSubjectIds;
  final bool savingEnrollment;
  final VoidCallback? onClearSelection;
  final VoidCallback? onSaveSelection;
  final void Function(Materia materia, bool selected) onToggleEnrollment;
  final ValueChanged<List<Materia>> onSelectYear;
  final ValueChanged<List<Materia>> onClearYear;
  final ValueChanged<Materia> onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        TarjetaResumenInscripcion(
          selectedCount: selectedSubjectIds.length,
          saving: savingEnrollment,
          onClear: onClearSelection,
          onSave: onSaveSelection,
        ),
        const SizedBox(height: 12),
        for (final year in [1, 2, 3, 4]) ...[
          BloqueMateriasAnio(
            year: year,
            materias: materias.where((m) => m.anio == year).toList(),
            savedBySubjectId: savedBySubjectId,
            selectedSubjectIds: selectedSubjectIds,
            saving: savingEnrollment,
            onToggleEnrollment: onToggleEnrollment,
            onSelectYear: onSelectYear,
            onClearYear: onClearYear,
            onEdit: onEdit,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
